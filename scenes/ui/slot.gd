extends PanelContainer

@onready var icona: TextureRect = $MarginContainer/MarginContainer/Icona
@onready var label_numero: Label = $MarginContainer/Numero
@onready var label_quantita: Label = $MarginContainer/Quantita


func imposta_numero(n: int) -> void:
	label_numero.text = str(n)

func imposta(item: ItemData, quantita: int) -> void:
	icona.texture = item.icona if item else null
	label_quantita.text = str(quantita) if item and quantita > 1 else ""
