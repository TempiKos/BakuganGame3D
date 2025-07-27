extends Node3D

@onready var player_throw_point = $PlayerThrowPoint
@onready var enemy_throw_point = $EnemyThrowPoint
@onready var bakugan_root = $BakuganRoot
@onready var field = $Field
@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D

# Переменные для управления бакуганами
var current_bakugan_index = 0
var spawned_bakugans = []
var spawned_cards = []
var gate_cards = []  # Карты-врата на поле
var is_throwing = false
var is_bakugan_open = false
var card_positions = []

# UI элементы
var bakugan_ui = null
var throw_card_button = null
var throw_bakugan_button = null
var switch_button = null
var back_button = null
var battle_log = null

# Константы для анимации
const THROW_DURATION = 2.0
const THROW_HEIGHT = 8.0
const CARD_THROW_DURATION = 1.5
const CARD_THROW_HEIGHT = 4.0
const ROTATION_SPEED = 10.0
const TRANSFORMATION_DURATION = 1.0

# Улучшенные пути к открытым моделям бакуганов
var open_bakugan_paths := {
	"Огненный": [
		{"name": "Saurus", "mesh_path": "res://models/open/fire_saurus_open.obj", "fallback_color": Color(1.0, 0.3, 0.0)},
		{"name": "Centipoid", "mesh_path": "res://models/open/fire_centipoid_open.obj", "fallback_color": Color(1.0, 0.4, 0.0)},
		{"name": "Gargonoid", "mesh_path": "res://models/open/fire_gargonoid_open.obj", "fallback_color": Color(1.0, 0.2, 0.0)}
	],
	"Водный": [
		{"name": "Vladitor", "mesh_path": "res://models/open/water_vladitor_open.obj", "fallback_color": Color(0.0, 0.5, 1.0)},
		{"name": "Preyas", "mesh_path": "res://models/open/water_preyas_open.obj", "fallback_color": Color(0.0, 0.6, 1.0)},
		{"name": "Juggernoid", "mesh_path": "res://models/open/water_juggernoid_open.obj", "fallback_color": Color(0.0, 0.4, 1.0)}
	],
	"Тёмный": [
		{"name": "Exedra", "mesh_path": "res://models/open/dark_exedra_open.obj", "fallback_color": Color(0.5, 0.0, 0.8)},
		{"name": "Reaper", "mesh_path": "res://models/open/dark_reaper_open.obj", "fallback_color": Color(0.6, 0.0, 0.8)},
		{"name": "Fear Ripper", "mesh_path": "res://models/open/dark_fear_ripper_open.obj", "fallback_color": Color(0.4, 0.0, 0.8)}
	]
}

# Типы карт-врат
enum GateCardType {
	FIRE,    # Огненная карта (+200 к огненным бакуганам)
	WATER,   # Водная карта (+200 к водным бакуганам)
	EARTH,   # Земляная карта (+150 ко всем)
	WIND,    # Воздушная карта (+100 к скорости)
	LIGHT,   # Световая карта (+300 к световым бакуганам)
	DARK     # Тёмная карта (+200 к тёмным бакуганам)
}

# Данные о картах-вратах
var gate_card_data = {
	GateCardType.FIRE: {"name": "Огненные Врата", "bonus": 200, "description": "+200 к огненным бакуганам"},
	GateCardType.WATER: {"name": "Водные Врата", "bonus": 200, "description": "+200 к водным бакуганам"},
	GateCardType.EARTH: {"name": "Земляные Врата", "bonus": 150, "description": "+150 ко всем бакуганам"},
	GateCardType.WIND: {"name": "Воздушные Врата", "bonus": 100, "description": "+100 к скорости"},
	GateCardType.LIGHT: {"name": "Световые Врата", "bonus": 300, "description": "+300 к световым бакуганам"},
	GateCardType.DARK: {"name": "Тёмные Врата", "bonus": 200, "description": "+200 к тёмным бакуганам"}
}

func _ready():
	print("=== БОЕВАЯ СЦЕНА ЗАГРУЖЕНА ===")
	print("Выбранный набор:", Global.selected_pack)
	
	# Проверяем, что у нас есть выбранный набор
	if Global.selected_pack == "":
		print("ОШИБКА: Набор не выбран! Возвращаемся в главное меню...")
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		return
	
	# Получаем данные о выбранном наборе
	var pack_data = Global.get_selected_pack_data()
	if pack_data.size() == 0:
		print("ОШИБКА: Нет данных для набора", Global.selected_pack)
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		return
	
	# Выводим информацию о бакуганах
	print("Бакуганы в наборе:")
	for i in range(pack_data.size()):
		var bakugan = pack_data[i]
		print(" -", bakugan.name, "(", bakugan.mesh_path, ")")
	
	# Настраиваем сцену
	_setup_battle_field()
	_setup_camera_and_lighting()
	_setup_throw_points()
	_create_battle_ui()
	_initialize_gate_card_positions()
	
	# Спавним первого бакугана
	_spawn_bakugan(current_bakugan_index)

