extends Control

# ================================================================
# select_pack_menu.gd  (с системой разблокировки через обучение)
# ================================================================

func _ready():
	_connect_element_buttons()
	_connect_back_button()
	_setup_create_pack_button()
	_build_custom_packs_section()


# ── Кнопки стихий ───────────────────────────────────────────────
func _connect_element_buttons() -> void:
	var base: String
	if has_node("VBoxContainer/ButtonsContainer/PyrusButton"):
		base = "VBoxContainer/ButtonsContainer/"
	elif has_node("ButtonsContainer/PyrusButton"):
		base = "ButtonsContainer/"
	else:
		push_warning("select_pack_menu: кнопки стихий не найдены")
		return

	var unlocked_elements = LearningData.get_unlocked_elements()

	var mapping = {
		"PyrusButton":    "Огненный",
		"VentusButton":   "Воздушный",
		"SubterraButton": "Земляной",
		"AquosButton":    "Водный",
		"HaosButton":     "Светлый",
		"DarkusButton":   "Тёмный",
	}
	for btn_name in mapping.keys():
		var node = get_node_or_null(base + btn_name)
		if node:
			var element = mapping[btn_name]
			if unlocked_elements.has(element):
				node.pressed.connect(_on_element_pressed.bind(element))
				node.disabled = false
				node.tooltip_text = ""
			else:
				node.disabled = true
				node.tooltip_text = "🔒 Пройди Обучение, чтобы открыть"
				node.modulate = Color(0.5, 0.5, 0.5)


func _on_element_pressed(element: String) -> void:
	Global.selected_pack = element
	get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")


# ── Кнопка «Назад» ──────────────────────────────────────────────
func _connect_back_button() -> void:
	var paths = ["VBoxContainer/BackButton", "BackButton"]
	for p in paths:
		var node = get_node_or_null(p)
		if node:
			node.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn"))
			return


# ── Кнопка «Создать свой набор» (узел из .tscn) ─────────────────
func _setup_create_pack_button() -> void:
	var paths = ["VBoxContainer/CreatePackButton", "CreatePackButton"]
	var btn: Button = null
	for p in paths:
		btn = get_node_or_null(p)
		if btn:
			break

	if btn == null:
		push_warning("select_pack_menu: CreatePackButton не найден в сцене")
		return

	if LearningData.is_custom_pack_creator_unlocked():
		btn.disabled = false
		btn.tooltip_text = ""
		btn.modulate = Color(1, 1, 1)
		btn.pressed.connect(_on_create_pack_pressed)
	else:
		btn.disabled = true
		btn.tooltip_text = "🔒 Пройди все %d темы обучения" % LearningData.topics.size()
		btn.modulate = Color(0.5, 0.5, 0.55)


# ── Секция пользовательских наборов ─────────────────────────────
var custom_section_container: VBoxContainer = null

func _build_custom_packs_section() -> void:
	var root_vbox = get_node_or_null("VBoxContainer")
	if root_vbox == null:
		push_warning("select_pack_menu: VBoxContainer не найден")
		return

	if custom_section_container and is_instance_valid(custom_section_container):
		custom_section_container.queue_free()

	custom_section_container = VBoxContainer.new()
	custom_section_container.name = "CustomPacksSection"
	custom_section_container.add_theme_constant_override("separation", 8)

	var title_label := Label.new()
	title_label.text = "── Мои наборы ──"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	custom_section_container.add_child(title_label)

	if Global.custom_packs.size() == 0:
		var empty_label := Label.new()
		empty_label.text = "Нет сохранённых наборов"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.modulate = Color(0.7, 0.7, 0.7)
		custom_section_container.add_child(empty_label)
	else:
		for pack_name in Global.custom_packs.keys():
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 8)

			var select_btn := Button.new()
			var element = Global.custom_packs[pack_name].get("element", "")
			select_btn.text = "%s  [%s]" % [pack_name, element]
			select_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			select_btn.add_theme_font_size_override("font_size", 18)
			select_btn.pressed.connect(_on_custom_pack_selected.bind(pack_name))

			var del_btn := Button.new()
			del_btn.text = "✕"
			del_btn.add_theme_font_size_override("font_size", 18)
			del_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			del_btn.custom_minimum_size = Vector2(48, 0)
			del_btn.pressed.connect(_on_custom_pack_deleted.bind(pack_name))

			row.add_child(select_btn)
			row.add_child(del_btn)
			custom_section_container.add_child(row)

	# Вставить секцию перед CreatePackButton
	var create_btn = get_node_or_null("VBoxContainer/CreatePackButton")
	if create_btn:
		root_vbox.add_child(custom_section_container)
		root_vbox.move_child(custom_section_container, create_btn.get_index())
	else:
		var back_btn = get_node_or_null("VBoxContainer/BackButton")
		if back_btn:
			root_vbox.add_child(custom_section_container)
			root_vbox.move_child(custom_section_container, back_btn.get_index())
		else:
			root_vbox.add_child(custom_section_container)


func _on_custom_pack_selected(pack_name: String) -> void:
	Global.selected_pack = pack_name
	get_tree().change_scene_to_file("res://Scenes/SelectPackScene.tscn")


func _on_custom_pack_deleted(pack_name: String) -> void:
	Global.delete_custom_pack(pack_name)
	if Global.selected_pack == pack_name:
		Global.selected_pack = ""
	_build_custom_packs_section()


func _on_create_pack_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CustomPackCreator.tscn")
