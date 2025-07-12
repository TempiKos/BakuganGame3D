extends Node3D

# Структура для хранения данных о наборах
var pack_data = {
	"Огненный": {
		"models": [
			{
				"mesh_path": "res://closed_obj/5DCE4AA322A1EE89835AF205F36DC641DA59B16E_Saurus Closed.obj",
				"texture_path": "res://TexturesBakugans/BF1CBB1F3B2434C729A43BFD7CA68AD94AA29AC4_saurus pyrus hd.png",
				"name": "Saurus",
				"power": 450
			},
			{
				"mesh_path": "res://closed_obj/EB579F93B7C6EEF17E44E0EB82E020246903C408_Centipoid closed.obj",
				"texture_path": "res://TexturesBakugans/E74E0BC47084CD6AB00005FF2980F455F58F3E26_Pyrus Centipoid HD.jpg",
				"name": "Centipoid",
				"power": 400
			},
			{
				"mesh_path": "res://closed_obj/12FFEE5D3A688D036EF6F63F79F0C81ACDF66D8D_Gargonoid Closed.obj",
				"texture_path": "res://TexturesBakugans/17D1D566D43C9BE453499D62CB17B01173B0D8EA_Pyrus Gargonoid HD.jpg",
				"name": "Gargonoid",
				"power": 350
			}
		]
	},
	"Водный": {
		"models": [
			{
				"mesh_path": "res://closed_obj/0CACCD4FB6242061D2120D23FD01231A5952B1F7_Vladitor_Closed.obj",
				"texture_path": "res://TexturesBakugans/aquas_texture_1.png",
				"name": "Vladitor",
				"power": 420
			},
			{
				"mesh_path": "res://closed_obj/aquas_model_2.obj",
				"texture_path": "res://TexturesBakugans/aquas_texture_2.png",
				"name": "Aquas Bakugan 2",
				"power": 380
			},
			{
				"mesh_path": "res://closed_obj/aquas_model_3.obj",
				"texture_path": "res://TexturesBakugans/aquas_texture_3.png",
				"name": "Aquas Bakugan 3",
				"power": 340
			}
		]
	},
	"Тёмный": {
		"models": [
			{
				"mesh_path": "res://closed_obj/0CF7F255F90305138E755C576E1B51767995DE91_Exedra_Closed.obj",
				"texture_path": "res://TexturesBakugans/0686FC1CC6213289C6010C346921E5D4FB49842E_Darkus Vladitor HD.png",
				"name": "Exedra",
				"power": 480
			},
			{
				"mesh_path": "res://closed_obj/darkus_model_2.obj",
				"texture_path": "res://TexturesBakugans/darkus_texture_2.png",
				"name": "Darkus Bakugan 2",
				"power": 410
			},
			{
				"mesh_path": "res://closed_obj/darkus_model_3.obj",
				"texture_path": "res://TexturesBakugans/darkus_texture_3.png",
				"name": "Darkus Bakugan 3",
				"power": 360
			}
		]
	}
}

# Массив для хранения всех MeshInstance3D
var mesh_instances = []
var rotation_timers = []
var loaded_models = []
var model_labels = []  # Для отображения имен и характеристик

func _ready():
	# Подключаем кнопки
	$VBoxContainer/ConfirmButton.pressed.connect(_on_confirm_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Получаем ссылки на MeshInstance3D узлы
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
	
	# Создаем лейблы для отображения информации о бакуганах
	_create_model_labels()
	
	# Загружаем выбранный набор
	_load_selected_pack()

func _create_model_labels():
	# Создаем лейблы для каждой модели
	for i in range(3):
		var label = Label.new()
		label.text = "Модель " + str(i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		
		# Позиционируем лейблы под соответствующими моделями
		match i:
			0:
				label.position = Vector2(50, 350)
				label.size = Vector2(200, 50)
			1:
				label.position = Vector2(get_viewport().size.x / 2 - 100, 350)
				label.size = Vector2(200, 50)
			2:
				label.position = Vector2(get_viewport().size.x - 250, 350)
				label.size = Vector2(200, 50)
		
		add_child(label)
		model_labels.append(label)

func _load_selected_pack():
	var selected_pack = Global.selected_pack if Global.selected_pack != "" else "Огненный"
	print("Загружаем набор:", selected_pack)
	
	# Проверяем, есть ли данные для этого набора
	if not pack_data.has(selected_pack):
		print("ОШИБКА: Неизвестный набор:", selected_pack)
		return
	
	var pack_models = pack_data[selected_pack]["models"]
	
	# Проверяем, что у нас есть достаточно моделей и MeshInstance3D
	var models_count = min(pack_models.size(), mesh_instances.size())
	
	print("Загружаем", models_count, "моделей для набора:", selected_pack)
	
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
			
			# Обновляем информацию о модели
			if i < model_labels.size():
				model_labels[i].text = model_data["name"] + "\nМощность: " + str(model_data["power"])
			
			print("Модель", i + 1, "успешно загружена и показана")
		else:
			mesh_instance.visible = false
			if i < model_labels.size():
				model_labels[i].text = "Не удалось загрузить"
			print("Не удалось загрузить модель", i + 1)
	
	# Обновляем заголовок - используем правильный путь к лейблу
	var title_label = $"VBoxContainer/Выбери набор"
	if title_label:
		title_label.text = "Набор: " + selected_pack + " (" + str(loaded_models.size()) + " бакуганов)"
	
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
	print("Набор подтвержден:", Global.selected_pack)
	print("Переходим в боевую сцену")
	get_tree().change_scene_to_file("res://Scenes/BattleScene.tscn")

func _on_back_pressed():
	print("Возврат к выбору элемента")
	get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn")