func _setup_battle_field():
	# Создаем поле для боя как в аниме
	if field:
		var field_mesh = BoxMesh.new()
		field_mesh.size = Vector3(30, 0.2, 25)
		field.mesh = field_mesh
		field.position = Vector3(0, -0.1, 0)
		
		# Создаем материал для поля с металлическим блеском
		var field_material = StandardMaterial3D.new()
		field_material.albedo_color = Color(0.15, 0.15, 0.25)  # Тёмно-серый с синим оттенком
		field_material.roughness = 0.3
		field_material.metallic = 0.8
		field_material.emission_enabled = true
		field_material.emission = Color(0.05, 0.1, 0.2)
		
		field.material_override = field_material
		
		# Создаем StaticBody3D для поля
		var field_body = StaticBody3D.new()
		field_body.name = "FieldBody"
		field_body.position = Vector3(0, -0.1, 0)
		
		# Добавляем коллизию к StaticBody3D
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(30, 0.2, 25)
		collision_shape.shape = box_shape
		field_body.add_child(collision_shape)
		
		# Добавляем StaticBody3D в сцену
		add_child(field_body)
		
		# Создаем декоративные элементы поля
		_create_field_decorations()
		
		print("✅ Поле боя создано с коллизией")

func _create_field_decorations():
	# Создаем голографические линии как в аниме
	var line_material = StandardMaterial3D.new()
	line_material.albedo_color = Color(0.0, 0.8, 1.0)  # Голубой
	line_material.emission_enabled = true
	line_material.emission = Color(0.0, 0.6, 0.8)
	line_material.flags_transparent = true
	line_material.albedo_color.a = 0.7
	
	# Центральная линия
	var center_line = MeshInstance3D.new()
	var center_line_mesh = BoxMesh.new()
	center_line_mesh.size = Vector3(30, 0.03, 0.15)
	center_line.mesh = center_line_mesh
	center_line.material_override = line_material
	center_line.position = Vector3(0, 0.12, 0)
	add_child(center_line)
	
	# Боковые линии
	for i in range(2):
		var side_line = MeshInstance3D.new()
		var side_line_mesh = BoxMesh.new()
		side_line_mesh.size = Vector3(0.15, 0.03, 25)
		side_line.mesh = side_line_mesh
		side_line.material_override = line_material
		side_line.position = Vector3((-1 + i * 2) * 14.5, 0.12, 0)
		add_child(side_line)
	
	# Создаем круговые зоны для карт-врат
	_create_gate_zones()

func _create_gate_zones():
	# Создаем светящиеся круги для позиций карт-врат
	var zone_material = StandardMaterial3D.new()
	zone_material.albedo_color = Color(0.2, 0.8, 0.2, 0.4)
	zone_material.emission_enabled = true
	zone_material.emission = Color(0.1, 0.5, 0.1)
	zone_material.flags_transparent = true
	zone_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	for i in range(6):  # 6 позиций для карт-врат
		var zone = MeshInstance3D.new()
		var cylinder_mesh = CylinderMesh.new()
		cylinder_mesh.top_radius = 2.5
		cylinder_mesh.bottom_radius = 2.5
		cylinder_mesh.height = 0.02
		zone.mesh = cylinder_mesh
		zone.material_override = zone_material
		zone.name = "GateZone_" + str(i)
		
		# Располагаем зоны в два ряда по 3
		var row = i / 3
		var col = i % 3
		var x = (col - 1) * 8.0  # -8, 0, 8
		var z = (row - 0.5) * 10.0  # -5, 5
		
		zone.position = Vector3(x, 0.02, z)
		add_child(zone)

func _initialize_gate_card_positions():
	# Создаем позиции для карт-врат (6 позиций как в аниме)
	card_positions.clear()
	for i in range(6):
		var row = i / 3
		var col = i % 3
		var x = (col - 1) * 8.0  # -8, 0, 8
		var z = (row - 0.5) * 10.0  # -5, 5
		card_positions.append(Vector3(x, 0.2, z))

func _setup_camera_and_lighting():
	# Настраиваем камеру для лучшего обзора
	if camera:
		camera.position = Vector3(0, 22, 18)
		camera.rotation_degrees = Vector3(-55, 0, 0)
		camera.fov = 75
		print("✅ Камера настроена")
	
	# Настраиваем освещение
	if light:
		light.position = Vector3(0, 30, 12)
		light.rotation_degrees = Vector3(-75, 0, 0)
		light.light_energy = 2.5
		light.shadow_enabled = true
		print("✅ Освещение настроено")

func _setup_throw_points():
	# Настраиваем точки броска
	if player_throw_point:
		player_throw_point.position = Vector3(0, 5, 12)
		print("✅ Точка броска игрока:", player_throw_point.position)
	
	if enemy_throw_point:
		enemy_throw_point.position = Vector3(0, 5, -12)
		print("✅ Точка броска врага:", enemy_throw_point.position)

