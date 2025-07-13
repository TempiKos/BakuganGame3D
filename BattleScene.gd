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

# Константы для анимации
const THROW_DURATION = 2.0
const THROW_HEIGHT = 8.0
const CARD_THROW_DURATION = 1.5
const CARD_THROW_HEIGHT = 4.0
const ROTATION_SPEED = 10.0
const TRANSFORMATION_DURATION = 1.0

# Путь к открытым моделям бакуганов
var open_bakugan_paths := {
	"Огненный": [
		{"name": "Saurus", "mesh_path": "A76534B5BBCCB82452143FA79F446FB492C80CE7_Saurus Hitbox.obj"},
		{"name": "Centipoid", "mesh_path": "4684845ED21D8A04C8DBDC754DDDAB89B823D01D_Angelo Hitbox.obj"},
		{"name": "Gargonoid", "mesh_path": "CCD240260FE0EDA23A64E14A211CABAC257777D8_Gargonoid hitbox.obj"}
	],
	"Водный": [
		{"name": "Vladitor", "mesh_path": "res://open_obj/vladitor_open.obj"},
		{"name": "Preyas", "mesh_path": "res://open_obj/preyas_open.obj"},
		{"name": "Juggernoid", "mesh_path": "res://open_obj/juggernoid_open.obj"}
	],
	"Тёмный": [
		{"name": "Exedra", "mesh_path": "res://open_obj/exedra_open.obj"},
		{"name": "Reaper", "mesh_path": "res://open_obj/reaper_open.obj"},
		{"name": "Fear Ripper", "mesh_path": "res://open_obj/fear_ripper_open.obj"}
	]
}

# Типы карт-врат
enum GateCardType {
	FIRE,    # Огненная карта
	WATER,   # Водная карта
	EARTH,   # Земляная карта
	WIND,    # Воздушная карта
	LIGHT,   # Световая карта
	DARK     # Тёмная карта
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
		field_mesh.size = Vector3(25, 0.1, 20)
		field.mesh = field_mesh
		field.position = Vector3(0, -0.05, 0)
		
		# Создаем материал для поля с металлическим блеском
		var field_material = StandardMaterial3D.new()
		field_material.albedo_color = Color(0.15, 0.15, 0.2)  # Тёмно-серый
		field_material.roughness = 0.3
		field_material.metallic = 0.8
		field_material.emission_enabled = true
		field_material.emission = Color(0.05, 0.1, 0.15)
		
		field.material_override = field_material
		
		# Создаем StaticBody3D для поля
		var field_body = StaticBody3D.new()
		field_body.name = "FieldBody"
		field_body.position = Vector3(0, -0.05, 0)
		
		# Добавляем коллизию к StaticBody3D
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(25, 0.1, 20)
		collision_shape.shape = box_shape
		field_body.add_child(collision_shape)
		
		# Добавляем StaticBody3D в сцену
		add_child(field_body)
		
		# Создаем декоративные элементы поля
		_create_field_decorations()
		
		print("Поле боя создано с коллизией")

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
	center_line_mesh.size = Vector3(25, 0.02, 0.1)
	center_line.mesh = center_line_mesh
	center_line.material_override = line_material
	center_line.position = Vector3(0, 0.06, 0)
	add_child(center_line)
	
	# Боковые линии
	for i in range(2):
		var side_line = MeshInstance3D.new()
		var side_line_mesh = BoxMesh.new()
		side_line_mesh.size = Vector3(0.1, 0.02, 20)
		side_line.mesh = side_line_mesh
		side_line.material_override = line_material
		side_line.position = Vector3((-1 + i * 2) * 12, 0.06, 0)
		add_child(side_line)
	
	# Создаем круговые зоны для карт-врат
	_create_gate_zones()

func _create_gate_zones():
	# Создаем светящиеся круги для позиций карт-врат
	var zone_material = StandardMaterial3D.new()
	zone_material.albedo_color = Color(0.2, 0.8, 0.2, 0.3)
	zone_material.emission_enabled = true
	zone_material.emission = Color(0.1, 0.4, 0.1)
	zone_material.flags_transparent = true
	zone_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	for i in range(6):  # 6 позиций для карт-врат
		var zone = MeshInstance3D.new()
		var cylinder_mesh = CylinderMesh.new()
		cylinder_mesh.top_radius = 2.0
		cylinder_mesh.bottom_radius = 2.0
		cylinder_mesh.height = 0.01
		zone.mesh = cylinder_mesh
		zone.material_override = zone_material
		zone.name = "GateZone_" + str(i)
		
