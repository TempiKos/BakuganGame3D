extends Node

# ================================================================
# CardEffects.gd — эффекты карт способностей
#
# Подключается к BattleScene через CardEffects.setup(battle_scene).
# Все функции работают через ссылку на сцену боя (bs),
# поэтому имеют полный доступ к состоянию поля.
#
# Чтобы добавить новую карту:
#   1. Добавь ветку elif в apply_ability()
#   2. Напиши функцию _apply_название()
#   3. Если карта требует выбора цели — используй паттерн pending_*
#      (см. Holy Beast как пример)
# ================================================================

# ── Ссылка на BattleScene ────────────────────────────────────────
var bs  # BattleScene — устанавливается через setup()

func setup(battle_scene: Node) -> void:
	bs = battle_scene

# ════════════════════════════════════════════════════════════════
# ТОЧКА ВХОДА — вызывается из BattleScene._on_ability_pressed()
#
# Возвращает true если эффект сработал (карта тратится),
# false если условия не выполнены (карта остаётся в руке).
# ════════════════════════════════════════════════════════════════
func apply_ability(card_path: String, card_name: String) -> bool:
	var name := card_name.to_lower()
	var file := card_path.get_file().get_basename().to_lower()

	# ── Amun Re ─────────────────────────────────────────────────
	if "amun re" in name or file == "amunre":
		return _apply_amun_re()

	# ── Battle Spirit ────────────────────────────────────────────
	elif "battle spirit" in name or file == "battlespirit":
		return _apply_battle_spirit()

	# ── Holy Beast Spirit Attack ─────────────────────────────────
	elif "holy beast" in name or file == "holybeastspirit":
		return _apply_holy_beast()

	# ── Карта не распознана — эффект не определён ───────────────
	print("CardEffects: эффект карты '%s' не реализован" % card_name)
	return false

# ════════════════════════════════════════════════════════════════
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ — общие для всех карт
# ════════════════════════════════════════════════════════════════

# Ищет бакугана по ключевому слову среди тех, кто стоит на поле.
# Проверяет имя бакугана и путь к его модели (регистронезависимо).
# Возвращает индекс в player_models, или -1 если не найден на поле.
#
# Примеры:
#   is_bakugan_on_field("manion")  → Сфинкс на поле?
#   is_bakugan_on_field("warius")  → Воин на поле?
#   is_bakugan_on_field("griffon") → Грифон на поле?
func is_bakugan_on_field(bakugan_id: String) -> int:
	var keyword := bakugan_id.to_lower()
	for i in bs.player_models.size():
		var model: Dictionary = bs.player_models[i]
		var bak_name: String  = model.get("name",      "").to_lower()
		var mesh_path: String = model.get("mesh_path", "").to_lower()
		if keyword in bak_name or keyword in mesh_path:
			for cell in range(bs.cell_bakugan_index.size()):
				if bs.cell_bakugan_index[cell] == i:
					return i
	return -1

# Возвращает массив индексов player_models для всех твоих бакуганов на поле,
# исключая бакугана с индексом exclude_idx.
func get_field_bakugans_except(exclude_idx: int) -> Array:
	var result: Array = []
	for cell in range(bs.cell_bakugan_index.size()):
		var idx: int = bs.cell_bakugan_index[cell]
		if idx >= 0 and idx != exclude_idx:
			if not result.has(idx):
				result.append(idx)
	return result

# Считает количество твоих бакуганов на поле, которые участвуют в битве.
# Бакуган считается "в битве" если на поле есть хотя бы один бакуган противника.
# (cell_bakugan_index: >= 0 — твой бакуган, -2 — бакуган противника, -1 — пусто)
func count_active_battles() -> int:
	var my_count    := 0
	var enemy_count := 0
	for cell in range(bs.cell_bakugan_index.size()):
		if bs.cell_bakugan_index[cell] >= 0:
			my_count += 1
		elif bs.cell_bakugan_index[cell] == -2:
			enemy_count += 1
	return my_count if enemy_count > 0 else 0

# Обновляет лейбл G-силы игрока для бакугана с индексом bakugan_idx.
func _refresh_gpower_label(bakugan_idx: int) -> void:
	var g: int = bs.player_models[bakugan_idx].get("g_power", 0)
	bs.player_gpower_label.text = "%d G" % g

# ════════════════════════════════════════════════════════════════
# ЭФФЕКТЫ КАРТ
# Каждая функция возвращает true при успехе, false при неудаче.
# ════════════════════════════════════════════════════════════════

# ── Amun Re: +100 G Сфинксу (Manion) ────────────────────────────
func _apply_amun_re() -> bool:
	var i := is_bakugan_on_field("manion")
	if i == -1:
		print("Amun Re: Сфинкс (Manion) не на поле — карта не сыграна")
		return false
	var model: Dictionary = bs.player_models[i]
	model["g_power"] = model.get("g_power", 0) + 100
	bs.player_models[i] = model
	_refresh_gpower_label(i)
	print("Amun Re: Сфинкс получил +100 G → %d G" % model["g_power"])
	return true

# ── Battle Spirit: +50 G Воину (Warius) за каждого бакугана в битве ──
# Бонус постоянный — сохраняется в bs.permanent_gpower_bonus до конца игры.
func _apply_battle_spirit() -> bool:
	var i := is_bakugan_on_field("warius")
	if i == -1:
		print("Battle Spirit: Воин (Warius) не на поле — карта не сыграна")
		return false
	var battles := count_active_battles()
	if battles == 0:
		print("Battle Spirit: нет бакуганов в битве — карта не сыграна")
		return false
	var bonus := 50 * battles
	var model: Dictionary = bs.player_models[i]
	model["g_power"] = model.get("g_power", 0) + bonus
	bs.player_models[i] = model
	bs.permanent_gpower_bonus["warius"] = bs.permanent_gpower_bonus.get("warius", 0) + bonus
	_refresh_gpower_label(i)
	print("Battle Spirit: Воин получил +%d G (%d × 50) → %d G" % [bonus, battles, model["g_power"]])
	return true

# ── Holy Beast Spirit Attack: Грифон проигрывает, передаёт G-силу выбранному бакугану ──
func _apply_holy_beast() -> bool:
	var griffon_idx: int = is_bakugan_on_field("griffon")
	if griffon_idx == -1:
		print("Holy Beast: Грифон не на поле — карта не сыграна")
		return false
	var targets := get_field_bakugans_except(griffon_idx)
	if targets.is_empty():
		print("Holy Beast: нет других бакуганов на поле для передачи G — карта не сыграна")
		return false

	# Сохраняем G-силу и убираем Грифона с поля
	var griffon: Dictionary = bs.player_models[griffon_idx]
	bs.holy_beast_transfer_gpower = griffon.get("g_power", 0)
	for cell in range(bs.cell_bakugan_index.size()):
		if bs.cell_bakugan_index[cell] == griffon_idx:
			bs.cell_bakugan_index[cell] = -1
			var mi: MeshInstance3D = bs.cell_bakugan_meshes[cell]
			if mi and is_instance_valid(mi):
				mi.queue_free()
			bs.cell_bakugan_meshes[cell] = null
			bs.cell_bakugan_open[cell]   = false
			break
	griffon["g_power"] = 0
	bs.player_models[griffon_idx] = griffon

	# Переходим в режим ожидания выбора получателя
	bs.pending_holy_beast_transfer = true
	bs._highlight_field_bakugans_for_transfer()
	print("Holy Beast: Грифон проиграл (%d G). Выберите бакугана-получателя на поле." % bs.holy_beast_transfer_gpower)
	return true
