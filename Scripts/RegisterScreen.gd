extends Control

# Экран регистрации — показывается только при первом запуске
# После ввода ника сохраняет профиль и переходит на главное меню

@onready var nick_input = $Panel/VBox/NickInput
@onready var confirm_btn = $Panel/VBox/ConfirmButton
@onready var error_label = $Panel/VBox/ErrorLabel

func _ready():
	error_label.visible = false
	nick_input.grab_focus()
	confirm_btn.pressed.connect(_on_confirm_pressed)
	nick_input.text_submitted.connect(_on_text_submitted)

func _on_text_submitted(_text: String):
	_on_confirm_pressed()

func _on_confirm_pressed():
	var nick = nick_input.text.strip_edges()
	if nick.length() < 2:
		error_label.text = "Ник должен быть не короче 2 символов!"
		error_label.visible = true
		return
	if nick.length() > 20:
		error_label.text = "Ник не должен превышать 20 символов!"
		error_label.visible = true
		return
	Global.player_name = nick
	Global.save_profile()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
