extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB,
}

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = 1

onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck

export(Resource) var moveData

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
	
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0
			
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = moveData.JUMP_FORCE
	else:
		animatedSprite.animation = "Jump"
		# If velocity.y < 0 we are going up. This stops the slight hang that happens releasing jump on the way down.
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE: 
			velocity.y = moveData.JUMP_RELEASE_FORCE
			
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = moveData.JUMP_FORCE
			double_jump -= 1
			
		if velocity.y > 1: # We are falling
			velocity.y += moveData.ADDITIONAL_FALL_GRAVITY
	
	var was_in_air = !is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP) # is_on_floor will update when move_and_slide is called
	var just_landed = is_on_floor() and was_in_air # if we were not on floor before move_and_slide and are after then we just landed :)
	
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	

func climb_state(input):
	if !is_on_ladder():
		state = MOVE
		
#	animatedSprite.animation = input.length() == 0 ? "Idle" : "Run"
	animatedSprite.animation = "Idle" if (input.length() == 0) else "Run"
		
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
		
		
func is_on_ladder():
	if !ladderCheck.is_colliding():
		return false
	
	var collider = ladderCheck.get_collider()
	if !collider is Ladder:
		return false
		
	return true
	

func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, moveData.MAX_DOWNWARD_FALL)
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
