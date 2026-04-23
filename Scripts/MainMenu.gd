extends Control

func _ready():
	# Если профиль не создан — отправляем на регистрацию
	if not Global.has_profile():
		get_tree().change_scene_to_file("res://Scenes/RegisterScreen.tscn")
		return

	$Panel/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$Panel/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$Panel/VBoxContainer/SelectPackButton.pressed.connect(_on_select_pack_pressed)
	$Panel/VBoxContainer/LearningButton.pressed.connect(_on_learning_pressed)
	$Panel/VBoxContainer/MultiplayerButton.pressed.connect(_on_multiplayer_pressed)
	$Panel/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	$NoPackLabel.visible = false

	# Показываем подсказку о прогрессе обучения
	_update_learning_hint()

func _update_learning_hint() -> void:
	var completed = LearningData.get_completed_count()
	var total     = LearningData.topics.size()
	var btn       = $Panel/VBoxContainer/LearningButton
	if completed == total:
		btn.text = "📚 Обучение  ✅"
	else:
		btn.text = "📚 Обучение  (%d/%d)" % [completed, total]

func _on_start_pressed():
	if Global.selected_pack == "":
		$NoPackLabel.visible = true
		return
	$NoPackLabel.visible = false
	if multiplayer.multiplayer_peer:
		NetworkManager.disconnect_network()
	get_tree().change_scene_to_file("res://Scenes/BattleScene.tscn")

func _on_multiplayer_pressed():
	if Global.selected_pack == "":
		$NoPackLabel.visible = true
		return
	$NoPackLabel.visible = false
	get_tree().change_scene_to_file("res://Scenes/LobbyMenu.tscn")

func _on_settings_pressed():
	print("Настройки еще не реализованы")

func _on_select_pack_pressed():
	get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn")

func _on_learning_pressed():
	get_tree().change_scene_to_file("res://Scenes/LearningMenu.tscn")

func _on_exit_pressed():
	get_tree().quit()
