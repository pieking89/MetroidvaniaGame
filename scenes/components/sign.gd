extends Area2D

@export_multiline var pagine: PackedStringArray = ["..."]
@export var frame_normale := 1
@export var frame_evidenziato := 0
@export var nome_parlante := "Cartello"
@export var icona: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
var _vicino := false


func _ready() -> void:
	DialogBox.nascondi_prompt()
	sprite.frame = frame_normale
	body_entered.connect(_on_entrato)
	body_exited.connect(_on_uscito)


func _on_entrato(body: Node2D) -> void:
	print("entrato: ", body.name, " gruppi: ", body.get_groups())
	if body.is_in_group("player"):
		_vicino = true
		DialogBox.mostra_prompt("Premi [%s] per leggere" % tasto_interazione())
		sprite.frame = frame_evidenziato


func _on_uscito(body: Node2D) -> void:
	if body.is_in_group("player"):
		_vicino = false
		DialogBox.nascondi_prompt()
		sprite.frame = frame_normale
		if DialogBox.aperto:
			DialogBox.chiudi()


func _unhandled_input(event: InputEvent) -> void:
	if not _vicino or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()

	if DialogBox.aperto:
		DialogBox.avanti()
	else:
		DialogBox.apri(pagine, nome_parlante, icona)
		DialogBox.nascondi_prompt()

	if not DialogBox.aperto:
		DialogBox.mostra_prompt("Premi [%s] per leggere" % tasto_interazione())

func tasto_interazione() -> String:
	for e in InputMap.action_get_events("interact"):
		if e is InputEventKey:
			var code: Key = e.physical_keycode if e.physical_keycode != 0 else e.keycode
			return OS.get_keycode_string(code)
	return "?"
