class_name ScreenFadeClass
extends ColorRect


@export var wait_during_black := 0.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func fade_to_black() -> void:
	animation_player.stop()
	animation_player.play("fade_to_black")
	await animation_player.animation_finished


func fade_from_black() -> void:
	animation_player.stop()
	animation_player.play_backwards("fade_to_black")
	await animation_player.animation_finished


func change_scene_to_file(path: String) -> void:
	get_tree().paused = true
	await fade_to_black()
	get_tree().change_scene_to_file(path)
	if wait_during_black > 0:
		await get_tree().create_timer(wait_during_black).timeout
	await fade_from_black()
	get_tree().paused = false
