extends Control

const LETTERS: Array = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
const p_Letter: PackedScene = preload("res://game/letter_label/letter_label.tscn")

const USED_WORDS_FILE: String = "res://game/player_data/used_words.txt"
const STARTING_TIME: float = 60.0

var _used_words_list: Array[String]

var chances: int
var countdown: Timer


var VALID_WORDS: Array[String]
var used_words: Array[String]
var running_word: String
var score: int

var game_round: int
var can_type: bool 

var required_letters: Array[String] = ["",""]
var used_letters: Array[String] = []

@onready var lbl_running_word: HBoxContainer = get_node("RunningWord")

func _ready() -> void:
	game_round = 1
	$TextureProgressBar.value = STARTING_TIME
	$Debug/LblRound.text = str(game_round)
	load_words_from_file()
	_update_player_label()
	print($TextureProgressBar.value)

func load_words_from_file() -> void:
	var path = "res://game/data/words.txt"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var line = file.get_line()
			VALID_WORDS.append(line)
	else:
		push_error("Word list file, not found")

func _go_to_gameover() -> void:
	get_tree().change_scene_to_file("res://game/game_over.tscn")

func _process(delta) -> void:
	if !$TmrCountDown.is_stopped():
		$TextureProgressBar.value = $TmrCountDown.time_left

func _start_countdown() -> void:
	$TmrCountDown.start(STARTING_TIME)

func _input(event) -> void:
	if event.is_action_pressed("backspace"):
		if running_word.length() > 0:
			self._remove_letter_from_running_word()
		else:
			return
		
	if event.is_action_released("submit_word"):
		if check_if_word_is_vaild(running_word) and len(running_word) > 2:
			_used_words_list.append(running_word)
			# save_word(running_word, USED_WORDS_FILE)
			submit_word(running_word)
			
			#if game_round == 1:
				#clone_letter(lbl_running_word.get_children().pick_random())
				#move_clone_one()
				#
				#for letter: LetterLabel in lbl_running_word.get_children():
					#letter.fade_away()
				#running_word = ""
				##_update_player_label()
			#if  has_required_letters(required_letters, word_to_array(running_word)):
				## clear required array
				#required_letters = ["",""]
				## clear temp childen
				#for c in $TempHolder.get_children():
					#$TempHolder.remove_child(c)
				## Add points
				#
				#var ran_letter_1 = lbl_running_word.get_children().pick_random()
				#print(str("letter be:", ran_letter_1.get_letter()))
				#required_letters[0] = ran_letter_1.get_letter()
				#clone_letter(ran_letter_1)
				#move_clone_one()
				#
				#
				#
				#
				#for letter: LetterLabel in lbl_running_word.get_children():
					#letter.fade_away()
				#running_word = ""
				#_update_player_label()
		else:
			# Not a real word or word is only 2 charaters 
			shake_letters()
			print(str(running_word, ": was not real"))
			pass

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
	new_letter.set_letter(letter)
	lbl_running_word.add_child(new_letter)


func clone_letter(node: LetterLabel):
	var clone: LetterLabel = node.duplicate()
	clone.global_position = node.global_position
	$TempHolder.add_child(clone)

func move_clone_one():
	var letter_copy = $TempHolder.get_child(0)
	if len(required_letters) == 1:
		letter_copy.move_to_pos($PosRequired1.position)
	else:
		letter_copy.move_to_pos($PosRequired2.position)

func move_clone_two():
	var letter_copy = $TempHolder.get_child(1)
	if len(required_letters) == 2:
		letter_copy.move_to_pos($PosRequired3.position)
		

func go_to_next_round() -> void:
	game_round += 1
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
	print(str("Entering a word on round: ", game_round))
	if game_round == 1:
		var shuffled_letters = $RunningWord.get_children()
		shuffled_letters.shuffle()
		
		#var ran_letter_1 = lbl_running_word.get_children().pick_random()
		var ran_letter_1 = shuffled_letters[0]
		print(str("letter be:", ran_letter_1.get_letter()))
		required_letters[0] = ran_letter_1.get_letter()
		clone_letter(ran_letter_1)
		move_clone_one()
		go_to_next_round()
		# Don't check for required
	if  game_round >= 2 and game_round < 5:
		# Check for required[0]
		if  has_required_letters(required_letters, word_to_array(running_word), false):
				# clear required array
				required_letters = ["",""]
				# clear temp childen
				for c in $TempHolder.get_children():
					$TempHolder.remove_child(c)
				# Add points
				
				var shuffled_letters = $RunningWord.get_children()
				shuffled_letters.shuffle()
				
				#var ran_letter_1 = lbl_running_word.get_children().pick_random()
				var ran_letter_1 = shuffled_letters[0]
				print(str("letter be:", ran_letter_1.get_letter()))
				required_letters[0] = ran_letter_1.get_letter()
				clone_letter(ran_letter_1)
				move_clone_one()
				
				if game_round == 4:
						#var ran_letter_2 = lbl_running_word.get_children().pick_random()
					var ran_letter_2 = shuffled_letters[1]
					print(str("letter be:", ran_letter_2.get_letter()))
					required_letters[1] = ran_letter_2.get_letter()
					clone_letter(ran_letter_2)
					move_clone_two()
			
				go_to_next_round()
	if game_round >= 5:
		# Check for both required
		print('on round five')
		if  has_required_letters(required_letters, word_to_array(running_word), true):
				# clear required array
				required_letters = ["",""]
				# clear temp childen
				for c in $TempHolder.get_children():
					$TempHolder.remove_child(c)
				# Add points
				
				var shuffled_letters = $RunningWord.get_children()
				shuffled_letters.shuffle()
				
				#var ran_letter_1 = lbl_running_word.get_children().pick_random()
				var ran_letter_1 = shuffled_letters[0]
				print(str("letter be:", ran_letter_1.get_letter()))
				required_letters[0] = ran_letter_1.get_letter()
				clone_letter(ran_letter_1)
				move_clone_one()
				
				#var ran_letter_2 = lbl_running_word.get_children().pick_random()
				var ran_letter_2 = shuffled_letters[1]
				print(str("letter be:", ran_letter_2.get_letter()))
				required_letters[1] = ran_letter_2.get_letter()
				clone_letter(ran_letter_2)
				move_clone_two()
				
				
				go_to_next_round()


func word_to_array(word: String) -> Array[String]:
	var _array: Array[String] = []
	for c in word:
		_array.append(c)
	
	return _array


func has_required_letters(required: Array, used: Array, use_both: bool) -> bool:
	
	if game_round == 1: # ["",""]:
		return true
	
	var _checks: Array = []
	
	print(str("required: ", required))
	print(str("used: ", used))

	
	if use_both:
		for c in required:
			if used.has(c):
				_checks.append(true)
			else:
				_checks.append(false)
	else:
		_checks.append(used.has(required_letters[0]))
				
	print(_checks)
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
	if !FileAccess.file_exists(filename):
		return
	var file: FileAccess = FileAccess.open(filename, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(word)
	file.close()

func save_words(words: Array, filename: String) -> void:
	if !FileAccess.file_exists(filename):
		return
	var file: FileAccess = FileAccess.open(filename, FileAccess.READ_WRITE)
	file.seek_end()
	for word in words:
		file.store_line(word)
	file.close()
