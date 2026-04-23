extends Node

# ================================================================
# GameData.gd  —  Автозагрузчик с данными
# Добавить в Project → Project Settings → Autoload как "GameData"
#
# Здесь хранится ВСЁ:
#   - данные о каждом бакугане (пути, имя, G-сила, описание)
#   - данные о каждой карте (путь, имя, тип, эффект)
#   - структура наборов (какие бакуганы и карты входят в набор)
#
# Global.gd просто обращается к GameData и содержит только логику.
# ================================================================


# ════════════════════════════════════════════════════════════════
#  БАКУГАНЫ
#  Ключ — уникальный ID строкой, чтобы легко ссылаться из наборов.
#  Поля:
#    name          — отображаемое имя
#    g_power       — базовая G-сила
#    element       — стихия
#    description   — описание / способность
#    mesh_close    — путь к закрытой модели (.obj)
#    mesh_open     — путь к открытой модели (.obj)
#    texture       — путь к текстуре
# ════════════════════════════════════════════════════════════════
var bakugans: Dictionary = {

	# ── Огненные (Pyrus) ────────────────────────────────────────
	"pyrus_warius": {
		"name":        "Воин",
		"g_power":     360,
		"element":     "Pyrus",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Wariuis Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Wariuis Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/Pyrus Warius HD.png",
	},
	"pyrus_griffon": {
		"name":        "Грифон",
		"g_power":     330,
		"element":     "Pyrus",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Griffon Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Griffon stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/Pyrus Griffon HD.jpg",
	},
	"pyrus_manion": {
		"name":        "Сфинкс",
		"g_power":     380,
		"element":     "Pyrus",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Manion Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Manion open.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/Pyrus Manion HD.jpg",
	},
	"pyrus_leonidas": {
		"name":        "Леонидас",
		"g_power":     420,
		"element":     "Огненный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Leonidas Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Leonidas Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/Pyrus Leonidas HD.png",
	},
	"pyrus_saurus": {
		"name":        "Саурус",
		"g_power":     380,
		"element":     "Огненный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Saurus Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Saurus Stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/saurus pyrus hd.png",
	},
	"pyrus_falconeer": {
		"name":        "Сокол",
		"g_power":     350,
		"element":     "Огненный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Falconeer Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Falconeer stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/Pyrus Falconeer HD.jpg",
	},
	"pyrus_b7": {
		"name":        "Pyrus #7",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_7.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_7.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_7.png",
	},
	"pyrus_b8": {
		"name":        "Pyrus #8",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_8.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_8.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_8.png",
	},
	"pyrus_b9": {
		"name":        "Pyrus #9",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_9.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_9.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_9.png",
	},
	"pyrus_b10": {
		"name":        "Pyrus #10",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_10.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_10.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_10.png",
	},
	"pyrus_b11": {
		"name":        "Pyrus #11",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_11.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_11.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_11.png",
	},
	"pyrus_b12": {
		"name":        "Pyrus #12",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_12.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_12.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_12.png",
	},
	"pyrus_b13": {
		"name":        "Pyrus #13",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_13.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_13.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_13.png",
	},
	"pyrus_b14": {
		"name":        "Pyrus #14",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_14.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_14.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_14.png",
	},
	"pyrus_b15": {
		"name":        "Pyrus #15",
		"g_power":     0,
		"element":     "Огненный",
		"description": "",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/pyrus_model_15.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/pyrus_model_15.obj",
		"texture":     "res://Textures/TexturesBakugans/Pyrus/pyrus_texture_15.png",
	},

	# ── Воздушные (Ventus) ──────────────────────────────────────
	"ventus_leonidas": {
		"name":        "Леонидас",
		"g_power":     420,
		"element":     "Воздушный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Leonidas Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Leonidas Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Ventus/Ventus Leonidas HD.png",
	},
	"ventus_bee_striker": {
		"name":        "Пчела убийца",
		"g_power":     350,
		"element":     "Воздушный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Bee Striker Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Bee Striker Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Ventus/Ventus Bee Striker.png",
	},
	"ventus_monarus": {
		"name":        "Мотылёк",
		"g_power":     360,
		"element":     "Воздушный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Monarus Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Monarus Stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Ventus/Ventus Monarus HD.jpg",
	},

	# ── Земляные (Subterra) ─────────────────────────────────────
	"subterra_leonidas": {
		"name":        "Леонидас",
		"g_power":     420,
		"element":     "Земляной",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Leonidas Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Leonidas Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Subterra/Subterra Leonidas.png",
	},
	"subterra_manion": {
		"name":        "Сфинкс",
		"g_power":     380,
		"element":     "Земляной",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Manion Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Manion open.obj",
		"texture":     "res://Textures/TexturesBakugans/Subterra/Subterra Manion.png",
	},
	"subterra_tuskor": {
		"name":        "Бивень",
		"g_power":     360,
		"element":     "Земляной",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Tuskor Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Tuskor Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Subterra/Subterra Tuskor.png",
	},

	# ── Водные (Aquos) ──────────────────────────────────────────
	"aquos_leonidas": {
		"name":        "Леонидас",
		"g_power":     420,
		"element":     "Водный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Leonidas Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Leonidas Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Aquos/Aquos Leonidas HD.png",
	},
	"aquos_juggernoid": {
		"name":        "Джагерноид",
		"g_power":     340,
		"element":     "Водный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Juggernoid Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Juggernoid Stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Aquos/Juggernoid Aquos HD.png",
	},
	"aquos_terrorclaw": {
		"name":        "Коготь ужаса",
		"g_power":     340,
		"element":     "Водный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Terrorclaw Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Terrorclaw Stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Aquos/Aquos Terrorclaw HD.jpg",
	},

	# ── Светлые (Haos) ──────────────────────────────────────────
	"haos_leonidas": {
		"name":        "Леонидас",
		"g_power":     420,
		"element":     "Светлый",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Leonidas Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Leonidas Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Haos/Haos Leonidas HD.png",
	},
	"haos_ravenoid": {
		"name":        "Ворон",
		"g_power":     350,
		"element":     "Светлый",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Ravenoid Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Ravenoid Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Haos/Haos Ravenoid HD.jpg",
	},
	"haos_griffon": {
		"name":        "Гриффон",
		"g_power":     330,
		"element":     "Светлый",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Griffon Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Griffon stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Haos/Haos Griffon HD.jpg",
	},

	# ── Тёмные (Darkus) ─────────────────────────────────────────
	"darkus_leonidas": {
		"name":        "Леонидас",
		"g_power":     420,
		"element":     "Тёмный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Leonidas Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Leonidas Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Darkus/Darkus Leonidas HD.png",
	},
	"darkus_mantris": {
		"name":        "Мантрис",
		"g_power":     310,
		"element":     "Тёмный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Mantris Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Mantris Open.obj",
		"texture":     "res://Textures/TexturesBakugans/Darkus/Darkus Mantris.png",
	},
	"darkus_laserman": {
		"name":        "Лазер",
		"g_power":     320,
		"element":     "Тёмный",
		"mesh_close":  "res://Textures/TexturesBakugans/ModelClose/Laserman Closed.obj",
		"mesh_open":   "res://Textures/TexturesBakugans/ModelOpen/Laserman Stand.obj",
		"texture":     "res://Textures/TexturesBakugans/Darkus/Darkus Laserman HD.jpg",
	},
}


