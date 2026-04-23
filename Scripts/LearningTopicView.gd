extends Control

# ================================================================
# LearningTopicView.gd
# Статичный каркас — в LearningTopicView.tscn.
# Скрипт только переключает страницы теории.
# ================================================================

var topic_index:  int = 0
var topic:        Dictionary = {}
var current_page: int = 0

# Ссылки на узлы сцены
@onready var topic_title_label:  Label  = $Panel/VBoxContainer/TopicTitleLabel
@onready var page_title_label:   Label  = $Panel/VBoxContainer/PageTitleLabel
@onready var page_text_label:    Label  = $Panel/VBoxContainer/ScrollContainer/PageTextLabel
@onready var page_counter_label: Label  = $Panel/VBoxContainer/PageCounterLabel
@onready var prev_btn:           Button = $Panel/VBoxContainer/NavButtons/PrevButton
@onready var next_btn:           Button = $Panel/VBoxContainer/NavButtons/NextButton


func _ready() -> void:
	topic_index = Global.current_learning_topic
	topic       = LearningData.topics[topic_index]

	$Panel/VBoxContainer/NavButtons/MenuButton.pressed.connect(
		func(): get_tree().change_scene_to_file("res://Scenes/LearningMenu.tscn")
	)
	prev_btn.pressed.connect(_on_prev)
	next_btn.pressed.connect(_on_next)

	topic_title_label.text = "%s  %s" % [topic["icon"], topic["title"]]
	_update_page()


func _update_page() -> void:
	var pages = topic["theory"]
	var page  = pages[current_page]
	var total = pages.size()

	page_title_label.text   = page["heading"]
	page_text_label.text    = page["text"]
	page_counter_label.text = "Страница %d / %d" % [current_page + 1, total]

	prev_btn.disabled = (current_page == 0)

	if current_page == total - 1:
		next_btn.text = "К тесту ▶"
		next_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	else:
		next_btn.text = "Далее ▶"
		next_btn.remove_theme_color_override("font_color")


func _on_prev() -> void:
	if current_page > 0:
		current_page -= 1
		_update_page()

func _on_next() -> void:
	if current_page < topic["theory"].size() - 1:
		current_page += 1
		_update_page()
	else:
		get_tree().change_scene_to_file("res://Scenes/LearningQuiz.tscn")
