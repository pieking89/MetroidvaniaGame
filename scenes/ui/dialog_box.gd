extends CanvasLayer

const VEL := 40.0   # caratteri al secondo

@onready var panel: PanelContainer = $Margin/Panel
@onready var testo: RichTextLabel = $Margin/Panel/Testo
@onready var prompt: Label = $PromptMargin/Prompt

var aperto := false
var _pagine: PackedStringArray
var _i := 0
var _t: Tween
var _pt: Tween


func _ready() -> void:
	panel.hide()
	prompt.hide()


func apri(pagine: PackedStringArray) -> void:
	_pagine = pagine
	_i = 0
	aperto = true
	panel.show()
	_mostra_pagina()
	prompt.hide()


func avanti() -> void:
	# se il testo sta ancora comparendo, completalo subito
	if _t and _t.is_running():
		_t.kill()
		testo.visible_ratio = 1.0
		return

	_i += 1
	if _i >= _pagine.size():
		chiudi()
	else:
		_mostra_pagina()


func chiudi() -> void:
	panel.hide()
	aperto = false


func _mostra_pagina() -> void:
	testo.text = _pagine[_i]
	testo.visible_ratio = 0.0
	_t = create_tween()
	_t.tween_property(testo, "visible_ratio", 1.0, _pagine[_i].length() / VEL)

func mostra_prompt(t: String) -> void:
	if aperto:
		return
	prompt.text = t
	prompt.show()
	prompt.modulate.a = 0.0
	prompt.scale = Vector2(0.8, 0.8)

	await get_tree().process_frame          # aspetta che la Label si ridimensioni sul testo
	prompt.pivot_offset = prompt.size / 2.0  # così cresce dal centro, non dall'angolo

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
