extends Control

# ─────────────────────────────────────────────────────────────
# BattleScene.gd — МУЛЬТИПЛЕЕРНАЯ ВЕРСИЯ
# Поддерживает 2 игроков по сети (RadminVPN / LAN)
# ─────────────────────────────────────────────────────────────

var player_models: Array = []
var player_cards:  Array = []

# Данные противника, полученные по сети
var enemy_models: Array = []
var enemy_cards:  Array = []

var player_name:  String = "Player"
var enemy_name:   String = "Opponent"
var player_balls: int    = 3
var enemy_balls:  int    = 3
var player_hsp:   int    = 0
var active_bakugan_index: int = 0

# ── Чей сейчас ход ──
# peer_id игрока чей ход. Хост (peer 1) начинает.
var current_turn_peer: int = 1
var my_peer_id: int = 1

# ─────────────────────────────────────────────────────────────
# Ссылки на узлы (те же, что в оригинале)
# ─────────────────────────────────────────────────────────────
@onready var player_label        = $PlayerPanel/VBox/PlayerLabel
@onready var player_name_label   = $PlayerPanel/VBox/PlayerNameDisplay/NameLabel
@onready var player_gpower_label = $PlayerPanel/VBox/PlayerGPower/GPowerLabel
@onready var player_bakugan_disp = $PlayerPanel/VBox/PlayerBakuganDisplay
@onready var enemy_label         = $EnemyPanel/VBox/EnemyLabel
@onready var enemy_gpower_label  = $EnemyPanel/VBox/EnemyGPower/EGPowerLabel
@onready var enemy_bakugan_disp  = $EnemyPanel/VBox/EnemyBakuganDisplay
@onready var enemy_name_label    = $EnemyPanel/VBox/EnemyNameDisplay/NameLabel
@onready var end_turn_button     = $TurnPanel/EndTurnButton
@onready var hand_container      = $HandPanel/HandContainer
@onready var pause_overlay       = $PauseOverlay
@onready var turn_label          = $TurnLabel   # новый Label — добавьте в сцену!

var bakugan_mesh_instances: Array = []
var bakugan_rotation_timers: Array = []
var bakugan_viewers: Array = []
var bakugan_name_labels: Array = []
var bakugan_gpower_labels: Array = []
var gate_buttons:    Array = []
var ability_buttons: Array = []
var gate_card_paths:    Array = []
var ability_card_paths: Array = []
var card_info_panel: Panel
var card_info_overlay: ColorRect
var card_info_popup_label: Label
var cell_buttons: Array = []
var selected_cell: int = -1
var selected_gate_index:    int = -1
var selected_ability_index: int = -1

# ── Эффекты карт ─────────────────────────────────────────────────
var card_effects  # CardEffects — создаётся в _ready()
var cell_gate_cards: Array = []
var cell_gate_meshes: Array = []
var cell_gate_real_paths: Array = []
var cell_gate_revealed: Array = []
var cell_bakugan_index: Array = []
var cell_bakugan_meshes: Array = []
var cell_bakugan_open: Array = []
var cell_enemy_bakugan_index: Array = []
var selected_bakugan_for_throw: int = -1
# ── Ожидание выбора получателя G-силы (Holy Beast Spirit Attack) ──
var pending_holy_beast_transfer: bool = false  # режим выбора получателя
var holy_beast_transfer_gpower:  int  = 0      # G-сила Грифона для передачи
const GATE_BACK_TEXTURE = "res://Textures/Cards/GateCards/GateCard.png"

# ── Лимиты действий за ход ──────────────────────────────────────
# За один ход можно:
#   - выложить 1 карту ворот
#   - бросить 1 бакугана
#   - открыть 1 карту ворот ИЛИ использовать 1 карту способности
var turn_gate_placed:   bool = false   # выложена карта ворот
var turn_bakugan_thrown: bool = false  # брошен бакуган
var turn_effect_used:   bool = false   # открыта карта ворот или использована способность

# ── Постоянные бонусы (действуют до конца игры) ─────────────────
# Ключ — keyword бакугана (совпадает с _is_bakugan_on_field), значение — накопленный бонус G
var permanent_gpower_bonus: Dictionary = {}

