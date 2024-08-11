extends CharacterBody2D


const IS_DEBUG := true

const SPEED := 90.0
const JUMP_VELOCITY := -260.0
const MAX_FALL_SPEED := -JUMP_VELOCITY
const BOTTOM_OF_THE_SCREEN := 144 + 16

const AIR_LOSS_PER_SEC := 0.01
const AIR_LOSS_PER_HIT := 0.2


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _physics_process(delta: float) -> void:
	if IS_DEBUG:
		pass
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if true:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			sprite.flip_h = direction < 0
			velocity.x = direction * SPEED
			animation_player.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animation_player.play("idle")

	move_and_slide()
	
	if position.y > BOTTOM_OF_THE_SCREEN:
		die()
		return
	
	if is_on_floor():
		if Input.is_action_pressed("ui_cancel"):
			#animation_player.play("fire")
			pass
	else:
		animation_player.play("jump")


func die() -> void:
	collision_shape.disabled = true
	set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
