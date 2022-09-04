extends Node

onready var audioChannels: = $AudioChannels
onready var musicPlayer = $MusicChannel/AudioStreamPlayer

const HURT = preload("res://resources/sfx/hurt.wav")
const JUMP = preload("res://resources/sfx/jump.wav")

func play_sound(sound):
	var channels = audioChannels.get_children()
	
	for audioStreamPlayer in channels:
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break

func play_bgm():
	musicPlayer.play()
