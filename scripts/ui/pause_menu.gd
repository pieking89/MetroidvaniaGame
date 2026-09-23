extends CanvasLayer

const SLIDE := 500.0
const DUR := 0.35

var skip_move_sfx := false
var main_x := 0.0
var in_transizione := false

@onready var overlay: ColorRect = $Overlay
@onready var main_panel: Control = $Overlay/MainPanel
@onready var options: Control = $Overlay/OptionsMenu
@onready var first_button: Button = $Overlay/MainPanel/Center/VBox/BtnRiprendi
@onready var btn_opzioni: Button = $Overlay/MainPanel/Center/VBox/BtnOpzioni
@onready var sfx_move: AudioStreamPlayer2D = $SfxMove
@onready var sfx_select: AudioStreamPlayer2D = $SfxSelect
@onready var sfx_pause: AudioStreamPlayer2D = $SfxPause
@onready var panel: Panel = $Panel


func _ready() -> void:
	hide()
	main_x = main_panel.position.x
	options.hide()
	options.chiudi.connect(close_options)

	var vbox := $Overlay/MainPanel/Center/VBox
	vbox.get_node("BtnRiprendi").pressed.connect(toggle_pause)
	vbox.get_node("BtnOpzioni").pressed.connect(open_options)
	vbox.get_node("BtnEsci").pressed.connect(quit_game)

	for btn in vbox.get_children():
		if btn is Button:
			setup_indicator(btn)
			btn.pressed.connect(sfx_select.play)
	


func open_options() -> void:
	if in_transizione:
		return
	in_transizione = true
	options.show()
	options.position.x = main_x + SLIDE
	options.modulate.a = 0.0

	var t := create_tween().set_parallel()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(main_panel, "position:x", main_x - SLIDE, DUR)
	t.tween_property(main_panel, "modulate:a", 0.0, DUR * 0.7)
	t.tween_property(options, "position:x", main_x, DUR)
	t.tween_property(options, "modulate:a", 1.0, DUR)

	await t.finished
	main_panel.hide()
	in_transizione = false
	options.primo_focus()


func close_options() -> void:
	if in_transizione:
		return
	in_transizione = true
	main_panel.show()
	main_panel.position.x = main_x - SLIDE

	var t := create_tween().set_parallel()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(main_panel, "position:x", main_x, DUR)
	t.tween_property(main_panel, "modulate:a", 1.0, DUR)
	t.tween_property(options, "position:x", main_x + SLIDE, DUR)
	t.tween_property(options, "modulate:a", 0.0, DUR * 0.7)

	await t.finished
	options.hide()
	skip_move_sfx = true
	btn_opzioni.grab_focus()
	in_transizione = false

func setup_indicator(btn: Button) -> void:
	var nome := btn.text
	btn.text = "  " + nome

	btn.focus_entered.connect(func():
		if skip_move_sfx:
			skip_move_sfx = false
		else:
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
	if in_transizione:
		return

	if options.visible:
		if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
			close_options()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	var p := not get_tree().paused
	get_tree().paused = p
	AudioManager.set_muffled(p)

	if p:
		sfx_pause.play()
		overlay.modulate.a = 0.0
		show()
		skip_move_sfx = true
		first_button.grab_focus()
		create_tween().tween_property(overlay, "modulate:a", 1.0, 0.15)
	else:
		var t := create_tween()
		t.tween_property(overlay, "modulate:a", 0.0, 0.15)
		await t.finished
		hide()


func quit_game() -> void:
	AudioManager.set_muffled(false)
	SceneTransition.change_scene("res://scenes/ui/main_menu.tscn")
