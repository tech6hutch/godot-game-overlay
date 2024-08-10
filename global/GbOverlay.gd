extends Node2D


@onready var press_left: Sprite2D = $Overlay/PressLeft
@onready var press_right: Sprite2D = $Overlay/PressRight
@onready var press_up: Sprite2D = $Overlay/PressUp
@onready var press_down: Sprite2D = $Overlay/PressDown
@onready var press_pause: Sprite2D = $Overlay/PressPause
@onready var press_z: Sprite2D = $Overlay/PressZ
@onready var press_x: Sprite2D = $Overlay/PressX

@onready var action_buttons := [
	["ui_left", press_left],
	["ui_right", press_right],
	["ui_up", press_up],
	["ui_down", press_down],
	["pause", press_pause],
	["ui_accept", press_z],
	["ui_cancel", press_x],
]


func _physics_process(_delta: float) -> void:
	for pair in action_buttons:
		var action := pair[0] as String
		var button := pair[1] as Sprite2D
		button.visible = Input.is_action_pressed(action)
