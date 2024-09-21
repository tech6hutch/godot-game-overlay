class_name TypingLabel
extends Label


signal finished_typing


const CHARS_PER_SECOND := 10
const _SECONDS_PER_CHAR := 1.0 / CHARS_PER_SECOND


@export var auto_run := false
@export var show_on_finish: NodePath
@export_file("*.tscn") var go_to_on_finish: String
@export var input_action_to_wait_for := &""
@export var extra_time_to_wait := 0.0

var is_waiting_extra_time := false


func _init() -> void:
	visible_characters = 0


func _ready() -> void:
	visibility_changed.connect(func():
		if is_visible_in_tree():
			run()
		else:
			set_process(false)
	)
	if auto_run:
		run()
	else:
		hide()
	
	if show_on_finish:
		var node := get_node(show_on_finish)
		finished_typing.connect(func():
			node.show()
		)
	if go_to_on_finish:
		finished_typing.connect(func():
			get_tree().change_scene_to_file(go_to_on_finish)
		)


var _elapsed_time := 0.0

func _process(delta: float) -> void:
	_elapsed_time += delta
	if is_waiting_extra_time:
		if _elapsed_time >= extra_time_to_wait:
			finished_typing.emit()
			set_process(false)
	elif visible_ratio == 1.0:
		if input_action_to_wait_for and Input.is_action_just_pressed(input_action_to_wait_for):
			if extra_time_to_wait > 0:
				is_waiting_extra_time = true
				_elapsed_time = 0
			else:
				finished_typing.emit()
	else:
		while _elapsed_time > _SECONDS_PER_CHAR:
			_elapsed_time -= _SECONDS_PER_CHAR
			visible_characters += 1
			if visible_ratio == 1.0:
				if not input_action_to_wait_for:
					if extra_time_to_wait > 0:
						is_waiting_extra_time = true
					else:
						finished_typing.emit()


func run() -> void:
	set_process(true)