# ─────────────────────────────────────────────────────────────
func _ready():
	# ── Эффекты карт ──
	card_effects = load("res://Scripts/CardEffects.gd").new()
	card_effects.setup(self)
	add_child(card_effects)

	# ── Мультиплеер: определяем роли ──
	my_peer_id = multiplayer.get_unique_id() if multiplayer.multiplayer_peer else 1

	# Получаем имя из NetworkManager если есть
	if multiplayer.multiplayer_peer:
		player_name = NetworkManager.local_player_info.get("name", "Player")
		var opp = NetworkManager.get_opponent_info()
		enemy_name = opp.get("name", "Opponent")
		NetworkManager.action_received.connect(_on_network_action)

	bakugan_viewers = [
		hand_container.get_node("BakuganSlot1"),
		hand_container.get_node("BakuganSlot2"),
		hand_container.get_node("BakuganSlot3"),
	]
	bakugan_name_labels = [
		hand_container.get_node("BakuganSlot1/BakuganNameLabel1"),
		hand_container.get_node("BakuganSlot2/BakuganNameLabel2"),
		hand_container.get_node("BakuganSlot3/BakuganNameLabel3"),
	]
	bakugan_gpower_labels = [
		hand_container.get_node("BakuganSlot1/BakuganGPowerLabel1"),
		hand_container.get_node("BakuganSlot2/BakuganGPowerLabel2"),
		hand_container.get_node("BakuganSlot3/BakuganGPowerLabel3"),
	]
	bakugan_mesh_instances = [
		hand_container.get_node("BakuganSlot1/Bakugan1/SubViewport/Preview3D/MeshInstance3D"),
		hand_container.get_node("BakuganSlot2/Bakugan2/SubViewport/Preview3D/MeshInstance3D"),
		hand_container.get_node("BakuganSlot3/Bakugan3/SubViewport/Preview3D/MeshInstance3D"),
	]
	bakugan_rotation_timers = [
		hand_container.get_node("BakuganSlot1/Bakugan1/SubViewport/Preview3D/RotationTimer"),
		hand_container.get_node("BakuganSlot2/Bakugan2/SubViewport/Preview3D/RotationTimer"),
		hand_container.get_node("BakuganSlot3/Bakugan3/SubViewport/Preview3D/RotationTimer"),
	]
	for i in bakugan_rotation_timers.size():
		bakugan_rotation_timers[i].timeout.connect(_on_bakugan_rotate.bind(i))

	gate_buttons = [
		hand_container.get_node("GateCard1"),
		hand_container.get_node("GateCard2"),
		hand_container.get_node("GateCard3"),
	]
	ability_buttons = [
		hand_container.get_node("AbilityCard1"),
		hand_container.get_node("AbilityCard2"),
		hand_container.get_node("AbilityCard3"),
		hand_container.get_node("AbilityCard4"),
		hand_container.get_node("AbilityCard5"),
		hand_container.get_node("AbilityCard6"),
	]

	for i in bakugan_viewers.size():
		bakugan_viewers[i].gui_input.connect(_on_bakugan_gui_input.bind(i))
	for i in gate_buttons.size():
		gate_buttons[i].pressed.connect(_on_gate_pressed.bind(i))
		gate_buttons[i].gui_input.connect(_on_card_gui_input.bind(gate_buttons[i], "gate", i))
	for i in ability_buttons.size():
		ability_buttons[i].pressed.connect(_on_ability_pressed.bind(i))
		ability_buttons[i].gui_input.connect(_on_card_gui_input.bind(ability_buttons[i], "ability", i))
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	pause_overlay.get_node("PausePanel/VBox/ResumeButton").pressed.connect(_on_resume_pressed)
	pause_overlay.get_node("PausePanel/VBox/MainMenuButton").pressed.connect(_on_main_menu_pressed)

	var cell_overlay = $BattleFieldArea/CellOverlay
	for i in range(8):
		var btn = cell_overlay.get_node("CellBtn%d" % (i + 1))
		cell_buttons.append(btn)
		btn.pressed.connect(_on_cell_pressed.bind(i))
		btn.gui_input.connect(_on_cell_gui_input.bind(i))
	_highlight_selected_cell(-1)

	cell_gate_cards.resize(8);  cell_gate_cards.fill(-1)
	cell_gate_real_paths.resize(8); cell_gate_real_paths.fill("")
	cell_gate_revealed.resize(8);  cell_gate_revealed.fill(false)
	cell_bakugan_index.resize(8);  cell_bakugan_index.fill(-1)
	cell_bakugan_open.resize(8);   cell_bakugan_open.fill(false)
	cell_enemy_bakugan_index.resize(8); cell_enemy_bakugan_index.fill(-1)
	for i in 8:
		cell_bakugan_meshes.append(null)

	card_info_panel        = $CardInfoLayer/CardInfoPanel
	card_info_overlay      = $CardInfoLayer/CardInfoOverlay
	card_info_popup_label  = $CardInfoLayer/CardInfoPanel/VBox/CardInfoLabel
	$CardInfoLayer/CardInfoPanel/VBox/CloseButton.pressed.connect(_close_card_info)
	card_info_overlay.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: _close_card_info())

	_update_ui_labels()
	_load_pack()
	_setup_3d_field()
	_update_turn_ui()

# ─────────────────────────────────────────────────────────────
# ХОД И БЛОКИРОВКА УПРАВЛЕНИЯ
# ─────────────────────────────────────────────────────────────

func _is_my_turn() -> bool:
	# В одиночной игре — всегда true
	if not multiplayer.multiplayer_peer:
		return true
	return current_turn_peer == my_peer_id

func _end_my_turn():
	# Сбрасываем счётчики действий для следующего хода
	turn_gate_placed    = false
	turn_bakugan_thrown = false
	turn_effect_used    = false
	selected_ability_index = -1
	_highlight_ability_button(-1)
	# Если передача G-силы осталась незавершённой — отменяем
	if pending_holy_beast_transfer:
		pending_holy_beast_transfer = false
		holy_beast_transfer_gpower  = 0
		_highlight_selected_cell(-1)
	_update_action_labels()
	if not multiplayer.multiplayer_peer:
		# Одиночная игра — просто меняем ход условно
		current_turn_peer = 2 if current_turn_peer == 1 else 1
		_update_turn_ui()
		return
	# Передаём ход противнику
	var opp_id = NetworkManager.get_opponent_id()
	NetworkManager.send_action({
		"type": "end_turn",
		"next_turn": opp_id
	})
	current_turn_peer = opp_id
	_update_turn_ui()

func _update_turn_ui():
	if not is_instance_valid(turn_label):
		return
	var my_turn = _is_my_turn()
	if my_turn:
		turn_label.text = "⚔ Ваш ход"
		turn_label.modulate = Color(0.3, 1.0, 0.5)
		end_turn_button.disabled = false
		end_turn_button.modulate = Color(1.0, 1.0, 1.0)
	else:
		turn_label.text = "⏳ Ход противника"
		turn_label.modulate = Color(1.0, 0.6, 0.2)
		end_turn_button.disabled = true
		end_turn_button.modulate = Color(0.5, 0.5, 0.5)
	_update_action_labels()