		# Располагаем зоны в два ряда
		var row = i / 3
		var col = i % 3
		var x = (col - 1) * 6.0  # -6, 0, 6
		var z = (row - 0.5) * 8.0  # -4, 4
		
		zone.position = Vector3(x, 0.01, z)
		add_child(zone)

func _initialize_gate_card_positions():
	# Создаем позиции для карт-врат (6 позиций как в аниме)
	card_positions.clear()
	for i in range(6):
		var row = i / 3
		var col = i % 3
		var x = (col - 1) * 6.0  # -6, 0, 6
		var z = (row - 0.5) * 8.0  # -4, 4
		card_positions.append(Vector3(x, 0.1, z))

func _setup_camera_and_lighting():
	# Настраиваем камеру для лучшего обзора
	if camera:
		camera.position = Vector3(0, 18, 15)
		camera.rotation_degrees = Vector3(-50, 0, 0)
		camera.fov = 70
		print("Камера настроена")
	
	# Настраиваем освещение
	if light:
		light.position = Vector3(0, 25, 10)
		light.rotation_degrees = Vector3(-70, 0, 0)
		light.light_energy = 2.0
		light.shadow_enabled = true
		print("Освещение настроено")

func _setup_throw_points():
	# Настраиваем точки броска
	if player_throw_point:
		player_throw_point.position = Vector3(0, 4, 10)
		print("Точка броска игрока:", player_throw_point.position)
	
	if enemy_throw_point:
		enemy_throw_point.position = Vector3(0, 4, -10)
		print("Точка броска врага:", enemy_throw_point.position)

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
	button_panel.size = Vector2(300, 400)
	button_panel.modulate = Color(0.1, 0.1, 0.15, 0.9)
	ui_container.add_child(button_panel)
	
	# Контейнер для кнопок
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(15, 15)
	button_container.size = Vector2(270, 370)
	button_panel.add_child(button_container)
	
	# Заголовок
	var title_label = Label.new()
	title_label.text = "🔥 БИТВА БАКУГАН 🔥"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	button_container.add_child(title_label)
	
	# Разделитель
	var separator = HSeparator.new()
	button_container.add_child(separator)
	
	# Кнопка для броска карты-врат
	throw_card_button = Button.new()
	throw_card_button.text = "🏛️ Бросить карту-врата"
	throw_card_button.add_theme_font_size_override("font_size", 14)
	throw_card_button.pressed.connect(_on_throw_gate_card_pressed)
	button_container.add_child(throw_card_button)
	
	# Кнопка для броска бакугана
	throw_bakugan_button = Button.new()
	throw_bakugan_button.text = "⚡ Бросить бакугана"
	throw_bakugan_button.add_theme_font_size_override("font_size", 14)
	throw_bakugan_button.disabled = true
	throw_bakugan_button.pressed.connect(_on_throw_bakugan_pressed)
	button_container.add_child(throw_bakugan_button)
	
	# Кнопка для смены бакугана
	switch_button = Button.new()
	switch_button.text = "🔄 Сменить бакугана"
	switch_button.add_theme_font_size_override("font_size", 14)
	switch_button.pressed.connect(_on_switch_bakugan_pressed)
	button_container.add_child(switch_button)
	
	# Кнопка возврата в меню
	back_button = Button.new()
	back_button.text = "🏠 Назад в меню"
	back_button.add_theme_font_size_override("font_size", 14)
	back_button.pressed.connect(_on_back_to_menu_pressed)
	button_container.add_child(back_button)
	
	# Информация о текущем бакугане
	bakugan_ui = Label.new()
	bakugan_ui.text = "Загрузка..."
	bakugan_ui.add_theme_font_size_override("font_size", 12)
	bakugan_ui.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bakugan_ui.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bakugan_ui.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button_container.add_child(bakugan_ui)
	
	# Инструкции
	var instructions = Label.new()
	instructions.text = "\n⌨️ Горячие клавиши:\n• Q - Бросить карту-врата\n• Space - Бросить бакугана\n• ↑ - Сменить бакугана\n• Esc - Выход"
	instructions.add_theme_font_size_override("font_size", 10)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	instructions.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button_container.add_child(instructions)
	
