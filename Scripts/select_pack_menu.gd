extends Control

func _ready():
	# Подключаем все кнопки
	$PyrusButton.pressed.connect(_on_pyrus_button_pressed)
	#$VentusButton.pressed.connect(_on_ventus_button_pressed)
	#$SubterraButton.pressed.connect(_on_subterra_button_pressed)
	#$AquasButton.pressed.connect(_on_aquas_button_pressed)
	#$HaosButton.pressed.connect(_on_haos_button_pressed)
	#$DarkusButton.pressed.connect(_on_darkus_button_pressed)

func _on_pyrus_button_pressed():
	print("Нажата кнопка PYRUS")
	Global.selected_pack = "Огненный"
	print("Установлен Global.selected_pack:", Global.selected_pack)
	print("Переключаемся на SelectPackScene...")
	get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")

#func _on_ventus_button_pressed():
	#print("Нажата кнопка VENTUS")
	#Global.selected_pack = "Воздушный"
	#get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")
#
#func _on_subterra_button_pressed():
	#print("Нажата кнопка SUBTERRA")
	#Global.selected_pack = "Земляной"
	#get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")
#
#func _on_aquas_button_pressed():
	#print("Нажата кнопка AQUAS")
	#Global.selected_pack = "Водный"
	#get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")
#
#func _on_haos_button_pressed():
	#print("Нажата кнопка HAOS")
	#Global.selected_pack = "Светлый"
	#get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")
#
#func _on_darkus_button_pressed():
	#print("Нажата кнопка DARKUS")
	#Global.selected_pack = "Тёмный"
	#get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")
