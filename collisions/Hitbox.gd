extends Area2D


func _on_Hitbox_body_entered(body):
	if body is Player:
		# warning-ignore:return_value_discarded
		body.player_die()
