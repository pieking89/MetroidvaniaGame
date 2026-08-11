extends CharacterBody2D

const SPEED = 110.0
const JUMP_VELOCITY = -160.0
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1
const JUMP_HOLD_TIME = 0.15
const DASH_SPEED = 300.0
const DASH_TIME = 0.15
const DASH_END_SPEED = 120.0

var dash_timer := 0.0
var dash_direction := Vector2.ZERO
var can_dash := true
var jump_hold_timer := 0.0
var coyote_timer := 0.0	
var jump_buffer_timer := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func start_dash() -> void:
	var input := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "crouch")
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
	
	# --- dash in corso: prende il controllo del frame
	if dash_timer > 0.0:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		if dash_timer <= 0.0:
			velocity = dash_direction * DASH_END_SPEED
		return
	
	if Input.is_action_just_pressed("crouch"):
		collision.shape.size.y -= 2.0
		collision.position.y += 1.0
	
	if Input.is_action_just_released("crouch"):
		collision.shape.size.y += 2.0
		collision.position.y -= 1.0

	# --- avvio del dash
	if is_on_floor():
		can_dash = true

	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

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

	# --- il salto vero
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
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

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animation(direction)
		
func update_animation(direction: float) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0



	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0.0 else "fall")
	elif direction != 0.0:
		sprite.play("run")
	else:
		sprite.play("idle")
		
	
