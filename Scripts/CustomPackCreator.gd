extends Control

# ================================================================
# CustomPackCreator.gd  —  только логика, UI описан в .tscn
# ================================================================

var pack_name:        String = ""
var selected_element: String = ""

var chosen_bakugan_indices: Array = [-1, -1, -1]
var chosen_ability_indices: Array = [-1, -1, -1, -1, -1, -1]
var chosen_gate_indices:    Array = [-1, -1, -1]

var editing_slot_type:  String = ""
var editing_slot_index: int    = -1

var catalog_bakugans:  Array = []
var catalog_abilities: Array = []
var catalog_gates:     Array = []

var ability_slot_buttons: Array = []
var gate_slot_buttons:    Array = []

# ── Шаги ─────────────────────────────────────────────────────────
@onready var step_name_panel:    Panel = $StepNamePanel
@onready var step_element_panel: Panel = $StepElementPanel
@onready var step_content_panel: Panel = $StepContentPanel
@onready var picker_overlay:     Panel = $PickerOverlay

# ── Шаг 1 ────────────────────────────────────────────────────────
@onready var pack_name_input:  LineEdit = $StepNamePanel/VBoxContainer/PackNameInput
@onready var name_error_label: Label    = $StepNamePanel/VBoxContainer/NameErrorLabel

# ── Шаг 2 ────────────────────────────────────────────────────────
@onready var element_grid: GridContainer = $StepElementPanel/VBoxContainer/ElementGrid

# ── Шаг 3 ────────────────────────────────────────────────────────
@onready var tab_container:    TabContainer = $StepContentPanel/VBoxContainer/TabContainer
@onready var save_error_label: Label        = $StepContentPanel/VBoxContainer/SaveErrorLabel

@onready var ability_grid: GridContainer = $StepContentPanel/VBoxContainer/TabContainer/"Карты способностей"/AbilityGrid
@onready var gate_hbox:    HBoxContainer = $StepContentPanel/VBoxContainer/TabContainer/"Карты ворот"/GateHBox

# ── 3D-слоты бакуганов (узлы из .tscn) ──────────────────────────
const _SB := "StepContentPanel/VBoxContainer/TabContainer/Бакуганы/BakuganHBox/"

@onready var slot_mesh: Array[MeshInstance3D] = [
	get_node(_SB + "BakuganSlot1/SubViewportContainer/SubViewport/Preview3D/MeshInstance3D"),
	get_node(_SB + "BakuganSlot2/SubViewportContainer/SubViewport/Preview3D/MeshInstance3D"),
	get_node(_SB + "BakuganSlot3/SubViewportContainer/SubViewport/Preview3D/MeshInstance3D"),
]
@onready var slot_name_label: Array[Label] = [
	get_node(_SB + "BakuganSlot1/NameLabel"),
	get_node(_SB + "BakuganSlot2/NameLabel"),
	get_node(_SB + "BakuganSlot3/NameLabel"),
]
@onready var slot_gpower_label: Array[Label] = [
	get_node(_SB + "BakuganSlot1/GPowerLabel"),
	get_node(_SB + "BakuganSlot2/GPowerLabel"),
	get_node(_SB + "BakuganSlot3/GPowerLabel"),
]

# ── Пикер ────────────────────────────────────────────────────────
@onready var picker_title: Label         = $PickerOverlay/VBoxContainer/PickerTitle
@onready var picker_grid:  GridContainer = $PickerOverlay/VBoxContainer/ScrollContainer/PickerGrid

const ELEMENT_COLORS: Dictionary = {
	"Огненный":  Color(1.0, 0.4, 0.1),
	"Воздушный": Color(0.3, 0.9, 0.3),
	"Земляной":  Color(0.8, 0.6, 0.2),
	"Водный":    Color(0.2, 0.6, 1.0),
	"Светлый":   Color(1.0, 0.95, 0.3),
	"Тёмный":    Color(0.6, 0.2, 0.9),
}


