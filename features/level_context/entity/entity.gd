class_name Entity
extends CharacterBody2D

enum ReasonBlocked {
	NONE, BOX, WALL, NOT_READY, INVALID_DIRECTION
}

enum Direction {
	UP, DOWN, LEFT, RIGHT
}

static var tile_size: int = 128
static var move_speed: float = 0.25

@export var sprite: Sprite2D
@export var rays: CardinalRays

var sprite_movement_tween: Tween = null

func _ready() -> void:
	rays.set_tile_size(tile_size)

func move(direction: Direction, ignore_collision: bool = false) -> ReasonBlocked:
	if not ready_to_move():
		return ReasonBlocked.NOT_READY
	
	var is_colliding: ReasonBlocked = rays.is_colliding(direction)
	if is_colliding != ReasonBlocked.NONE and not ignore_collision:
		return is_colliding
	
	var delta_pos: Vector2 = Vector2.ZERO
	match direction:
		Direction.UP:
			delta_pos = Vector2(0.0,-1.0)
		Direction.DOWN:
			delta_pos = Vector2(0.0,1.0)
		Direction.LEFT:
			delta_pos = Vector2(-1.0,0.0)
		Direction.RIGHT:
			delta_pos = Vector2(1.0,0.0)
		_:
			push_error("Direction " + str(direction) + " provided to Entity.move is invalid.")
			return ReasonBlocked.INVALID_DIRECTION
	
	delta_pos *= tile_size
	
	position += delta_pos
	
	sprite.position -= delta_pos
	sprite_movement_tween = get_tree().create_tween()
	sprite_movement_tween.tween_property(sprite, "position", Vector2.ZERO, move_speed)
	sprite_movement_tween.finished.connect(
		func() -> void: 
			sprite_movement_tween = null
	)
	
	return ReasonBlocked.NONE

func ready_to_move() -> bool:
	if sprite_movement_tween == null:
		return true
	return false
