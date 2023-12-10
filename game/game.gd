extends Control

const LETTERS: Array = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
const p_Letter: PackedScene = preload("res://game/letter_label/letter_label.tscn")


var VALID_WORDS: Array[String]
var used_words: Array[String]
var running_word: String
var score: int

var game_round: int

var required_letters: Array[String] = []
var used_letters: Array[String] = []

@onready var lbl_running_word: HBoxContainer = get_node("RunningWord")

func _ready() -> void:
	game_round = 1
	print(has_required_letters(['a', 's'], ['b', 'a', 's', 'e']))
	load_words_from_file()

func load_words_from_file() -> void:
	var path = "res://game/data/words.txt"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		while not file.eof_reached():
			var line = file.get_line()
			VALID_WORDS.append(line)
	else:
		push_error("Word list file, not found")

func _process(delta) -> void:
	pass

func _input(event) -> void:
	if event.is_action_pressed("backspace"):
		if running_word.length() > 0:
			self._remove_letter_from_running_word()
		else:
			return
		
	if event.is_action_released("submit_word"):
		if check_if_word_is_vaild(running_word):
			pass
			# Add points
			
			clone_letter(lbl_running_word.get_children().pick_random())
			move_clone_one()
			
			for letter: LetterLabel in lbl_running_word.get_children():
				letter.fade_away()
		else:
			# Got wrong
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
	var last_child = lbl_running_word.get_child(letters-1)
	lbl_running_word.remove_child(last_child)
	_update_player_label()

func _add_letter_to_running_word(letter: String) -> void:
	running_word += letter
	create_letter(letter)
	_update_player_label()

func _update_player_label() -> void:
	$Debug/lbl_current_word.text = running_word

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

#region WordManagment

func word_to_array(word: String) -> Array[String]:
	var _array = []
	for c in word:
		_array.append(c)
	
	return _array


func has_required_letters(required: Array, used: Array) -> bool:
	
	var _checks: Array = []
	
	print(str("required: ", required))
	print(str("used: ", used))

	
	for c in required:
		if used.has(c):
			_checks.append(true)
		else:
			_checks.append(false)
				
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
