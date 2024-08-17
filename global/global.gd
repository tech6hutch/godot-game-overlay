extends Node


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		toggle_fullscreen(Input.is_key_pressed(KEY_SHIFT))


var _borderless: bool = ProjectSettings.get_setting("display/window/size/borderless")
func toggle_fullscreen(exclusive := false) -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if exclusive
				else DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# The docs say that setting the window to full screen sets the
		# borderless flag to true, so set it to the previous value.
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, _borderless)
