extends Node

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	music.stream = load("res://assets/audio/music/From Shadows (Black Trailer).mp3")
	music.volume_db = -40.0
	music.play()
	create_tween().tween_property(music, "volume_db", 0.0, 2.0)