	print("UI создан")

func _create_gate_card(card_type: GateCardType = GateCardType.FIRE):
	# Создаем карту-врата как в аниме
	var card_body = RigidBody3D.new()
	card_body.name = "GateCard"
	card_body.position = player_throw_point.global_transform.origin
	card_body.gravity_scale = 0.5
	card_body.mass = 0.3
	card_body.freeze = true
	
	# Создаем визуальную модель карты
	var card_mesh = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 1.8
	cylinder_mesh.bottom_radius = 1.8
	cylinder_mesh.height = 0.05
	card_mesh.mesh = cylinder_mesh
	card_mesh.name = "GateCardMesh"
	
	# Материал для карты-врат в зависимости от типа
	var card_material = StandardMaterial3D.new()
	var card_color = _get_gate_card_color(card_type)
	card_material.albedo_color = card_color
	card_material.emission_enabled = true
	card_material.emission = card_color * 0.5
	card_material.roughness = 0.2
	card_material.metallic = 0.8
	card_material.flags_transparent = true
	card_material.albedo_color.a = 0.8
	card_mesh.material_override = card_material
	
	# Создаем символ на карте
	var symbol = MeshInstance3D.new()
	var symbol_mesh = CylinderMesh.new()
	symbol_mesh.top_radius = 0.8
	symbol_mesh.bottom_radius = 0.8
	symbol_mesh.height = 0.02
	symbol.mesh = symbol_mesh
	symbol.position = Vector3(0, 0.035, 0)
	
	var symbol_material = StandardMaterial3D.new()
	symbol_material.albedo_color = Color.WHITE
	symbol_material.emission_enabled = true
	symbol_material.emission = Color.WHITE * 0.8
	symbol.material_override = symbol_material
	
	# Коллизия для карты
	var collision_shape = CollisionShape3D.new()
	var cylinder_shape = CylinderShape3D.new()
	cylinder_shape.height = 0.05
	cylinder_shape.top_radius = 1.8
	cylinder_shape.bottom_radius = 1.8
	collision_shape.shape = cylinder_shape
	
	# Добавляем детектор попадания бакугана
	var area = Area3D.new()
	area.name = "GateCardArea"
	var area_collision = CollisionShape3D.new()
	var area_shape = CylinderShape3D.new()
	area_shape.height = 2.0
	area_shape.top_radius = 2.0
	area_shape.bottom_radius = 2.0
	area_collision.shape = area_shape
	area.add_child(area_collision)
	
	# Подключаем сигнал попадания
	area.body_entered.connect(_on_bakugan_hit_gate_card.bind(card_body))
	
	card_body.add_child(collision_shape)
	card_body.add_child(card_mesh)
	card_body.add_child(symbol)
	card_body.add_child(area)
	
	# Сохраняем тип карты
	card_body.set_meta("card_type", card_type)
	
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
	
	print("🏛️ Бросаем карту-врата на поле!")
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
	gate_cards.append(gate_card)
	
	# Выбираем позицию для карты
	var available_positions = []
	for i in range(card_positions.size()):
		var pos = card_positions[i]
		var occupied = false
		for existing_card in gate_cards:
			if existing_card.position.distance_to(pos) < 3.0:
				occupied = true
				break
		if not occupied:
			available_positions.append(pos)
	
	if available_positions.size() == 0:
		print("Нет свободных позиций для карты!")
		gate_card.queue_free()
		gate_cards.pop_back()
		is_throwing = false
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
	var pos = start_pos.lerp(mid_pos, progress).lerp(mid_pos.lerp(end_pos, progress), progress)
	gate_card.position = pos

func _animate_gate_card_rotation(card_mesh: MeshInstance3D, rotation_degrees: float):
	card_mesh.rotation_degrees = Vector3(0, rotation_degrees, 0)

func _on_gate_card_throw_complete(gate_card: RigidBody3D):
	print("✅ Карта-врата приземлилась!")
	
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
	
	# Эффект активации карты
	_activate_gate_card_effect(gate_card)

func _activate_gate_card_effect(gate_card: RigidBody3D):
	# Создаем эффект активации карты-врат
	var card_mesh = gate_card.get_child(1)
	var symbol = gate_card.get_child(2)
	var activate_tween = create_tween()
	activate_tween.set_parallel(true)
	
