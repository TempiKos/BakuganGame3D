extends Control

# ================================================================
# LearningQuiz.gd
# Статичный каркас — в LearningQuiz.tscn.
# Скрипт управляет только логикой:
#   - заполняет OptionsContainer кнопками вариантов
#   - показывает/скрывает FeedbackPanel
#   - заполняет ResultPanel данными и переключает видимость
# ================================================================

var topic_index: int = 0
var topic:       Dictionary = {}
var questions:   Array = []
var current_q:   int = 0
var score:       int = 0
var answered:    bool = false

# Ссылки на узлы сцены
@onready var main_panel:       PanelContainer = $MainPanel
@onready var title_label:      Label          = $MainPanel/VBoxContainer/TitleLabel
@onready var q_counter_label:  Label          = $MainPanel/VBoxContainer/HeaderRow/QuestionCounterLabel
@onready var score_label:      Label          = $MainPanel/VBoxContainer/HeaderRow/ScoreLabel
@onready var question_label:   Label          = $MainPanel/VBoxContainer/QuestionLabel
@onready var options_container: VBoxContainer = $MainPanel/VBoxContainer/OptionsContainer
@onready var feedback_panel:   PanelContainer = $MainPanel/VBoxContainer/FeedbackPanel
@onready var feedback_label:   Label          = $MainPanel/VBoxContainer/FeedbackPanel/FeedbackLabel
@onready var next_btn:         Button         = $MainPanel/VBoxContainer/NextButton

@onready var result_panel:        PanelContainer = $ResultPanel
@onready var result_icon:         Label          = $ResultPanel/ResultVBox/ResultIcon
@onready var result_score_label:  Label          = $ResultPanel/ResultVBox/ResultScoreLabel
@onready var result_status_label: Label          = $ResultPanel/ResultVBox/ResultStatusLabel
@onready var unlock_label:        Label          = $ResultPanel/ResultVBox/UnlockLabel
@onready var retry_btn:           Button         = $ResultPanel/ResultVBox/ResultButtons/RetryButton
@onready var menu_btn:            Button         = $ResultPanel/ResultVBox/ResultButtons/MenuButton
@onready var main_menu_btn:       Button         = $ResultPanel/ResultVBox/ResultButtons/MainMenuButton


func _ready() -> void:
	topic_index = Global.current_learning_topic
	topic       = LearningData.topics[topic_index]
	questions   = topic["questions"]

	title_label.text = "📝  Тест: %s" % topic["title"]

	next_btn.pressed.connect(_on_next_question)
	retry_btn.pressed.connect(_on_retry)
	menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/LearningMenu.tscn"))
	main_menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn"))

	_show_question()


# ════════════════════════════════════════════════════════════════
#  ЛОГИКА ВОПРОСОВ
# ════════════════════════════════════════════════════════════════

func _show_question() -> void:
	answered = false
	feedback_panel.visible = false
	next_btn.visible       = false

	var q = questions[current_q]
	q_counter_label.text = "Вопрос %d / %d" % [current_q + 1, questions.size()]
	score_label.text     = "✅ %d" % score
	question_label.text  = q["text"]

	# Очищаем старые варианты и создаём новые
	for child in options_container.get_children():
		child.queue_free()
	for i in range(q["options"].size()):
		var btn := Button.new()
		btn.text = q["options"][i]
		btn.add_theme_font_size_override("font_size", 17)
		btn.custom_minimum_size   = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_answer.bind(i))
		options_container.add_child(btn)


func _on_answer(chosen: int) -> void:
	if answered:
		return
	answered = true

	var q       = questions[current_q]
	var correct = q["correct"]
	var is_ok   = (chosen == correct)

	if is_ok:
		score += 1

	# Подсвечиваем кнопки
	var btns = options_container.get_children()
	for i in range(btns.size()):
		btns[i].disabled = true
		if i == correct:
			btns[i].add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
		elif i == chosen and not is_ok:
			btns[i].add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	# Обратная связь
	var fb_style = StyleBoxFlat.new()
	if is_ok:
		fb_style.bg_color     = Color(0.07, 0.20, 0.08)
		fb_style.border_color = Color(0.2, 0.8, 0.2)
		feedback_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		feedback_label.text = "✅ Правильно!\n" + q["explanation"]
	else:
		fb_style.bg_color     = Color(0.20, 0.07, 0.07)
		fb_style.border_color = Color(0.8, 0.2, 0.2)
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		feedback_label.text = ("💡 Подсказка:\n" + q["hint"]) if q.has("hint") \
			else ("❌ Неверно.\n" + q["explanation"])
	fb_style.set_border_width_all(2)
	fb_style.corner_radius_top_left     = 8
	fb_style.corner_radius_top_right    = 8
	fb_style.corner_radius_bottom_left  = 8
	fb_style.corner_radius_bottom_right = 8
	feedback_panel.add_theme_stylebox_override("panel", fb_style)
	feedback_panel.visible = true

	next_btn.visible = true
	next_btn.text = "Завершить тест ✔" if current_q == questions.size() - 1 \
		else "Следующий вопрос ▶"


func _on_next_question() -> void:
	current_q += 1
	if current_q >= questions.size():
		_show_result()
	else:
		_show_question()


# ════════════════════════════════════════════════════════════════
#  ЭКРАН РЕЗУЛЬТАТА
# ════════════════════════════════════════════════════════════════

func _show_result() -> void:
	main_panel.visible   = false
	result_panel.visible = true

	var total            = questions.size()
	var passed           = (score >= 4)
	var was_already_done = LearningData.is_topic_completed(topic_index)

	if passed and not was_already_done:
		LearningData.mark_topic_completed(topic_index)

	result_icon.text = "🏆" if passed else "📖"

	result_score_label.text = "%d / %d правильных ответов" % [score, total]
	result_score_label.add_theme_color_override("font_color",
		Color(0.3, 1.0, 0.4) if passed else Color(1.0, 0.5, 0.3))

	if passed:
		result_status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		if was_already_done:
			result_status_label.text = "✅ Отлично! Тема повторена."
		else:
			result_status_label.text = "✅ Тема пройдена!"
			var unlocks = _get_unlock_message()
			if unlocks != "":
				unlock_label.text    = "🔓 Разблокировано:\n" + unlocks
				unlock_label.visible = true
		retry_btn.text = "🔄 Повторить тест"
	else:
		result_status_label.text = "Нужно 4 правильных ответа. Попробуй ещё раз!"
		result_status_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
		retry_btn.text = "🔄 Пройти ещё раз"


func _on_retry() -> void:
	current_q            = 0
	score                = 0
	unlock_label.visible = false
	result_panel.visible = false
	main_panel.visible   = true
	_show_question()


func _get_unlock_message() -> String:
	match topic_index:
		0: return "Воздушный набор, Земляной набор, Огненный Набор 2"
		1: return "Водный, Светлый, Тёмный наборы, Огненный Набор 3"
		2: return "Огненный Набор 4"
		3: return "Огненный Набор 5"
		4: return "✨ Редактор своих наборов!"
	return ""