func _ready() -> void:
	# Шаг 1
	$StepNamePanel/VBoxContainer/NextButton.pressed.connect(_on_next_to_element)
	$StepNamePanel/VBoxContainer/BackToMenuButton.pressed.connect(
		func(): get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn"))

	# Шаг 2
	$StepElementPanel/VBoxContainer/BackButton.pressed.connect(func(): _show_step(1))

	# Шаг 3
	$StepContentPanel/VBoxContainer/ButtonRow/BackToElementButton.pressed.connect(func(): _show_step(2))
	$StepContentPanel/VBoxContainer/ButtonRow/SaveButton.pressed.connect(_on_save_pressed)

	# Клик по слотам бакуганов
	get_node(_SB + "BakuganSlot1/SubViewportContainer/ClickOverlay").pressed.connect(_open_picker.bind("bakugan", 0))
	get_node(_SB + "BakuganSlot2/SubViewportContainer/ClickOverlay").pressed.connect(_open_picker.bind("bakugan", 1))
	get_node(_SB + "BakuganSlot3/SubViewportContainer/ClickOverlay").pressed.connect(_open_picker.bind("bakugan", 2))

	# Пикер
	$PickerOverlay/VBoxContainer/CloseButton.pressed.connect(func(): picker_overlay.visible = false)

	_build_element_buttons()
	_build_card_slots()
	_show_step(1)


# ── Кнопки стихий ────────────────────────────────────────────────
func _build_element_buttons() -> void:
	for child in element_grid.get_children():
		child.queue_free()
	for element_name in Global.pack_data.keys():
		var btn := Button.new()
		btn.text = element_name
		btn.custom_minimum_size = Vector2(200, 60)
		btn.add_theme_font_size_override("font_size", 20)
		if ELEMENT_COLORS.has(element_name):
			btn.add_theme_color_override("font_color", ELEMENT_COLORS[element_name])
		btn.pressed.connect(_on_element_selected.bind(element_name))
		element_grid.add_child(btn)


# ── Слоты карт (динамически, т.к. зависят от каталога стихии) ────
func _build_card_slots() -> void:
	ability_slot_buttons.clear()
	for child in ability_grid.get_children():
		child.queue_free()
	for i in range(6):
		var slot := _make_card_button(Vector2(130, 180), "Слот %d" % (i + 1))
		slot.pressed.connect(_open_picker.bind("ability", i))
		ability_grid.add_child(slot)
		ability_slot_buttons.append(slot)

	gate_slot_buttons.clear()
	for child in gate_hbox.get_children():
		child.queue_free()
	for i in range(3):
		var slot := _make_card_button(Vector2(200, 280), "Слот %d" % (i + 1))
		slot.pressed.connect(_open_picker.bind("gate", i))
		gate_hbox.add_child(slot)
		gate_slot_buttons.append(slot)


func _make_card_button(min_size: Vector2, hint: String) -> TextureButton:
	var btn := TextureButton.new()
	btn.custom_minimum_size = min_size
	btn.ignore_texture_size  = true
	btn.stretch_mode         = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.tooltip_text         = hint
	return btn


# ── Навигация ────────────────────────────────────────────────────
func _show_step(step: int) -> void:
	step_name_panel.visible    = (step == 1)
	step_element_panel.visible = (step == 2)
	step_content_panel.visible = (step == 3)
	picker_overlay.visible     = false


func _on_next_to_element() -> void:
	pack_name = pack_name_input.text.strip_edges()
	if pack_name.length() < 1:
		name_error_label.text = "Введите название набора!"
		return
	if Global.pack_data.has(pack_name) or Global.custom_packs.has(pack_name):
		name_error_label.text = "Набор с таким именем уже существует."
		return
	name_error_label.text = ""
	_show_step(2)


func _on_element_selected(element: String) -> void:
	selected_element = element
	_build_catalog_for_element(element)
	_reset_slots()
	_refresh_all_slots()
	_show_step(3)


# ── Каталог ──────────────────────────────────────────────────────
func _build_catalog_for_element(element: String) -> void:
	catalog_bakugans.clear()
	catalog_abilities.clear()
	catalog_gates.clear()
	if not Global.pack_data.has(element):
		return
	var pack = Global.pack_data[element]

	if pack.has("sub_packs"):
		for sp in pack["sub_packs"].keys():
			var sub = pack["sub_packs"][sp]
			for id in sub.get("bakugans", []):
				var data = GameData.get_bakugan(id)
				if not data.is_empty() and not data in catalog_bakugans:
					catalog_bakugans.append(data)
			for id in sub.get("ability_cards", []):
				var path = GameData.get_card_texture(id)
				if path != "" and not path in catalog_abilities:
					catalog_abilities.append(path)
			for id in sub.get("gate_cards", []):
				var path = GameData.get_card_texture(id)
				if path != "" and not path in catalog_gates:
					catalog_gates.append(path)
	else:
		for id in pack.get("bakugans", []):
			var data = GameData.get_bakugan(id)
			if not data.is_empty():
				catalog_bakugans.append(data)
		for id in pack.get("ability_cards", []):
			var path = GameData.get_card_texture(id)
			if path != "" and not path in catalog_abilities:
				catalog_abilities.append(path)
		for id in pack.get("gate_cards", []):
			var path = GameData.get_card_texture(id)
			if path != "" and not path in catalog_gates:
				catalog_gates.append(path)


# ── Обновление слотов ────────────────────────────────────────────
func _reset_slots() -> void:
	for i in range(3): chosen_bakugan_indices[i] = -1
	for i in range(6): chosen_ability_indices[i] = -1
	for i in range(3): chosen_gate_indices[i]    = -1


func _refresh_all_slots() -> void:
	for i in range(3): _refresh_bakugan_slot(i)
	for i in range(6): _refresh_ability_slot(i)
	for i in range(3): _refresh_gate_slot(i)


func _refresh_bakugan_slot(idx: int) -> void:
	var mesh_inst  := slot_mesh[idx]
	var name_lbl   := slot_name_label[idx]
	var gpower_lbl := slot_gpower_label[idx]
	var c           = chosen_bakugan_indices[idx]

	if c >= 0 and c < catalog_bakugans.size():
		var bak: Dictionary = catalog_bakugans[c]

		# Меш
		var mesh_path: String = bak.get("mesh_path", "")
		mesh_inst.mesh = load(mesh_path) as Mesh if ResourceLoader.exists(mesh_path) else null

		# Текстура — один материал на все поверхности
		var tex_path: String = bak.get("texture_path", "")
		if tex_path != "" and ResourceLoader.exists(tex_path) and mesh_inst.mesh != null:
			var mat := StandardMaterial3D.new()
			mat.albedo_texture = load(tex_path) as Texture2D
			for s in range(mesh_inst.mesh.get_surface_count()):
				mesh_inst.set_surface_override_material(s, mat)

		name_lbl.text   = bak.get("name", "???")
		gpower_lbl.text = "%d G" % bak.get("g_power", 0)
	else:
		mesh_inst.mesh  = null
		name_lbl.text   = "Слот %d" % (idx + 1)
		gpower_lbl.text = ""


func _refresh_ability_slot(idx: int) -> void:
	var btn: TextureButton = ability_slot_buttons[idx]
	var c = chosen_ability_indices[idx]
	btn.texture_normal = _load_tex(catalog_abilities[c]) if c >= 0 and c < catalog_abilities.size() else null
	if btn.texture_normal == null:
		btn.tooltip_text = "Слот %d" % (idx + 1)


func _refresh_gate_slot(idx: int) -> void:
	var btn: TextureButton = gate_slot_buttons[idx]
	var c = chosen_gate_indices[idx]
	btn.texture_normal = _load_tex(catalog_gates[c]) if c >= 0 and c < catalog_gates.size() else null
	if btn.texture_normal == null:
		btn.tooltip_text = "Слот %d" % (idx + 1)


func _load_tex(path: String) -> Texture2D:
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


# ── Пикер ────────────────────────────────────────────────────────
func _open_picker(slot_type: String, slot_index: int) -> void:
	editing_slot_type  = slot_type
	editing_slot_index = slot_index
	for child in picker_grid.get_children():
		child.queue_free()

	match slot_type:
		"bakugan":
			picker_grid.columns = 4
			picker_title.text = "Выберите бакугана (слот %d)" % (slot_index + 1)
			# Собираем всех бакуганов из GameData у которых есть меш и g_power > 0
			var all_valid: Array = []
			for id in GameData.bakugans.keys():
				var b = GameData.bakugans[id]
				if b.get("g_power", 0) > 0 and b.get("mesh_close", "") != "" and b.get("texture", "") != "":
					all_valid.append(GameData.get_bakugan(id))
			for i in range(all_valid.size()):
				_add_bakugan_picker_item(all_valid[i], i)
		"ability":
			picker_grid.columns = 6
			picker_title.text = "Карта способности (слот %d)" % (slot_index + 1)
			for i in range(catalog_abilities.size()):
				_add_card_picker_item(_load_tex(catalog_abilities[i]), Vector2(100, 140), i)
		"gate":
			picker_grid.columns = 6
			picker_title.text = "Карта ворот (слот %d)" % (slot_index + 1)
			for i in range(catalog_gates.size()):
				_add_card_picker_item(_load_tex(catalog_gates[i]), Vector2(100, 140), i)

	picker_overlay.visible = true


# Создаёт карточку выбора бакугана в стиле BakuganWrapper из SelectPackScene
func _add_bakugan_picker_item(bak: Dictionary, idx: int) -> void:
	const WRAP_SIZE := Vector2(180, 210)

	# Контейнер-обёртка (Control) — кликабельный
	var wrapper := Control.new()
	wrapper.custom_minimum_size = WRAP_SIZE

	# SubViewportContainer для 3D-превью
	var svc := SubViewportContainer.new()
	svc.layout_mode = 1
	svc.set_anchors_preset(Control.PRESET_FULL_RECT)
	svc.anchor_bottom = 0.82   # оставляем место под подписи
	svc.grow_horizontal = 2
	svc.grow_vertical = 2

	var svp := SubViewport.new()
	svp.handle_input_locally = false
	svp.size = Vector2i(180, 172)
	svp.size_2d_override_stretch = true
	svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svc.add_child(svp)

	var scene3d := Node3D.new()
	svp.add_child(scene3d)

	var cam := Camera3D.new()
	cam.transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 3)
	scene3d.add_child(cam)

	var light := DirectionalLight3D.new()
	light.transform = Transform3D(1, 0, 0, 0, 0.707, 0.707, 0, -0.707, 0.707, 0, 3, 0)
	scene3d.add_child(light)

	var mesh_inst := MeshInstance3D.new()
	var mesh_path: String = bak.get("mesh_path", "")
	if mesh_path != "" and ResourceLoader.exists(mesh_path):
		mesh_inst.mesh = load(mesh_path) as Mesh
		var tex_path: String = bak.get("texture_path", "")
		if tex_path != "" and ResourceLoader.exists(tex_path):
			var mat := StandardMaterial3D.new()
			mat.albedo_texture = load(tex_path) as Texture2D
			if mesh_inst.mesh != null:
				for s in range(mesh_inst.mesh.get_surface_count()):
					mesh_inst.set_surface_override_material(s, mat)
	scene3d.add_child(mesh_inst)

	wrapper.add_child(svc)

	# Имя бакугана
	var name_lbl := Label.new()
	name_lbl.layout_mode = 1
	name_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name_lbl.offset_top = -50.0
	name_lbl.offset_bottom = -26.0
	name_lbl.grow_vertical = 0
	name_lbl.grow_horizontal = 2
	name_lbl.text = bak.get("name", "???")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	wrapper.add_child(name_lbl)

	# G-power
	var gp_lbl := Label.new()
	gp_lbl.layout_mode = 1
	gp_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	gp_lbl.offset_top = -26.0
	gp_lbl.offset_bottom = 0.0
	gp_lbl.grow_vertical = 0
	gp_lbl.grow_horizontal = 2
	gp_lbl.text = "%d G" % bak.get("g_power", 0)
	gp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gp_lbl.add_theme_font_size_override("font_size", 13)
	gp_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
	wrapper.add_child(gp_lbl)

	# Прозрачная кнопка-оверлей поверх всего враппера
	var overlay := Button.new()
	overlay.layout_mode = 1
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.grow_horizontal = 2
	overlay.grow_vertical = 2
	overlay.flat = true
	overlay.modulate = Color(1, 1, 1, 0)
	# При наведении показываем рамку через StyleBoxFlat
	overlay.pressed.connect(_on_bakugan_picker_select.bind(bak, idx))
	wrapper.add_child(overlay)

	picker_grid.add_child(wrapper)