# ════════════════════════════════════════════════════════════════
#  КАРТЫ
#  Ключ — уникальный ID строкой.
#  Поля:
#    name        — отображаемое имя
#    type        — "ability" | "gate"
#    element     — стихия (или "any" для универсальных)
#    effect      — описание эффекта
#    texture     — путь к изображению карты
# ════════════════════════════════════════════════════════════════
var cards: Dictionary = {

	#Карты способностей
	"card_amun_re": {
		"name":    "Amun Re",
		"type":    "ability",
		"element": "Any",
		"effect":  "-",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/AmunRe.jpg",
	},
	"card_battle_spirit": {
		"name":    "Battle Spirit",
		"type":    "ability",
		"element": "Pyrus",
		"effect":  "-",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/BattleSpirit.jpg",
	},
	"card_holy_beast": {
		"name":    "Holy Beast Spirit Attack",
		"type":    "ability",
		"element": "Pyrus and Haos",
		"effect":  "Грифон проигрывает и добавляет свою G-силу одному из ваших Бакуганов на поле.",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/HolyBeastSpiritAttack.jpg",
	},
	"card_fire_judge":  {
		"name": "Fire judge",
		"type": "ability",
		"element": "Pyrus",
		"effect": "-",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/PyrusCards/FireJugde.jpg"
	},
	"card_fire_tornado":  {
		"name": "Fire tornado",
		"type": "ability",
		"element": "Pyrus",
		"effect": "Вычтите 100G у вражеского бакугана",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/PyrusCards/FireTornado.jpg"
	},
	"card_power_charge":  {
		"name": "Power charge",
		"type": "ability",
		"element": "Pyrus",
		"effect": "Прибавь своему бакугану 100G. Можешь перенести его на любую карту ворот",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/PyrusCards/PowerCharge.jpg"
	},
	"card_overheat":  {
		"name": "Overheat",
		"type": "ability",
		"element": "Pyrus",
		"effect": "Прибавь 300G твоему бакугану. Когда он покинет поле отними у него 100G до конца игры",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/PyrusCards/Overheat.jpg"
	},
	"card_burning_charge":  {
		"name": "Burning charge",
		"type": "ability",
		"element": "Pyrus and Haos",
		"effect": "Прибавь 100G Саурусу. Если он выиграет бой, то сохранит 100G до конца игры и переместится на соседнюю карту ворот",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/BurningCharge.jpg"
	},
	"card_pyrus_comet":  {
		"name": "Pyrus comet",
		"type": "ability",
		"element": "Pyrus",
		"effect": "Когда Леонидас на поле, все бакуганы противника на этой карте ворот с меньшей G-силой чем у него, проигрывают",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/PyrusComet.jpg"
	},
	"card_strong_winds":  {
		"name": "Strong winds",
		"type": "ability",
		"element": "Pyrus and Ventus",
		"effect": "Сокол удваивает количество G, которое получил твой бакуган от карты ворот",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/StrongWinds.jpg"
	},
	"card_saving_grace":  {
		"name": "Saving grace",
		"type": "ability",
		"element": "Ventus and Haos",
		"effect": "Остальные ваши бакуганы не могут проиграть в бою, пока Мотылёк не покинет поле боя. Или можете вернуть всех своих бакуганов в руку",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/SavingGrace.jpg"
	},
	"card_ventus_storm":  {
		"name": "Ventus storm",
		"type": "ability",
		"element": "Ventus",
		"effect": "Когда леонидас открывается на карте ворот противника, его действия анулируется. Все бакуганы на этой и соседних картах ворот возвращаются их владельцам",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/VentusStorm.jpg"
	},
	"card_reverse_blow":  {
		"name": "Reverse blow",
		"type": "ability",
		"element": "Ventus and Subterra",
		"effect": "Пчела убийца перемещает себя и вражеского бакугана на другую карту ворот",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/ReverseBlow.jpg"
	},
	"card_blow_away":  {
		"name": "Blow away",
		"type": "ability",
		"element": "Ventus",
		"effect": "Переместите бакугана противника на другую карту ворот",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/VentusCards/BlowAway.jpg"
	},
	"card_scarlet_twister":  {
		"name": "Scarlet twister",
		"type": "ability",
		"element": "Ventus",
		"effect": "Верните себе любое количество ваших бакуганов, находящихся на поле. За каждого возвращённого бакугана вычитается 50G у вражеского бакугана на поле",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/VentusCards/ScarletTwister.jpg"
	},
	"card_air_battle":  {
		"name": "Air battle",
		"type": "ability",
		"element": "Ventus",
		"effect": "Переместите одного из ваших бакуганов на любую карту ворот и анулируйте её эффект",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/VentusCards/AirBattle.jpg"
	},
	"card_earth_power":  {
		"name": "Earth power",
		"type": "ability",
		"element": "Subterra andVentus",
		"effect": "Положите одну из ваших использованных карт ворот на поле. За каждую карту ворот на поле Сфинкс получает 50G",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/EarthPower.jpg"
	},
	"card_subterra_quake":  {
		"name": "Subterra quake",
		"type": "ability",
		"element": "Subterra",
		"effect": "Когда Леонидас появляется на поле, верните все карты ворот и бакуганов на поле их владельцам, за исключение карты ворот на которой находится леонидас вместе с другими бакуганами на ней",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/SubterraQuake.jpg"
	},
	"card_earth_shatter":  {
		"name": "Earth shatter",
		"type": "ability",
		"element": "Subterra and Haos",
		"effect": "Закройте карту ворот на которой находится Бивень и все соседние карты ворот с ней",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/EarthShatter.jpg"
	},
	"card_grand_slide":  {
		"name": "Grand slide",
		"type": "ability",
		"element": "Subterra",
		"effect": "Переместите карту ворот в любое место на поле и позвольте вашему соседнему бакугану атаковать всех вражеских бакуганов находящихся на этом поле",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/SubterraCards/GrandSlide.jpg"
	},
	"card_copycat":  {
		"name": "Copycat",
		"type": "ability",
		"element": "Subterra",
		"effect": "Скопируйте способность которую использовал противник",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/SubterraCards/Copycat.jpg"
	},
	"card_spirit_canyon":  {
		"name": "Spirit canyon",
		"type": "ability",
		"element": "Subterra",
		"effect": "Анулируйте или отразите действие карты ворот",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/SubterraCards/SpiritCanyon.jpg"
	},
	"card_mirror_shell":  {
		"name": "Mirror shell",
		"type": "ability",
		"element": "Aquos and Haos",
		"effect": "Джагерноид копирует и удваивает карту способностей, используемую противником",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/MirrorShell.jpg"
	},
	"card_lock_claw":  {
		"name": "Lock claw",
		"type": "ability",
		"element": "Aquos and Haos",
		"effect": "Коготь ужаса  уменьшает силу вражеского бакугана на 100G и предотвращает активацию его фирменных способностей во время битвы",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/LockClaw.jpg"
	},
	"card_aquos_spiral":  {
		"name": "Aquos spiral",
		"type": "ability",
		"element": "Aquos",
		"effect": "Переместите Леонидаса на любую карту ворот. Леонидас не может быть подвержен воздействию карт способностей до конца своей следующей битвы",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/AquosSpiral.jpg"
	},
	"card_water_veil":  {
		"name": "Water veil",
		"type": "ability",
		"element": "Aquos",
		"effect": "Выберите карту ворот на игровом поле. Когда один из ваших бакуганов попадает на эту карту ворот, он получает 100G",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/AquosCards/WaterVeil.jpg"
	},
	"card_dive_mirage":  {
		"name": "Dive mirage",
		"type": "ability",
		"element": "Aquos",
		"effect": "Переместите своего бакугана на любую другую карту ворот, в результате чего выбранная вами карта ворот будет аннулирована",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/AquosCards/DiveMirage.jpg"
	},
	"card_water_refrain":  {
		"name": "Water refrain",
		"type": "ability",
		"element": "Aquos",
		"effect": "Анулируйте обычную карту способностей противника. Также предотвратите активацию обычных карт способностей до конца следующего хода",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/AquosCards/WaterRefrain.jpg"
	},
	"card_spark_out":  {
		"name": "Spark out",
		"type": "ability",
		"element": "Haos and Ventus",
		"effect": "Ворон аннулирует карту ворот противника и не позволяет противнику открывать карты ворот до конца следующего хода",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/SparkOut.jpg"
	},
	"card_haos_lighting":  {
		"name": "Haos lighting",
		"type": "ability",
		"element": "Haos",
		"effect": "Леонидас возвращает любого противостоящего бакугана на карте ворот к своему владельцу. Вы можете выбрать одного из ваших побежденных бакуганов для возрождения",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/HaosLighting.jpg"
	},
	"card_haos_freeze":  {
		"name": "Haos freeze",
		"type": "ability",
		"element": "Haos",
		"effect": "Приостановите текущую битву до тех пор, пока к ней не присоединится другой ваш бакуган. Нельзя использовать если это ваш последний бакуган",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/HaosCards/HaosFreeze.jpg"
	},
	"card_shade_ability":  {
		"name": "Shade ability",
		"type": "ability",
		"element": "Haos",
		"effect": "Аннулируйте фирменную способность бакугана противника",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/HaosCards/ShadeAbility.jpg"
	},
	"card_lightning_tornado":  {
		"name": "Lightning tornado",
		"type": "ability",
		"element": "Haos",
		"effect": " Добавьте 200G к вашему бакугану",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/HaosCards/LightningTornado.jpg"
	},
	"card_darkus_phantom":  {
		"name": "Darkus phantom",
		"type": "ability",
		"element": "Darkus",
		"effect": "Леонидас аннулирует карту ворот противника, на которой находится или любые способности противника, нацеленные на Леонидаса, до тех пор, пока он не покинет поле",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/DarkusPhantom.jpg"
	},
	"card_leap_sting":  {
		"name": "Leap sting",
		"type": "ability",
		"element": "Darkus and Ventus",
		"effect": "Лазер может атаковать из любой точки поля и уменьшить G-силу бакугана противника на 100G",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/LeapSting.jpg"
	},
	"card_marionette":  {
		"name": "Marionette",
		"type": "ability",
		"element": "Darkus and Pyrus",
		"effect": "Мантрис перемещает бакугана на поля к любой карте ворот",
		"texture": "res://Textures/Cards/AbilityCards/NameAbilityCards/Marionette.jpg"
	},
	"card_grand_down":  {
		"name": "Grand down",
		"type": "ability",
		"element": "Darkus",
		"effect": "Аннулируйте карту ворот противника",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/DarkusCards/GrandDown.jpg"
	},
	"card_auragano_revenge":  {
		"name": "Auragano revenge",
		"type": "ability",
		"element": "Darkus",
		"effect": "Отнимите 200G у бакугана противника",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/DarkusCards/AuraganoRevenge.jpg"
	},
	"card_darkus_gravity":  {
		"name": "Darkus gravity",
		"type": "ability",
		"element": "Darkus",
		"effect": "Добавьте одного вашего Даркус бакугана в бой",
		"texture": "res://Textures/Cards/AbilityCards/ElementsCards/DarkusCards/DarkusGravity.jpg"
	},
	
	#Карты ворот
	
	"card_pyrus_gate": {
		"name":    "Pyrus Gate Card",
		"type":    "gate",
		"effect":  "Прибавьте 120G к вашим Пайрус бакуганам на карте ворот",
		"texture": "res://Textures/Cards/GateCards/elemental cards/PyrusGateCard.jpg",
	},
	"card_warius_name": {
		"name":    "Warius Name Card",
		"type":    "gate",
		"effect":  "Удвойте G-силу Воина",
		"texture": "res://Textures/Cards/GateCards/NameCards/WaririusCard.jpg",
	},
	"card_intercept": {
		"name":    "Intercept",
		"type":    "gate",
		"effect":  "Заморозьде бой до тех пор пока сами не решите его продолжить. На эту карту не могут попасть другие бакуганы. Если это последний бакуган любой из сторон, бой продолжается",
		"texture": "res://Textures/Cards/GateCards/RuleCards/Intercept.jpg",
	},
	"card_falconeer_name": {
		"name": "Falconeer Name Card",
		"type": "gate",
		"effect": "Удвойте G-силу Сокола",
		"texture": "res://Textures/Cards/GateCards/NameCards/FalconeerCard.jpg"
	},
	"card_king's_gambit": {
		"name": "King's gambit",
		"type": "gate",
		"effect": "Если бакуган игрока пайрус, то прибавьте по 100G ко всем своим бакуганам на поле",
		"texture": "res://Textures/Cards/GateCards/RuleCards/King'sGambit.jpg"
	},
	"card_ventus_gate": {
		"name":    "Ventus Gate Card",
		"type":    "gate",
		"effect":  "Прибавьте 120G к вашим Вентус бакуганам на карте ворот",
		"texture": "res://Textures/Cards/GateCards/elemental cards/VentusGateCard.jpg",
	},
	"card_bee_striker_name": {
		"name": "Bee striker Name Card",
		"type": "gate",
		"effect": "Удвойте G-силу Пчелы убийцы",
		"texture": "res://Textures/Cards/GateCards/NameCards/BeeStrikerCard.jpg"
	},
	"card_ace's_ploy": {
		"name": "Ace's ploy",
		"type": "gate",
		"effect": "Если бакуган игрока вентус, то он может перенести до двух бакуганов на поле на любую карту ворот",
		"texture": "res://Textures/Cards/GateCards/RuleCards/Ace'sPloy.jpg"
	},
		"card_jack's_trade": {
		"name":    "Jack's trade",
		"type":    "gate",
		"effect":  "Если ваш бакуган Сабтерра, то он может поменять местами любые дву карты ворот",
		"texture": "res://Textures/Cards/GateCards/RuleCards/Jack'sTrade.jpg",
	},
	"card_tuskor_name": {
		"name": "Tuskor Name Card",
		"type": "gate",
		"effect": "Удвойте G-силу Бивня",
		"texture": "res://Textures/Cards/GateCards/NameCards/TuskorCard.jpg"
	},
	"card_subterra_gate": {
		"name":    "Subterra Gate Card",
		"type":    "gate",
		"effect":  "Прибавьте 120G к вашим Сабтерра бакуганам на карте ворот",
		"texture": "res://Textures/Cards/GateCards/elemental cards/SubterraGateCard.jpg",
	},
	"card_aquos_gate": {
		"name":    "Aquos Gate Card",
		"type":    "gate",
		"effect":  "Прибавьте 120G к вашим Аквас бакуганам на карте ворот",
		"texture": "res://Textures/Cards/GateCards/elemental cards/AquosGateCard.jpg",
	},
	"card_juggernoid_name": {
		"name": "Juggernoid Name Card",
		"type": "gate",
		"effect": "Удвойте G-силу Джагерноида",
		"texture": "res://Textures/Cards/GateCards/NameCards/JuggernoidCard.jpg"
	},
	"card_suit's_rule": {
		"name":    "Suit's rule",
		"type":    "gate",
		"effect":  "Если бакуган пользователя Аквас, то применяется эффект карты ворот Акваса",
		"texture": "res://Textures/Cards/GateCards/RuleCards/Suit'sRule.jpg",
	},
	"card_queen's_grace": {
		"name":    "Queen's grace",
		"type":    "gate",
		"effect":  "Если ваш бакуган — Хаос, то воскресите одного из ваших побежденных бакуганов и добавляет его в битву",
		"texture": "res://Textures/Cards/GateCards/RuleCards/Queen'sGrace.jpg",
	},
	"card_griffon_name": {
		"name": "Griffon Name Card",
		"type": "gate",
		"effect": "Удвойте G-силу Грифона",
		"texture": "res://Textures/Cards/GateCards/NameCards/GriffonHaosCard.png"
	},
	"card_haos_gate": {
		"name":    "Haos Gate Card",
		"type":    "gate",
		"effect":  "Прибавьте 120G к вашим Хаос бакуганам на карте ворот",
		"texture": "res://Textures/Cards/GateCards/elemental cards/HaosGateCard.jpg",
	},
	"card_darkus_gate": {
		"name":    "Darkus Gate Card",
		"type":    "gate",
		"effect":  "Прибавьте 120G к вашим Даркус бакуганам на карте ворот",
		"texture": "res://Textures/Cards/GateCards/elemental cards/DarkusGateCard.jpg",
	},
	"card_laserman_name": {
		"name": "Laserman Name Card",
		"type": "gate",
		"effect": "Удвойте G-силу Лазера",
		"texture": "res://Textures/Cards/GateCards/NameCards/LasermanCard.jpg"
	},
	"card_joker's_wild": {
		"name":    "Joker's wild",
		"type":    "gate",
		"effect":  "Если ваш бакуган — Даркус, он мгновенно побеждает всех бакуганов противника на этой карте ворот",
		"texture": "res://Textures/Cards/GateCards/RuleCards/Joker'sWild.jpg",
	},
}

