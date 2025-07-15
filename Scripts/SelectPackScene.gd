extends Node3D

# Структура для хранения данных о наборах
# Каждый набор теперь содержит несколько подборов по 3 модели
var pack_data = {
	"Огненный": {
		"sub_packs": {
			"Набор 1": {
				"models": [
					{
						"mesh_path": "res://closed_obj/5DCE4AA322A1EE89835AF205F36DC641DA59B16E_Saurus Closed.obj",
						"texture_path": "res://TexturesBakugans/Pyrus/BF1CBB1F3B2434C729A43BFD7CA68AD94AA29AC4_saurus pyrus hd.png"
					},
					{
						"mesh_path": "res://closed_obj/EB579F93B7C6EEF17E44E0EB82E020246903C408_Centipoid closed.obj",
						"texture_path": "res://TexturesBakugans/Pyrus/E74E0BC47084CD6AB00005FF2980F455F58F3E26_Pyrus Centipoid HD.jpg"
					},
					{
						"mesh_path": "res://closed_obj/12FFEE5D3A688D036EF6F63F79F0C81ACDF66D8D_Gargonoid Closed.obj",
						"texture_path": "res://TexturesBakugans/Pyrus/17D1D566D43C9BE453499D62CB17B01173B0D8EA_Pyrus Gargonoid HD.jpg"
					}
				]
			},
			"Набор 2": {
				"models": [
					{
						"mesh_path": "res://closed_obj/pyrus_model_4.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_4.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_5.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_5.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_6.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_6.png"
					}
				]
			},
			"Набор 3": {
				"models": [
					{
						"mesh_path": "res://closed_obj/pyrus_model_7.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_7.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_8.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_8.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_9.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_9.png"
					}
				]
			},
			"Набор 4": {
				"models": [
					{
						"mesh_path": "res://closed_obj/pyrus_model_10.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_10.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_11.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_11.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_12.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_12.png"
					}
				]
			},
			"Набор 5": {
				"models": [
					{
						"mesh_path": "res://closed_obj/pyrus_model_13.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_13.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_14.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_14.png"
					},
					{
						"mesh_path": "res://closed_obj/pyrus_model_15.obj",
						"texture_path": "res://TexturesBakugans/pyrus_texture_15.png"
					}
				]
			}
		}
	},
	"Воздушный": {
		"models": [
			{
				"mesh_path": "res://closed_obj/ventus_model_1.obj",
				"texture_path": "res://TexturesBakugans/ventus_texture_1.png"
			},
			{
				"mesh_path": "res://closed_obj/ventus_model_2.obj",
				"texture_path": "res://TexturesBakugans/ventus_texture_2.png"
			},
			{
				"mesh_path": "res://closed_obj/ventus_model_3.obj",
				"texture_path": "res://TexturesBakugans/ventus_texture_3.png"
			}
		]
	},
	"Земляной": {
		"models": [
			{
				"mesh_path": "res://closed_obj/subterra_model_1.obj",
				"texture_path": "res://TexturesBakugans/subterra_texture_1.png"
			},
			{
				"mesh_path": "res://closed_obj/subterra_model_2.obj",
				"texture_path": "res://TexturesBakugans/subterra_texture_2.png"
			},
			{
				"mesh_path": "res://closed_obj/subterra_model_3.obj",
				"texture_path": "res://TexturesBakugans/subterra_texture_3.png"
			}
		]
	},
	"Водный": {
		"models": [
			{
				"mesh_path": "res://closed_obj/0CACCD4FB6242061D2120D23FD01231A5952B1F7_Vladitor_Closed.obj",
				"texture_path": "res://TexturesBakugans/aquas_texture_1.png"
			},
			{
				"mesh_path": "res://closed_obj/aquas_model_2.obj",
				"texture_path": "res://TexturesBakugans/aquas_texture_2.png"
			},
			{
				"mesh_path": "res://closed_obj/aquas_model_3.obj",
				"texture_path": "res://TexturesBakugans/aquas_texture_3.png"
			}
		]
	},
	"Светлый": {
		"models": [
			{
				"mesh_path": "res://closed_obj/haos_model_1.obj",
				"texture_path": "res://TexturesBakugans/haos_texture_1.png"
			},
			{
				"mesh_path": "res://closed_obj/haos_model_2.obj",
				"texture_path": "res://TexturesBakugans/haos_texture_2.png"
			},
			{
				"mesh_path": "res://closed_obj/haos_model_3.obj",
				"texture_path": "res://TexturesBakugans/haos_texture_3.png"
			}
		]
	},
	"Тёмный": {
		"models": [
			{
				"mesh_path": "res://closed_obj/0CF7F255F90305138E755C576E1B51767995DE91_Exedra_Closed.obj",
				"texture_path": "res://TexturesBakugans/0686FC1CC6213289C6010C346921E5D4FB49842E_Darkus Vladitor HD.png"
			},
			{
				"mesh_path": "res://closed_obj/darkus_model_2.obj",
				"texture_path": "res://TexturesBakugans/darkus_texture_2.png"
			},
			{
				"mesh_path": "res://closed_obj/darkus_model_3.obj",
				"texture_path": "res://TexturesBakugans/darkus_texture_3.png"
			}
		]
	}
}

