extends Node

signal cambiato

var _attivi: Dictionary = {}  # ItemData.Effetto -> { "molt": float, "resta": float }

func _ready() -> void:
	Inventario.oggetto_usato.connect(_on_oggetto_usato)

func _on_oggetto_usato(item: ItemData) -> void:
	if item.effetto == ItemData.Effetto.NESSUNO:
		return
	_attivi[item.effetto] = { "molt": item.moltiplicatore, "resta": item.durata }
	cambiato.emit()

func _process(delta: float) -> void:
	if _attivi.is_empty():
		return
	for e in _attivi.keys():
		_attivi[e]["resta"] -= delta
		if _attivi[e]["resta"] <= 0.0:
			_attivi.erase(e)
			cambiato.emit()

func moltiplicatore(e: ItemData.Effetto) -> float:
	return _attivi[e]["molt"] if _attivi.has(e) else 1.0

func tempo_rimasto(e: ItemData.Effetto) -> float:
	return _attivi[e]["resta"] if _attivi.has(e) else 0.0

func reset() -> void:
	_attivi.clear()
	cambiato.emit()
