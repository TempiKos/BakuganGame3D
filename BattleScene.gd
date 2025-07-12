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
var is_throwing = false
var is_bakugan_open = false

# UI элементы
var bakugan_ui = null
var throw_button = null
var switch_button = null
var back_button = null

# Константы для анимации
const THROW_DURATION = 2.0
const THROW_HEIGHT = 8.0
const ROTATION_SPEED = 10.0

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
	
	# Спавним первого бакугана
	_spawn_bakugan(current_bakugan_index)

func _setup_battle_field():
	# Создаем красивое поле для боя
	if field:
		var field_mesh = BoxMesh.new()
		field_mesh.size = Vector3(25, 0.5, 25)
		field.mesh = field_mesh
		field.position = Vector3(0, -0.25, 0)
		
		# Создаем материал для поля с текстурой
		var field_material = StandardMaterial3D.new()
		field_material.albedo_color = Color(0.1, 0.6, 0.1)  # Темно-зеленый
		field_material.roughness = 0.7
		field_material.metallic = 0.0
		
		# Добавляем небольшое свечение
		field_material.emission_enabled = true
		field_material.emission = Color(0.05, 0.2, 0.05)
		
		field.material_override = field_material
		
		# Добавляем коллизию для поля
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(25, 0.5, 25)
		collision_shape.shape = box_shape
		collision_shape.position = Vector3(0, -0.25, 0)
		
		if not field.has_node("CollisionShape3D"):
			field.add_child(collision_shape)
		
		print("Поле боя создано")

func _setup_camera_and_lighting():
	# Настраиваем камеру для лучшего обзора
	if camera:
		camera.position = Vector3(0, 12, 15)
		camera.rotation_degrees = Vector3(-35, 0, 0)
		camera.fov = 60
		print("Камера настроена")
	
	# Настраиваем освещение
	if light:
		light.position = Vector3(5, 15, 10)
		light.rotation_degrees = Vector3(-45, -30, 0)
		light.light_energy = 1.2
		light.shadow_enabled = true
		print("Освещение настроено")

func _setup_throw_points():
	# Настраиваем точки броска
	if player_throw_point:
		player_throw_point.position = Vector3(0, 2, 8)
		print("Точка броска игрока:", player_throw_point.position)
	
	if enemy_throw_point:
		enemy_throw_point.position = Vector3(0, 2, -8)
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
	button_panel.size = Vector2(250, 300)
	button_panel.modulate = Color(0.2, 0.2, 0.2, 0.8)
	ui_container.add_child(button_panel)
	
	# Контейнер для кнопок
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(10, 10)
	button_container.size = Vector2(230, 280)
	button_panel.add_child(button_container)
	
	# Заголовок
	var title_label = Label.new()
	title_label.text = "Управление боем"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	button_container.add_child(title_label)
	
	# Разделитель
	var separator = HSeparator.new()
	button_container.add_child(separator)
	
	# Кнопка для броска
	throw_button = Button.new()
	throw_button.text = "🎯 Бросить бакугана"
	throw_button.add_theme_font_size_override("font_size", 14)
	throw_button.pressed.connect(_on_throw_button_pressed)
	button_container.add_child(throw_button)
	
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
	instructions.text = "\n⌨️ Горячие клавиши:\n• Space - Бросить\n• ↑ - Сменить\n• Esc - Выход"
	instructions.add_theme_font_size_override("font_size", 10)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	instructions.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button_container.add_child(instructions)
	
	print("UI создан")

func _spawn_bakugan(index: int):
	# Получаем данные о бакугане
	var bakugan_data = Global.get_bakugan_by_index(index)
	if not bakugan_data:
		print("ОШИБКА: Нет данных для бакугана с индексом", index)
		return
	
	print("Спавним бакугана:", bakugan_data.name)
	
	# Удаляем предыдущего бакугана
	_clear_spawned_bakugans()
	
	# Проверяем существование файлов
	var mesh_path = bakugan_data.mesh_path
	var texture_path = bakugan_data.texture_path
	
	if not ResourceLoader.exists(mesh_path):
		print("ОШИБКА: Модель не найдена:", mesh_path)
		_spawn_fallback_bakugan(bakugan_data.name)
		return
	
	# Загружаем модель
	var mesh_res = load(mesh_path)
	if not mesh_res:
		print("ОШИБКА: Не удалось загрузить модель:", mesh_path)
		_spawn_fallback_bakugan(bakugan_data.name)
		return
	
	# Создаем MeshInstance3D
	var bakugan_instance = MeshInstance3D.new()
	bakugan_instance.mesh = mesh_res
	bakugan_instance.name = bakugan_data.name
	
	# Позиционируем бакугана
	bakugan_instance.position = player_throw_point.global_transform.origin
	bakugan_instance.scale = Vector3(0.8, 0.8, 0.8)  # Немного уменьшаем размер
	
	# Загружаем и применяем текстуру
	_apply_texture_to_bakugan(bakugan_instance, texture_path)
	
	# Добавляем физику (RigidBody3D)
	var rigid_body = RigidBody3D.new()
	rigid_body.name = bakugan_data.name + "_Body"
	rigid_body.position = bakugan_instance.position
	rigid_body.gravity_scale = 0.5  # Уменьшаем гравитацию для более красивого полета
	rigid_body.mass = 1.0
	
	# Добавляем коллизию
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 1.0
	collision_shape.shape = sphere_shape
	rigid_body.add_child(collision_shape)
	
	# Перемещаем MeshInstance3D в RigidBody3D
	bakugan_instance.position = Vector3.ZERO
	rigid_body.add_child(bakugan_instance)
	
	# Добавляем в сцену
	bakugan_root.add_child(rigid_body)
	spawned_bakugans.append(rigid_body)
	
	# Обновляем UI
	_update_bakugan_ui()
	
	print("Бакуган", bakugan_data.name, "успешно заспавнен!")

