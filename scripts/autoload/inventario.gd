extends Node

signal cambiato

var monete: int = 0
var oggetti: Dictionary = {}  # nome -> quantità

func aggiungi_monete(n: int) -> void:
	monete += n
	cambiato.emit()

func aggiungi_oggetto(nome: String, quantita: int = 1) -> void:
	oggetti[nome] = oggetti.get(nome, 0) + quantita
	cambiato.emit()
