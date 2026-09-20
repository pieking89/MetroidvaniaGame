extends Control

signal chiudi

@onready var btn_applica: Button = $Panel2/BtnApplica
@onready var btn_indietro: Button = $Panel2/BtnIndietro
@onready var slider_musica: HSlider = $Panel/Musica/Slider
@onready var slider_sfx: HSlider = $"Panel/Effetti sonori/Slider"
@onready var slider_generale: HSlider = $Panel/Generale/Slider
@onready var sfx_move: AudioStreamPlayer2D = $SfxMove
@onready var lbl_generale: Label = $Panel/Generale/Percentuale
@onready var lbl_musica: Label = $Panel/Musica/Percentuale
@onready var lbl_sfx: Label = $"Panel/Effetti sonori/Percentuale"
@onready var opt_modalita: OptionButton = $Panel/Modalitá/OptionButton
@onready var opt_risoluzione: OptionButton = $Panel/Risoluzione/OptionButton
@onready var opt_fps: OptionButton = $Panel/Limiter/OptionButton
@onready var opt_vsync: OptionButton = $Panel/Limiter/OptionButton2
var pending := {}


func _ready() -> void:
	print("letti: ", Settings.data)
	slider_generale.value = Settings.data["vol_master"]
	slider_generale.value = Settings.data["vol_master"]
	slider_musica.value = Settings.data["vol_music"]
	slider_sfx.value = Settings.data["vol_sfx"]
	lbl_generale.text = "%.1f%%" % slider_generale.value
	lbl_musica.text = "%.1f%%" % slider_musica.value
	lbl_sfx.text = "%.1f%%" % slider_sfx.value
	btn_indietro.pressed.connect(_on_indietro)
	slider_generale.value_changed.connect(_on_volume.bind("vol_master", "Master", lbl_generale, true))
	slider_musica.value_changed.connect(_on_volume.bind("vol_music", "Music", lbl_musica, false))
	slider_sfx.value_changed.connect(_on_volume.bind("vol_sfx", "SFX", lbl_sfx, true))
	opt_modalita.selected = Settings.data["window_mode"]
	opt_modalita.item_selected.connect(_on_modalita)
	opt_risoluzione.selected = Settings.data["resolution"]
	opt_risoluzione.item_selected.connect(_on_risoluzione)
	aggiorna_risoluzione_ui()
	opt_fps.selected = Settings.data["fps_limit"]
	opt_fps.item_selected.connect(_on_fps)
	opt_vsync.selected = 0 if Settings.data["vsync"] else 1
	opt_vsync.item_selected.connect(_on_vsync)
	for opt in [opt_risoluzione, opt_modalita, opt_fps, opt_vsync]:
		opt.focus_mode = Control.FOCUS_ALL
		opt.gui_input.connect(_on_option_input.bind(opt))



func _on_indietro() -> void:
	chiudi.emit()


func _on_applica() -> void:
	# qui finiranno le impostazioni in sospeso
	print(pending)

func _on_volume(valore: float, key: String, bus_name: String, lbl: Label, suona: bool) -> void:
	Settings.set_value(key, valore)
	Settings.set_bus(bus_name, valore)

	lbl.text = "%.1f%%" % valore

	if suona and valore > 0.5:
		sfx_move.pitch_scale = 0.6 + (valore / 100.0) * 0.8
		sfx_move.play()
		
func _on_modalita(idx: int) -> void:
	Settings.set_value("window_mode", idx)
	Settings.apply_video()
	aggiorna_risoluzione_ui()

func _on_risoluzione(idx: int) -> void:
	Settings.set_value("resolution", idx)
	Settings.apply_video()

func aggiorna_risoluzione_ui() -> void:
	var in_finestra: bool = Settings.data["window_mode"] == 0
	opt_risoluzione.disabled = not in_finestra

	if not in_finestra:
		var nativa := DisplayServer.screen_get_size()
		var idx: int = Settings.RESOLUTIONS.find(nativa)
		if idx != -1:
			opt_risoluzione.selected = idx
	else:
		opt_risoluzione.selected = Settings.data["resolution"]

func _on_fps(idx: int) -> void:
	Settings.set_value("fps_limit", idx)
	Settings.apply_fps()


func _on_vsync(idx: int) -> void:
	Settings.set_value("vsync", idx == 0)
	Settings.apply_fps()

func _on_option_input(event: InputEvent, opt: OptionButton) -> void:
	if opt.disabled:
		return
	if event.is_action_pressed("ui_right"):
		cicla(opt, 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		cicla(opt, -1)
		get_viewport().set_input_as_handled()

func cicla(opt: OptionButton, dir: int) -> void:
	var n := opt.item_count
	var i := opt.selected + dir
	if i < 0:
		i = n - 1
	elif i >= n:
		i = 0
	opt.selected = i
	opt.item_selected.emit(i)

func primo_focus() -> void:
	slider_generale.grab_focus()