# ════════════════════════════════════════════════════════════════
#  НАБОРЫ
#  Здесь только ссылки на ID бакуганов и карт — никаких путей!
#  Global.gd сам разворачивает ID в полные данные при необходимости.
# ════════════════════════════════════════════════════════════════
var pack_data: Dictionary = {
	"Огненный": {
			"bakugans": ["pyrus_leonidas", "pyrus_saurus", "pyrus_falconeer"],
			"ability_cards": ["card_burning_charge", "card_pyrus_comet", "card_strong_winds",
							  "card_power_charge", "card_overheat", "card_fire_tornado"],
			"gate_cards": ["card_pyrus_gate", "card_falconeer_name", "card_king's_gambit"],
	},
	"Воздушный": {
		"bakugans": ["ventus_leonidas", "ventus_bee_striker", "ventus_monarus"],
		"ability_cards": ["card_saving_grace", "card_ventus_storm", "card_reverse_blow",
						  "card_blow_away", "card_scarlet_twister", "card_air_battle"],
		"gate_cards": ["card_ventus_gate", "card_bee_striker_name", "card_ace's_ploy"],
	},
	"Земляной": {
		"bakugans": ["subterra_leonidas", "subterra_manion", "subterra_tuskor"],
		"ability_cards": ["card_earth_power", "card_subterra_quake", "card_earth_shatter",
						  "card_grand_slide", "card_copycat", "card_spirit_canyon"],
		"gate_cards": ["card_subterra_gate", "card_tuskor_name", "card_jack's_trade"],
	},
	"Водный": {
		"bakugans": ["aquos_leonidas", "aquos_juggernoid", "aquos_terrorclaw"],
		"ability_cards": ["card_mirror_shell", "card_aquos_spiral", "card_lock_claw",
						  "card_water_veil", "card_dive_mirage", "card_water_refrain"],
		"gate_cards": ["card_aquos_gate", "card_juggernoid_name", "card_suit's_rule"],
	},
	"Светлый": {
		"bakugans": ["haos_leonidas", "haos_ravenoid", "haos_griffon"],
		"ability_cards": ["card_spark_out", "card_haos_lighting", "card_holy_beast",
						  "card_haos_freeze", "card_shade_ability", "card_lightning_tornado"],
		"gate_cards": ["card_haos_gate", "card_griffon_name", "card_queen's_grace"],
	},
	"Тёмный": {
		"bakugans": ["darkus_leonidas", "darkus_mantris", "darkus_laserman"],
		"ability_cards": ["card_darkus_phantom", "card_leap_sting", "card_marionette",
						  "card_grand_down", "card_auragano_revenge", "card_darkus_gravity"],
		"gate_cards": ["card_darkus_gate", "card_laserman_name", "card_joker's_wild"],
	},
}

