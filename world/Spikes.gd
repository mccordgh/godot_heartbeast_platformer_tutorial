extends Area2D


func _on_Spikes_body_entered(body):
	if body is Player:
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
