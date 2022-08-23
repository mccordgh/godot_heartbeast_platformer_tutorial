extends KinematicBody2D

var velocity = Vector2.ZERO

export(int) var ACCELERATION = 10
export(int) var ADDITIONAL_FALL_GRAVITY = 2
export(int) var FRICTION = 10
export(int) var GRAVITY = 6
export(int) var JUMP_FORCE = -180
export(int) var JUMP_RELEASE_FORCE = -80
export(int) var MAX_SPEED = 100


func _physics_process(delta):
	apply_gravity()
	
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input.x == 0:
		apply_friction()
	else:
		apply_acceleration(input.x)
			
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_FORCE
	else:
		# If velocity.y < 0 we are going up. This stops the slight hang that happens releasing jump on the way down.
		if Input.is_action_just_released("ui_up") and velocity.y < JUMP_RELEASE_FORCE: 
			velocity.y = JUMP_RELEASE_FORCE
			
		if velocity.y > 1: # We are falling
			velocity.y += ADDITIONAL_FALL_GRAVITY
		
	velocity = move_and_slide(velocity, Vector2.UP)


func apply_gravity():
	velocity.y += GRAVITY
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
