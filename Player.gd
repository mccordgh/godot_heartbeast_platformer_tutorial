extends KinematicBody2D
class_name Player

var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite

export(int) var ACCELERATION = 10
export(int) var ADDITIONAL_FALL_GRAVITY = 2
export(int) var FRICTION = 10
export(int) var GRAVITY = 6
export(int) var JUMP_FORCE = -180
export(int) var JUMP_RELEASE_FORCE = -80
export(int) var MAX_DOWNWARD_FALL = 400
export(int) var MAX_SPEED = 100


func _ready():
	#animatedSprite.frames = load("res://resources/PlayerBlueSkin.tres")
	animatedSprite.frames = load("res://resources/PlayerGreenSkin.tres")


func _physics_process(_delta):
	apply_gravity()
	
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0
			
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_FORCE
	else:
		animatedSprite.animation = "Jump"
		# If velocity.y < 0 we are going up. This stops the slight hang that happens releasing jump on the way down.
		if Input.is_action_just_released("ui_up") and velocity.y < JUMP_RELEASE_FORCE: 
			velocity.y = JUMP_RELEASE_FORCE
			
		if velocity.y > 1: # We are falling
			velocity.y += ADDITIONAL_FALL_GRAVITY
	
	var was_in_air = !is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP) # is_on_floor will update when move_and_slide is called
	var just_landed = is_on_floor() and was_in_air # if we were not on floor before move_and_slide and are after then we just landed :)
	
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1

func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, MAX_DOWNWARD_FALL)
	
func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
