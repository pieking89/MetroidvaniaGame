extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var label: Label = $Panel/Label

var _t: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()


func mostra(titolo: String) -> void:
	if _t:
		_t.kill()

	label.text = "♪  " + titolo
	panel.show()
	panel.modulate.a = 0.0
	await get_tree().process_frame   # aspetta che il pannello si ridimensioni sul testo

	var x_finale := panel.position.x
	panel.position.x = x_finale + 400.0

	_t = create_tween().set_parallel()
	_t.tween_property(panel, "position:x", x_finale, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_t.tween_property(panel, "modulate:a", 1.0, 0.3)

	_t.chain().tween_interval(3.0)

	_t.chain().tween_property(panel, "position:x", x_finale + 400.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_t.tween_property(panel, "modulate:a", 0.0, 0.3)
	_t.chain().tween_callback(func(): panel.position.x = x_finale; panel.hide())
	
