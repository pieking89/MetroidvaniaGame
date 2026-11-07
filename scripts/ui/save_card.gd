extends Control

signal cambiata

@export var slot: int = 0

const SPOSTAMENTO_INFO := 60.0
const SCALA_SELEZIONE := 1.05

@onready var card_panel: PanelContainer = $Card
@onready var vuota: Button = $Card/Vuota
@onready var piena: MarginContainer = $Card/Piena
@onready var label_nome: Label = $Card/Piena/VBox/Nome
@onready var campo_nome: LineEdit = $Card/Piena/VBox/CampoNome
@onready var label_monete: Label = $Card/Piena/VBox/Stats/Monete
@onready var btn_gioca: Button = $Card/Piena/VBox/Opzioni/Gioca
@onready var btn_rinomina: Button = $Card/Piena/VBox/Opzioni/Rinomina
@onready var btn_elimina: Button = $Card/Piena/VBox/Opzioni/Elimina
@onready var info: PanelContainer = $Info
@onready var label_tempo: Label = $Info/Margine/VBox/Tempo

var _conferma_elimina := false
var _nomi := {}
var _tw_info: Tween
var _tw_sel: Tween

func _ready() -> void:
	info.visible = false
	campo_nome.visible = false
	for btn in [btn_gioca, btn_rinomina, btn_elimina]:
		_setup_indicatore(btn)
	vuota.pressed.connect(func(): SaveManager.nuovo(slot))
	btn_gioca.pressed.connect(func(): SaveManager.carica(slot))
	btn_rinomina.pressed.connect(_inizia_rinomina)
	btn_elimina.pressed.connect(_on_elimina)
	btn_elimina.focus_exited.connect(_annulla_elimina)
	campo_nome.text_submitted.connect(_fine_rinomina)
	campo_nome.focus_exited.connect(_annulla_rinomina)
	btn_gioca.focus_neighbor_top = NodePath(".")
	btn_gioca.focus_neighbor_bottom = btn_gioca.get_path_to(btn_rinomina)
	btn_rinomina.focus_neighbor_top = btn_rinomina.get_path_to(btn_gioca)
	btn_rinomina.focus_neighbor_bottom = btn_rinomina.get_path_to(btn_elimina)
	btn_elimina.focus_neighbor_top = btn_elimina.get_path_to(btn_rinomina)
	btn_elimina.focus_neighbor_bottom = NodePath(".")
	vuota.focus_neighbor_top = NodePath(".")
	vuota.focus_neighbor_bottom = NodePath(".")
	aggiorna()

func bottoni() -> Array:
	return [vuota, btn_gioca, btn_rinomina, btn_elimina]

func aggiorna() -> void:
	var d := SaveManager.leggi(slot)
	var ha_dati := not d.is_empty()
	vuota.visible = not ha_dati
	piena.visible = ha_dati
	info.visible = false
	z_index = 0
	if ha_dati:
		label_nome.text = d.get("nome", "")
		var inv: Dictionary = d.get("inventario", {})
		label_monete.text = str(int(inv.get("monete", 0)))
		label_tempo.text = _formatta_tempo(d.get("tempo", 0.0))
	cambiata.emit()

func primo_focus() -> Control:
	return btn_gioca if piena.visible else vuota

# --- animazioni ---

func entra(ritardo: float) -> void:
	card_panel.position.y = 40.0
	card_panel.modulate.a = 0.0
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(card_panel, "position:y", 0.0, 0.35).set_delay(ritardo)
	t.tween_property(card_panel, "modulate:a", 1.0, 0.25).set_delay(ritardo)

func imposta_selezionata(sel: bool) -> void:
	card_panel.pivot_offset = card_panel.size / 2.0
	if _tw_sel:
		_tw_sel.kill()
	_tw_sel = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw_sel.tween_property(card_panel, "scale", Vector2.ONE * (SCALA_SELEZIONE if sel else 1.0), 0.2)
	_tw_sel.tween_property(self, "modulate", Color.WHITE if sel else Color(0.6, 0.6, 0.6), 0.2)

