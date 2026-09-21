extends Node

const FADE := 1.0

var _a: AudioStreamPlayer
var _b: AudioStreamPlayer
var _current: AudioStreamPlayer
var _lowpass: AudioEffectLowPassFilter
var _toast

var _coda: Array[Track] = []
var _indice := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_a = _crea_player()
	_b = _crea_player()
	_current = _a

	var idx := AudioServer.get_bus_index("Music")
	_lowpass = AudioEffectLowPassFilter.new()
	AudioServer.add_bus_effect(idx, _lowpass)
	_lowpass.cutoff_hz = 20000.0

	_toast = preload("res://scenes/ui/MusicToast.tscn").instantiate()
	add_child(_toast)


func _crea_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "Music"
	p.volume_db = -60.0
	add_child(p)
	p.finished.connect(_on_finished.bind(p))
	return p


# --- una canzone singola (menu): svuota la coda
func play_music(stream: AudioStream, titolo := "") -> void:
	_coda.clear()
	_avvia(stream, titolo)


# --- più canzoni in fila, che ricominciano alla fine
func play_playlist(tracce: Array[Track]) -> void:
	if tracce == _coda:
		return
	_coda = tracce
	_indice = 0
	_avvia(_coda[0].stream, _coda[0].titolo)


func _on_finished(player: AudioStreamPlayer) -> void:
	if player != _current or _coda.is_empty():
		return
	_indice = (_indice + 1) % _coda.size()
	_avvia(_coda[_indice].stream, _coda[_indice].titolo)


func _avvia(stream: AudioStream, titolo: String) -> void:
	if _current.stream == stream and _current.playing:
		return
	if titolo != "":
		_toast.mostra(titolo)

	var vecchio := _current
	var nuovo := _b if _current == _a else _a
	_current = nuovo

	nuovo.stream = stream
	nuovo.volume_db = -40.0
	nuovo.play()

	var t := create_tween().set_parallel()
	t.tween_property(nuovo, "volume_db", 0.0, FADE)
	t.tween_property(vecchio, "volume_db", -60.0, FADE)
	await t.finished
	if _current != vecchio:
		vecchio.stop()


func set_muffled(on: bool) -> void:
	var target := 800.0 if on else 20000.0
	create_tween().tween_property(_lowpass, "cutoff_hz", target, 0.3)
