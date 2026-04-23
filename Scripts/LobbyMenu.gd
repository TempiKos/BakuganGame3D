extends Control

@onready var status_label = $Panel/VBox/StatusLabel
@onready var ip_input = $Panel/VBox/IPInput
@onready var host_btn = $Panel/VBox/HostButton
@onready var join_btn = $Panel/VBox/JoinButton
@onready var back_btn = $Panel/VBox/BackButton
@onready var player_name_input = $Panel/VBox/PlayerNameInput
@onready var players_list = $Panel/VBox/PlayersList
@onready var start_btn = $Panel/VBox/StartButton

func _ready():
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	start_btn.visible = false
	player_name_input.text = Global.player_name
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)
	NetworkManager.game_ready.connect(_on_game_ready)
	_update_players_list()
	_set_status("Введите IP RadminVPN и нажмите Создать или Присоединиться")

func _on_host_pressed():
	_apply_name()
	var err = NetworkManager.create_server()
	if err != OK:
		_set_status("Ошибка создания сервера: %d" % err)
		return
	_set_status("Ожидание второго игрока...")
	host_btn.disabled = true
	join_btn.disabled = true
	ip_input.editable = false
	_update_players_list()

func _on_join_pressed():
	_apply_name()
	var ip = ip_input.text.strip_edges()
	if ip == "":
		_set_status("Введите IP адресс хоста!")
		return
	var err = NetworkManager.join_server(ip)
	if err != OK:
		_set_status("Ошибка подключения: %d" % err)
		return
	_set_status("Подключение к %s..." % ip)
	host_btn.disabled = true
	join_btn.disabled = true
	ip_input.editable = false

func _on_back_pressed():
	NetworkManager.disconnect_network()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_start_pressed():
	if not NetworkManager.is_host:
		return
	if Global.selected_pack == "":
		_set_status("Сначала выберите набор!")
		return
	NetworkManager.sync_pack_selection()
	rpc("_start_battle")

@rpc("call_local")
func _start_battle():
	get_tree().change_scene_to_file("res://Scenes/BattleScene.tscn")

func _on_player_connected(_id: int):
	_set_status("Игрок подключается!")
	_update_players_list()
	if NetworkManager.is_host:
		start_btn.visible = true

func _on_player_disconnected(_id: int):
	_set_status("Игрок отключился.")
	start_btn.visible = false
	_update_players_list()

func _on_server_disconnected():
	_set_status("Сервер отключился.")
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_game_ready():
	_set_status("Все готовы! Начинаем...")

func _apply_name():
	var nm = player_name_input.text.strip_edges()
	if nm == "":
		nm = "Player"
	Global.player_name = nm
	NetworkManager.local_player_info["name"] = nm

func _update_players_list():
	var text = "Игроки в лобби:\n"
	for pid in NetworkManager.players:
		var info = NetworkManager.players[pid]
		var marker = " *" if pid == NetworkManager.my_peer_id else ""
		text += "  - %s%s\n" % [info.get("name", "Player"), marker]
	if NetworkManager.players.is_empty():
		text += "  (...)\n"
	players_list.text = text

func _set_status(msg: String):
	status_label.text = msg
