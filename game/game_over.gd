extends Control

const USED_WORDS_FILE: String = "res://game/data/used_words.txt"
# Called when the node enters the scene tree for the first time.
func _ready():
	_load_words_from_file()
	pass
	#$Control/ScrollContainer.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _load_words_from_file() -> void:
	if FileAccess.file_exists(USED_WORDS_FILE):
		var file = FileAccess.open(USED_WORDS_FILE, FileAccess.READ)
		while not file.eof_reached():
			var line: String = file.get_line()
			if line:
				#TODO: Make new label
				var new_label: Label = Label.new()
				new_label.text = line
				$Control/ScrollContainer/VBoxContainer.add_child(new_label)
				#TODO: Add to scroll container
				print(line)
	else:
		push_error("Word list file, not found")
