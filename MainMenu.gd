extends Control

func _ready():
	$Panel/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$Panel/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$Panel/VBoxContainer/SelectPackButton.pressed.connect(_on_select_pack_pressed)
	$Panel/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://BattleScene.tscn")

func _on_settings_pressed():
	print("Настройки еще не реализованы")

func _on_select_pack_pressed():
	get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn")

func _on_exit_pressed():
	get_tree().quit()
