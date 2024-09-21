class_name TypingLabel
extends Label


signal finished_typing


const CHARS_PER_SECOND := 10
const _SECONDS_PER_CHAR := 1.0 / CHARS_PER_SECOND

var CENSOR_CHARS: Array[String] = ["!", "@", "#", "?", "%", "*"]
const CENSOR_FRAMES_PER_SECOND := 10.0
const _SECONDS_PER_CENSOR_FRAME := 1.0 / CENSOR_FRAMES_PER_SECOND


@export var auto_run := false
@export_group("On Finish", "on_finish")
@export var on_finish_hide_self := false
@export var on_finish_show_node: NodePath
@export_file("*.tscn") var on_finish_change_scene_to_file: String
@export var on_finish_wait_for_input_action := &""
@export var on_finish_wait_extra_time := 0.0

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
	
	if on_finish_hide_self:
		finished_typing.connect(hide)
	if on_finish_show_node:
		var node := get_node(on_finish_show_node)
		finished_typing.connect(node.show)
	if on_finish_change_scene_to_file:
		finished_typing.connect(func():
			get_tree().change_scene_to_file(on_finish_change_scene_to_file)
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
		if _extra_time_waited >= on_finish_wait_extra_time:
			finished_typing.emit()
			_is_done = true
	elif visible_ratio == 1.0:
		if on_finish_wait_for_input_action and Input.is_action_just_pressed(on_finish_wait_for_input_action):
			if on_finish_wait_extra_time > 0:
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
				if not on_finish_wait_for_input_action:
					if on_finish_wait_extra_time > 0:
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