func _create_battle_ui():
	# Создаем UI для управления боем
	var ui_canvas = CanvasLayer.new()
	ui_canvas.name = "BattleUI"
	add_child(ui_canvas)
	
	# Основной контейнер для UI
	var ui_container = Control.new()
	ui_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_container.name = "UIContainer"
	ui_canvas.add_child(ui_container)
	
	# Панель для кнопок
	var button_panel = Panel.new()
	button_panel.position = Vector2(20, 20)
	button_panel.size = Vector2(320, 500)
	button_panel.modulate = Color(0.1, 0.1, 0.2, 0.92)
	ui_container.add_child(button_panel)
	
	# Контейнер для кнопок
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(15, 15)
	button_container.size = Vector2(290, 470)
	button_panel.add_child(button_container)
	
	# Заголовок
	var title_label = Label.new()
	title_label.text = "🔥 БИТВА БАКУГАН 🔥"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	button_container.add_child(title_label)
	
	# Разделитель
	var separator = HSeparator.new()
	button_container.add_child(separator)
	
	# Кнопка для броска карты-врат
	throw_card_button = Button.new()
	throw_card_button.text = "🏛️ Бросить карту-врата"
	throw_card_button.add_theme_font_size_override("font_size", 16)
	throw_card_button.custom_minimum_size = Vector2(0, 50)
	throw_card_button.pressed.connect(_on_throw_gate_card_pressed)
	button_container.add_child(throw_card_button)
	
	# Кнопка для броска бакугана
	throw_bakugan_button = Button.new()
	throw_bakugan_button.text = "⚡ Бросить бакугана"
	throw_bakugan_button.add_theme_font_size_override("font_size", 16)
	throw_bakugan_button.custom_minimum_size = Vector2(0, 50)
	throw_bakugan_button.disabled = true
	throw_bakugan_button.pressed.connect(_on_throw_bakugan_pressed)
	button_container.add_child(throw_bakugan_button)
	
	# Кнопка для смены бакугана
	switch_button = Button.new()
	switch_button.text = "🔄 Сменить бакугана"
	switch_button.add_theme_font_size_override("font_size", 16)
	switch_button.custom_minimum_size = Vector2(0, 50)
	switch_button.pressed.connect(_on_switch_bakugan_pressed)
	button_container.add_child(switch_button)
	
	# Кнопка возврата в меню
	back_button = Button.new()
	back_button.text = "🏠 Назад в меню"
	back_button.add_theme_font_size_override("font_size", 16)
	back_button.custom_minimum_size = Vector2(0, 50)
	back_button.pressed.connect(_on_back_to_menu_pressed)
	button_container.add_child(back_button)
	
	# Информация о текущем бакугане
	bakugan_ui = Label.new()
	bakugan_ui.text = "Загрузка..."
	bakugan_ui.add_theme_font_size_override("font_size", 14)
	bakugan_ui.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bakugan_ui.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bakugan_ui.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bakugan_ui.custom_minimum_size = Vector2(0, 80)
	button_container.add_child(bakugan_ui)
	
	# Лог боя
	battle_log = Label.new()
	battle_log.text = "📋 Лог боя:\n• Добро пожаловать в арену!\n• Сначала бросьте карту-врата!"
	battle_log.add_theme_font_size_override("font_size", 12)
	battle_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	battle_log.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	battle_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	battle_log.custom_minimum_size = Vector2(0, 120)
	button_container.add_child(battle_log)
	
	# Инструкции
	var instructions = Label.new()
	instructions.text = "⌨️ Горячие клавиши:\n• Q - Бросить карту-врата\n• SPACE - Бросить бакугана\n• ↑ - Сменить бакугана\n• ESC - Выход в меню"
	instructions.add_theme_font_size_override("font_size", 11)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	instructions.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	button_container.add_child(instructions)
	
	print("✅ UI создан")

func _add_to_battle_log(message: String):
	if battle_log:
		var lines = battle_log.text.split("\n")
		lines.append("• " + message)
		# Ограничиваем количество строк
		if lines.size() > 8:
			lines = lines.slice(lines.size() - 8, lines.size())
		battle_log.text = "\n".join(lines)

func _create_gate_card(card_type: GateCardType = GateCardType.FIRE):
	# Создаем карту-врата как в аниме
	var card_body = RigidBody3D.new()
	card_body.name = "GateCard_" + GateCardType.keys()[card_type]
	card_body.position = player_throw_point.global_transform.origin
	card_body.gravity_scale = 0.8
	card_body.mass = 0.5
	card_body.freeze = true
	
	# Создаем визуальную модель карты
	var card_mesh = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 2.2
	cylinder_mesh.bottom_radius = 2.2
	cylinder_mesh.height = 0.08
	card_mesh.mesh = cylinder_mesh
	card_mesh.name = "GateCardMesh"
	
	# Материал для карты-врат в зависимости от типа
	var card_material = StandardMaterial3D.new()
	var card_color = _get_gate_card_color(card_type)
	card_material.albedo_color = card_color
	card_material.emission_enabled = true
	card_material.emission = card_color * 0.6
	card_material.roughness = 0.2
	card_material.metallic = 0.9
	card_material.flags_transparent = true
	card_material.albedo_color.a = 0.9
	card_mesh.material_override = card_material
	
	# Создаем символ на карте
	# Создаем символ на карте с изображением
	var symbol = MeshInstance3D.new()
	var symbol_mesh = CylinderMesh.new()
	symbol_mesh.top_radius = 1.0
	symbol_mesh.bottom_radius = 1.0
	symbol_mesh.height = 0.03
	symbol.mesh = symbol_mesh
	symbol.position = Vector3(0, 0.055, 0)
	symbol.name = "CardSymbol"

	var symbol_material = StandardMaterial3D.new()
	symbol_material.albedo_color = Color.WHITE

