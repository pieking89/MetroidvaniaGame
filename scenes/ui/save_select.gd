extends Control

const SCENA_MENU := "res://scenes/ui/main_menu.tscn"

@onready var carte: Array[Node] = $Centro/Carte.get_children()
@onready var sfx_move: AudioStreamPlayer2D = $SfxMove
@onready var sfx_select: AudioStreamPlayer2D = $SfxSelect

var _skip_move_sfx := true
var _attiva: Node = null

func _ready() -> void:
	for i in carte.size():
		carte[i].slot = i
		carte[i].aggiorna()
		carte[i].entra(i * 0.08)
		for btn in carte[i].bottoni():
			btn.pressed.connect(sfx_select.play)
		carte[i].cambiata.connect(_collega_focus)
	_collega_focus()
	get_viewport().gui_focus_changed.connect(_on_focus_cambiato)
	carte[0].primo_focus().grab_focus()

func _collega_focus() -> void:
	for i in carte.size():
		var sx: Control = carte[i - 1].primo_focus() if i > 0 else null
		var dx: Control = carte[i + 1].primo_focus() if i < carte.size() - 1 else null
		for btn: Control in carte[i].bottoni():
			btn.focus_neighbor_left = btn.get_path_to(sx) if sx else NodePath(".")
			btn.focus_neighbor_right = btn.get_path_to(dx) if dx else NodePath(".")

func _input(event: InputEvent) -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus is LineEdit:
		if event.is_action_pressed("ui_cancel"):
			focus.release_focus()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("save_info"):
		var carta = _carta_di(focus)
		if carta:
			carta.toggle_info()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		SceneTransition.change_scene(SCENA_MENU)

func _on_focus_cambiato(focus: Control) -> void:
	if _skip_move_sfx:
		_skip_move_sfx = false
	elif not focus is LineEdit:
		sfx_move.play()
	var carta = _carta_di(focus)
	if carta == null or carta == _attiva:
		return
	_attiva = carta
	for c in carte:
		c.imposta_selezionata(c == carta)
		if c != carta:
			c.nascondi_info()

func _carta_di(focus: Control) -> Node:
	if focus == null:
		return null
	for c in carte:
		if c.is_ancestor_of(focus):
			return c
	return null