	# Пульсация света
	var material = card_mesh.material_override
	var symbol_material = symbol.material_override
	var original_emission = material.emission
	
	activate_tween.tween_method(_animate_gate_card_pulse.bind(material, symbol_material, original_emission), 0.0, 1.0, 3.0)

func _animate_gate_card_pulse(material: StandardMaterial3D, symbol_material: StandardMaterial3D, original_emission: Color, progress: float):
	var pulse_strength = sin(progress * PI * 4) * 0.3 + 0.5
	material.emission = original_emission * pulse_strength
	symbol_material.emission = Color.WHITE * pulse_strength

func _on_bakugan_hit_gate_card(bakugan_body: RigidBody3D, gate_card: RigidBody3D):
	print("🎯 Бакуган попал на карту-врата!")
	
	# Проверяем, что это действительно бакуган
	if not bakugan_body.name.ends_with("_Body"):
		return
	
	# Запускаем трансформацию
	_start_bakugan_transformation(bakugan_body, gate_card)

func _start_bakugan_transformation(bakugan_body: RigidBody3D, gate_card: RigidBody3D):
	print("⚡ Начинаем трансформацию бакугана!")
	
	# Останавливаем физику бакугана
	bakugan_body.freeze = true
	
	# Получаем данные о бакугане
	var bakugan_mesh = bakugan_body.get_child(1)
	var bakugan_name = bakugan_mesh.name
	
	# Создаем эффект трансформации
	_create_transformation_effect(bakugan_body.position)
	
	# Ждем немного для эффекта
	await get_tree().create_timer(0.5).timeout
	
	# Заменяем модель на открытую
	_replace_with_open_bakugan(bakugan_body, bakugan_name)
	
	# Увеличиваем размер
	var transform_tween = create_tween()
	transform_tween.set_parallel(true)
	
	# Анимируем увеличение
	transform_tween.tween_property(bakugan_body, "scale", Vector3(2.0, 2.0, 2.0), TRANSFORMATION_DURATION)
	
	# Анимируем подъем
	var target_position = bakugan_body.position + Vector3(0, 1.5, 0)
	transform_tween.tween_property(bakugan_body, "position", target_position, TRANSFORMATION_DURATION)
	
	# Анимируем вращение
	transform_tween.tween_method(_animate_transformation_rotation.bind(bakugan_mesh), 0.0, 360.0, TRANSFORMATION_DURATION)
	
	# Завершение трансформации
	transform_tween.tween_callback(_on_transformation_complete.bind(bakugan_body))

func _create_transformation_effect(position: Vector3):
	# Создаем эффект вспышки при трансформации
	var effect = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1
	sphere_mesh.height = 0.2
	effect.mesh = sphere_mesh
	effect.position = position
	
	var effect_material = StandardMaterial3D.new()
	effect_material.albedo_color = Color.WHITE
	effect_material.emission_enabled = true
	effect_material.emission = Color.WHITE
	effect_material.flags_transparent = true
	effect.material_override = effect_material
	
	add_child(effect)
	
	# Анимируем эффект
	var effect_tween = create_tween()
	effect_tween.set_parallel(true)
	
	effect_tween.tween_property(effect, "scale", Vector3(5.0, 5.0, 5.0), 0.5)
	effect_tween.tween_property(effect_material, "albedo_color:a", 0.0, 0.5)
	effect_tween.tween_callback(effect.queue_free)

func _replace_with_open_bakugan(bakugan_body: RigidBody3D, bakugan_name: String):
	# Найдем путь к открытой модели
	var open_mesh_path = _find_open_bakugan_path(bakugan_name)
	if open_mesh_path == "":
		print("Не найдена открытая модель для:", bakugan_name)
		return
	
	# Проверяем существование файла
	if not ResourceLoader.exists(open_mesh_path):
		print("Файл открытой модели не найден:", open_mesh_path)
		return
	
	# Загружаем новую модель
	var open_mesh = load(open_mesh_path)
	if not open_mesh:
		print("Не удалось загрузить открытую модель:", open_mesh_path)
		return
	
	# Заменяем модель на открытую
	var bakugan_mesh = bakugan_body.get_child(1)
	bakugan_mesh.mesh = open_mesh
	