func _update_action_labels():
	# Обновляем визуальное состояние кнопок в зависимости от использованных действий
	# Карты ворот — блокируем если уже выложена
	for btn in gate_buttons:
		if not _is_my_turn() or turn_gate_placed:
			btn.modulate = Color(0.45, 0.45, 0.45)
		else:
			if btn.modulate == Color(0.45, 0.45, 0.45):
				btn.modulate = Color(1.0, 1.0, 1.0)
	# Карты способностей — блокируем если эффект уже использован
	for btn in ability_buttons:
		if not _is_my_turn() or turn_effect_used:
			btn.modulate = Color(0.45, 0.45, 0.45)
		else:
			if btn.modulate == Color(0.45, 0.45, 0.45):
				btn.modulate = Color(1.0, 1.0, 1.0)
	# Бакуганы — блокируем если уже брошен
	for viewer in bakugan_viewers:
		if not viewer.visible: continue
		if not _is_my_turn() or turn_bakugan_thrown:
			viewer.modulate = Color(0.45, 0.45, 0.45)
		else:
			if viewer.modulate == Color(0.45, 0.45, 0.45):
				viewer.modulate = Color(1.0, 1.0, 1.0)

# ─────────────────────────────────────────────────────────────
# ПОЛУЧЕНИЕ СЕТЕВЫХ ДЕЙСТВИЙ
# ─────────────────────────────────────────────────────────────

func _on_network_action(action: Dictionary):
	var t = action.get("type", "")
	match t:
		"end_turn":
			current_turn_peer = action.get("next_turn", my_peer_id)
			# Сбрасываем наши счётчики когда начинается наш ход
			if current_turn_peer == my_peer_id:
				turn_gate_placed    = false
				turn_bakugan_thrown = false
				turn_effect_used    = false
				selected_ability_index = -1
				_highlight_ability_button(-1)
				_update_action_labels()
			_update_turn_ui()

		"place_gate":
			var gate_idx = action.get("gate_index", -1)
			var cell_idx = action.get("cell_index", -1)
			# Карту противника мы визуально не показываем (рубашка)
			_apply_enemy_gate_card(gate_idx, cell_idx)

		"throw_bakugan":
			var bak_idx  = action.get("bakugan_index", -1)
			var cell_idx = action.get("cell_index", -1)
			_apply_enemy_bakugan(bak_idx, cell_idx)

		"reveal_gate":
			var cell_idx = action.get("cell_index", -1)
			_reveal_gate_card(cell_idx)

		"use_ability":
			var ab_idx = action.get("ability_index", -1)
			print("Противник использовал карту способности #%d" % ab_idx)

		"pass":
			print("Противник пасует")
			current_turn_peer = my_peer_id
			_update_turn_ui()

		"balls_update":
			enemy_balls = action.get("balls", enemy_balls)
			_update_ui_labels()

		"bakugan_data":
			enemy_models = action.get("models", [])

func _apply_enemy_gate_card(gate_index: int, cell_index: int):
	if cell_index < 0 or cell_index >= 8:
		return
	if cell_gate_real_paths[cell_index] != "":
		return
	# Показываем рубашку — реального пути карты противника мы не знаем
	var field_scene = $BattleFieldArea/FieldViewportContainer/FieldViewport/FieldScene
	var cols = 4; var rows = 2
	var field_w = 12.0; var field_h = 8.0
	var cell_w = field_w / cols; var cell_h = field_h / rows
	var col = cell_index % cols; var row = cell_index / cols
	var cx = -field_w / 2.0 + col * cell_w + cell_w / 2.0
	var cz = -field_h / 2.0 + row * cell_h + cell_h / 2.0

	var card_mesh = PlaneMesh.new()
	card_mesh.size = Vector2(cell_w * 0.88, cell_h * 0.88)
	var mi = MeshInstance3D.new()
	mi.mesh = card_mesh
	var mat = StandardMaterial3D.new()
	mat.roughness = 1.0
	var back_tex = _load_texture_raw(GATE_BACK_TEXTURE)
	if back_tex:
		mat.albedo_texture = back_tex
	else:
		mat.albedo_color = Color(0.08, 0.12, 0.20)
	mi.set_surface_override_material(0, mat)
	mi.position = Vector3(cx, 0.015, cz)
	field_scene.add_child(mi)

	while cell_gate_meshes.size() <= cell_index:
		cell_gate_meshes.append(null)
	cell_gate_meshes[cell_index] = mi
	cell_gate_real_paths[cell_index] = "enemy_card"  # заглушка
	cell_gate_revealed[cell_index] = false

func _apply_enemy_bakugan(bakugan_index: int, cell_index: int):
	if cell_index < 0 or cell_index >= 8:
		return
	cell_bakugan_index[cell_index] = -2  # -2 = бакуган противника
	cell_enemy_bakugan_index[cell_index] = bakugan_index
	enemy_balls = max(0, enemy_balls - 1)
	_update_ui_labels()
	# Показываем шар-заглушку на поле
	var field_scene = $BattleFieldArea/FieldViewportContainer/FieldViewport/FieldScene
	var cols = 4; var field_w = 12.0; var field_h = 8.0
	var cell_w = field_w / cols; var cell_h = field_h / 2
	var col = cell_index % cols; var row = cell_index / cols
	var cx = -field_w / 2.0 + col * cell_w + cell_w / 2.0
	var cz = -field_h / 2.0 + row * cell_h + cell_h * 0.75
	var mi = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.35; sphere.height = 0.7
	mi.mesh = sphere
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.2, 0.2)
	mi.set_surface_override_material(0, mat)
	mi.position = Vector3(cx, 0.4, cz)
	field_scene.add_child(mi)
	cell_bakugan_meshes[cell_index] = mi
	cell_bakugan_open[cell_index] = true

# ─────────────────────────────────────────────────────────────
func _on_bakugan_rotate(index: int):
	if index < bakugan_mesh_instances.size():
		var mesh = bakugan_mesh_instances[index]
		if mesh and mesh.mesh != null:
			mesh.rotate_y(deg_to_rad(1.5))