func _spawn_fallback_bakugan(name: String):
	# Создаем простую сферу как запасной вариант
	print("Создаем запасного бакугана:", name)
	
	var fallback_mesh = SphereMesh.new()
	fallback_mesh.radius = 1.0
	fallback_mesh.height = 2.0
	
	var bakugan_instance = MeshInstance3D.new()
	bakugan_instance.mesh = fallback_mesh
	bakugan_instance.name = name
	bakugan_instance.position = player_throw_point.global_transform.origin
	
	# Создаем яркий материал
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.5, 0.0)  # Оранжевый
	material.emission_enabled = true
	material.emission = Color(0.3, 0.1, 0.0)
	material.metallic = 0.3
	material.roughness = 0.4
	bakugan_instance.material_override = material
	
	# Добавляем физику
	var rigid_body = RigidBody3D.new()
	rigid_body.name = name + "_Body"
	rigid_body.position = bakugan_instance.position
	rigid_body.gravity_scale = 0.5
	rigid_body.mass = 1.0
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 1.0
	collision_shape.shape = sphere_shape
	rigid_body.add_child(collision_shape)
	
	bakugan_instance.position = Vector3.ZERO
	rigid_body.add_child(bakugan_instance)
	
	bakugan_root.add_child(rigid_body)
	spawned_bakugans.append(rigid_body)
	
	_update_bakugan_ui()

func _apply_texture_to_bakugan(bakugan_instance: MeshInstance3D, texture_path: String):
	# Загружаем и применяем текстуру
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		if texture:
			var material = StandardMaterial3D.new()
			material.albedo_texture = texture
			material.metallic = 0.2
			material.roughness = 0.6
			material.emission_enabled = true
			material.emission = Color(0.1, 0.1, 0.1)
			
			# Применяем материал ко всем поверхностям
			var surface_count = bakugan_instance.mesh.get_surface_count()
			for surface_idx in range(surface_count):
				bakugan_instance.set_surface_override_material(surface_idx, material)
			
			print("Текстура применена:", texture_path)
		else:
			print("Предупреждение: Не удалось загрузить текстуру:", texture_path)
			_apply_default_material(bakugan_instance)
	else:
		print("Предупреждение: Текстура не найдена:", texture_path)
		_apply_default_material(bakugan_instance)

func _apply_default_material(bakugan_instance: MeshInstance3D):
	# Создаем красивый материал по умолчанию
	var default_material = StandardMaterial3D.new()
	default_material.albedo_color = Color(0.8, 0.6, 0.4)
	default_material.metallic = 0.3
	default_material.roughness = 0.5
	default_material.emission_enabled = true
	default_material.emission = Color(0.15, 0.1, 0.05)
	
	var surface_count = bakugan_instance.mesh.get_surface_count()
	for surface_idx in range(surface_count):
		bakugan_instance.set_surface_override_material(surface_idx, default_material)

func _clear_spawned_bakugans():
	# Удаляем всех заспавненных бакуганов
	for bakugan in spawned_bakugans:
		if bakugan and is_instance_valid(bakugan):
			bakugan.queue_free()
	spawned_bakugans.clear()

func _update_bakugan_ui():
	if bakugan_ui:
		var bakugan_data = Global.get_bakugan_by_index(current_bakugan_index)
		if bakugan_data:
			bakugan_ui.text = "🎯 Текущий бакуган:\n" + bakugan_data.name + "\n\n" + \
							  "📦 Набор: " + Global.selected_pack + "\n\n" + \
							  "🔢 Бакуган " + str(current_bakugan_index + 1) + " из " + str(Global.get_bakugan_count())

func _on_throw_button_pressed():
	if is_throwing:
		print("Бросок уже в процессе!")
		return
	
	if spawned_bakugans.size() == 0:
		print("Нет бакугана для броска!")
		return
	
	print("🎯 Бросаем бакугана!")
	_start_throw_animation()

