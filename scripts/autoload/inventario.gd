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

func usa_slot(indice: int) -> void:
	var item := hotbar[indice]
	if item == null:
		return
	oggetto_usato.emit(item)
	rimuovi_oggetto(item)