# ─────────────────────────────────────────────────────────────
func _load_pack():
	player_models = Global.get_current_models()
	player_cards  = Global.get_current_cards()
	print("=== BattleScene: набор '%s' / '%s' ===" % [Global.selected_pack, Global.selected_sub_pack])

	_load_bakugan_3d_models()

	var gate_cards    = Global.get_current_gate_cards()
	var ability_cards = Global.get_current_ability_cards()

	gate_card_paths    = gate_cards.duplicate()
	ability_card_paths = ability_cards.duplicate()

	for i in gate_buttons.size():
		if i < gate_cards.size():
			_set_card_button(gate_buttons[i], gate_cards[i], "GATE")
		else:
			_reset_card_button(gate_buttons[i], "GATE")

	for i in ability_buttons.size():
		if i < ability_cards.size():
			_set_card_button(ability_buttons[i], ability_cards[i], "ABIL")
		else:
			_reset_card_button(ability_buttons[i], "ABIL")

	_highlight_active_bakugan(0)
	player_balls = player_models.size()
	_update_ui_labels()
	if multiplayer.multiplayer_peer:
		var models_to_send: Array = []
		for m in player_models:
			models_to_send.append({
				"name":           m.get("name", ""),
				"g_power":        m.get("g_power", 0),
				"open_mesh_path": m.get("open_mesh_path", ""),
				"texture_path":   m.get("texture_path", ""),
				"mesh_path":      m.get("mesh_path", ""),
			})
		NetworkManager.send_action({"type": "bakugan_data", "models": models_to_send})

