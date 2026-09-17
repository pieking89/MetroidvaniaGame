extends CanvasLayer

@onready var first_button: Button = $Overlay/Center/VBox/BtnRiprendi
@onready var overlay: ColorRect = $Overlay
@onready var sfx_move: AudioStreamPlayer2D = $SfxMove
@onready var sfx_select: AudioStreamPlayer2D = $SfxSelect

func _ready() -> void:
	hide()
	
	var vbox := $Overlay/Center/VBox
	vbox.get_node("BtnRiprendi").pressed.connect(toggle_pause)
	vbox.get_node("BtnEsci").pressed.connect(get_tree().quit)

	for btn in vbox.get_children():
		if btn is Button:
			setup_indicator(btn)
			btn.pressed.connect(sfx_select.play)



func setup_indicator(btn: Button) -> void:
	var nome := btn.text
	btn.text = "  " + nome

	btn.focus_entered.connect(func():
		sfx_move.play()
		btn.text = "> " + nome
		var t := btn.create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.tween_property(btn, "position:x", 16.0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	)

	btn.focus_exited.connect(func():
		btn.text = "  " + nome
		var t := btn.create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.tween_property(btn, "position:x", 0.0, 0.12)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		print("pause premuto")
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var p := not get_tree().paused
	get_tree().paused = p

	if p:
		overlay.modulate.a = 0.0
		show()
		first_button.grab_focus()
		create_tween().tween_property(overlay, "modulate:a", 1.0, 0.15)
	else:
		var t := create_tween()
		t.tween_property(overlay, "modulate:a", 0.0, 0.15)
		await t.finished
		hide()