	# Обновляем материал для открытой модели
	var open_material = StandardMaterial3D.new()
	open_material.albedo_color = Color.WHITE
	open_material.emission_enabled = true
	open_material.emission = Color(1.0, 0.8, 0.0, 0.3)  # Золотистое свечение
	open_material.roughness = 0.4
	open_material.metallic = 0.7
	bakugan_mesh.material_override = open_material
	
	print("✅ Модель заменена на открытую:", open_mesh_path)

func _find_open_bakugan_path(bakugan_name: String) -> String:
	# Ищем путь к открытой модели по имени бакугана
	for pack_type in open_bakugan_paths:
		var bakugans = open_bakugan_paths[pack_type]
		for bakugan in bakugans:
			if bakugan.name == bakugan_name:
				return bakugan.mesh_path
	return ""

func _animate_transformation_rotation(mesh: MeshInstance3D, rotation_degrees: float):
	mesh.rotation_degrees = Vector3(rotation_degrees * 0.5, rotation_degrees, rotation_degrees * 0.3)

func _on_transformation_complete(bakugan_body: RigidBody3D):
	print("🎉 Трансформация завершена!")
	
	is_bakugan_open = true
	
	# Создаем эффект успешной трансформации
	_create_success_effect(bakugan_body.position)
	
	# Включаем физику обратно, но с меньшей гравитацией
	bakugan_body.freeze = false
	bakugan_body.gravity_scale = 0.3
	
	# Обновляем UI
	_update_bakugan_ui()

func _create_success_effect(position: Vector3):
	# Создаем частицы успеха
	for i in range(10):
		var particle = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.1
		sphere_mesh.height = 0.2
		particle.mesh = sphere_mesh
		particle.position = position + Vector3(
			randf_range(-1.0, 1.0),
			randf_range(0.0, 2.0),
			randf_range(-1.0, 1.0)
		)
		
		var particle_material = StandardMaterial3D.new()
		particle_material.albedo_color = Color(randf(), randf(), randf())
		particle_material.emission_enabled = true
		particle_material.emission = particle_material.albedo_color
		particle_material.flags_transparent = true
		particle.material_override = particle_material
		
		add_child(particle)
		
		# Анимируем частицу
		var particle_tween = create_tween()
		particle_tween.set_parallel(true)
		
		particle_tween.tween_property(particle, "position", particle.position + Vector3(0, 3, 0), 2.0)
		particle_tween.tween_property(particle, "scale", Vector3.ZERO, 2.0)
		particle_tween.tween_property(particle_material, "albedo_color:a", 0.0, 2.0)
		particle_tween.tween_callback(particle.queue_free)

func _spawn_bakugan(bakugan_index: int):
	# Получаем данные о выбранном наборе
	var pack_data = Global.get_selected_pack_data()
	if bakugan_index >= pack_data.size():
		print("Неверный индекс бакугана:", bakugan_index)
		return
	
	# Очищаем предыдущих бакуганов
	for bakugan in spawned_bakugans:
		if is_instance_valid(bakugan):
			bakugan.queue_free()
	spawned_bakugans.clear()
	
	var bakugan_data = pack_data[bakugan_index]
	print("Спавним бакугана:", bakugan_data.name)
	
	# Создаем физическое тело бакугана
	var bakugan_body = RigidBody3D.new()
	bakugan_body.name = bakugan_data.name + "_Body"
	bakugan_body.position = player_throw_point.global_transform.origin
	bakugan_body.mass = 1.0
	bakugan_body.gravity_scale = 1.0
	bakugan_body.freeze = true  # Замораживаем до броска
	
	# Создаем визуальную модель
	var bakugan_mesh = MeshInstance3D.new()
	bakugan_mesh.name = bakugan_data.name
	
	# Загружаем закрытую модель
	if ResourceLoader.exists(bakugan_data.mesh_path):
		var mesh = load(bakugan_data.mesh_path)
		if mesh:
			bakugan_mesh.mesh = mesh
			print("✅ Модель загружена:", bakugan_data.mesh_path)
		else:
			print("❌ Не удалось загрузить модель:", bakugan_data.mesh_path)
			# Создаем сферу как заглушку
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = 0.5
			sphere_mesh.height = 1.0
			bakugan_mesh.mesh = sphere_mesh
	else:
		print("❌ Файл модели не найден:", bakugan_data.mesh_path)
		# Создаем сферу как заглушку
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.5
		sphere_mesh.height = 1.0
		bakugan_mesh.mesh = sphere_mesh
	
