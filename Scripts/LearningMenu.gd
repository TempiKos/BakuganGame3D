extends Control

# ================================================================
# LearningMenu.gd
# Статичный каркас — в LearningMenu.tscn.
# Скрипт заполняет только динамические контейнеры:
#   - TopicsContainer  — карточки тем
#   - RewardsContainer — строки наград
# ================================================================

func _ready() -> void:
	$ScrollContainer/VBoxContainer/BackButton.pressed.connect(
		func(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	)
	_update_progress_label()
	_fill_topics()
	_fill_rewards()


func _update_progress_label() -> void:
	var completed = LearningData.get_completed_count()
	var total     = LearningData.topics.size()
	$ScrollContainer/VBoxContainer/ProgressLabel.text = \
		"Пройдено тем: %d / %d" % [completed, total]


# ── Карточки тем ────────────────────────────────────────────────

func _fill_topics() -> void:
	var container = $ScrollContainer/VBoxContainer/TopicsContainer
	for i in range(LearningData.topics.size()):
		container.add_child(_make_topic_card(
			i,
			LearningData.topics[i],
			LearningData.is_topic_unlocked(i),
			LearningData.is_topic_completed(i)
		))


func _make_topic_card(index: int, topic: Dictionary, unlocked: bool, done: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 110 if done else 90)

	var style := StyleBoxFlat.new()
	if done:
		style.bg_color     = Color(0.1, 0.25, 0.1)
		style.border_color = Color(0.3, 0.9, 0.3)
	elif unlocked:
		style.bg_color     = Color(0.12, 0.1, 0.22)
		style.border_color = Color(0.5, 0.3, 0.9)
	else:
		style.bg_color     = Color(0.1, 0.1, 0.12)
		style.border_color = Color(0.25, 0.25, 0.3)
	style.set_border_width_all(2)
	style.corner_radius_top_left     = 10
	style.corner_radius_top_right    = 10
	style.corner_radius_bottom_left  = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)

	# Иконка
	var icon_label := Label.new()
	icon_label.text = topic["icon"] if unlocked else "🔒"
	icon_label.add_theme_font_size_override("font_size", 36)
	icon_label.custom_minimum_size    = Vector2(60, 0)
	icon_label.horizontal_alignment   = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment     = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_label)

	# Текст
	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	var num_label := Label.new()
	num_label.text = "Тема %d" % (index + 1)
	num_label.add_theme_font_size_override("font_size", 13)
	num_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	text_vbox.add_child(num_label)

	var name_label := Label.new()
	name_label.text = topic["title"]
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color",
		Color(0.9, 0.9, 0.9) if unlocked else Color(0.4, 0.4, 0.45))
	text_vbox.add_child(name_label)

	if not unlocked:
		var lock_hint := Label.new()
		lock_hint.text = "🔒 Пройди предыдущую тему"
		lock_hint.add_theme_font_size_override("font_size", 13)
		lock_hint.add_theme_color_override("font_color", Color(0.5, 0.45, 0.45))
		text_vbox.add_child(lock_hint)

	# Кнопки справа
	var status_vbox := VBoxContainer.new()
	status_vbox.custom_minimum_size = Vector2(120, 0)
	status_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(status_vbox)

	if done:
		var badge := Label.new()
		badge.text = "✅ Пройдено"
		badge.add_theme_font_size_override("font_size", 14)
		badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_vbox.add_child(badge)

		var theory_btn := Button.new()
		theory_btn.text = "📖 Теория"
		theory_btn.add_theme_font_size_override("font_size", 14)
		theory_btn.custom_minimum_size = Vector2(110, 34)
		theory_btn.pressed.connect(_on_topic_pressed.bind(index))
		status_vbox.add_child(theory_btn)

		var quiz_btn := Button.new()
		quiz_btn.text = "📝 Тест снова"
		quiz_btn.add_theme_font_size_override("font_size", 14)
		quiz_btn.custom_minimum_size = Vector2(110, 34)
		quiz_btn.pressed.connect(_on_quiz_pressed.bind(index))
		status_vbox.add_child(quiz_btn)

	elif unlocked:
		var go_btn := Button.new()
		go_btn.text = "Учиться →"
		go_btn.add_theme_font_size_override("font_size", 16)
		go_btn.custom_minimum_size = Vector2(110, 40)
		go_btn.pressed.connect(_on_topic_pressed.bind(index))
		status_vbox.add_child(go_btn)

	else:
		var lock_lbl := Label.new()
		lock_lbl.text = "Заблокировано"
		lock_lbl.add_theme_font_size_override("font_size", 13)
		lock_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		lock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_vbox.add_child(lock_lbl)

	return panel


# ── Строки наград ────────────────────────────────────────────────

func _fill_rewards() -> void:
	var container = $ScrollContainer/VBoxContainer/RewardsContainer
	var rewards = [
		["Тема 1", "Воздушный, Земляной наборы + Огненный Набор 2"],
		["Тема 2", "Водный, Светлый, Тёмный наборы + Огненный Набор 3"],
		["Тема 3", "Огненный Набор 4"],
		["Тема 4", "Огненный Набор 5"],
		["Тема 5", "🔓 Редактор своих наборов!"],
	]
	for i in range(rewards.size()):
		var done = LearningData.is_topic_completed(i)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		container.add_child(row)

		var check := Label.new()
		check.text = "✅" if done else "⬜"
		check.add_theme_font_size_override("font_size", 18)
		row.add_child(check)

		var lbl := Label.new()
		lbl.text = "%s → %s" % [rewards[i][0], rewards[i][1]]
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.add_theme_color_override("font_color",
			Color(0.7, 1.0, 0.7) if done else Color(0.65, 0.65, 0.7))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)


# ── Переходы ────────────────────────────────────────────────────

func _on_topic_pressed(index: int) -> void:
	Global.current_learning_topic = index
	get_tree().change_scene_to_file("res://Scenes/LearningTopicView.tscn")

func _on_quiz_pressed(index: int) -> void:
	Global.current_learning_topic = index
	get_tree().change_scene_to_file("res://Scenes/LearningQuiz.tscn")