# Загружаем изображение карты
	var card_image_path = _get_gate_card_image_path(card_type)
	var card_texture = load(card_image_path)
	if card_texture:
		symbol_material.albedo_texture = card_texture
		print("✅ Загружено изображение карты:", card_image_path)
	else:
		print("❌ Не удалось загрузить изображение:", card_image_path)
	# Оставляем стандартный материал
		symbol_material.emission_enabled = true
		symbol_material.emission = Color.WHITE * 0.9

	symbol_material.roughness = 0.1
	symbol_material.metallic = 1.0
	symbol.material_override = symbol_material
	
	# Коллизия для карты
	var collision_shape = CollisionShape3D.new()
	var cylinder_shape = CylinderShape3D.new()
	cylinder_shape.height = 0.08
	cylinder_shape.top_radius = 2.2
	cylinder_shape.bottom_radius = 2.2
	collision_shape.shape = cylinder_shape
	
	# Добавляем детектор попадания бакугана
	var area = Area3D.new()
	area.name = "GateCardArea"
	var area_collision = CollisionShape3D.new()
	var area_shape = CylinderShape3D.new()
	area_shape.height = 3.0
	area_shape.top_radius = 2.8
	area_shape.bottom_radius = 2.8
	area_collision.shape = area_shape
	area.add_child(area_collision)
	
	# Подключаем сигнал попадания
	area.body_entered.connect(_on_bakugan_hit_gate_card.bind(card_body))
	
	card_body.add_child(collision_shape)
	card_body.add_child(card_mesh)
	card_body.add_child(symbol)
	card_body.add_child(area)
	
	# Сохраняем тип карты и данные
	card_body.set_meta("card_type", card_type)
	card_body.set_meta("card_data", gate_card_data[card_type])
	
	return card_body

func _get_gate_card_color(card_type: GateCardType) -> Color:
	match card_type:
		GateCardType.FIRE:
			return Color(1.0, 0.3, 0.0)  # Красный
		GateCardType.WATER:
			return Color(0.0, 0.5, 1.0)  # Синий
		GateCardType.EARTH:
			return Color(0.8, 0.5, 0.2)  # Коричневый
		GateCardType.WIND:
			return Color(0.7, 1.0, 0.3)  # Зеленый
		GateCardType.LIGHT:
			return Color(1.0, 1.0, 0.3)  # Желтый
		GateCardType.DARK:
			return Color(0.5, 0.0, 0.8)  # Фиолетовый
		_:
			return Color.WHITE

func _on_throw_gate_card_pressed():
	if is_throwing:
		print("Бросок уже в процессе!")
		return
	
	if gate_cards.size() >= 6:
		print("Максимальное количество карт-врат уже на поле!")
		_add_to_battle_log("Максимум карт-врат на поле!")
		return
	
	print("🏛️ Бросаем карту-врата на поле!")
	_add_to_battle_log("Бросаем карту-врата...")
	_start_gate_card_throw_animation()

func _start_gate_card_throw_animation():
	is_throwing = true
	
	# Обновляем UI
	if throw_card_button:
		throw_card_button.text = "⏳ Бросаем карту-врата..."
		throw_card_button.disabled = true
	
	# Создаем случайный тип карты-врат
	var card_type = randi() % GateCardType.size()
	var gate_card = _create_gate_card(card_type)
	add_child(gate_card)
	
	# Выбираем позицию для карты
	var available_positions = []
	for i in range(card_positions.size()):
		var pos = card_positions[i]
		var occupied = false
		for existing_card in gate_cards:
			if is_instance_valid(existing_card) and existing_card.position.distance_to(pos) < 4.0:
				occupied = true
				break
		if not occupied:
			available_positions.append(pos)
	
	if available_positions.size() == 0:
		print("Нет свободных позиций для карты!")
		_add_to_battle_log("Нет места для карты!")
		gate_card.queue_free()
		is_throwing = false
		if throw_card_button:
			throw_card_button.text = "🏛️ Бросить карту-врата"
			throw_card_button.disabled = false
		return
	
	var target_position = available_positions[randi() % available_positions.size()]
	
	# Анимация броска карты
	var tween = create_tween()
	tween.set_parallel(true)
	
	var start_pos = gate_card.position
	var end_pos = target_position
	var mid_pos = Vector3(
		(start_pos.x + end_pos.x) / 2,
		max(start_pos.y, end_pos.y) + CARD_THROW_HEIGHT,
		(start_pos.z + end_pos.z) / 2
	)
	
	# Анимируем движение карты
	tween.tween_method(_animate_gate_card_curve.bind(gate_card, start_pos, mid_pos, end_pos), 0.0, 1.0, CARD_THROW_DURATION)
	
	# Анимируем вращение карты
	tween.tween_method(_animate_gate_card_rotation.bind(gate_card.get_child(1)), 0.0, 360.0, CARD_THROW_DURATION)
	
	# Завершение анимации
	tween.tween_callback(_on_gate_card_throw_complete.bind(gate_card))

