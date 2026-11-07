class_name ItemData
extends Resource

@export var nome: String = ""
@export_multiline var descrizione: String = ""
@export var icona: Texture2D

enum Effetto { NESSUNO, VELOCITA }

@export var effetto: Effetto = Effetto.NESSUNO
@export var moltiplicatore: float = 1.5
@export var durata: float = 15.0
