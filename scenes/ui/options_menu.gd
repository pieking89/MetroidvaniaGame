extends Control

signal chiudi

@onready var btn_applica: Button = $Panel2/BtnApplica
@onready var btn_indietro: Button = $Panel2/BtnIndietro


var pending := {}


func _ready() -> void:
	btn_indietro.pressed.connect(_on_indietro)	
	btn_applica.pressed.connect(_on_applica)


func _on_indietro() -> void:
	chiudi.emit()


func _on_applica() -> void:
	# qui finiranno le impostazioni in sospeso
	print(pending)
