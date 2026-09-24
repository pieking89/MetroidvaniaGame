extends CanvasLayer

@export var durata_tooltip: float = 2.5

@onready var pannello: PanelContainer = $Pannello
@onready var lista: ItemList = $Pannello/Margine/Contenuto/Lista
@onready var monete_hud: MarginContainer = $MoneteHUD
@onready var label_monete: Label = $MoneteHUD/MoneteRiga/Monete
@onready var hotbar_box: MarginContainer = $HotbarMargin
@onready var slots: Array[Node] = $HotbarMargin/Hotbar.get_children()
@onready var tooltip_box: PanelContainer = $TooltipBox
@onready var tooltip: Label = $TooltipBox/Tooltip
@onready var prompt: Label = $PromptMargin/Prompt

var _tw: Tween
var _pt: Tween

func _ready() -> void:
	pannello.visible = false
	tooltip_box.visible = false
	prompt.hide()
	for i in slots.size():
		slots[i].imposta_numero(i + 1)
	Inventario.cambiato.connect(_aggiorna)
	Inventario.oggetto_usato.connect(_on_oggetto_usato)
	_aggiorna()

func _process(_delta: float) -> void:
	var gioco := _in_gioco()
	monete_hud.visible = gioco
	hotbar_box.visible = gioco
	if gioco:
		return
	if pannello.visible or tooltip_box.visible or prompt.visible:
		pannello.visible = false
		tooltip_box.visible = false
		prompt.hide()
		if _tw:
			_tw.kill()
		if _pt:
			_pt.kill()

func _input(event: InputEvent) -> void:
	if not _in_gioco():
		return
	if event.is_action_pressed("backpack"):
		pannello.visible = not pannello.visible
		if pannello.visible:
			lista.grab_focus()
		else:
			lista.release_focus()
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not _in_gioco():
		return
	for i in slots.size():
		if event.is_action_pressed("hotbar_%d" % (i + 1)):
			if pannello.visible:
				_assegna_selezionato(i)
			else:
				Inventario.usa_slot(i)
			get_viewport().set_input_as_handled()
			return

func _in_gioco() -> bool:
	return get_tree().get_first_node_in_group("player") != null

func _assegna_selezionato(indice: int) -> void:
	var sel := lista.get_selected_items()
	if sel.is_empty():
		return
	var item: ItemData = lista.get_item_metadata(sel[0])
	Inventario.assegna_hotbar(indice, item)

func _on_oggetto_usato(item: ItemData) -> void:
	mostra_tooltip("Hai usato: %s" % item.nome)

func _aggiorna() -> void:
	label_monete.text = str(Inventario.monete)

	var selezionato: ItemData = null
	var sel := lista.get_selected_items()
	if not sel.is_empty():
		selezionato = lista.get_item_metadata(sel[0])

	lista.clear()
	for item: ItemData in Inventario.oggetti:
		var idx := lista.add_item("%s x%d" % [item.nome, Inventario.oggetti[item]], item.icona)
		lista.set_item_metadata(idx, item)
		if item == selezionato:
			lista.select(idx)

	for i in slots.size():
		var item: ItemData = Inventario.hotbar[i]
		slots[i].imposta(item, Inventario.oggetti.get(item, 0))

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
