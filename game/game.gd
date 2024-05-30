extends Control

const LETTERS: Array = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
const p_Letter: PackedScene = preload("res://game/letter_label/letter_label.tscn")

const GAME_HISTORY_PATH = "user://game_history.json"
const USED_WORDS_PATH: String = "user://used_words.txt"


const WORD_LIST_PATH = "res://game/game_data/word_list.txt"
const STARTING_TIME: float = 60.0


@onready var pbar_game_time: ProgressBar = get_node("PBarGameTime")
@onready var tmr_game_time: Timer = get_node("TmrCountDown")

var _used_words_list: Array[String]
var _game_history: Array
var chances: int
var countdown: Timer


var game_data: Dictionary = {
	"date": null,
	"words": [],
	"score" : 0 
}

var VALID_WORDS: Array[String]
var used_words: Array[String] = []
var running_word: String
var player_score: int

var game_round: int
var can_type: bool 

var required_letters: Array[String] = ["",""]
var used_letters: Array[String] = []

@onready var lbl_running_word: HBoxContainer = get_node("RunningWord")

func _ready() -> void:
	# Delete txt file from last game
	DirAccess.remove_absolute(USED_WORDS_PATH)
	#var new_word_txt = FileAccess.open(USED_WORDS_PATH, FileAccess.WRITE_READ)
	#new_word_txt.close
	_check_for_player_files()
	_update_score(0)
	game_round = 1
	$Tutorial/AnimationPlayer.play("bop")
	_show_tutorial_msg(0)
	#$Tutorial/LblHelp0.show()
	#$Tutorial/LblHelp1.hide()
	#$Tutorial/LblHelp3.hide()
	#$Tutorial/LblHelp2.hide()
	pbar_game_time.value = STARTING_TIME
	$Debug/LblRound.text = str(game_round)
	load_words_from_file()
	_update_player_label()
	_game_history = load_history()
	tmr_game_time.connect("timeout", _go_to_gameover)

func load_words_from_file() -> void:
	if FileAccess.file_exists(WORD_LIST_PATH):
		var file = FileAccess.open(WORD_LIST_PATH, FileAccess.READ)
		while not file.eof_reached():
			var line = file.get_line()
			VALID_WORDS.append(line)
	else:
		push_error("Word list file, not found")

func _go_to_gameover() -> void:
	store_game_data()
	get_tree().change_scene_to_file("res://game/game_over.tscn")

func _update_score(amount: int) -> void:
	player_score += amount
	$LblScore.text = str(player_score)

func _process(delta) -> void:
	if !tmr_game_time.is_stopped():
		pbar_game_time.value = tmr_game_time.time_left

func _start_countdown() -> void:
	tmr_game_time.start(STARTING_TIME)