# Массив для хранения всех MeshInstance3D
var mesh_instances = []
var rotation_timers = []
var loaded_models = []  # Массив для отслеживания загруженных моделей

# Переменные для управления подборами
var current_selected_pack = ""
var current_sub_pack = ""
var sub_pack_buttons = []
var sub_pack_container = null

func _ready():
	# Подключаем кнопки
	$VBoxContainer/ConfirmButton.pressed.connect(_on_confirm_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Получаем ссылки на MeshInstance3D узлы в правильном порядке согласно структуре сцены
	mesh_instances = [
		$SubViewportContainer/SubViewport/Preview3D/MeshInstance3D_1,
		$SubViewportContainer2/SubViewport/Preview3D/MeshInstance3D_2,
		$SubViewportContainer3/SubViewport/Preview3D/MeshInstance3D_3
	]
	
	# Получаем ссылки на таймеры вращения
	rotation_timers = [
		$SubViewportContainer/SubViewport/Preview3D/RotationTimer,
		$SubViewportContainer2/SubViewport/Preview3D/RotationTimer,
		$SubViewportContainer3/SubViewport/Preview3D/RotationTimer
	]
	
	# Подключаем каждый таймер к своей функции вращения
	for i in range(rotation_timers.size()):
		rotation_timers[i].timeout.connect(_on_rotation_timer_timeout.bind(i))
	
	# Настраиваем кнопки
	setup_buttons()
	
	# Загружаем выбранный набор
	_load_selected_pack()

func _load_selected_pack():
	current_selected_pack = Global.selected_pack if Global else "Огненный"
	print("Загружаем набор:", current_selected_pack)
	
	# Проверяем, что selected_pack не пустой
	if current_selected_pack == "":
		print("ОШИБКА: selected_pack пустой! Используем Огненный набор по умолчанию")
		current_selected_pack = "Огненный"
	
	# Проверяем, есть ли данные для этого набора
	if not pack_data.has(current_selected_pack):
		print("ОШИБКА: Неизвестный набор:", current_selected_pack)
		return
	
	# Создаем интерфейс для выбора подборов если это "Огненный" набор
	if current_selected_pack == "Огненный":
		_create_sub_pack_interface()
		# Загружаем первый подбор по умолчанию
		var first_sub_pack = pack_data[current_selected_pack]["sub_packs"].keys()[0]
		_load_sub_pack(first_sub_pack)
	else:
		# Для других наборов загружаем как раньше
		_hide_sub_pack_interface()
		_load_regular_pack()

func _create_sub_pack_interface():
	# Создаем контейнер для кнопок подборов, если его еще нет
	if sub_pack_container == null:
		sub_pack_container = HBoxContainer.new()
		sub_pack_container.name = "SubPackContainer"
		
		# Вставляем контейнер перед кнопками подтверждения
		$VBoxContainer.add_child(sub_pack_container)
		$VBoxContainer.move_child(sub_pack_container, 1)  # После лейбла, перед кнопками
		
		# Добавляем отступ
		sub_pack_container.add_theme_constant_override("separation", 10)
	
	# Очищаем старые кнопки
	_clear_sub_pack_buttons()
	
	# Создаем кнопки для каждого подбора
	var sub_packs = pack_data[current_selected_pack]["sub_packs"]
	for sub_pack_name in sub_packs.keys():
		var button = Button.new()
		button.text = sub_pack_name
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(_on_sub_pack_button_pressed.bind(sub_pack_name))
		
		sub_pack_container.add_child(button)
		sub_pack_buttons.append(button)
	
	# Выделяем первую кнопку как активную
	if sub_pack_buttons.size() > 0:
		current_sub_pack = sub_packs.keys()[0]
		_update_sub_pack_button_styles()

func _hide_sub_pack_interface():
	if sub_pack_container:
		sub_pack_container.visible = false

func _clear_sub_pack_buttons():
	for button in sub_pack_buttons:
		if button:
			button.queue_free()
	sub_pack_buttons.clear()

func _on_sub_pack_button_pressed(sub_pack_name: String):
	print("Выбран подбор:", sub_pack_name)
	current_sub_pack = sub_pack_name
	_update_sub_pack_button_styles()
	_load_sub_pack(sub_pack_name)

func _update_sub_pack_button_styles():
	# Обновляем стили кнопок (выделяем активную)
	for button in sub_pack_buttons:
		if button.text == current_sub_pack:
			button.modulate = Color(0.8, 1.0, 0.8)  # Светло-зеленый для активной кнопки
		else:
			button.modulate = Color.WHITE  # Обычный цвет для неактивных

func _load_sub_pack(sub_pack_name: String):
	if not pack_data[current_selected_pack]["sub_packs"].has(sub_pack_name):
		print("ОШИБКА: Неизвестный подбор:", sub_pack_name)
		return
	
	var pack_models = pack_data[current_selected_pack]["sub_packs"][sub_pack_name]["models"]
	_load_models(pack_models)

func _load_regular_pack():
	var pack_models = pack_data[current_selected_pack]["models"]
	_load_models(pack_models)

func _load_models(pack_models: Array):
	# Проверяем, что у нас есть достаточно моделей и MeshInstance3D
	var models_count = min(pack_models.size(), mesh_instances.size())
	
	print("Загружаем", models_count, "моделей")
	
	# Очищаем предыдущие данные
	loaded_models.clear()
	
	# Загружаем все модели из набора
	for i in range(models_count):
		var model_data = pack_models[i]
		var mesh_instance = mesh_instances[i]
		
		print("Загружаем модель", i + 1, ":", model_data["mesh_path"])
		
		# Загружаем модель и текстуру
		var success = _load_mesh_and_texture(mesh_instance, model_data["mesh_path"], model_data["texture_path"])
		
		if success:
			mesh_instance.visible = true
			loaded_models.append(mesh_instance)
			print("Модель", i + 1, "успешно загружена и показана")
		else:
			mesh_instance.visible = false
			print("Не удалось загрузить модель", i + 1)
	
	print("Всего загружено моделей:", loaded_models.size())

func _load_mesh_and_texture(mesh_instance: MeshInstance3D, mesh_path: String, texture_path: String) -> bool:
	var success = false
	
	# Загружаем модель
	if ResourceLoader.exists(mesh_path):
		print("Файл модели найден:", mesh_path)
		var mesh_res = load(mesh_path)
		if mesh_res:
			mesh_instance.mesh = mesh_res
			print("Модель успешно установлена!")
			success = true
			
			# Загружаем и применяем текстуру
			if ResourceLoader.exists(texture_path):
				print("Загружаем текстуру:", texture_path)
				var texture = load(texture_path)
				if texture:
					var material = StandardMaterial3D.new()
					material.albedo_texture = texture
					material.metallic = 0.0
					material.roughness = 0.5
					
					# Применяем материал ко всем поверхностям модели
					var surface_count = mesh_instance.mesh.get_surface_count()
					for surface_idx in range(surface_count):
						mesh_instance.set_surface_override_material(surface_idx, material)
					
					print("Текстура применена!")
				else:
					print("ОШИБКА: Не удалось загрузить текстуру:", texture_path)
			else:
				print("Предупреждение: Текстура не найдена:", texture_path)
				# Создаем материал по умолчанию
				var default_material = StandardMaterial3D.new()
				default_material.albedo_color = Color(0.8, 0.8, 0.8)
				default_material.metallic = 0.1
				default_material.roughness = 0.7
				
				var surface_count = mesh_instance.mesh.get_surface_count()
				for surface_idx in range(surface_count):
					mesh_instance.set_surface_override_material(surface_idx, default_material)
		else:
			print("ОШИБКА: Не удалось загрузить mesh из файла:", mesh_path)
	else:
		print("ОШИБКА: Файл модели не найден:", mesh_path)
	
	return success

func _on_rotation_timer_timeout(index: int):
	# Вращаем соответствующую модель
	if index < mesh_instances.size() and index < loaded_models.size():
		var mesh_instance = mesh_instances[index]
		if mesh_instance and mesh_instance.visible:
			mesh_instance.rotate_y(deg_to_rad(1.0))

func _on_confirm_pressed():
	# Сохраняем выбранную стихию и набор
	if Global:
		Global.selected_pack = current_selected_pack
		
		# Сохраняем выбранный подбор для огненного набора
		if current_selected_pack == "Огненный" and current_sub_pack != "":
			Global.selected_sub_pack = current_sub_pack
			print("Набор подтвержден:", current_selected_pack, "- подбор:", current_sub_pack)
		else:
			# Для других стихий сбрасываем подбор
			Global.selected_sub_pack = ""
			print("Набор подтвержден:", current_selected_pack)
		
		# Можно добавить дополнительные данные для сохранения
		print("Сохранено в Global:")
		print("- Стихия:", Global.selected_pack)
		print("- Подбор:", Global.selected_sub_pack)
	else:
		print("ОШИБКА: Global не найден!")
	
	# Переходим к следующему экрану (можно изменить на нужную сцену)
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_back_pressed():
	print("Возврат к выбору стихии")
	# Переходим обратно к сцене выбора стихии
	get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn")

# Функция для настройки кнопок
func setup_buttons():
	# Настраиваем кнопки
	var confirm_button = $VBoxContainer/ConfirmButton
	var back_button = $VBoxContainer/BackButton
	
	# Устанавливаем текст кнопок
	confirm_button.text = "Подтвердить"
	back_button.text = "Назад"

# Функция для остановки/запуска вращения
func toggle_rotation(enable: bool):
	for timer in rotation_timers:
		if enable:
			timer.start()
		else:
			timer.stop()

# Функция для загрузки конкретного набора моделей
func load_pack_models(pack_name: String):
	if not pack_data.has(pack_name):
		print("ОШИБКА: Неизвестный набор:", pack_name)
		return
	
	if Global:
		Global.selected_pack = pack_name
	current_selected_pack = pack_name
	_load_selected_pack()

# Функция для ручного назначения модели и текстуры конкретному MeshInstance3D
func assign_mesh_to_instance(instance_index: int, mesh_path: String, texture_path: String):
	if instance_index < 0 or instance_index >= mesh_instances.size():
		print("ОШИБКА: Неверный индекс MeshInstance3D:", instance_index)
		return
	
	var mesh_instance = mesh_instances[instance_index]
	var success = _load_mesh_and_texture(mesh_instance, mesh_path, texture_path)
	
	if success:
		mesh_instance.visible = true
		# Добавляем в список загруженных моделей, если её там нет
		if not loaded_models.has(mesh_instance):
			loaded_models.append(mesh_instance)
	else:
		mesh_instance.visible = false
		# Убираем из списка загруженных моделей
		if loaded_models.has(mesh_instance):
			loaded_models.erase(mesh_instance)

# Функция для получения количества загруженных моделей
func get_loaded_models_count() -> int:
	return loaded_models.size()

# Функция для получения текущего выбранного подбора
func get_current_sub_pack() -> String:
	return current_sub_pack

# Функция для программного выбора подбора
func select_sub_pack(sub_pack_name: String):
	if current_selected_pack == "Огненный" and pack_data[current_selected_pack]["sub_packs"].has(sub_pack_name):
		current_sub_pack = sub_pack_name
		_update_sub_pack_button_styles()
		_load_sub_pack(sub_pack_name)
	else:
		print("ОШИБКА: Невозможно выбрать подбор", sub_pack_name)
