extends CanvasLayer

@export var durata_tooltip: float = 2.5

@onready var pannello: PanelContainer = $Pannello
@onready var label_monete: Label = $Pannello/Margine/Contenuto/Monete
@onready var lista: VBoxContainer = $Pannello/Margine/Contenuto/Lista
@onready var tooltip_box: PanelContainer = $PanelContainer
@onready var tooltip: Label = $PanelContainer/Tooltip
@onready var prompt: Label = $PromptMargin/Prompt

var _tw: Tween
var _pt: Tween

func _ready() -> void:
	pannello.visible = false
	tooltip_box.visible = false
	prompt.hide()
	Inventario.cambiato.connect(_aggiorna)
	_aggiorna()

func _process(_delta: float) -> void:
	if (pannello.visible or tooltip_box.visible or prompt.visible) and not _in_gioco():
		pannello.visible = false
		tooltip_box.visible = false
		prompt.hide()
		if _tw:
			_tw.kill()
		if _pt:
			_pt.kill()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("backpack"):
		return
	if not _in_gioco():
		return
	pannello.visible = not pannello.visible
	get_viewport().set_input_as_handled()

func _in_gioco() -> bool:
	return get_tree().get_first_node_in_group("player") != null

func mostra_tooltip(testo: String) -> void:
	if _tw:
		_tw.kill()
	tooltip.text = testo
	tooltip_box.modulate.a = 0.0
	tooltip_box.visible = true
	_tw = create_tween()
	_tw.tween_property(tooltip_box, "modulate:a", 1.0, 0.2)
	_tw.tween_interval(durata_tooltip)
	_tw.tween_property(tooltip_box, "modulate:a", 0.0, 0.4)
	_tw.tween_callback(tooltip_box.hide)

func mostra_prompt(t: String) -> void:
	prompt.text = t
	prompt.show()
	prompt.modulate.a = 0.0
	prompt.scale = Vector2(0.8, 0.8)

	await get_tree().process_frame
	prompt.pivot_offset = prompt.size / 2.0

	if _pt:
		_pt.kill()
	_pt = create_tween().set_parallel()
	_pt.tween_property(prompt, "modulate:a", 1.0, 0.15)
	_pt.tween_property(prompt, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func nascondi_prompt() -> void:
	if _pt:
		_pt.kill()
	_pt = create_tween().set_parallel()
	_pt.tween_property(prompt, "modulate:a", 0.0, 0.12)
	_pt.tween_property(prompt, "scale", Vector2(0.9, 0.9), 0.12)
	_pt.chain().tween_callback(prompt.hide)

func _aggiorna() -> void:
	label_monete.text = "Monete: %d" % Inventario.monete
	for figlio in lista.get_children():
		figlio.queue_free()
	if Inventario.oggetti.is_empty():
		_aggiungi_riga("Vuoto")
		return
	for nome in Inventario.oggetti:
		_aggiungi_riga("%s x%d" % [nome, Inventario.oggetti[nome]])

func _aggiungi_riga(testo: String) -> void:
	var riga := Label.new()
	riga.text = testo
	lista.add_child(riga)
