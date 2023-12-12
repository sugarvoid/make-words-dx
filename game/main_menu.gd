extends Control

func _start_game() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")

func _input(event) -> void:
	if event.is_action_pressed("space"):
		_start_game()


func _ready():
	$AnimationPlayer.play("opening")