	# Создаем материал для закрытого бакугана
	var bakugan_material = StandardMaterial3D.new()
	
	# Загружаем текстуру, если есть
	if ResourceLoader.exists(bakugan_data.texture_path):
		var texture = load(bakugan_data.texture_path)
		if texture:
			bakugan_material.albedo_texture = texture
			print("✅ Текстура загружена:", bakugan_data.texture_path)
		else:
			print("❌ Не удалось загрузить текстуру:", bakugan_data.texture_path)
	else:
		print("❌ Файл текстуры не найден:", bakugan_data.texture_path)
		# Устанавливаем цвет по умолчанию в зависимости от пака
		bakugan_material.albedo_color = _get_pack_color(Global.selected_pack)
	
	# Настраиваем свойства материала
	bakugan_material.roughness = 0.3
	bakugan_material.metallic = 0.8
	bakugan_material.emission_enabled = true
	bakugan_material.emission = bakugan_material.albedo_color * 0.2
	
	bakugan_mesh.material_override = bakugan_material
	
	# Создаем коллизию
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.5
	collision_shape.shape = sphere_shape
	
	# Добавляем компоненты
	bakugan_body.add_child(collision_shape)
	bakugan_body.add_child(bakugan_mesh)
	
	# Добавляем в сцену
	bakugan_root.add_child(bakugan_body)
	spawned_bakugans.append(bakugan_body)
	
	# Обновляем UI
	_update_bakugan_ui()
	
	print("✅ Бакуган создан и добавлен в сцену")

func _get_pack_color(pack_name: String) -> Color:
	match pack_name:
		"Огненный":
			return Color(1.0, 0.3, 0.0)  # Красный
		"Водный":
			return Color(0.0, 0.5, 1.0)  # Синий
		"Тёмный":
			return Color(0.5, 0.0, 0.8)  # Фиолетовый
		_:
			return Color.WHITE

func _update_bakugan_ui():
	if not bakugan_ui:
		return
	
	var pack_data = Global.get_selected_pack_data()
	if current_bakugan_index < pack_data.size():
		var bakugan = pack_data[current_bakugan_index]
		var status = "🔒 Закрыт" if not is_bakugan_open else "🔓 Открыт"
		bakugan_ui.text = "🎯 Текущий бакуган:\n" + bakugan.name + "\n" + status + "\n(" + str(current_bakugan_index + 1) + "/" + str(pack_data.size()) + ")"
	else:
		bakugan_ui.text = "Нет данных о бакугане"

func _on_throw_bakugan_pressed():
	if is_throwing:
		print("Бросок уже в процессе!")
		return
	
	if spawned_bakugans.size() == 0:
		print("Нет бакугана для броска!")
		return
	
	# Проверяем, что есть хотя бы одна карта-врата на поле
	if gate_cards.size() == 0:
		print("Сначала нужно бросить карту-врата!")
		return
	
	print("⚡ Бросаем бакугана на поле!")
	_start_bakugan_throw_animation()

func _start_bakugan_throw_animation():
	is_throwing = true
	is_bakugan_open = false
	
	# Обновляем UI
	if throw_bakugan_button:
		throw_bakugan_button.text = "⏳ Бросаем бакугана..."
		throw_bakugan_button.disabled = true
	
	var bakugan_body = spawned_bakugans[0]
	
	# Выбираем случайную карту-врата как цель
	var target_gate_card = gate_cards[randi() % gate_cards.size()]
	var target_position = target_gate_card.position
	
	# Добавляем небольшое случайное отклонение для реалистичности
	target_position += Vector3(
		randf_range(-1.5, 1.5),
		0,
		randf_range(-1.5, 1.5)
	)
	
	# Размораживаем бакугана
	bakugan_body.freeze = false
	
	# Анимация броска
	var tween = create_tween()
	tween.set_parallel(true)
	
	var start_pos = bakugan_body.position
	var end_pos = target_position
	var mid_pos = Vector3(
		(start_pos.x + end_pos.x) / 2,
		max(start_pos.y, end_pos.y) + THROW_HEIGHT,
		(start_pos.z + end_pos.z) / 2
	)
	
