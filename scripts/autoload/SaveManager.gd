extends Node

const SCENA_INIZIALE := "res://scenes/levels/Overworld.tscn"

var slot_attivo: int = -1
var nome: String = ""
var tempo: float = 0.0
var spawn_protetto := false
var _scena: String = ""
var _pos = null

func _process(delta: float) -> void:
	if slot_attivo != -1 and _player() != null:
		tempo += delta

func percorso(slot: int) -> String:
	return "user://save_%d.json" % slot

func leggi(slot: int) -> Dictionary:
	if not FileAccess.file_exists(percorso(slot)):
		return {}
	var f := FileAccess.open(percorso(slot), FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary else {}

func _scrivi(slot: int, d: Dictionary) -> void:
	var f := FileAccess.open(percorso(slot), FileAccess.WRITE)
	f.store_string(JSON.stringify(d, "\t"))

func salva_al_checkpoint(id: String, posizione: Vector2) -> void:
	if slot_attivo == -1:
		return
	GameState.bandiera_attiva = id
	_scena = get_tree().current_scene.scene_file_path
	_pos = [posizione.x, posizione.y]
	_salva()

func _salva() -> void:
	_scrivi(slot_attivo, {
		"nome": nome,
		"tempo": tempo,
		"scena": _scena,
		"pos": _pos,
		"inventario": Inventario.to_dict(),
		"stato": GameState.to_dict(),
	})

func nuovo(slot: int) -> void:
	slot_attivo = slot
	nome = "Salvataggio %d" % (slot + 1)
	tempo = 0.0
	_scena = SCENA_INIZIALE
	_pos = null
	Inventario.reset()
	GameState.reset()
	Effetti.reset()
	_salva()
	_entra()

func carica(slot: int) -> void:
	var d := leggi(slot)
	if d.is_empty():
		return
	slot_attivo = slot
	nome = d.get("nome", "")
	tempo = d.get("tempo", 0.0)
	_scena = d.get("scena", SCENA_INIZIALE)
	_pos = d.get("pos")
	Inventario.from_dict(d.get("inventario", {}))
	GameState.from_dict(d.get("stato", {}))
	Effetti.reset()
	_entra()

func _entra() -> void:
	spawn_protetto = true
	await SceneTransition.change_scene(_scena, _posiziona_player)
	await get_tree().create_timer(0.3).timeout
	spawn_protetto = false

func _posiziona_player() -> void:
	var p := _player()
	if p and _pos is Array:
		p.global_position = Vector2(_pos[0], _pos[1])
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.reset_smoothing()

func elimina(slot: int) -> void:
	DirAccess.remove_absolute(percorso(slot))
	if slot == slot_attivo:
		slot_attivo = -1

func rinomina(slot: int, nuovo_nome: String) -> void:
	var d := leggi(slot)
	if d.is_empty():
		return
	d["nome"] = nuovo_nome
	_scrivi(slot, d)
	if slot == slot_attivo:
		nome = nuovo_nome

func esci_al_menu(scena_menu: String) -> void:
	slot_attivo = -1
	SceneTransition.change_scene(scena_menu)

func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D
