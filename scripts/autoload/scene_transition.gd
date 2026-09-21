extends CanvasLayer

const CELL := 80.0      # dimensione di ogni cubo in pixel
const DUR := 0.5        # durata della transizione
const SPREAD := 0.4     # quanto è sfalsata l'onda (0 = tutti insieme)

var busy := false
var _rect: Control

var progress := 1.0:
	set(v):
		progress = v
		if _rect:
			_rect.queue_redraw()


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_rect = Control.new()
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_rect.draw.connect(_draw_cells)
	add_child(_rect)

	# all'avvio lo schermo parte coperto: aspetta che tutto sia caricato
	busy = true
	await get_tree().process_frame
	await get_tree().process_frame
	await reveal()
	busy = false


func _draw_cells() -> void:
	var area := _rect.size
	var cols := ceili(area.x / CELL)
	var rows := ceili(area.y / CELL)
	var max_d := float(cols + rows)

	for x in cols:
		for y in rows:
			var delay := float(x + y) / max_d * SPREAD
			var local := clampf(progress * (1.0 + SPREAD) - delay, 0.0, 1.0)
			if local <= 0.0:
				continue
			var s := (CELL + 1.0) * local
			var center := Vector2(x + 0.5, y + 0.5) * CELL
			_rect.draw_rect(Rect2(center - Vector2(s, s) / 2.0, Vector2(s, s)), Color.BLACK)


func cover() -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var t := create_tween()
	t.tween_property(self, "progress", 1.0, DUR).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await t.finished


func reveal() -> void:
	var t := create_tween()
	t.tween_property(self, "progress", 0.0, DUR).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene(path: String) -> void:
	if busy:
		return
	busy = true
	await cover()
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	await reveal()
	busy = false
