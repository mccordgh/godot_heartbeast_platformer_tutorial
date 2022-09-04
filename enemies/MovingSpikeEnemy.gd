tool
extends Node2D

enum ANIMATION_TYPE {
	LOOP,
	RUBBER_BAND,
}

onready var animationPlayer: = $AnimationPlayer

export(int) var speed = 1 setget set_speed
export(ANIMATION_TYPE) var animation_type setget set_animation_type


func _ready():
	play_updated_animation()


func play_updated_animation():
	match animation_type:
		ANIMATION_TYPE.LOOP:
			animationPlayer.play("MoveAlongPathLooping")
		ANIMATION_TYPE.RUBBER_BAND:
			animationPlayer.play("MoveAlongPathRubberband")


func set_animation_type(value):
	animation_type = value
	if animationPlayer:
		play_updated_animation()
		
func set_speed(value):
	speed = value
	if animationPlayer:
		animationPlayer.playback_speed = speed