# ─────────────────────────────────────────────────────────────
func _load_bakugan_3d_models():
	for i in bakugan_mesh_instances.size():
		var mesh_inst: MeshInstance3D = bakugan_mesh_instances[i]
		var viewer = bakugan_viewers[i]
		if i >= player_models.size():
			viewer.visible = false
			continue
		var model_data: Dictionary = player_models[i]
		var mesh_path: String = model_data.get("mesh_path", "")
		var tex_path:  String = model_data.get("texture_path", "")
		var loaded = false
		if mesh_path != "" and ResourceLoader.exists(mesh_path):
			var mesh_res = ResourceLoader.load(mesh_path, "", ResourceLoader.CACHE_MODE_IGNORE)
			if mesh_res:
				mesh_inst.mesh = mesh_res.duplicate()
				loaded = true
				var tex: Texture2D = null
				if tex_path != "" and ResourceLoader.exists(tex_path):
					tex = ResourceLoader.load(tex_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
				for s in mesh_res.get_surface_count():
					var mat = StandardMaterial3D.new()
					mat.metallic = 0.0
					mat.roughness = 0.5
					if tex:
						mat.albedo_texture = tex.duplicate()
					else:
						mat.albedo_color = Color(0.8, 0.3, 0.1)
					mesh_inst.set_surface_override_material(s, mat)
		if i < bakugan_name_labels.size():
			var bak_name = model_data.get("name", "Bakugan %d" % (i + 1))
			var g_power  = model_data.get("g_power", 0)
			bakugan_name_labels[i].text  = bak_name
			bakugan_gpower_labels[i].text = "%d G" % g_power if g_power > 0 else "??? G"
		viewer.visible = loaded

# ─────────────────────────────────────────────────────────────
func _update_player_bakugan_display(index: int):
	var old = player_bakugan_disp.get_node_or_null("BakuganTexture")
	if old: old.queue_free()
	var no_bak_label = player_bakugan_disp.get_node_or_null("NoBakuganLabel")
	if index >= player_models.size():
		if no_bak_label: no_bak_label.visible = true
		return
	var tex_path: String = player_models[index].get("texture_path", "")
	if tex_path != "" and ResourceLoader.exists(tex_path):
		var tex = load(tex_path) as Texture2D
		if tex:
			var tr = TextureRect.new()
			tr.name           = "BakuganTexture"
			tr.texture        = tex
			tr.expand_mode    = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tr.stretch_mode   = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.layout_mode    = 1
			tr.anchors_preset = 15
			tr.anchor_right   = 1.0
			tr.anchor_bottom  = 1.0
			player_bakugan_disp.add_child(tr)
			if no_bak_label: no_bak_label.visible = false
			return
	if no_bak_label: no_bak_label.visible = true

func _highlight_active_bakugan(index: int):
	active_bakugan_index = index
	for i in bakugan_viewers.size():
		if not bakugan_viewers[i].visible: continue
		bakugan_viewers[i].modulate = Color(1.0, 1.0, 0.35) if i == index else Color(0.55, 0.55, 0.55)

func _set_card_button(btn: Button, card_path: String, fallback_text: String):
	btn.tooltip_text = card_path.get_file().get_basename()
	if ResourceLoader.exists(card_path):
		var tex = load(card_path) as Texture2D
		if tex:
			btn.icon = tex; btn.text = ""; btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			return
	_reset_card_button(btn, fallback_text)

func _reset_card_button(btn: Button, label_text: String):
	btn.icon = null; btn.text = label_text; btn.expand_icon = false

func _update_ui_labels():
	player_label.text        = "%s: %d Ball(s)" % [player_name, player_balls]
	player_name_label.text   = ""
	player_gpower_label.text = "--- G"
	enemy_label.text         = "%s: %d Ball(s)" % [enemy_name, enemy_balls]
	enemy_gpower_label.text  = "--- G"
	if is_instance_valid(enemy_name_label):
		enemy_name_label.text = ""

# ─────────────────────────────────────────────────────────────
# ПОЛЬЗОВАТЕЛЬСКИЕ ДЕЙСТВИЯ — с проверкой хода
# ─────────────────────────────────────────────────────────────

func _on_bakugan_gui_input(event: InputEvent, index: int):
	if not _is_my_turn(): return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if index >= player_models.size(): return
		if turn_bakugan_thrown:
			print("Бакуган уже брошен в этот ход")
			return
		if selected_bakugan_for_throw == index:
			selected_bakugan_for_throw = -1
			_highlight_active_bakugan(index)
		else:
			selected_bakugan_for_throw = index
			_highlight_active_bakugan(index)
			bakugan_viewers[index].modulate = Color(0.3, 1.0, 0.5)

func _on_card_gui_input(event: InputEvent, btn: Button, card_type: String, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var card_path = ""
		if card_type == "gate"    and index < gate_card_paths.size():    card_path = gate_card_paths[index]
		elif card_type == "ability" and index < ability_card_paths.size(): card_path = ability_card_paths[index]
		if card_path == "": return
		var info = Global.get_card_info(card_path)
		if info and not info.is_empty():
			card_info_popup_label.text = "━━━━━━━━━━━━━━━━━━━━\n%s\n━━━━━━━━━━━━━━━━━━━━\n\nТип: %s\n\n%s" % [info["name"], info["type"], info["effect"]]
		else:
			card_info_popup_label.text = "━━━━━━━━━━━━━━━━━━━━\n%s\n━━━━━━━━━━━━━━━━━━━━\n\nИнформация не найдена." % card_path.get_file().get_basename()
		card_info_overlay.visible = true; card_info_panel.visible = true

func _close_card_info():
	card_info_panel.visible = false; card_info_overlay.visible = false

func _on_pass_pressed():
	if not _is_my_turn(): return
	print("Передаём ход")
	if multiplayer.multiplayer_peer:
		NetworkManager.send_action({"type": "pass"})
	_end_my_turn()

func _on_end_turn_pressed():
	if not _is_my_turn(): return
	print("Ход завершён вручную")
	if multiplayer.multiplayer_peer:
		NetworkManager.send_action({"type": "end_turn", "next_turn": NetworkManager.get_opponent_id()})
	_end_my_turn()

func _on_gate_pressed(index: int):
	if not _is_my_turn(): return
	if turn_gate_placed:
		print("Карта ворот уже выложена в этот ход")
		return
	if index >= gate_card_paths.size() or gate_card_paths[index] == "": return

	# ── Первый клик — выбор; второй клик по той же карте — снять выделение ──
	# Выкладывание происходит при нажатии на ячейку поля (_on_cell_pressed)
	if selected_gate_index == index:
		selected_gate_index = -1
		_highlight_gate_button(-1)
	else:
		selected_gate_index = index
		_highlight_gate_button(index)

func _highlight_gate_button(index: int):
	for i in gate_buttons.size():
		gate_buttons[i].modulate = Color(0.2, 1.0, 1.0) if i == index else Color(1.0, 1.0, 1.0)

func _on_ability_pressed(index: int):
	if not _is_my_turn(): return
	if turn_effect_used:
		print("Эффект уже использован в этот ход")
		return
	if index >= ability_card_paths.size() or ability_card_paths[index] == "":
		return

	# ── Первый клик — выбор; второй клик по той же карте — активация ──
	if selected_ability_index != index:
		selected_ability_index = index
		_highlight_ability_button(index)
		return

	# Второй клик — применяем эффект
	selected_ability_index = -1
	_highlight_ability_button(-1)

	var card_path: String = ability_card_paths[index]
	var card_info = Global.get_card_info(card_path)
	var card_name: String = card_info.get("name", "") if card_info else ""

	var effect_applied: bool = card_effects.apply_ability(card_path, card_name)

	if effect_applied:
		ability_card_paths[index] = ""
		_reset_card_button(ability_buttons[index], "ABIL")
		turn_effect_used = true
		_update_action_labels()
		if multiplayer.multiplayer_peer:
			NetworkManager.send_action({"type": "use_ability", "ability_index": index})

func _highlight_ability_button(index: int):
	for i in ability_buttons.size():
		ability_buttons[i].modulate = Color(0.2, 1.0, 1.0) if i == index else Color(1.0, 1.0, 1.0)

# ── UI-функции для Holy Beast (вызываются из CardEffects) ────────

# Подсвечивает жёлтым ячейки поля где стоят свои бакуганы — подсказка для выбора получателя.
func _highlight_field_bakugans_for_transfer():
	for cell in range(cell_bakugan_index.size()):
		if cell_bakugan_index[cell] >= 0:
			var btn: Button = cell_buttons[cell]
			var sb = StyleBoxFlat.new()
			sb.bg_color    = Color(1.0, 0.85, 0.0, 0.28)
			sb.border_color = Color(1.0, 1.0, 0.0, 0.9)
			sb.set_border_width_all(3)
			btn.add_theme_stylebox_override("normal",  sb)
			btn.add_theme_stylebox_override("hover",   sb)
			btn.add_theme_stylebox_override("pressed", sb)

# Завершает передачу G-силы выбранному бакугану и выходит из режима ожидания.
func _finish_holy_beast_transfer(target_bakugan_idx: int):
	var model: Dictionary = player_models[target_bakugan_idx]
	model["g_power"] = model.get("g_power", 0) + holy_beast_transfer_gpower
	player_models[target_bakugan_idx] = model
	print("Holy Beast: %s получил +%d G → %d G" % [model.get("name", "?"), holy_beast_transfer_gpower, model["g_power"]])
	player_gpower_label.text = "%d G" % model["g_power"]
	holy_beast_transfer_gpower  = 0
	pending_holy_beast_transfer = false
	_highlight_selected_cell(-1)

# ─────────────────────────────────────────────────────────────
# 3D ПОЛЕ
# ─────────────────────────────────────────────────────────────

func _setup_3d_field():
	var field_plane = $BattleFieldArea/FieldViewportContainer/FieldViewport/FieldScene/FieldPlane
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(12.0, 8.0)
	field_plane.mesh = plane_mesh
	var mat = StandardMaterial3D.new()
	var field_tex_path = "res://Assets/Поле.png"
	if ResourceLoader.exists(field_tex_path):
		var tex = load(field_tex_path) as Texture2D
		if tex: mat.albedo_texture = tex
	else:
		mat.albedo_color = Color(0.08, 0.12, 0.20)
	mat.roughness = 0.9; mat.metallic = 0.1
	field_plane.set_surface_override_material(0, mat)
	_add_field_grid_lines()
	_style_transparent_cells()

func _add_field_grid_lines():
	var scene = $BattleFieldArea/FieldViewportContainer/FieldViewport/FieldScene
	var line_mat = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.0, 0.85, 1.0, 0.7)
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.0, 0.6, 0.9)
	line_mat.emission_energy_multiplier = 1.5
	line_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var field_w = 12.0; var field_h = 8.0
	var cols = 4; var rows = 2
	var cell_w = field_w / cols; var cell_h = field_h / rows
	var line_thickness = 0.04; var line_height = 0.02
	for c in range(cols + 1):
		var x = -field_w / 2.0 + c * cell_w
		var lm = BoxMesh.new(); lm.size = Vector3(line_thickness, line_height, field_h)
		var mi = MeshInstance3D.new(); mi.mesh = lm
		mi.set_surface_override_material(0, line_mat)
		mi.position = Vector3(x, line_height / 2.0, 0)
		scene.add_child(mi)
	for r in range(rows + 1):
		var z = -field_h / 2.0 + r * cell_h
		var lm = BoxMesh.new(); lm.size = Vector3(field_w, line_height, line_thickness)
		var mi = MeshInstance3D.new(); mi.mesh = lm
		mi.set_surface_override_material(0, line_mat)
		mi.position = Vector3(0, line_height / 2.0, z)
		scene.add_child(mi)