func _input(event) -> void:
	if event.is_action_pressed("backspace"):
		if running_word.length() > 0:
			self._remove_letter_from_running_word()
		else:
			return
		
	if event.is_action_released("submit_word"):
		if check_if_word_is_vaild(running_word) and len(running_word) > 2:
			if !_used_words_list.has(running_word):
				_used_words_list.append(running_word)
				submit_word(running_word)
			else:
				print("Used this word already")
				shake_letters()
		else:
			# Not a real word or word is only 2 charaters 
			shake_letters()
			print(str(running_word, ": was not real"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed(): 
		var key_typed = OS.get_keycode_string(event.keycode).to_lower()
		if _check_if_key_is_letter(key_typed):
			if lbl_running_word.get_child_count() <= 12:
				_add_letter_to_running_word(key_typed)
		else:
			return

func _check_if_key_is_letter(key: String) -> bool:
	return LETTERS.has(key)

func _remove_letter_from_running_word() -> void:
	running_word = running_word.left(running_word.length() -1 )
	var letters = lbl_running_word.get_child_count()
	if letters > 0:
		var last_child = lbl_running_word.get_child(clamp(letters-1, 0, 13))
		lbl_running_word.remove_child(last_child)
	_update_player_label()

func _add_letter_to_running_word(letter: String) -> void:
	running_word += letter
	create_letter(letter)
	_update_player_label()

func _update_player_label() -> void:
	$Debug/lbl_current_word.text = running_word
	$Debug/RequiredLetters/one.text = required_letters[0]
	$Debug/RequiredLetters/two.text = required_letters[1]

func create_letter(letter: String) -> void:
	var new_letter: LetterLabel = p_Letter.instantiate()
	lbl_running_word.add_child(new_letter)
	new_letter.set_letter(letter)
	

func clone_letter(node: LetterLabel):
	var clone: LetterLabel = node.duplicate()
	clone.global_position = node.global_position
	$TempHolder.add_child(clone)

func move_clone_one():
	var letter_copy = $TempHolder.get_child(0)
	if game_round >= 1 and game_round < 5: #(required_letters) == 1:
		letter_copy.move_to_pos($PosRequired1.global_position)
	else:
		letter_copy.move_to_pos($PosRequired2.global_position)

func move_clone_two():
	var letter_copy = $TempHolder.get_child(1)
	if len(required_letters) == 2:
		letter_copy.move_to_pos($PosRequired3.global_position)

func go_to_next_round() -> void:
	game_round += 1
	if game_round == 2:
		_show_tutorial_msg(1)
	elif game_round == 3:
		_show_tutorial_msg(2)
		_start_countdown()
	elif game_round == 4:
		_show_tutorial_msg(-1)
	elif game_round == 5:
		_show_tutorial_msg(3)
	elif game_round == 6:
		_show_tutorial_msg(-1)
		$Tutorial/AnimationPlayer.stop()
		
	running_word = ""
	for letter: LetterLabel in lbl_running_word.get_children():
		letter.fade_away()
		$Debug/LblRound.text = str(game_round)
	_update_player_label()

#region WordManagment

func shake_letters() -> void: 
	for l: LetterLabel in lbl_running_word.get_children():
		l.shake(false)

func submit_word(word: String) -> void:
	randomize()
	var shuffled_letters = $RunningWord.get_children()
	shuffled_letters.shuffle()
	
	if game_round == 1:
		var ran_letter_1 = shuffled_letters[0]
		required_letters[0] = ran_letter_1.get_letter()
		clone_letter(ran_letter_1)
		move_clone_one()
		used_words.append(running_word)
		_update_score(get_word_value(running_word))
		go_to_next_round()
		
		# Don't check for required
	elif game_round >= 2 and game_round < 5:
		# Check for required[0]
		if  has_required_letters(required_letters, word_to_array(running_word), false):
			# clear required array
			required_letters = ["",""]
			_clear_temp_children()
			
			var ran_letter_1 = shuffled_letters[0]
			required_letters[0] = ran_letter_1.get_letter()
			clone_letter(ran_letter_1)
			move_clone_one()
			
			if game_round == 4:
				var ran_letter_2 = shuffled_letters[1]
				if ran_letter_1 == ran_letter_2:
					ran_letter_2 = shuffled_letters[2]
				
				required_letters[1] = ran_letter_2.get_letter()
				clone_letter(ran_letter_2)
				move_clone_two()
			
			used_words.append(running_word)
			_update_score(get_word_value(running_word))
			go_to_next_round()
		else :
			shake_letters()
	
	elif game_round >= 5:
		if  has_required_letters(required_letters, word_to_array(running_word), true):
				required_letters = ["",""]
				_clear_temp_children()
				var ran_letter_1 = shuffled_letters[0]
				required_letters[0] = ran_letter_1.get_letter()
				clone_letter(ran_letter_1)
				move_clone_one()
				
				#var ran_letter_2 = lbl_running_word.get_children().pick_random()
				var ran_letter_2 = shuffled_letters[1]
				if ran_letter_1 == ran_letter_2:
					print('duplicate letter redo??')
					ran_letter_2 = shuffled_letters[2]
				required_letters[1] = ran_letter_2.get_letter()
				clone_letter(ran_letter_2)
				move_clone_two()
				used_words.append(running_word)
				_update_score(get_word_value(running_word))
				go_to_next_round()
		else :
			shake_letters()

func _clear_temp_children() -> void:
	for c in $TempHolder.get_children():
		$TempHolder.remove_child(c)

func word_to_array(word: String) -> Array[String]:
	var _array: Array[String] = []
	for c in word:
		_array.append(c)
	
	return _array


func has_required_letters(required: Array, used: Array, use_both: bool) -> bool:
	if game_round == 1:
		return true
	var _checks: Array = []
	
	if use_both:
		for c in required:
			if used.has(c):
				_checks.append(true)
			else:
				_checks.append(false)
	else:
		_checks.append(used.has(required_letters[0]))
	
	return _checks.min()

func get_letter_vaule(letter: String) -> int:
	match letter:
		'a','e','i','l','n','o','r','s','t','u':
			return 1
		'd','g':
			return 2
		'b','c','m','p':
			return 3
		'f','h','v','w','y':
			return 4
		'k':
			return 5
		'j','x':
			return 8
		_:
			return -99

func get_word_value(word: String) -> int:
	var _word_array: Array = word_to_array(word)
	var vaule: int
	for l in _word_array:
		vaule += get_letter_vaule(l)
	return vaule

func check_if_word_is_vaild(word: String) -> bool:
	return VALID_WORDS.has(word)
#endregion

func save_word(word: String, filename: String) -> void:
	if FileAccess.file_exists(filename):
		var file: FileAccess = FileAccess.open(filename, FileAccess.READ_WRITE)
		file.seek_end()
		file.store_line(word)
		file.close()

func save_words(words: Array, filename: String) -> void:
	if FileAccess.file_exists(filename):
		var file: FileAccess = FileAccess.open(filename, FileAccess.READ_WRITE)
		file.seek_end()
		for word in words:
			file.store_line(word)
		file.close()

func store_game_data() -> void:
	var time: Dictionary = Time.get_datetime_dict_from_system()
	var display_string : String = "%d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute]
	
	game_data.date = display_string
	for w in used_words:
		game_data.words.append(w)
		save_word(str(w, " - ", get_word_value(w)), USED_WORDS_PATH)
	
	game_data.score = player_score
	_game_history.append(game_data)
	
	var file = FileAccess.open(GAME_HISTORY_PATH, FileAccess.READ_WRITE)
	var json_string = JSON.stringify(_game_history, "\t")
	
	file.store_string(json_string)
	file.close()


func load_history() -> Array:
	var file = FileAccess.open(GAME_HISTORY_PATH, FileAccess.READ_WRITE)
	var test: Array = []
	var content = file.get_as_text()
	file.close()
	if content != "":
		test = JSON.parse_string(content)
	return test

func _show_tutorial_msg(msg_num: int) -> void:
	for c in $Tutorial.get_children():
		if c is Label:
			c.hide()
	if msg_num != -1:
		$Tutorial.get_child(msg_num).show()

func _check_for_player_files() -> void:
	var _needed_files := [USED_WORDS_PATH, GAME_HISTORY_PATH]
	for path in _needed_files:
		if !FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.WRITE)
			file.close()
