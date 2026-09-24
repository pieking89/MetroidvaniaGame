extends Node

signal collezionabile_preso(id: String)

var collezionabili: Dictionary = {}
var abilita: Dictionary = {}
var bandiera_attiva: String = ""
var casse_aperte: Dictionary = {}

func ha_preso(id: String) -> bool:
	return collezionabili.has(id)

func prendi(id: String) -> void:
	if ha_preso(id):
		return
	collezionabili[id] = true
	collezionabile_preso.emit(id)

func ha_abilita(nome: String) -> bool:
	return abilita.has(nome)

func sblocca(nome: String) -> void:
	abilita[nome] = true

func cassa_aperta(id: String) -> bool:
	return casse_aperte.has(id)

func segna_cassa(id: String) -> void:
	casse_aperte[id] = true

func reset() -> void:
	casse_aperte.clear()
