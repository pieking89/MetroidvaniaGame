extends Control

const SLIDE := 500.0
const DUR := 0.35

var skip_move_sfx := false
var main_x := 0.0
var in_transizione := false

@onready var main_panel: Control = $MainPanel
@onready var vbox: VBoxContainer = $MainPanel/VBox
@onready var options: Control = $OptionsMenu
@onready var first_button: Button = $MainPanel/VBox/BtnGioca
@onready var sfx_move: AudioStreamPlayer2D = $SfxMove
@onready var sfx_select: AudioStreamPlayer2D = $SfxSelect
@onready var titolo: Label = $MainPanel/VBox/Titolo


func _ready() -> void:
	main_x = main_panel.position.x
	options.hide()
	vbox.get_node("BtnGioca").pressed.connect(start_game)
	vbox.get_node("BtnOpzioni").pressed.connect(open_options)
	vbox.get_node("BtnEsci").pressed.connect(quit_game)
	options.chiudi.connect(close_options)

	for btn in vbox.get_children():
		if btn is Button:
			setup_indicator(btn)
			btn.pressed.connect(sfx_select.play)

	skip_move_sfx = true
	first_button.grab_focus()
	await get_tree().process_frame
	print("titolo: ", titolo.position, " ", titolo.size)


func open_options() -> void:
	if in_transizione:
		return
	in_transizione = true
	options.show()
	options.position.x = main_x + SLIDE
	options.modulate.a = 0.0

	var t := create_tween().set_parallel()
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(main_panel, "position:x", main_x - SLIDE, DUR)
	t.tween_property(main_panel, "modulate:a", 0.0, DUR * 0.7)
	t.tween_property(options, "position:x", main_x, DUR)
	t.tween_property(options, "modulate:a", 1.0, DUR)

	await t.finished
	main_panel.hide()
	in_transizione = false


func close_options() -> void:
	if in_transizione:
		return
	in_transizione = true
	main_panel.show()
	main_panel.position.x = main_x - SLIDE

	var t := create_tween().set_parallel()
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(main_panel, "position:x", main_x, DUR)
	t.tween_property(main_panel, "modulate:a", 1.0, DUR)
	t.tween_property(options, "position:x", main_x + SLIDE, DUR)
	t.tween_property(options, "modulate:a", 0.0, DUR * 0.7)

	await t.finished
	options.hide()
	skip_move_sfx = true
	vbox.get_node("BtnOpzioni").grab_focus()
	in_transizione = false


func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Overworld.tscn")


func quit_game() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
	
func setup_indicator(btn: Button) -> void:
	var nome := btn.text
	btn.text = "  " + nome + "  "

	btn.focus_entered.connect(func():
		if skip_move_sfx:
			skip_move_sfx = false
		else:
			sfx_move.play()
		btn.text = "> " + nome
		var t := btn.create_tween()
		t.tween_property(btn, "position:x", 16.0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	)

	btn.focus_exited.connect(func():
		btn.text = "  " + nome
		var t := btn.create_tween()
		t.tween_property(btn, "position:x", 0.0, 0.12)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not in_transizione:
		close_options()
		get_viewport().set_input_as_handled()
		
