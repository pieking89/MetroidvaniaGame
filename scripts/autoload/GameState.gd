extends Node

var casse_aperte: Dictionary = {}
var bandiera_attiva: String = ""

func cassa_aperta(id: String) -> bool:
	return casse_aperte.has(id)

func segna_cassa(id: String) -> void:
	casse_aperte[id] = true

func to_dict() -> Dictionary:
	return { "casse": casse_aperte.keys(), "bandiera": bandiera_attiva }

func from_dict(d: Dictionary) -> void:
	reset()
	for id in d.get("casse", []):
		casse_aperte[id] = true
	bandiera_attiva = d.get("bandiera", "")

func reset() -> void:
	casse_aperte.clear()
	bandiera_attiva = ""
