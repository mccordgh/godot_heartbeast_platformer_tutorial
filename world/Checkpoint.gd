extends Area2D

onready var animatedSprite: = $AnimatedSprite

var activated = false

func _on_Checkpoint_body_entered(body):
	if activated or (!body is Player): return
	
	print("checkpoint!")
	activated = true
	animatedSprite.play("Checked")
	Events.emit_signal("hit_checkpoint", position)
