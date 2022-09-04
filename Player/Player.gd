extends KinematicBody2D
class_name Player

export(Resource) var moveData = preload("res://Player/FastPlayerMovementData.tres") as PlayerMovementData

enum {
	MOVE,
	CLIMB,
}

var buffered_jump = false
var coyote_time = false
var double_jump = 1
var state = MOVE
var velocity = Vector2.ZERO

onready var animatedSprite: = $AnimatedSprite
onready var coyoteTimeTimer: = $CoyoteTimeTimer
onready var jumpBufferTimer: = $JumpBufferTimer
onready var ladderCheck: = $LadderCheck
onready var remoteTransform2d = $RemoteTransform2D

func _physics_process(_delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE:
			move_state(input)
		CLIMB:
			climb_state(input)

func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
	
	apply_gravity()
	
	if !horizontal_move_input(input):
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0
			
	if is_on_floor():
		reset_double_jump()
	else:
		animatedSprite.animation = "Jump"
		
	if can_jump():
		try_jump()
	else:
		input_jump_release()
		input_double_jump()
		buffer_jump()
		fast_fall()
	
	var was_in_air = !is_on_floor()
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP) # is_on_floor will update when move_and_slide is called
	var just_landed = is_on_floor() and was_in_air # if we were not on floor before move_and_slide and are after then we just landed :)
	var just_left_ground = !is_on_floor() and was_on_floor
	
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
		
	# see if we just left a ledge
	if just_left_ground and velocity.y >= 0:
		coyote_time = true
		coyoteTimeTimer.start()
	
func climb_state(input):
	if !is_on_ladder():
		state = MOVE
		
#	animatedSprite.animation = input.length() == 0 ? "Idle" : "Run"
	animatedSprite.animation = "Idle" if (input.length() == 0) else "Run"
		
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
		
func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")
	
func connect_camera(camera):
	remoteTransform2d.remote_path = camera.get_path()

func input_jump_release():
	# If velocity.y < 0 we are going up. This stops the slight hang that happens releasing jump on the way down.
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE: 
		velocity.y = moveData.JUMP_RELEASE_FORCE
			
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1
	
func fast_fall():
	if velocity.y > 1: # We are falling
		velocity.y += moveData.ADDITIONAL_FALL_GRAVITY

func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()	

func is_on_ladder():
	if !ladderCheck.is_colliding():
		return false
	
	var collider = ladderCheck.get_collider()
	if !collider is Ladder:
		return false
		
	return true
	
func horizontal_move_input(input):
	return input.x != 0
	
func try_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false
		
func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT
		
func can_jump():
	return is_on_floor() or coyote_time

func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, moveData.MAX_DOWNWARD_FALL)
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteTimeTimer_timeout():
	coyote_time = false
