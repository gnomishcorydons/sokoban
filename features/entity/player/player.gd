extends Entity

func _physics_process(_delta: float) -> void:
	movement()

func movement() -> void:
	if not ready_to_move(): return
	
	var should_move: bool = true # If an action is not triggered, dont move.
	var movement_direction: Direction
	
	if Input.is_action_pressed("move_up"):
		movement_direction = Direction.UP
	elif Input.is_action_pressed("move_down"):
		movement_direction = Direction.DOWN
	elif Input.is_action_pressed("move_left"):
		movement_direction = Direction.LEFT
	elif Input.is_action_pressed("move_right"):
		movement_direction = Direction.RIGHT
	else:
		should_move = false
	
	if should_move == true:
		var reason_blocked: ReasonBlocked = move(movement_direction)
		if reason_blocked == ReasonBlocked.BOX:
			var box: Box = rays.get_collider(movement_direction) as Box
			if box != null:
				var reason_box_blocked: ReasonBlocked = box.move(movement_direction)
				if reason_box_blocked == ReasonBlocked.NONE:
					move(movement_direction, true) # For some reason it doesnt work if you dont ignore collision even though the rust prototpe worked fine