func _animate_gate_card_curve(gate_card: RigidBody3D, start_pos: Vector3, mid_pos: Vector3, end_pos: Vector3, progress: float):
	if is_instance_valid(gate_card):
		var pos = start_pos.lerp(mid_pos, progress).lerp(mid_pos.lerp(end_pos, progress), progress)
		gate_card.position = pos

func _animate_gate_card_rotation(card_mesh: MeshInstance3D, rotation_degrees: float):
	if is_instance_valid(card_mesh):
		card_mesh.rotation_degrees = Vector3(0, rotation_degrees, 0)

func _on_gate_card_throw_complete(gate_card: RigidBody3D):
	if not is_instance_valid(gate_card):
		return
		
	print("✅ Карта-врата приземлилась!")
	
	# Добавляем в список активных карт
	gate_cards.append(gate_card)
	
	# Включаем физику для карты
	gate_card.freeze = false
	
	# Активируем кнопку броска бакугана
	if throw_bakugan_button:
		throw_bakugan_button.disabled = false
	
	# Обновляем UI
	if throw_card_button:
		throw_card_button.text = "🏛️ Бросить карту-врата"
		throw_card_button.disabled = false
	
	is_throwing = false
	
	# Получаем данные о карте
	var card_data = gate_card.get_meta("card_data")
	_add_to_battle_log("Карта активирована: " + card_data.name)
	
	# Эффект активации карты
	_activate_gate_card_effect(gate_card)

func _activate_gate_card_effect(gate_card: RigidBody3D):
	if not is_instance_valid(gate_card):
		return
		
	# Создаем эффект активации карты-врат
	var card_mesh = gate_card.get_child(1)  # GateCardMesh
	var symbol = gate_card.get_child(2)     # CardSymbol
	
	if card_mesh and symbol:
		# Создаем пульсирующий эффект
		var tween = create_tween()
		tween.set_loops()
		tween.set_parallel(true)
		
		# Пульсация основной карты
		tween.tween_method(_pulse_gate_card.bind(card_mesh), 1.0, 1.3, 0.8)
		tween.tween_method(_pulse_gate_card.bind(card_mesh), 1.3, 1.0, 0.8)
		
		# Вращение символа
		tween.tween_method(_rotate_symbol.bind(symbol), 0.0, 360.0, 2.0)
		
		# Сохраняем tween для остановки при необходимости
		gate_card.set_meta("activation_tween", tween)

func _pulse_gate_card(card_mesh: MeshInstance3D, scale_factor: float):
	if is_instance_valid(card_mesh):
		card_mesh.scale = Vector3(scale_factor, 1.0, scale_factor)

func _rotate_symbol(symbol: MeshInstance3D, rotation_degrees: float):
	if is_instance_valid(symbol):
		symbol.rotation_degrees = Vector3(0, rotation_degrees, 0)

func _on_throw_bakugan_pressed():
	if is_throwing or is_bakugan_open:
		print("Бросок уже в процессе или бакуган открыт!")
		return
	
	if gate_cards.size() == 0:
		print("Сначала нужно бросить карту-врата!")
		_add_to_battle_log("Сначала бросьте карту-врата!")
		return
	
	print("⚡ Бросаем бакугана на поле!")
	_add_to_battle_log("Бросаем бакугана в бой!")
	_start_bakugan_throw_animation()

func _start_bakugan_throw_animation():
	is_throwing = true
	
	# Обновляем UI
	if throw_bakugan_button:
		throw_bakugan_button.text = "⏳ Бросаем бакугана..."
		throw_bakugan_button.disabled = true
	
	# Получаем текущего бакугана
	var pack_data = Global.get_selected_pack_data()
	if current_bakugan_index >= pack_data.size():
		print("Ошибка: неверный индекс бакугана!")
		return
	
	var bakugan_data = pack_data[current_bakugan_index]
	
	# Создаем бакугана для броска
	var bakugan = _create_bakugan(bakugan_data)
	if not bakugan:
		print("Ошибка создания бакугана!")
		return
	
	bakugan.position = player_throw_point.global_transform.origin
	add_child(bakugan)
	
	# Выбираем случайную карту-врата как цель
	var target_gate_card = gate_cards[randi() % gate_cards.size()]
	var target_position = target_gate_card.position + Vector3(0, 1, 0)
	
	# Анимация броска бакугана
	var tween = create_tween()
	tween.set_parallel(true)
	
	var start_pos = bakugan.position
	var end_pos = target_position
	var mid_pos = Vector3(
		(start_pos.x + end_pos.x) / 2,
		max(start_pos.y, end_pos.y) + THROW_HEIGHT,
		(start_pos.z + end_pos.z) / 2
	)
	
	# Анимируем движение бакугана
	tween.tween_method(_animate_bakugan_curve.bind(bakugan, start_pos, mid_pos, end_pos), 0.0, 1.0, THROW_DURATION)
	
	# Анимируем вращение бакугана
	tween.tween_method(_animate_bakugan_rotation.bind(bakugan), 0.0, 720.0, THROW_DURATION)
	
	# Завершение анимации
	tween.tween_callback(_on_bakugan_throw_complete.bind(bakugan, target_gate_card))

