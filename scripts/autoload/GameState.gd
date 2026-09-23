extends Node

signal collezionabile_preso(id: String)

var collezionabili: Dictionary = {}
var abilita: Dictionary = {}
var bandiera_attiva: String = ""

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
