class_name LetterLabel
extends Label

var _value: String

func _ready() -> void:
	pass 

func get_letter() -> String:
	return _value

func set_letter(letter: String) -> void:
	_value = letter
	self.text = letter

func fade_away() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 2)
	#tween.tween_property(self, "scale", Vector2(), 1)
	tween.tween_callback(self.queue_free)
