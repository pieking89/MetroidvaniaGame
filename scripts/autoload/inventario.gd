extends Node

signal cambiato
signal oggetto_usato(item: ItemData)

const SLOT_HOTBAR := 5

var monete: int = 0
var oggetti: Dictionary = {}  # ItemData -> quantità
var hotbar: Array[ItemData] = []

func _ready() -> void:
	hotbar.resize(SLOT_HOTBAR)

func aggiungi_monete(n: int) -> void:
	monete += n
	cambiato.emit()

func aggiungi_oggetto(item: ItemData, quantita: int = 1) -> void:
	oggetti[item] = oggetti.get(item, 0) + quantita
	cambiato.emit()

func rimuovi_oggetto(item: ItemData, quantita: int = 1) -> void:
	if not oggetti.has(item):
		return
	oggetti[item] -= quantita
	if oggetti[item] <= 0:
		oggetti.erase(item)
		var i := hotbar.find(item)
		if i != -1:
			hotbar[i] = null
	cambiato.emit()

func assegna_hotbar(indice: int, item: ItemData) -> void:
	var vecchio := hotbar.find(item)
	if vecchio != -1:
		hotbar[vecchio] = hotbar[indice]
	hotbar[indice] = item
	cambiato.emit()

func usa_oggetto(item: ItemData) -> void:
	if item == null or not oggetti.has(item):
		return
	oggetto_usato.emit(item)
	rimuovi_oggetto(item)

func usa_slot(indice: int) -> void:
	usa_oggetto(hotbar[indice])

func to_dict() -> Dictionary:
	var ogg := {}
	for item: ItemData in oggetti:
		ogg[item.resource_path] = oggetti[item]
	var hb := []
	for item in hotbar:
		hb.append(item.resource_path if item else "")
	return { "monete": monete, "oggetti": ogg, "hotbar": hb }

func from_dict(d: Dictionary) -> void:
	monete = int(d.get("monete", 0))
	oggetti.clear()
	var ogg: Dictionary = d.get("oggetti", {})
	for path in ogg:
		var item := load(path) as ItemData
		if item:
			oggetti[item] = int(ogg[path])
	hotbar.clear()
	hotbar.resize(SLOT_HOTBAR)
	var hb: Array = d.get("hotbar", [])
	for i in mini(hb.size(), SLOT_HOTBAR):
		if hb[i] != "":
			hotbar[i] = load(hb[i]) as ItemData
	cambiato.emit()

func reset() -> void:
	from_dict({})