func _add_card_picker_item(tex: Texture2D, min_size: Vector2, idx: int) -> void:
	var btn := TextureButton.new()
	btn.custom_minimum_size = min_size
	btn.ignore_texture_size  = true
	btn.stretch_mode         = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.texture_normal       = tex
	btn.pressed.connect(_on_picker_select.bind(idx))
	picker_grid.add_child(btn)


# Выбор бакугана напрямую по данным (не по индексу каталога)
func _on_bakugan_picker_select(bak: Dictionary, _idx: int) -> void:
	# Находим или добавляем в catalog_bakugans
	var found_idx := -1
	for i in range(catalog_bakugans.size()):
		if catalog_bakugans[i] == bak:
			found_idx = i
			break
	if found_idx == -1:
		catalog_bakugans.append(bak)
		found_idx = catalog_bakugans.size() - 1
	chosen_bakugan_indices[editing_slot_index] = found_idx
	_refresh_bakugan_slot(editing_slot_index)
	picker_overlay.visible = false


func _on_picker_select(catalog_index: int) -> void:
	match editing_slot_type:
		"bakugan":
			chosen_bakugan_indices[editing_slot_index] = catalog_index
			_refresh_bakugan_slot(editing_slot_index)
		"ability":
			chosen_ability_indices[editing_slot_index] = catalog_index
			_refresh_ability_slot(editing_slot_index)
		"gate":
			chosen_gate_indices[editing_slot_index] = catalog_index
			_refresh_gate_slot(editing_slot_index)
	picker_overlay.visible = false


# ── Сохранение ───────────────────────────────────────────────────
func _on_save_pressed() -> void:
	save_error_label.text = ""
	for i in range(3):
		if chosen_bakugan_indices[i] < 0:
			save_error_label.text = "Заполните все 3 слота бакуганов!"
			tab_container.current_tab = 0; return
	for i in range(6):
		if chosen_ability_indices[i] < 0:
			save_error_label.text = "Заполните все 6 карт способностей!"
			tab_container.current_tab = 1; return
	for i in range(3):
		if chosen_gate_indices[i] < 0:
			save_error_label.text = "Заполните все 3 карты ворот!"
			tab_container.current_tab = 2; return

	var models_arr: Array = []
	for i in chosen_bakugan_indices:
		models_arr.append(catalog_bakugans[i])
	var cards_arr: Array = []
	for i in chosen_ability_indices:
		cards_arr.append(catalog_abilities[i])
	for i in chosen_gate_indices:
		cards_arr.append(catalog_gates[i])

	Global.save_custom_pack(pack_name, {
		"element": selected_element,
		"models":  models_arr,
		"cards":   cards_arr
	})
	get_tree().change_scene_to_file("res://Scenes/SelectPackMenu.tscn")
