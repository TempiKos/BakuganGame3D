extends Node3D

# Массив для хранения всех MeshInstance3D
var mesh_instances = []
var rotation_timers = []
var loaded_models = []

# Лейблы названия и G-power для каждого бакугана
var bakugan_name_labels = []
var bakugan_gpower_labels = []

# Массив для хранения кнопок карт
var card_buttons = []

# Текущий выбранный набор
var current_selected_pack = ""

# Ссылка на панель информации о карте
var card_info_label: Label

func _ready():
	$VBoxContainer/ConfirmButton.pressed.connect(_on_confirm_pressed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

	card_info_label = $CardInfoPanel/CardInfoLabel

	mesh_instances = [
		$BakuganWrapper1/SubViewportContainer/SubViewport/Preview3D/MeshInstance3D_1,
		$BakuganWrapper2/SubViewportContainer2/SubViewport/Preview3D/MeshInstance3D_2,
		$BakuganWrapper3/SubViewportContainer3/SubViewport/Preview3D/MeshInstance3D_3
	]

	rotation_timers = [
		$BakuganWrapper1/SubViewportContainer/SubViewport/Preview3D/RotationTimer,
		$BakuganWrapper2/SubViewportContainer2/SubViewport/Preview3D/RotationTimer,
		$BakuganWrapper3/SubViewportContainer3/SubViewport/Preview3D/RotationTimer
	]

	bakugan_name_labels = [
		$BakuganWrapper1/BakuganNameLabel1,
		$BakuganWrapper2/BakuganNameLabel2,
		$BakuganWrapper3/BakuganNameLabel3
	]
	bakugan_gpower_labels = [
		$BakuganWrapper1/BakuganGPowerLabel1,
		$BakuganWrapper2/BakuganGPowerLabel2,
		$BakuganWrapper3/BakuganGPowerLabel3
	]

	for i in range(rotation_timers.size()):
		rotation_timers[i].timeout.connect(_on_rotation_timer_timeout.bind(i))

	var card_paths = [
		"AbilityCardsContainer/Card1", "AbilityCardsContainer/Card2", "AbilityCardsContainer/Card3",
		"AbilityCardsContainer/Card4", "AbilityCardsContainer/Card5", "AbilityCardsContainer/Card6",
		"GateCardsContainer/Card7", "GateCardsContainer/Card8", "GateCardsContainer/Card9"
	]
	card_buttons = []
	for path in card_paths:
		var node = get_node_or_null(path)
		if node:
			card_buttons.append(node)
		else:
			push_warning("SelectPackScene: узел не найден — " + path)

	for i in range(card_buttons.size()):
		card_buttons[i].pressed.connect(_on_card_button_pressed.bind(i))

	setup_buttons()
	_load_selected_pack()

func _on_card_button_pressed(card_index: int):
	var card_button = card_buttons[card_index]
	var texture = card_button.texture_normal
	if texture == null:
		card_info_label.text = "Карта не загружена"
		return
	var texture_path = texture.resource_path
	var info = Global.get_card_info(texture_path)
	if info != null and not info.is_empty():
		card_info_label.text = "━━━━━━━━━━━━━━━━━━━━\n%s\n━━━━━━━━━━━━━━━━━━━━\n\nТип: %s\n\n%s" % [info["name"], info["type"], info["effect"]]
	else:
		var file_name = texture_path.get_file().get_basename()
		card_info_label.text = "━━━━━━━━━━━━━━━━━━━━\n%s\n━━━━━━━━━━━━━━━━━━━━\n\nПуть: %s\n\nИнформация не найдена в базе данных." % [file_name, texture_path]

func _load_selected_pack():
	current_selected_pack = Global.selected_pack if Global.selected_pack != "" else "Огненный"
	print("Загружаем набор:", current_selected_pack)
	if not Global.pack_data.has(current_selected_pack):
		print("ОШИБКА: Неизвестный набор:", current_selected_pack)
		return
	Global.selected_pack     = current_selected_pack
	Global.selected_sub_pack = ""
	_load_models(Global.get_current_models())
	_load_cards(Global.get_current_cards())

func _load_models(pack_models: Array):
	var models_count = min(pack_models.size(), mesh_instances.size())
	loaded_models.clear()
	for i in range(models_count):
		var model_data = pack_models[i]
		var mesh_instance = mesh_instances[i]
		var success = _load_mesh_and_texture(mesh_instance, model_data["mesh_path"], model_data["texture_path"])
		if i < bakugan_name_labels.size():
			var bak_name = model_data.get("name", "Bakugan %d" % (i + 1))
			var g_power  = model_data.get("g_power", 0)
			bakugan_name_labels[i].text  = bak_name
			bakugan_gpower_labels[i].text = "%d G" % g_power if g_power > 0 else "??? G"
		if success:
			mesh_instance.visible = true
			loaded_models.append(mesh_instance)
		else:
			mesh_instance.visible = false

func _load_cards(cards_array: Array):
	for i in range(min(cards_array.size(), card_buttons.size())):
		var card_path   = cards_array[i]
		var card_button = card_buttons[i]
		if ResourceLoader.exists(card_path):
			var texture = load(card_path)
			if texture:
				card_button.texture_normal = texture
				card_button.modulate  = Color.WHITE
				card_button.visible   = true
				card_button.disabled  = false
			else:
				card_button.modulate  = Color.WHITE
				card_button.visible   = false
				card_button.disabled  = true
		else:
			card_button.texture_normal = null
			card_button.modulate  = Color(0.5, 0.5, 0.5, 0.5)
			card_button.visible   = true
			card_button.disabled  = true

func _load_mesh_and_texture(mesh_instance: MeshInstance3D, mesh_path: String, texture_path: String) -> bool:
	var success = false
	if ResourceLoader.exists(mesh_path):
		var mesh_res = load(mesh_path)
		if mesh_res:
			mesh_instance.mesh = mesh_res.duplicate()
			success = true
			var texture: Texture2D = null
			if ResourceLoader.exists(texture_path):
				texture = load(texture_path) as Texture2D
			var surface_count = mesh_instance.mesh.get_surface_count()
			for surface_idx in range(surface_count):
				var material = StandardMaterial3D.new()
				material.metallic   = 0.0
				material.roughness  = 0.5
				if texture:
					material.albedo_texture = texture
				else:
					material.albedo_color = Color(0.8, 0.8, 0.8)
				mesh_instance.set_surface_override_material(surface_idx, material)
	return success

func _on_rotation_timer_timeout(index: int):
	if index < mesh_instances.size() and index < loaded_models.size():
		var mesh_instance = mesh_instances[index]
		if mesh_instance and mesh_instance.visible:
			mesh_instance.rotate_y(deg_to_rad(1.0))

func _on_confirm_pressed():
	Global.selected_pack     = current_selected_pack
	Global.selected_sub_pack = ""
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn")

func setup_buttons():
	$VBoxContainer/ConfirmButton.text = "Подтвердить"
	$VBoxContainer/BackButton.text    = "Назад"

func toggle_rotation(enable: bool):
	for timer in rotation_timers:
		if enable: timer.start()
		else:       timer.stop()
