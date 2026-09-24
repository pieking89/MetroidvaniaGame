extends Node2D

@export var id: String = ""
@export var monete: int = 0
@export var oggetti: Array[ItemData] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var polvere: GPUParticles2D = $Polvere
@onready var zona: Area2D = $ZonaInterazione

var _player_vicino := false
var _aperta := false

func _ready() -> void:
	if id == "":
		id = "%s:%s" % [owner.scene_file_path, owner.get_path_to(self)]
	if GameState.cassa_aperta(id):
		_aperta = true
		sprite.play("aperta")
	else:
		sprite.play("chiusa")
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_vicino = true
		_aggiorna_evidenza()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_vicino = false
		_aggiorna_evidenza()

func _aggiorna_evidenza() -> void:
	if _aperta:
		return
	if _player_vicino:
		sprite.play("chiusa_evidenziata")
		InventarioUI.mostra_prompt("Premi [F] per aprire")
	else:
		sprite.play("chiusa")
		InventarioUI.nascondi_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if _aperta or not _player_vicino:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		apri()

func apri() -> void:
	_aperta = true
	GameState.segna_cassa(id)
	InventarioUI.nascondi_prompt()
	sprite.play("aperta")
	polvere.restart()
	if monete > 0:
		Inventario.aggiungi_monete(monete)
	for item in oggetti:
		if item:
			Inventario.aggiungi_oggetto(item)
	InventarioUI.mostra_tooltip(_testo_bottino())

func _testo_bottino() -> String:
	var parti := PackedStringArray()
	if monete > 0:
		parti.append("Monete x%d" % monete)
	var conteggio := {}
	for item in oggetti:
		if item:
			conteggio[item] = conteggio.get(item, 0) + 1
	for item: ItemData in conteggio:
		var n: int = conteggio[item]
		parti.append(item.nome if n == 1 else "%s x%d" % [item.nome, n])
	if parti.is_empty():
		return "La cassa è vuota"
	return "Hai trovato: [%s]" % ", ".join(parti)
