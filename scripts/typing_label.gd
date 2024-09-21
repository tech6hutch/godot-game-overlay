class_name TypingLabel
extends Label


signal finished_typing


const CHARS_PER_SECOND := 10
const _SECONDS_PER_CHAR := 1.0 / CHARS_PER_SECOND

var CENSOR_CHARS: Array[String] = ["!", "@", "#", "?", "%", "*"]
const CENSOR_FRAMES_PER_SECOND := 10.0
const _SECONDS_PER_CENSOR_FRAME := 1.0 / CENSOR_FRAMES_PER_SECOND


@export_group("Animation")
@export var auto_run := false
@export var show_on_finish: NodePath
@export_file("*.tscn") var go_to_on_finish: String
@export var input_action_to_wait_for := &""
@export var extra_time_to_wait := 0.0

@export_group("Effects")
@export var censor_effect := false

var is_waiting_extra_time := false

@onready var uncensored_text := text


func _init() -> void:
	CENSOR_CHARS.shuffle()
	
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


var _is_done := false
var _extra_time_waited := 0.0
var _time_since_showed_char := 0.0
var _censor_starting_idx := 0
var _censor_starting_idx_direction := 1
var _time_since_censor_frame := 0.0

func _process(delta: float) -> void:
	if censor_effect:
		_time_since_censor_frame += delta
		while _time_since_censor_frame > _SECONDS_PER_CENSOR_FRAME:
			_time_since_censor_frame -= _SECONDS_PER_CENSOR_FRAME
			text = _censor_text(uncensored_text)
	
	if _is_done:
		return
	
	if is_waiting_extra_time:
		_extra_time_waited += delta
		if _extra_time_waited >= extra_time_to_wait:
			finished_typing.emit()
			_is_done = true
	elif visible_ratio == 1.0:
		if input_action_to_wait_for and Input.is_action_just_pressed(input_action_to_wait_for):
			if extra_time_to_wait > 0:
				is_waiting_extra_time = true
				_extra_time_waited = 0
			else:
				finished_typing.emit()
	else:
		_time_since_showed_char += delta
		while _time_since_showed_char > _SECONDS_PER_CHAR:
			_time_since_showed_char -= _SECONDS_PER_CHAR
			visible_characters += 1
			if visible_ratio == 1.0:
				if not input_action_to_wait_for:
					if extra_time_to_wait > 0:
						is_waiting_extra_time = true
						_extra_time_waited = _time_since_showed_char
					else:
						finished_typing.emit()


func _censor_text(s: String) -> String:
	var censor_idx := _censor_starting_idx
	_censor_starting_idx += _censor_starting_idx_direction
	if _censor_starting_idx >= CENSOR_CHARS.size():
		_censor_starting_idx_direction = -1
		_censor_starting_idx = CENSOR_CHARS.size() - 2
	elif _censor_starting_idx < 0:
		_censor_starting_idx_direction = 1
		_censor_starting_idx = 1
	for i in s.length():
		if s[i] != "*": continue
		s[i] = CENSOR_CHARS[censor_idx]
		censor_idx += 1
		censor_idx %= CENSOR_CHARS.size()
		#s = s.erase(i)
		#s = s.insert(i, CENSOR_CHARS.pick_random())
	return s


func run() -> void:
	_time_since_showed_char = 0
	_extra_time_waited = 0
	set_process(true)
