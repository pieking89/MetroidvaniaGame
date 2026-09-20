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
	btn_applica.pressed.connect(_on_applica)
	slider_generale.value_changed.connect(_on_volume.bind("vol_master", "Master", lbl_generale, true))
	slider_musica.value_changed.connect(_on_volume.bind("vol_music", "Music", lbl_musica, false))
	slider_sfx.value_changed.connect(_on_volume.bind("vol_sfx", "SFX", lbl_sfx, true))
	opt_modalita.selected = Settings.data["window_mode"]
	opt_modalita.item_selected.connect(_on_modalita)
	opt_risoluzione.selected = Settings.data["resolution"]
	opt_risoluzione.item_selected.connect(_on_risoluzione)



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
	print("modalita cambiata: ", idx)
	Settings.set_value("window_mode", idx)
	Settings.apply_video()

func _on_risoluzione(idx: int) -> void:
	Settings.set_value("resolution", idx)
	Settings.apply_video()
