class_name LetterLabel
extends Control

var _value: String

@onready var lbl_letter: Label = $Label


func get_letter() -> String:
	return _value

func change_color(new_color: Color) -> void:
	lbl_letter.add_theme_color_override("font_color", new_color)

func set_letter(letter: String) -> void:
	_value = letter
	lbl_letter.text = letter.to_upper()

func fade_away() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.25)
	tween.tween_callback(self.queue_free)

func move_to_pos(pos: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, 0.6)

func shake(do_flash: bool=false) -> void:
	var shake_amount = 2.5
	var shake_duration = 0.03
	var shake_count = 5
	var tween = get_tree().create_tween()
	var start_pos: Vector2 = self.position
	
	if do_flash:
		flash_wrong()
	for i in shake_count:
		randomize()
		var x_ran = randf_range((start_pos.x - shake_amount), (start_pos.x + shake_amount))
		var y_ran = randf_range((start_pos.y - shake_amount), (start_pos.y + shake_amount))
		tween.tween_property(self, "position", Vector2(x_ran, y_ran), shake_duration)
		tween.tween_property(self, "position", start_pos, shake_duration)
	
	await get_tree().create_timer(0.8).timeout
	reset_color()

func flash_wrong() -> void:
	change_color(Color("cc1424"))

func reset_color() -> void:
	change_color(Color("ffbf40"))


