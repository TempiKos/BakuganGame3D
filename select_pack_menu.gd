extends Control

func _ready():
	# Подключаем все кнопки
	$PyrusButton.pressed.connect(_on_pyrus_button_pressed)
	# Раскомментируйте, когда добавите остальные кнопки
	#$VentusButton.pressed.connect(_on_ventus_button_pressed)
	#$SubterraButton.pressed.connect(_on_subterra_button_pressed)
	#$AquasButton.pressed.connect(_on_aquas_button_pressed)
	#$HaosButton.pressed.connect(_on_haos_button_pressed)
	#$DarkusButton.pressed.connect(_on_darkus_button_pressed)
	
	print("Меню выбора пака загружено")

func _on_pyrus_button_pressed():
	print("Нажата кнопка PYRUS")
	_select_pack("Огненный")

func _on_ventus_button_pressed():
	print("Нажата кнопка VENTUS")
	_select_pack("Воздушный")

func _on_subterra_button_pressed():
	print("Нажата кнопка SUBTERRA")
	_select_pack("Земляной")

func _on_aquas_button_pressed():
	print("Нажата кнопка AQUAS")
	_select_pack("Водный")

func _on_haos_button_pressed():
	print("Нажата кнопка HAOS")
	_select_pack("Светлый")

func _on_darkus_button_pressed():
	print("Нажата кнопка DARKUS")
	_select_pack("Тёмный")

func _select_pack(pack_name: String):
	# Проверяем, что такой пак существует
	if not Global.bakugan_packs.has(pack_name):
		print("ОШИБКА: Неизвестный пак:", pack_name)
		return
	
	# Устанавливаем выбранный пак
	Global.selected_pack = pack_name
	Global.selected_bakugan_set = Global.bakugan_packs[pack_name]
	
	print("Установлен Global.selected_pack:", Global.selected_pack)
	print("Выбранный набор содержит", Global.selected_bakugan_set.size(), "бакуганов:")
	
	# Выводим информацию о бакуганах в наборе
	for i in range(Global.selected_bakugan_set.size()):
		var bakugan = Global.selected_bakugan_set[i]
		print(" -", bakugan.name)
	
	# Переходим к сцене предварительного просмотра
	get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")

# Функция для быстрого тестирования (можно вызвать из кода)
func test_select_pack():
	print("=== ТЕСТ ВЫБОРА ПАКА ===")
	_select_pack("Огненный")
