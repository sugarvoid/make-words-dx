extends Control

const GAME_HISTORY_PATH = "res://game/data/game_history.json"
const USED_WORDS_FILE: String = "res://game/data/used_words.txt"


func _ready():
	_load_words_from_file()
	$LblScore.text = str(load_game_history())

func  _unhandled_input(event):
	if event.is_action_released("back_to_main"):
		get_tree().change_scene_to_file("res://game/main_menu.tscn")

func _load_words_from_file() -> void:
	if FileAccess.file_exists(USED_WORDS_FILE):
		var file = FileAccess.open(USED_WORDS_FILE, FileAccess.READ)
		while not file.eof_reached():
			var line: String = file.get_line()
			if line:
				#TODO: Make new label
				var new_label: Label = Label.new()
				new_label.text = line
				new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				$Control/ScrollContainer/VBoxContainer.add_child(new_label)
				#TODO: Add to scroll container
				print(line)
	else:
		push_error("Word list file, not found")

func load_game_history() -> int:
	var file = FileAccess.open(GAME_HISTORY_PATH, FileAccess.READ)
	var test: Array = []
	var content = file.get_as_text()
	file.close()
	test = JSON.parse_string(content)
	var last_game = test.size() - 1
	return(test[last_game].score)
	