func _animate_bakugan_curve(bakugan: RigidBody3D, start_pos: Vector3, mid_pos: Vector3, end_pos: Vector3, progress: float):
	if is_instance_valid(bakugan):
		var pos = start_pos.lerp(mid_pos, progress).lerp(mid_pos.lerp(end_pos, progress), progress)
		bakugan.position = pos

func _animate_bakugan_rotation(bakugan: RigidBody3D, rotation_degrees: float):
	if is_instance_valid(bakugan):
		bakugan.rotation_degrees = Vector3(0, rotation_degrees, 0)

func _on_bakugan_throw_complete(bakugan: RigidBody3D, target_gate_card: RigidBody3D):
	if not is_instance_valid(bakugan) or not is_instance_valid(target_gate_card):
		return
		
	print("✅ Бакуган приземлился!")
	
	# Включаем физику для бакугана
	bakugan.freeze = false
	
	# Обновляем UI
	if throw_bakugan_button:
		throw_bakugan_button.text = "⚡ Бросить бакугана"
		throw_bakugan_button.disabled = true
	
	is_throwing = false
	
	# Добавляем в список активных бакуганов
	spawned_bakugans.append(bakugan)
	
	# Активируем открытие бакугана
	_add_to_battle_log("Бакуган попал на карту-врата!")
	_trigger_bakugan_transformation(bakugan, target_gate_card)

func _trigger_bakugan_transformation(bakugan: RigidBody3D, gate_card: RigidBody3D):
	if not is_instance_valid(bakugan) or not is_instance_valid(gate_card):
		return
		
	print("🔥 Начинаем трансформацию бакугана!")
	_add_to_battle_log("Бакуган трансформируется!")
	
	is_bakugan_open = true
	
	# Получаем данные о бакугане
	var bakugan_data = bakugan.get_meta("bakugan_data")
	var bakugan_type = bakugan_data.type
	
	# Получаем данные о карте-вратах
	var card_type = gate_card.get_meta("card_type")
	var card_data = gate_card.get_meta("card_data")
	
	# Создаем открытую модель бакугана
	var open_bakugan = _create_open_bakugan(bakugan_data, bakugan.position)
	if open_bakugan:
		add_child(open_bakugan)
		
		# Удаляем закрытого бакугана
		bakugan.queue_free()
		
		# Применяем бонус от карты-врат
		var bonus = _calculate_gate_card_bonus(bakugan_type, card_type, card_data)
		_add_to_battle_log("Бонус от карты: +" + str(bonus) + " силы!")
		
		# Показываем финальную силу
		var final_power = bakugan_data.power + bonus
		_add_to_battle_log(bakugan_data.name + " сила: " + str(final_power))
		
		# Создаем эффект трансформации
		_create_transformation_effect(open_bakugan.position)
		
		# Запускаем анимацию появления
		_animate_bakugan_opening(open_bakugan)

func _create_open_bakugan(bakugan_data: Dictionary, position: Vector3) -> RigidBody3D:
	var bakugan_type = bakugan_data.type
	var bakugan_name = bakugan_data.name
	
	# Ищем открытую модель в наших данных
	var open_model_info = null
	if open_bakugan_paths.has(bakugan_type):
		var type_models = open_bakugan_paths[bakugan_type]
		for model_info in type_models:
			if model_info.name == bakugan_name:
				open_model_info = model_info
				break
	
	if not open_model_info:
		print("Открытая модель для", bakugan_name, "не найдена!")
		return null
	
	# Создаем RigidBody3D для открытого бакугана
	var open_bakugan = RigidBody3D.new()
	open_bakugan.name = "OpenBakugan_" + bakugan_name
	open_bakugan.position = position
	open_bakugan.freeze = true
	open_bakugan.mass = 2.0
	
	# Создаем визуальную модель
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "OpenBakuganMesh"
	
	# Пытаемся загрузить модель
	var mesh_resource = load(open_model_info.mesh_path)
	if mesh_resource:
		mesh_instance.mesh = mesh_resource
		print("✅ Загружена открытая модель:", open_model_info.mesh_path)
	else:
		print("❌ Не удалось загрузить модель:", open_model_info.mesh_path)
		# Создаем заменяющую модель
		mesh_instance.mesh = _create_fallback_open_bakugan_mesh(bakugan_type)
	
	# Создаем материал для открытого бакугана
	var material = StandardMaterial3D.new()
	material.albedo_color = open_model_info.fallback_color
	material.emission_enabled = true
	material.emission = open_model_info.fallback_color * 0.4
	material.roughness = 0.3
	material.metallic = 0.7
	mesh_instance.material_override = material
	
	# Увеличиваем размер для открытого бакугана
	mesh_instance.scale = Vector3(2.0, 2.0, 2.0)
	
	# Создаем коллизию
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(3.0, 3.0, 3.0)
	collision_shape.shape = box_shape
	
	# Добавляем компоненты
	open_bakugan.add_child(mesh_instance)
	open_bakugan.add_child(collision_shape)
	
	# Сохраняем данные
	open_bakugan.set_meta("bakugan_data", bakugan_data)
	open_bakugan.set_meta("is_open", true)
	
	return open_bakugan

