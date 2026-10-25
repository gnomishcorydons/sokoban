class_name Player
extends Entity

const PACKED_SCENE: PackedScene = preload("uid://dcq47felmt2ny")

var frozen: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if not can_move(): return
	
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == 1:
			var mouse_position: Vector2 = get_global_mouse_position()
			var direction: Vector2 = global_position.direction_to(mouse_position)
			if abs(direction.x) < abs(direction.y):
				if direction.y < 0: # Up
					move(Direction.UP)
				else: # Down
					move(Direction.DOWN)
			else:
				if direction.x < 0: #  Left
					move(Direction.LEFT)
				else: # Right
					move(Direction.RIGHT)
			get_viewport().set_input_as_handled()

func _physics_process(_delta: float) -> void:
	movement()

func movement() -> void:
	if not can_move(): return
	
	if Input.is_action_pressed("move_up"):
		move(Direction.UP)
	elif Input.is_action_pressed("move_down"):
		move(Direction.DOWN)
	elif Input.is_action_pressed("move_left"):
		move(Direction.LEFT)
	elif Input.is_action_pressed("move_right"):
		move(Direction.RIGHT)

func can_move() -> bool:
	if frozen: return false
	if not ready_to_move(): return false
	return true

func move(direction: Direction, _ignore_collision: bool = false) -> ReasonBlocked:
	var reason_blocked: ReasonBlocked = super.move(direction)
	if reason_blocked == ReasonBlocked.BOX:
		var box: Box = rays.get_collider(direction) as Box
		if box != null:
			var reason_box_blocked: ReasonBlocked = box.move(direction)
			if reason_box_blocked == ReasonBlocked.NONE:
				return super.move(direction, true) # For some reason it doesnt work if you dont ignore collision even though the rust prototpe worked fine
	return reason_blocked
