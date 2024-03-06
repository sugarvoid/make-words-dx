extends Control

const GAME_HISTORY_PATH: String = "user://game_history.json"
const USED_WORDS_FILE: String = "user://used_words.txt"

@onready var word_holder: VBoxContainer = get_node("Control/ScrollContainer/VBoxContainer")
@onready var lbl_score: Label = get_node("LblScore")


func _ready():
	_load_words_from_file()
	lbl_score.text = str(_load_game_history())

func  _unhandled_input(event):
	if event.is_action_released("back_to_main"):
		get_tree().change_scene_to_file("res://game/main_menu.tscn")

func _load_words_from_file() -> void:
	if FileAccess.file_exists(USED_WORDS_FILE):
		var file = FileAccess.open(USED_WORDS_FILE, FileAccess.READ)
		while not file.eof_reached():
			var line: String = file.get_line()
			if line:
				var new_label: Label = Label.new()
				new_label.text = line
				new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				word_holder.add_child(new_label)
		file.close()
		DirAccess.remove_absolute(USED_WORDS_FILE) # clean up
	else:
		push_error("Word list file was not found")

func _load_game_history() -> int:
	var _file = FileAccess.open(GAME_HISTORY_PATH, FileAccess.READ)
	var _game_history: Array = []
	var _content = _file.get_as_text()
	_file.close()
	_game_history = JSON.parse_string(_content)
	var _last_game = _game_history.size() - 1
	return(_game_history[_last_game].score)
	
