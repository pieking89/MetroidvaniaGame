extends CanvasLayer

const VEL := 40.0   # caratteri al secondo

@onready var panel: PanelContainer = $Margin/Panel
@onready var testo: RichTextLabel = $Margin/Panel/Testo

var aperto := false
var _pagine: PackedStringArray
var _i := 0
var _t: Tween


func _ready() -> void:
	panel.hide()


func apri(pagine: PackedStringArray) -> void:
	_pagine = pagine
	_i = 0
	aperto = true
	panel.show()
	_mostra_pagina()


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
