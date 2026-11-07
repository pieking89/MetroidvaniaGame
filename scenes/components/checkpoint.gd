extends Node2D

@export var id: String = ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var scintille: GPUParticles2D = $Scintille
@onready var spawn: Marker2D = $Spawn
@onready var zona: Area2D = $Zona

func _ready() -> void:
	add_to_group("checkpoint")
	if id == "":
		id = "%s:%s" % [owner.scene_file_path, owner.get_path_to(self)]
	aggiorna_stato()
	zona.body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animazione_finita)

func aggiorna_stato() -> void:
	sprite.play("accesa" if GameState.bandiera_attiva == id else "spenta")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or SaveManager.spawn_protetto:
		return
	var era_attiva := GameState.bandiera_attiva == id
	SaveManager.salva_al_checkpoint(id, spawn.global_position)
	get_tree().call_group("checkpoint", "aggiorna_stato")
	if not era_attiva:
		sprite.play("accensione")
		scintille.restart()
	InventarioUI.mostra_tooltip("Partita salvata")

func _on_animazione_finita() -> void:
	if sprite.animation == "accensione":
		sprite.play("accesa")