# ════════════════════════════════════════════════════════════════
#  ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
#  Разворачивают ID в полные данные — используются в Global.gd
# ════════════════════════════════════════════════════════════════

# Возвращает словарь бакугана по ID (совместимый со старым форматом Global)
func get_bakugan(id: String) -> Dictionary:
	if not bakugans.has(id):
		push_warning("GameData: неизвестный ID бакугана: " + id)
		return {}
	var b = bakugans[id]
	return {
		"mesh_path":      b["mesh_close"],
		"open_mesh_path": b["mesh_open"],
		"texture_path":   b["texture"],
		"name":           b["name"],
		"g_power":        b["g_power"],
	}

# Возвращает путь к текстуре карты по ID
func get_card_texture(id: String) -> String:
	if not cards.has(id):
		push_warning("GameData: неизвестный ID карты: " + id)
		return ""
	return cards[id]["texture"]

# Возвращает данные карты по пути к текстуре (для обратной совместимости)
func get_card_info_by_texture(texture_path: String) -> Dictionary:
	for id in cards.keys():
		if cards[id]["texture"] == texture_path:
			return cards[id]
	return {}

# Разворачивает список ID бакуганов в массив словарей (старый формат)
func resolve_bakugans(ids: Array) -> Array:
	var result: Array = []
	for id in ids:
		var data = get_bakugan(id)
		if not data.is_empty():
			result.append(data)
	return result

# Разворачивает список ID карт в массив путей к текстурам (старый формат)
func resolve_card_textures(ids: Array) -> Array:
	var result: Array = []
	for id in ids:
		var path = get_card_texture(id)
		if path != "":
			result.append(path)
	return result

# Возвращает все бакуганы конкретной стихии
func get_bakugans_by_element(element: String) -> Array:
	var result: Array = []
	for id in bakugans.keys():
		if bakugans[id]["element"] == element:
			result.append(id)
	return result

# Возвращает все карты конкретной стихии и типа ("ability" / "gate" / "")
func get_cards_by_element(element: String, type_filter: String = "") -> Array:
	var result: Array = []
	for id in cards.keys():
		var c = cards[id]
		if c["element"] == element or c["element"] == "any":
			if type_filter == "" or c["type"] == type_filter:
				result.append(id)
	return result
