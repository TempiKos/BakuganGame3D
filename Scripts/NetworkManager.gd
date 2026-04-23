extends Node

# ─────────────────────────────────────────────────────────────
# NetworkManager — одиночный узел (Autoload)
# Управляет подключением, ролями и синхронизацией игрового состояния
# Работает через RadminVPN (виртуальная LAN-сеть ENet)
# ─────────────────────────────────────────────────────────────

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal server_disconnected()
signal game_ready()           # оба игрока подключились и выбрали наборы
signal action_received(action: Dictionary)

const PORT        = 7777
const MAX_PLAYERS = 2

# Данные локального игрока, которые отправляются другому
var local_player_info := {
	"name":          "Player",
	"selected_pack": "",
	"selected_sub_pack": ""
}

# Данные обоих игроков: { peer_id: { name, selected_pack, ... } }
var players := {}

# peer_id == 1 → хост / сервер
var is_host: bool = false
var my_peer_id: int = 0

# ─────────────────────────────────────────────────────────────
func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ─────────────────────────────────────────────────────────────
# СОЗДАТЬ / ПРИСОЕДИНИТЬСЯ
# ─────────────────────────────────────────────────────────────

func create_server() -> Error:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	is_host = true
	my_peer_id = 1
	# Хост сам себя добавляет в список
	players[1] = local_player_info.duplicate()
	print("[Net] Сервер создан на порту %d" % PORT)
	return OK

func join_server(ip: String) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, PORT)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	is_host = false
	print("[Net] Подключение к %s:%d..." % [ip, PORT])
	return OK

func disconnect_network():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	players.clear()
	is_host = false
	my_peer_id = 0

# ─────────────────────────────────────────────────────────────
# CALLBACKS MULTIPLAYER
# ─────────────────────────────────────────────────────────────

func _on_peer_connected(id: int):
	print("[Net] Пир подключился: %d" % id)
	# Посылаем новому пиру наши данные
	_send_player_info.rpc_id(id, local_player_info)
	player_connected.emit(id)

func _on_peer_disconnected(id: int):
	print("[Net] Пир отключился: %d" % id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	my_peer_id = multiplayer.get_unique_id()
	print("[Net] Успешно подключились, peer_id = %d" % my_peer_id)
	# Сообщаем серверу наши данные
	_send_player_info.rpc_id(1, local_player_info)

func _on_connection_failed():
	print("[Net] Не удалось подключиться")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("[Net] Сервер отключился")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

# ─────────────────────────────────────────────────────────────
# RPC — обмен данными
# ─────────────────────────────────────────────────────────────

# Обновить локальный pack и уведомить другого игрока
func sync_pack_selection():
	local_player_info["selected_pack"]     = Global.selected_pack
	local_player_info["selected_sub_pack"] = Global.selected_sub_pack
	local_player_info["name"]              = Global.player_name if "player_name" in Global else "Player"
	if multiplayer.multiplayer_peer:
		_broadcast_player_info.rpc(local_player_info)
	# Обновляем у себя
	players[my_peer_id] = local_player_info.duplicate()
	_check_both_ready()

@rpc("any_peer", "reliable")
func _send_player_info(info: Dictionary):
	var sender = multiplayer.get_remote_sender_id()
	players[sender] = info
	print("[Net] Получены данные игрока %d: %s" % [sender, info])
	_check_both_ready()

@rpc("any_peer", "reliable")
func _broadcast_player_info(info: Dictionary):
	var sender = multiplayer.get_remote_sender_id()
	players[sender] = info
	_check_both_ready()

func _check_both_ready():
	if players.size() >= 2:
		var all_chosen = true
		for pid in players:
			if players[pid].get("selected_pack", "") == "":
				all_chosen = false
				break
		if all_chosen:
			game_ready.emit()

# ─────────────────────────────────────────────────────────────
# ИГРОВЫЕ ДЕЙСТВИЯ — отправка и получение
# ─────────────────────────────────────────────────────────────

# Отправить действие всем (или конкретному пиру)
func send_action(action: Dictionary):
	action["sender"] = my_peer_id
	_receive_action.rpc(action)

@rpc("any_peer", "reliable")
func _receive_action(action: Dictionary):
	var sender = multiplayer.get_remote_sender_id()
	action["sender"] = sender
	print("[Net] Получено действие от %d: %s" % [sender, action.get("type", "?")])
	action_received.emit(action)

# ─────────────────────────────────────────────────────────────
# ВСПОМОГАТЕЛЬНЫЕ
# ─────────────────────────────────────────────────────────────

func get_opponent_info() -> Dictionary:
	for pid in players:
		if pid != my_peer_id:
			return players[pid]
	return {}

func get_opponent_id() -> int:
	for pid in players:
		if pid != my_peer_id:
			return pid
	return -1

func is_my_turn(current_turn_peer: int) -> bool:
	return current_turn_peer == my_peer_id
