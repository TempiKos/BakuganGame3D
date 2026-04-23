extends Node

# ================================================================
# Global.gd  —  Автозагрузчик с игровой логикой и состоянием.
# Все данные (пути, имена, эффекты) хранятся в GameData.gd.
# ================================================================

const SAVE_PATH         = "user://profile.cfg"
const CUSTOM_PACKS_PATH = "user://custom_packs.cfg"

var selected_pack:     String = ""
var selected_sub_pack: String = ""
var player_name:       String = "Player"

# Индекс текущей темы обучения (передаётся между сценами)
var current_learning_topic: int = 0

# Пользовательские наборы: { "Название": { "element", "bakugans", "ability_cards", "gate_cards" } }
var custom_packs: Dictionary = {}

func _ready() -> void:
	load_profile()
	load_custom_packs()


# ════════════════════════════════════════════════════════════════
#  ПРОФИЛЬ
# ════════════════════════════════════════════════════════════════
func save_profile() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("profile", "player_name", player_name)
	cfg.save(SAVE_PATH)

func load_profile() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		player_name = cfg.get_value("profile", "player_name", "Player")

func has_profile() -> bool:
	var cfg = ConfigFile.new()
	return cfg.load(SAVE_PATH) == OK


# ════════════════════════════════════════════════════════════════
#  ПОЛЬЗОВАТЕЛЬСКИЕ НАБОРЫ
# ════════════════════════════════════════════════════════════════
func save_custom_pack(pack_name: String, data: Dictionary) -> void:
	custom_packs[pack_name] = data
	_persist_custom_packs()

func delete_custom_pack(pack_name: String) -> void:
	if custom_packs.has(pack_name):
		custom_packs.erase(pack_name)
		_persist_custom_packs()

func is_custom_pack(pack_name: String) -> bool:
	return custom_packs.has(pack_name)

func _persist_custom_packs() -> void:
	var cfg = ConfigFile.new()
	for pack_name in custom_packs.keys():
		var p = custom_packs[pack_name]
		cfg.set_value(pack_name, "element",       p.get("element", ""))
		cfg.set_value(pack_name, "bakugans",       JSON.stringify(p.get("bakugans", [])))
		cfg.set_value(pack_name, "ability_cards",  JSON.stringify(p.get("ability_cards", [])))
		cfg.set_value(pack_name, "gate_cards",     JSON.stringify(p.get("gate_cards", [])))
	cfg.save(CUSTOM_PACKS_PATH)

func load_custom_packs() -> void:
	custom_packs.clear()
	var cfg = ConfigFile.new()
	if cfg.load(CUSTOM_PACKS_PATH) != OK:
		return
	for section in cfg.get_sections():
		custom_packs[section] = {
			"element":       cfg.get_value(section, "element", ""),
			"bakugans":      _parse_json_array(cfg.get_value(section, "bakugans", "[]")),
			"ability_cards": _parse_json_array(cfg.get_value(section, "ability_cards", "[]")),
			"gate_cards":    _parse_json_array(cfg.get_value(section, "gate_cards", "[]")),
		}

func _parse_json_array(raw: String) -> Array:
	var parsed = JSON.parse_string(raw)
	return parsed if parsed is Array else []


# ════════════════════════════════════════════════════════════════
#  ПОЛУЧЕНИЕ ДАННЫХ ТЕКУЩЕГО НАБОРА
# ════════════════════════════════════════════════════════════════

func get_current_models() -> Array:
	return GameData.resolve_bakugans(_get_raw_pack_field("bakugans"))

func get_current_ability_cards() -> Array:
	return GameData.resolve_card_textures(_get_raw_pack_field("ability_cards"))

func get_current_gate_cards() -> Array:
	return GameData.resolve_card_textures(_get_raw_pack_field("gate_cards"))

func get_current_cards() -> Array:
	return get_current_ability_cards() + get_current_gate_cards()

func get_card_info(texture_path: String) -> Dictionary:
	return GameData.get_card_info_by_texture(texture_path)

var pack_data: Dictionary:
	get: return GameData.pack_data


# ── Внутренние хелперы ───────────────────────────────────────────

func _get_raw_pack_field(field: String) -> Array:
	if selected_pack == "":
		return []
	if custom_packs.has(selected_pack):
		return custom_packs[selected_pack].get(field, [])
	return _get_builtin_pack().get(field, [])

func _get_builtin_pack() -> Dictionary:
	if not GameData.pack_data.has(selected_pack):
		return {}
	var pack = GameData.pack_data[selected_pack]
	# Если в данных всё ещё есть sub_packs — берём первый доступный,
	# но наружу это не выставляем (один набор на стихию).
	if pack.has("sub_packs"):
		var keys = pack["sub_packs"].keys()
		if keys.size() > 0:
			return pack["sub_packs"][keys[0]]
		return {}
	return pack

# Оставлен для совместимости с остальным кодом, всегда возвращает пустой массив
func get_available_sub_packs(_pack_name: String) -> Array:
	return []

func get_sub_pack_data(pack_name: String, sub_pack_name: String) -> Dictionary:
	if not GameData.pack_data.has(pack_name):
		return {}
	var pack = GameData.pack_data[pack_name]
	if pack.has("sub_packs") and pack["sub_packs"].has(sub_pack_name):
		return pack["sub_packs"][sub_pack_name]
	return {}
