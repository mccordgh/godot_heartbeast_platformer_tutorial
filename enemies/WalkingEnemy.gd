extends KinematicBody2D


var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var animatedSprite = $AnimatedSprite
onready var ledgeCheckRight = $LedgeCheckRight
onready var ledgeCheckLeft = $LedgeCheckLeft


func _physics_process(delta):
	var found_wall = is_on_wall()
	var found_ledge = !ledgeCheckRight.is_colliding() or !ledgeCheckLeft.is_colliding()
	
	if found_wall or found_ledge:
		direction *= -1 # flip direction from Vector2 RIGHT to LEFT or LEFT to RIGHT
		if found_wall:
			print ("found wall")
		if !ledgeCheckRight.is_colliding():
			print ("ledge check right not colliding")
		if !ledgeCheckLeft.is_colliding():
			print ("ledge check left not colliding")

	animatedSprite.flip_h = direction.x > 0
	
	velocity = direction * 25
	move_and_slide(velocity, Vector2.UP)