func _start_throw_animation():
	is_throwing = true
	
	# Обновляем UI
	if throw_button:
		throw_button.text = "⏳ Бросаем..."
		throw_button.disabled = true
	
	if switch_button:
		switch_button.disabled = true
	
	# Получаем текущего бакугана
	var bakugan_body = spawned_bakugans[0]
	var bakugan_mesh = bakugan_body.get_child(1)  # MeshInstance3D
	
	# Отключаем физику на время анимации
	bakugan_body.freeze = true
	
	# Анимация броска
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Начальная и конечная позиция
	var start_pos = bakugan_body.position
	var end_pos = Vector3(0, 0.5, 0)  # Центр поля
	
	# Создаем параболическую траекторию
	var mid_pos = Vector3(
		(start_pos.x + end_pos.x) / 2,
		max(start_pos.y, end_pos.y) + THROW_HEIGHT,
		(start_pos.z + end_pos.z) / 2
	)
	
	# Анимируем движение по кривой
	tween.tween_method(_animate_throw_curve.bind(bakugan_body, start_pos, mid_pos, end_pos), 0.0, 1.0, THROW_DURATION)
	
	# Анимируем вращение
	tween.tween_method(_animate_throw_rotation.bind(bakugan_mesh), 0.0, 360.0 * 3, THROW_DURATION)
	
	# Завершение анимации
	tween.tween_callback(_on_throw_animation_complete.bind(bakugan_body))

func _animate_throw_curve(bakugan_body: RigidBody3D, start_pos: Vector3, mid_pos: Vector3, end_pos: Vector3, progress: float):
	# Квадратичная кривая Безье
	var pos = start_pos.lerp(mid_pos, progress).lerp(mid_pos.lerp(end_pos, progress), progress)
	bakugan_body.position = pos

func _animate_throw_rotation(bakugan_mesh: MeshInstance3D, rotation_degrees: float):
	bakugan_mesh.rotation_degrees = Vector3(rotation_degrees, rotation_degrees * 0.7, rotation_degrees * 0.5)

func _on_throw_animation_complete(bakugan_body: RigidBody3D):
	print("✅ Бросок завершен!")
	
	# Включаем физику обратно
	bakugan_body.freeze = false
	
	# Добавляем небольшой импульс для отскока
	bakugan_body.apply_central_impulse(Vector3(0, 2, 0))
	
	# Запускаем анимацию "открытия" бакугана
	_start_open_animation(bakugan_body)
	
	# Обновляем UI
	if throw_button:
		throw_button.text = "🎯 Бросить бакугана"
		throw_button.disabled = false
	
	if switch_button:
		switch_button.disabled = false
	
	is_throwing = false

func _start_open_animation(bakugan_body: RigidBody3D):
	if is_bakugan_open:
		return
	
	is_bakugan_open = true
	print("🌟 Бакуган открывается!")
	
	# Получаем MeshInstance3D
	var bakugan_mesh = bakugan_body.get_child(1)
	
	# Эффект открытия - увеличиваем размер и добавляем вращение
	var open_tween = create_tween()
	open_tween.set_parallel(true)
	
	# Увеличиваем размер
	open_tween.tween_property(bakugan_mesh, "scale", Vector3(1.5, 1.5, 1.5), 0.8)
	
	# Добавляем световой эффект
	var material = bakugan_mesh.get_active_material(0)
	if material:
		var original_emission = material.emission
		open_tween.tween_method(_animate_emission.bind(material, original_emission), 0.0, 1.0, 0.8)
	
	# Завершение открытия
	open_tween.tween_callback(_on_open_animation_complete)

func _animate_emission(material: StandardMaterial3D, original_emission: Color, progress: float):
	var emission_strength = sin(progress * PI * 4) * 0.3 + 0.2
	material.emission = original_emission + Color(emission_strength, emission_strength, emission_strength)

func _on_open_animation_complete():
	print("🎉 Бакуган полностью открыт!")
	# Здесь можно добавить дополнительные эффекты или логику боя

func _on_switch_bakugan_pressed():
	if is_throwing:
		print("Нельзя переключать бакугана во время броска!")
		return
	
	# Переключаемся на следующего бакугана
	current_bakugan_index = (current_bakugan_index + 1) % Global.get_bakugan_count()
	is_bakugan_open = false
	_spawn_bakugan(current_bakugan_index)
	
	print("🔄 Переключились на бакугана:", current_bakugan_index + 1)

func _on_back_to_menu_pressed():
	print("🏠 Возвращаемся в главное меню")
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _input(event):
	# Управление с клавиатуры
	if event.is_action_pressed("ui_accept"):  # Enter или Space
		if not is_throwing:
			_on_throw_button_pressed()
	elif event.is_action_pressed("ui_up"):  # Стрелка вверх
		if not is_throwing:
			_on_switch_bakugan_pressed()
	elif event.is_action_pressed("ui_cancel"):  # Escape
		_on_back_to_menu_pressed()

func _process(delta):
	# Простое вращение бакугана в режиме ожидания
	if not is_throwing and spawned_bakugans.size() > 0:
		var bakugan_body = spawned_bakugans[0]
		if bakugan_body and is_instance_valid(bakugan_body):
			var bakugan_mesh = bakugan_body.get_child(1)
			if bakugan_mesh and not is_bakugan_open:
				bakugan_mesh.rotate_y(delta * 0.5)  # Медленное вращение
