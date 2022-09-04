extends Node2D

const PlayerScene = preload("res://Player/Player.tscn")

onready var camera: = $Camera2D
onready var player: = $Player
onready var playerRespawnTimer: = $PlayerRespawnTimer

var player_spawn_location = Vector2.ZERO

func _ready():
	VisualServer.set_default_clear_color(Color.darkseagreen)
	
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	
# warning-ignore:return_value_discarded
	Events.connect("player_died", self, "_on_player_died")
# warning-ignore:return_value_discarded
	Events.connect("hit_checkpoint", self, "_on_hit_checkpoint")

func _on_player_died():
	playerRespawnTimer.start(1.0)
	yield(playerRespawnTimer, "timeout") # wait for timer to emit timeout signal
	
	var new_player = PlayerScene.instance()
	new_player.position = player_spawn_location
	add_child(new_player)
	new_player.connect_camera(camera)

func _on_hit_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position