	# Анимируем движение бакугана по дуге
	tween.tween_method(_animate_bakugan_curve.bind(bakugan_body, start_pos, mid_pos, end_pos), 0.0, 1.0, THROW_DURATION)
	
	# Анимируем вращение бакугана
	var bakugan_mesh = bakugan_body.get_child(1)
	tween.tween_method(_animate_bakugan_rotation.bind(bakugan_mesh), 0.0, 720.0, THROW_DURATION)
	
	# Завершение анимации
	tween.tween_callback(_on_bakugan_throw_complete.bind(bakugan_body))

func _animate_bakugan_curve(bakugan_body: RigidBody3D, start_pos: Vector3, mid_pos: Vector3, end_pos: Vector3, progress: float):
	var pos = start_pos.lerp(mid_pos, progress).lerp(mid_pos.lerp(end_pos, progress), progress)
	bakugan_body.position = pos

func _animate_bakugan_rotation(bakugan_mesh: MeshInstance3D, rotation_degrees: float):
	bakugan_mesh.rotation_degrees = Vector3(rotation_degrees * 0.7, rotation_degrees, rotation_degrees * 0.5)

func _on_bakugan_throw_complete(bakugan_body: RigidBody3D):
	print("✅ Бакуган приземлился!")
	
	# Включаем физику
	bakugan_body.gravity_scale = 1.0
	
	# Обновляем UI
	if throw_bakugan_button:
		throw_bakugan_button.text = "⚡ Бросить бакугана"
		throw_bakugan_button.disabled = false
	
	is_throwing = false
	
	# Создаем эффект приземления
	_create_landing_effect(bakugan_body.position)

func _create_landing_effect(position: Vector3):
	# Создаем эффект пыли при приземлении
	var dust_effect = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.1
	cylinder_mesh.bottom_radius = 2.0
	cylinder_mesh.height = 0.5
	dust_effect.mesh = cylinder_mesh
	dust_effect.position = position
	
	var dust_material = StandardMaterial3D.new()
	dust_material.albedo_color = Color(0.8, 0.7, 0.6, 0.5)
	dust_material.emission_enabled = true
	dust_material.emission = Color(0.4, 0.35, 0.3)
	dust_material.flags_transparent = true
	dust_effect.material_override = dust_material
	
	add_child(dust_effect)
	
	# Анимируем эффект пыли
	var dust_tween = create_tween()
	dust_tween.set_parallel(true)
	
	dust_tween.tween_property(dust_effect, "scale", Vector3(3.0, 1.5, 3.0), 1.0)
	dust_tween.tween_property(dust_material, "albedo_color:a", 0.0, 1.0)
	dust_tween.tween_callback(dust_effect.queue_free)

func _on_switch_bakugan_pressed():
	if is_throwing:
		print("Нельзя сменить бакугана во время броска!")
		return
	
	var pack_data = Global.get_selected_pack_data()
	if pack_data.size() <= 1:
		print("В наборе только один бакуган!")
		return
	
	# Переключаем на следующего бакугана
	current_bakugan_index = (current_bakugan_index + 1) % pack_data.size()
	print("🔄 Переключаемся на бакугана:", pack_data[current_bakugan_index].name)
	
	# Спавним нового бакугана
	_spawn_bakugan(current_bakugan_index)

func _on_back_to_menu_pressed():
	print("🏠 Возвращаемся в главное меню...")
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Q:
				if not is_throwing:
					_on_throw_gate_card_pressed()
			KEY_SPACE:
				if not is_throwing and gate_cards.size() > 0:
					_on_throw_bakugan_pressed()
			KEY_UP:
				if not is_throwing:
					_on_switch_bakugan_pressed()
			KEY_ESCAPE:
				_on_back_to_menu_pressed()

func _physics_process(delta):
	# Проверяем, нужно ли активировать трансформацию
	if not is_bakugan_open and spawned_bakugans.size() > 0:
		var bakugan_body = spawned_bakugans[0]
		if is_instance_valid(bakugan_body):
			# Проверяем расстояние до карт-врат
			for gate_card in gate_cards:
				if is_instance_valid(gate_card):
					var distance = bakugan_body.global_position.distance_to(gate_card.global_position)
					if distance < 2.5:  # Расстояние для активации
						# Проверяем, что бакуган не движется быстро
						if bakugan_body.linear_velocity.length() < 2.0:
							_start_bakugan_transformation(bakugan_body, gate_card)
							break