func _create_fallback_open_bakugan_mesh(bakugan_type: String) -> Mesh:
	# Создаем более сложную модель для открытого бакугана
	var mesh = SphereMesh.new()
	mesh.radius = 1.5
	mesh.height = 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	return mesh

func _calculate_gate_card_bonus(bakugan_type: String, card_type: GateCardType, card_data: Dictionary) -> int:
	var bonus = 0
	
	# Проверяем совпадение типов для специальных бонусов
	match card_type:
		GateCardType.FIRE:
			if bakugan_type == "Огненный":
				bonus = card_data.bonus
		GateCardType.WATER:
			if bakugan_type == "Водный":
				bonus = card_data.bonus
		GateCardType.DARK:
			if bakugan_type == "Тёмный":
				bonus = card_data.bonus
		GateCardType.EARTH:
			# Земляная карта даёт бонус всем
			bonus = card_data.bonus
		GateCardType.WIND:
			# Воздушная карта даёт бонус к скорости (условно к силе)
			bonus = card_data.bonus
		GateCardType.LIGHT:
			# Световая карта пока не имеет соответствующих бакуганов
			bonus = 0
	
	return bonus

func _create_transformation_effect(position: Vector3):
	# Создаем эффект трансформации с частицами
	var effect_duration = 2.0
	var particle_count = 20
	
	for i in range(particle_count):
		var particle = MeshInstance3D.new()
		var particle_mesh = SphereMesh.new()
		particle_mesh.radius = 0.1
		particle_mesh.height = 0.2
		particle.mesh = particle_mesh
		
		# Материал для частиц
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1.0, 0.8, 0.0, 0.8)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.8, 0.0)
		material.flags_transparent = true
		particle.material_override = material
		
		# Случайная позиция вокруг точки трансформации
		var offset = Vector3(
			randf_range(-2.0, 2.0),
			randf_range(0.0, 4.0),
			randf_range(-2.0, 2.0)
		)
		particle.position = position + offset
		
		add_child(particle)
		
		# Анимация частицы
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Движение вверх
		tween.tween_property(particle, "position", particle.position + Vector3(0, 3, 0), effect_duration)
		
		# Исчезновение
		tween.tween_property(particle, "modulate:a", 0.0, effect_duration)
		
		# Удаление после анимации
		tween.tween_callback(particle.queue_free)

func _animate_bakugan_opening(open_bakugan: RigidBody3D):
	if not is_instance_valid(open_bakugan):
		return
		
	var mesh_instance = open_bakugan.get_child(0)
	if not mesh_instance:
		return
	
	# Начинаем с маленького размера
	mesh_instance.scale = Vector3(0.1, 0.1, 0.1)
	
	# Анимируем увеличение размера
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Увеличение размера
	tween.tween_property(mesh_instance, "scale", Vector3(2.0, 2.0, 2.0), TRANSFORMATION_DURATION)
	
	# Вращение при появлении
	tween.tween_property(mesh_instance, "rotation_degrees", Vector3(0, 360, 0), TRANSFORMATION_DURATION)
	
	# Завершение трансформации
	tween.tween_callback(_on_transformation_complete.bind(open_bakugan))

func _on_transformation_complete(open_bakugan: RigidBody3D):
	if not is_instance_valid(open_bakugan):
		return
		
	print("🎉 Трансформация завершена!")
	_add_to_battle_log("Бакуган готов к бою!")
	
	# Включаем физику
	open_bakugan.freeze = false
	
	# Обновляем состояние
	is_bakugan_open = false
	
	# Разрешаем новые броски
	if throw_bakugan_button:
		throw_bakugan_button.disabled = false

func _on_bakugan_hit_gate_card(gate_card: RigidBody3D, bakugan: RigidBody3D):
	if not is_instance_valid(gate_card) or not is_instance_valid(bakugan):
		return
		
	print("💥 Бакуган попал на карту-врата!")
	_add_to_battle_log("Прямое попадание на карту-врата!")
	
	# Дополнительный бонус за точное попадание
	var extra_bonus = 100
	_add_to_battle_log("Бонус за точность: +" + str(extra_bonus))

