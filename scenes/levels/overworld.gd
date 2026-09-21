extends Node2D

@export var musica: Array[Track]

func _ready() -> void:
	AudioManager.play_playlist(musica)