func _load_texture_raw(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var tex = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
		if tex: return tex
	var img = Image.new()
	var err = img.load(ProjectSettings.globalize_path(path))
	if err == OK and not img.is_empty():
		return ImageTexture.create_from_image(img)
	return null

func _style_transparent_cells():
	pass

# ─────────────────────────────────────────────────────────────
func _on_cell_gui_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		_show_cell_bakugan_in_panel(index)
		return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if index >= cell_gate_real_paths.size() or cell_gate_real_paths[index] == "": return
		var card_path = cell_gate_real_paths[index]
		if card_path == "enemy_card":
			card_info_popup_label.text = "Карта противника (скрыта)"
		else:
			var info = Global.get_card_info(card_path)
			if info and not info.is_empty():
				card_info_popup_label.text = "━━━━━━━━━━━━━━━━━━━━\n%s\n━━━━━━━━━━━━━━━━━━━━\n\nТип: %s\n\n%s" % [info["name"], info["type"], info["effect"]]
			else:
				card_info_popup_label.text = "━━━━━━━━━━━━━━━━━━━━\n%s\n━━━━━━━━━━━━━━━━━━━━\n\nИнформация не найдена." % card_path.get_file().get_basename()
		card_info_overlay.visible = true; card_info_panel.visible = true

func _show_cell_bakugan_in_panel(cell_index: int):
	if cell_index < 0 or cell_index >= cell_bakugan_index.size():
		return
	var bak_idx: int = cell_bakugan_index[cell_index]

	# ── Бакуган противника ──
	if bak_idx == -2:
		var enemy_bak_idx: int = cell_enemy_bakugan_index[cell_index] if cell_index < cell_enemy_bakugan_index.size() else -1
		if enemy_bak_idx >= 0 and enemy_bak_idx < enemy_models.size():
			var model: Dictionary = enemy_models[enemy_bak_idx]
			_build_panel_3d_preview(enemy_bakugan_disp, model.get("open_mesh_path", ""), model.get("texture_path", ""))
			enemy_gpower_label.text = "%d G" % model.get("g_power", 0)
			enemy_name_label.text   = model.get("name", "")
		else:
			_clear_panel_3d_preview(enemy_bakugan_disp)
			enemy_gpower_label.text = "??? G"
			enemy_name_label.text   = ""
		return

	# ── Бакуган игрока ──
	if bak_idx >= 0 and bak_idx < player_models.size():
		var model: Dictionary = player_models[bak_idx]
		var open_mesh_path: String = model.get("open_mesh_path", "")
		var tex_path: String       = model.get("texture_path", "")
		var bak_name: String       = model.get("name", "Bakugan")
		var g_power: int           = model.get("g_power", 0)
		for keyword in permanent_gpower_bonus.keys():
			if keyword in bak_name.to_lower() or keyword in model.get("mesh_path", "").to_lower():
				g_power += permanent_gpower_bonus[keyword]
		_build_panel_3d_preview($PlayerPanel/VBox/PlayerBakuganDisplay, open_mesh_path, tex_path)
		player_gpower_label.text = "%d G" % g_power
		player_name_label.text   = bak_name
		return

	_clear_panel_3d_preview($PlayerPanel/VBox/PlayerBakuganDisplay)
	player_gpower_label.text = "--- G"
	player_name_label.text   = ""

func _build_panel_3d_preview(display: Panel, open_mesh_path: String, tex_path: String):
	_clear_panel_3d_preview(display)
	var no_label = display.get_node_or_null("NoBakuganLabel")
	var svc = SubViewportContainer.new()
	svc.name = "PanelBakuganSVC"
	svc.stretch = true
	svc.layout_mode = 1
	svc.anchor_left   = 0.1
	svc.anchor_top    = 0.05
	svc.anchor_right  = 0.9
	svc.anchor_bottom = 0.95
	display.add_child(svc)
	var sv = SubViewport.new()
	sv.own_world_3d = true
	sv.handle_input_locally = false
	sv.size = Vector2i(180, 180)
	sv.size_2d_override_stretch = true
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svc.add_child(sv)
	var scene3d = Node3D.new()
	sv.add_child(scene3d)
	var cam = Camera3D.new()
	cam.transform = Transform3D(Basis(), Vector3(0, 2.0, 4.0))
	scene3d.add_child(cam)
	var light = DirectionalLight3D.new()
	light.transform = Transform3D(Basis(), Vector3(1, 3, 2))
	light.light_energy = 1.4
	scene3d.add_child(light)
	var ambient = OmniLight3D.new()
	ambient.transform = Transform3D(Basis(), Vector3(-1, 2, 2))
	ambient.light_color = Color(0.5, 0.65, 1.0)
	ambient.light_energy = 0.5
	ambient.omni_range = 18.0
	scene3d.add_child(ambient)
	var mi = MeshInstance3D.new()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var loaded_mesh = false
	if open_mesh_path != "" and ResourceLoader.exists(open_mesh_path):
		var mesh_res = ResourceLoader.load(open_mesh_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if mesh_res:
			mi.mesh = mesh_res.duplicate()
			mi.scale = Vector3(0.68, 0.68, 0.68)
			var tex: Texture2D = null
			if tex_path != "" and ResourceLoader.exists(tex_path):
				tex = ResourceLoader.load(tex_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			for s in mesh_res.get_surface_count():
				var mat = StandardMaterial3D.new()
				mat.roughness = 0.5; mat.metallic = 0.1
				if tex: mat.albedo_texture = tex
				else:   mat.albedo_color = Color(0.8, 0.3, 0.1)
				mi.set_surface_override_material(s, mat)
			loaded_mesh = true
	if not loaded_mesh:
		var quad = QuadMesh.new()
		quad.size = Vector2(2.0, 2.0)
		mi.mesh = quad
		var mat = StandardMaterial3D.new()
		mat.roughness = 1.0
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		if tex_path != "" and ResourceLoader.exists(tex_path):
			var tex = ResourceLoader.load(tex_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			if tex: mat.albedo_texture = tex
			else:   mat.albedo_color = Color(0.8, 0.3, 0.1)
		else:
			mat.albedo_color = Color(0.8, 0.3, 0.1)
		mi.set_surface_override_material(0, mat)
	mi.position = Vector3(0, 1.4, 0)
	mi.rotation_degrees = Vector3(0, 180, 0)
	scene3d.add_child(mi)
	var timer = Timer.new()
	timer.wait_time = 0.016
	timer.autostart = true
	scene3d.add_child(timer)
	timer.timeout.connect(func(): if is_instance_valid(mi): mi.rotate_y(deg_to_rad(1.5)))
	if no_label: no_label.visible = false

func _clear_panel_3d_preview(display: Panel):
	var old = display.get_node_or_null("PanelBakuganSVC")
	if old: old.queue_free()
	var no_label = display.get_node_or_null("NoBakuganLabel")
	if no_label: no_label.visible = true

func _on_cell_pressed(index: int):
	if not _is_my_turn():
		print("Сейчас не ваш ход!")
		return

	# ── Режим выбора получателя G-силы (Holy Beast Spirit Attack) ──
	if pending_holy_beast_transfer:
		var target_idx: int = cell_bakugan_index[index]
		if target_idx < 0:
			print("Holy Beast: выберите ячейку со своим бакуганом")
			return
		_finish_holy_beast_transfer(target_idx)
		return

	if selected_gate_index >= 0:
		_place_gate_card_on_cell(selected_gate_index, index)
		if multiplayer.multiplayer_peer:
			NetworkManager.send_action({
				"type": "place_gate",
				"gate_index": selected_gate_index,
				"cell_index": index
			})
		selected_gate_index = -1
		_highlight_gate_button(-1)
		turn_gate_placed = true
		_update_action_labels()

	elif selected_bakugan_for_throw >= 0:
		if cell_gate_real_paths[index] == "":
			print("Нельзя бросить бакуган: на ячейке нет карты ворот")
			return
		if cell_bakugan_index[index] >= 0:
			print("На этой ячейке уже стоит бакуган")
			return
		_throw_bakugan_on_cell(selected_bakugan_for_throw, index)
		if multiplayer.multiplayer_peer:
			NetworkManager.send_action({
				"type": "throw_bakugan",
				"bakugan_index": selected_bakugan_for_throw,
				"cell_index": index
			})
			NetworkManager.send_action({
				"type": "balls_update",
				"balls": player_balls
			})
		selected_bakugan_for_throw = -1
		_highlight_active_bakugan(-1)
		turn_bakugan_thrown = true
		_update_action_labels()

	elif index < cell_gate_real_paths.size() and cell_gate_real_paths[index] != "" and cell_gate_real_paths[index] != "enemy_card":
		selected_cell = index
		_highlight_selected_cell(index)
	elif index < cell_bakugan_index.size() and cell_bakugan_index[index] >= 0:
		if not cell_bakugan_open[index]:
			_open_bakugan_on_cell(index)
		else:
			selected_cell = index; _highlight_selected_cell(index)
	else:
		selected_cell = index
		_highlight_selected_cell(index)

func _throw_bakugan_on_cell(bakugan_idx: int, cell_index: int):
	if bakugan_idx >= player_models.size(): return
	cell_bakugan_index[cell_index] = bakugan_idx
	cell_bakugan_meshes[cell_index] = null
	cell_bakugan_open[cell_index] = false
	if bakugan_idx < bakugan_viewers.size():
		bakugan_viewers[bakugan_idx].visible = false
	player_balls -= 1
	_update_ui_labels()
	_open_bakugan_on_cell(cell_index)

func _open_bakugan_on_cell(cell_index: int):
	var bakugan_idx = cell_bakugan_index[cell_index]
	if bakugan_idx < 0 or bakugan_idx >= player_models.size(): return
	var model_data = player_models[bakugan_idx]
	var open_mesh_path: String = model_data.get("open_mesh_path", "")
	var tex_path: String = model_data.get("texture_path", "")
	var bak_name: String = model_data.get("name", "Bakugan")

	# Применяем постоянный бонус G если он есть для этого бакугана
	var g_power: int = model_data.get("g_power", 0)
	for keyword in permanent_gpower_bonus.keys():
		if keyword in bak_name.to_lower() or keyword in model_data.get("mesh_path", "").to_lower():
			g_power += permanent_gpower_bonus[keyword]

	var old_mi: MeshInstance3D = cell_bakugan_meshes[cell_index]
	var field_scene = $BattleFieldArea/FieldViewportContainer/FieldViewport/FieldScene
	var cols = 4; var field_w = 12.0; var field_h = 8.0
	var cell_w = field_w / cols; var cell_h = field_h / 2
	var col = cell_index % cols; var row = cell_index / cols
	var cx = -field_w / 2.0 + col * cell_w + cell_w / 2.0
	var cz = -field_h / 2.0 + row * cell_h + cell_h * 0.75

	if old_mi and is_instance_valid(old_mi): old_mi.queue_free()
	cell_bakugan_meshes[cell_index] = null

	var mi = MeshInstance3D.new()
	if open_mesh_path != "" and ResourceLoader.exists(open_mesh_path):
		var mesh_res = ResourceLoader.load(open_mesh_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if mesh_res:
			mi.mesh = mesh_res.duplicate()
			mi.scale = Vector3(0.675, 0.675, 0.675)
			var tex: Texture2D = null
			if tex_path != "" and ResourceLoader.exists(tex_path):
				tex = ResourceLoader.load(tex_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			for s in mesh_res.get_surface_count():
				var mat = StandardMaterial3D.new()
				mat.roughness = 0.5; mat.metallic = 0.1
				if tex: mat.albedo_texture = tex
				else:   mat.albedo_color = Color(0.8, 0.3, 0.1)
				mi.set_surface_override_material(s, mat)
	else:
		var quad = QuadMesh.new()
		quad.size = Vector2(cell_w * 0.75, cell_h * 0.9)
		mi.mesh = quad
		var mat = StandardMaterial3D.new()
		mat.roughness = 1.0
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		if tex_path != "" and ResourceLoader.exists(tex_path):
			var tex = ResourceLoader.load(tex_path, "", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			if tex: mat.albedo_texture = tex
		else:
			mat.albedo_color = Color(0.8, 0.3, 0.1)
		mi.set_surface_override_material(0, mat)

	mi.position = Vector3(cx, 0.55, cz)
	mi.rotation_degrees = Vector3(0, 180, 0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	field_scene.add_child(mi)
	cell_bakugan_meshes[cell_index] = mi
	cell_bakugan_open[cell_index] = true
	player_gpower_label.text = "%d G" % g_power

func _reveal_gate_card(cell_index: int):
	var card_path = cell_gate_real_paths[cell_index]
	if card_path == "" or card_path == "enemy_card": return
	if cell_index >= cell_gate_meshes.size(): return
	var mi: MeshInstance3D = cell_gate_meshes[cell_index]
	if not mi: return
	var mat = StandardMaterial3D.new()
	mat.roughness = 1.0; mat.metallic = 0.0
	if ResourceLoader.exists(card_path):
		var tex = load(card_path) as Texture2D
		if tex: mat.albedo_texture = tex
	else:
		mat.albedo_color = Color(0.2, 0.4, 0.6)
	mi.set_surface_override_material(0, mat)
	cell_gate_revealed[cell_index] = true

func _place_gate_card_on_cell(gate_index: int, cell_index: int):
	if gate_index >= gate_card_paths.size(): return
	var card_path = gate_card_paths[gate_index]
	if card_path == "": return
	if cell_index < cell_gate_real_paths.size() and cell_gate_real_paths[cell_index] != "":
		print("Ячейка #%d уже занята" % cell_index); return

	_reset_card_button(gate_buttons[gate_index], "GATE")
	gate_card_paths[gate_index] = ""

	var field_scene = $BattleFieldArea/FieldViewportContainer/FieldViewport/FieldScene
	var cols = 4; var rows = 2
	var field_w = 12.0; var field_h = 8.0
	var cell_w = field_w / cols; var cell_h = field_h / rows
	var col = cell_index % cols; var row = cell_index / cols
	var cx = -field_w / 2.0 + col * cell_w + cell_w / 2.0
	var cz = -field_h / 2.0 + row * cell_h + cell_h / 2.0

	var card_mesh = PlaneMesh.new()
	card_mesh.size = Vector2(cell_w * 0.88, cell_h * 0.88)
	var mi = MeshInstance3D.new()
	mi.mesh = card_mesh
	var mat = StandardMaterial3D.new()
	mat.roughness = 1.0; mat.metallic = 0.0
	var back_tex = _load_texture_raw(GATE_BACK_TEXTURE)
	if back_tex: mat.albedo_texture = back_tex
	else:        mat.albedo_color = Color(0.08, 0.12, 0.20)
	mi.set_surface_override_material(0, mat)
	mi.position = Vector3(cx, 0.015, cz)
	field_scene.add_child(mi)

	while cell_gate_meshes.size() <= cell_index:
		cell_gate_meshes.append(null)
	cell_gate_meshes[cell_index] = mi
	cell_gate_real_paths[cell_index] = card_path
	cell_gate_revealed[cell_index] = false
	_highlight_selected_cell(cell_index)

func _highlight_selected_cell(index: int):
	for i in cell_buttons.size():
		var btn: Button = cell_buttons[i]
		if i == index:
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(0.0, 0.85, 1.0, 0.22)
			sb.border_color = Color(0.2, 1.0, 1.0, 0.9)
			sb.set_border_width_all(3)
			btn.add_theme_stylebox_override("normal", sb)
			btn.add_theme_stylebox_override("hover", sb)
			btn.add_theme_stylebox_override("pressed", sb)
		else:
			var sb_n = StyleBoxFlat.new()
			sb_n.bg_color = Color(0.0, 0.0, 0.0, 0.0)
			sb_n.set_border_width_all(0)
			var sb_h = StyleBoxFlat.new()
			sb_h.bg_color = Color(0.0, 0.85, 1.0, 0.12)
			sb_h.border_color = Color(0.0, 1.0, 1.0, 0.4)
			sb_h.set_border_width_all(2)
			btn.add_theme_stylebox_override("normal", sb_n)
			btn.add_theme_stylebox_override("hover", sb_h)
			btn.add_theme_stylebox_override("pressed", sb_h)

# ─────────────────────────────────────────────────────────────
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	var showing = !pause_overlay.visible
	pause_overlay.visible = showing
	get_tree().paused = showing

func _on_resume_pressed():    _toggle_pause()
func _on_main_menu_pressed():
	get_tree().paused = false
	if multiplayer.multiplayer_peer:
		NetworkManager.disconnect_network()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
