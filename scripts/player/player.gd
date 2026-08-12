extends CharacterBody2D

const SPEED = 110.0
const CROUCH_SPEED = 50.0
const JUMP_VELOCITY = -160.0
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1
const JUMP_HOLD_TIME = 0.15
const DASH_SPEED = 300.0
const DASH_TIME = 0.15
const DASH_END_SPEED = 160.0
const ACCELERATION = 1200.0
const FRICTION = 1600.0
const MOMENTUM_FRICTION = 200.0

var dash_timer := 0.0
var dash_direction := Vector2.ZERO
var is_crouching := false
var can_dash := true
var jump_hold_timer := 0.0
var coyote_timer := 0.0	
var jump_buffer_timer := 0.0
var was_on_floor := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var stand_size: Vector2 = collision.shape.size
@onready var stand_position: Vector2 = collision.position
@onready var crouch_size: Vector2 = Vector2(stand_size.x, stand_size.y - 2.0)
@onready var crouch_position: Vector2 = Vector2(stand_position.x, stand_position.y + 1.0)
@export var landing_particles_scene: PackedScene
@export var jump_particles_scene: PackedScene

func start_dash() -> void:
	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if input == Vector2.ZERO:
		input.x = -1.0 if sprite.flip_h else 1.0

	dash_direction = input.normalized()
	dash_timer = DASH_TIME
	can_dash = false

	if absf(dash_direction.y) > 0.7:
		sprite.play("dash_down" if dash_direction.y > 0.0 else "dash_up")
	else:
		sprite.play("dash_side")


func _physics_process(delta: float) -> void:
	
	is_crouching = Input.is_action_pressed("crouch")

	if is_crouching:
		collision.shape.size = crouch_size
		collision.position = crouch_position
	else:
		collision.shape.size = stand_size
		collision.position = stand_position
	
		# --- coyote: si ricarica a terra, scala in aria
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# --- buffer: si ricarica alla pressione, scala sempre
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta
	
	# --- dash in corso: prende il controllo del frame
	if dash_timer > 0.0:
		# uscita anticipata per salto
		if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
			dash_timer = 0.0
			velocity.x = dash_direction.x * DASH_SPEED
		else:
			dash_timer -= delta
			velocity = dash_direction * DASH_SPEED
			move_and_slide()

		var hit_floor := is_on_floor() and dash_direction.y > 0.0
		if hit_floor or is_on_wall() and dash_direction.dot(get_wall_normal()) < 0.0:
			dash_timer = 0.0
			velocity = dash_direction * DASH_END_SPEED
		elif dash_timer <= 0.0:
			velocity = dash_direction * DASH_END_SPEED
		return
	

	# --- avvio del dash
	if is_on_floor():
		can_dash = true

	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- il salto vero
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		spawn_jump_particles()
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump_hold_timer = JUMP_HOLD_TIME
	
	# --- mantenimento del salto
	if jump_hold_timer > 0.0:
		if Input.is_action_pressed("jump") and not is_on_ceiling():
			velocity.y = JUMP_VELOCITY
			jump_hold_timer -= delta
		else:
			jump_hold_timer = 0.0
			if velocity.y < 0.0:
				velocity.y *= 0.4

	var current_speed := CROUCH_SPEED if is_crouching else SPEED

	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		var target := direction * current_speed
		var same_way := signf(velocity.x) == signf(direction)
		var above_speed := absf(velocity.x) > current_speed

		if same_way and above_speed:
			velocity.x = move_toward(velocity.x, target, MOMENTUM_FRICTION * delta)
		else:
			velocity.x = move_toward(velocity.x, target, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	
	if absf(velocity.x) > SPEED:
		print(velocity.x)

	move_and_slide()
	update_animation(direction)
	
	if is_on_floor() and not was_on_floor:
		spawn_landing_particles()
	was_on_floor = is_on_floor()
		
func update_animation(direction: float) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0



	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0.0 else "fall")
	elif is_crouching:
		sprite.play("crouch_walk" if direction != 0.0 else "crouch")
	elif direction != 0.0:
		sprite.play("run")
	else:
		sprite.play("idle")


func spawn_landing_particles() -> void:
	if landing_particles_scene == null:
		return

	var p := landing_particles_scene.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position + Vector2(0, 8)
	p.get_node("GPUParticles2D").emitting = true
	
func spawn_jump_particles() -> void:
	if jump_particles_scene == null:
		return

	var p := jump_particles_scene.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position + Vector2(0, 8)
	p.get_node("GPUParticles2D").emitting = true
	