func toggle_info() -> void:
	if not piena.visible:
		return
	if info.visible:
		nascondi_info()
	else:
		_mostra_info()

func _mostra_info() -> void:
	var sporgenza := size.x * (SCALA_SELEZIONE - 1.0) / 2.0
	var larghezza := get_viewport_rect().size.x
	var a_destra := global_position.x + size.x + sporgenza + info.size.x <= larghezza
	var x_finale := size.x + sporgenza if a_destra else -info.size.x - sporgenza
	var direzione := 1.0 if a_destra else -1.0
	info.position.x = x_finale - SPOSTAMENTO_INFO * direzione
	info.modulate.a = 0.0
	info.visible = true
	z_index = 1
	if _tw_info:
		_tw_info.kill()
	_tw_info = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw_info.tween_property(info, "position:x", x_finale, 0.25)
	_tw_info.tween_property(info, "modulate:a", 1.0, 0.2)

func nascondi_info() -> void:
	if not info.visible:
		return
	var direzione := 1.0 if info.position.x >= 0.0 else -1.0
	if _tw_info:
		_tw_info.kill()
	_tw_info = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tw_info.tween_property(info, "position:x", info.position.x - SPOSTAMENTO_INFO * direzione, 0.18)
	_tw_info.tween_property(info, "modulate:a", 0.0, 0.15)
	_tw_info.chain().tween_callback(func():
		info.visible = false
		z_index = 0
	)

func _shake(nodo: Control) -> void:
	var x := nodo.position.x
	var t := nodo.create_tween()
	for d in [6.0, -6.0, 4.0, -4.0, 0.0]:
		t.tween_property(nodo, "position:x", x + d, 0.04)

# --- indicatore ">" come nel menu principale ---

func _setup_indicatore(btn: Button) -> void:
	_nomi[btn] = btn.text.strip_edges()
	_applica_testo(btn)
	btn.focus_entered.connect(func():
		_applica_testo(btn)
		var t := btn.create_tween()
		t.tween_property(btn, "position:x", 16.0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	)
	btn.focus_exited.connect(func():
		_applica_testo(btn)
		var t := btn.create_tween()
		t.tween_property(btn, "position:x", 0.0, 0.12)
	)

func _applica_testo(btn: Button) -> void:
	var nome: String = _nomi[btn]
	btn.text = "> " + nome if btn.has_focus() else "  " + nome + "  "

func _imposta_testo(btn: Button, nome: String) -> void:
	_nomi[btn] = nome
	_applica_testo(btn)

# --- rinomina ---

func _inizia_rinomina() -> void:
	label_nome.visible = false
	campo_nome.text = label_nome.text
	campo_nome.visible = true
	campo_nome.grab_focus()
	campo_nome.select_all()

func _fine_rinomina(testo: String) -> void:
	var t := testo.strip_edges()
	if t != "":
		SaveManager.rinomina(slot, t)
		label_nome.text = t
	_chiudi_campo()

func _annulla_rinomina() -> void:
	if campo_nome.visible:
		_chiudi_campo()

func _chiudi_campo() -> void:
	campo_nome.visible = false
	label_nome.visible = true
	btn_rinomina.grab_focus()

# --- elimina ---

func _on_elimina() -> void:
	if not _conferma_elimina:
		_conferma_elimina = true
		_imposta_testo(btn_elimina, "Sicuro?")
		_shake(btn_elimina)
		return
	SaveManager.elimina(slot)
	_annulla_elimina()
	var t := create_tween()
	t.tween_property(card_panel, "modulate:a", 0.0, 0.2)
	await t.finished
	aggiorna()
	vuota.grab_focus()
	create_tween().tween_property(card_panel, "modulate:a", 1.0, 0.2)

func _annulla_elimina() -> void:
	_conferma_elimina = false
	_imposta_testo(btn_elimina, "Elimina")

func _formatta_tempo(secondi: float) -> String:
	var t := int(secondi)
	return "%d:%02d:%02d" % [t / 3600, (t / 60) % 60, t % 60]