func _on_switch_bakugan_pressed():
	if is_throwing or is_bakugan_open:
		print("Нельзя сменить бакугана во время броска или трансформации!")
		return
	
	var pack_data = Global.get_selected_pack_data()
	current_bakugan_index = (current_bakugan_index + 1) % pack_data.size()
	
	print("🔄 Сменили бакугана на:", pack_data[current_bakugan_index].name)
	_add_to_battle_log("Выбран: " + pack_data[current_bakugan_index].name)
	
	# Удаляем старого бакугана из превью
	for child in bakugan_root.get_children():
		child.queue_free()
	
	# Спавним нового бакугана
	_spawn_bakugan(current_bakugan_index)

func _on_back_to_menu_pressed():
	print("🏠 Возвращаемся в главное меню")
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

# Обработка горячих клавиш
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Q:
				if not is_throwing:
					_on_throw_gate_card_pressed()
			KEY_SPACE:
				if not is_throwing and not is_bakugan_open:
					_on_throw_bakugan_pressed()
			KEY_UP:
				if not is_throwing and not is_bakugan_open:
					_on_switch_bakugan_pressed()
			KEY_ESCAPE:
				_on_back_to_menu_pressed()

func _spawn_bakugan(index: int):
	# Получаем данные о выбранном наборе
	var pack_data = Global.get_selected_pack_data()
	if index >= pack_data.size():
		print("Ошибка: индекс бакугана вне диапазона!")
		return
	
	var bakugan_data = pack_data[index]
	
	# Создаем бакугана для превью
	var bakugan = _create_bakugan(bakugan_data)
	if bakugan:
		bakugan.position = Vector3(0, 3, 5)  # Позиция для превью
		bakugan.freeze = true  # Замораживаем для превью
		bakugan_root.add_child(bakugan)
		
		# Добавляем легкое вращение для превью
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(bakugan, "rotation_degrees", Vector3(0, 360, 0), 4.0)
		
		print("✅ Бакуган заспавнен для превью:", bakugan_data.name)
	
	# Обновляем UI
	_update_bakugan_ui()

func _create_bakugan(bakugan_data: Dictionary) -> RigidBody3D:
	# Создаем RigidBody3D для бакугана
	var bakugan = RigidBody3D.new()
	bakugan.name = "Bakugan_" + bakugan_data.name
	bakugan.mass = 1.0
	bakugan.gravity_scale = 1.0
	bakugan.freeze = true
	
	# Создаем визуальную модель
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "BakuganMesh"
	
	# Пытаемся загрузить модель
	var mesh_resource = load(bakugan_data.mesh_path)
	if mesh_resource:
		mesh_instance.mesh = mesh_resource
		print("✅ Загружена модель:", bakugan_data.mesh_path)
	else:
		print("❌ Не удалось загрузить модель:", bakugan_data.mesh_path)
		# Создаем заменяющую модель
		mesh_instance.mesh = _create_fallback_bakugan_mesh(bakugan_data.type)
	
	# Создаем материал
	var material = StandardMaterial3D.new()
	material.emission_enabled = true
	material.roughness = 0.4
	material.metallic = 0.8
	mesh_instance.material_override = material
	
	# Создаем коллизию
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.8
	collision_shape.shape = sphere_shape
	
	# Добавляем компоненты
	bakugan.add_child(mesh_instance)
	bakugan.add_child(collision_shape)
	
	# Сохраняем данные о бакугане
	bakugan.set_meta("bakugan_data", bakugan_data)
	bakugan.set_meta("is_open", false)
	
	return bakugan

func _create_fallback_bakugan_mesh(bakugan_type: String) -> Mesh:
	# Создаем сферу как заменяющую модель
	var sphere = SphereMesh.new()
	sphere.radius = 0.8
	sphere.height = 1.6
	sphere.radial_segments = 12
	sphere.rings = 8
	return sphere

func _update_bakugan_ui():
	if not bakugan_ui:
		return
		
	var pack_data = Global.get_selected_pack_data()
	if current_bakugan_index >= pack_data.size():
		bakugan_ui.text = "Ошибка: неверный индекс бакугана!"
		return
	
	var bakugan_data = pack_data[current_bakugan_index]
	
	var ui_text = "🎯 Текущий бакуган:\n"
	ui_text += "• Имя: " + bakugan_data.name + "\n"
	ui_text += "• Сила: " + str(bakugan_data.power) + "\n"
	ui_text += "• Позиция: " + str(current_bakugan_index + 1) + "/" + str(pack_data.size())
	
	bakugan_ui.text = ui_text
	
			
func _get_gate_card_image_path(card_type: GateCardType) -> String:
	match card_type:
		GateCardType.FIRE:
			return "res://ImagesGateCard/gate_cards/fire_gate.jpg"
		GateCardType.WATER:
			return "res://ImagesGateCard/gate_cards/water_gate.jpg"
		GateCardType.EARTH:
			return "res://ImagesGateCard/gate_cards/earth_gate.jpg"
		GateCardType.WIND:
			return "res://ImagesGateCard/gate_cards/wind_gate.jpg"
		GateCardType.LIGHT:
			return "res://ImagesGateCard/gate_cards/light_gate.jpg"
		GateCardType.DARK:
			return "res://ImagesGateCard/gate_cards/dark_gate.jpg"
		_:
			return "res://ImagesGateCard/gate_cards/default_gate.jpg"
