class_name CardinalRays
extends Node2D
## Component of rays to be used in entity derivitives because inherited scenes are scary.

@onready var ray_up: RayCast2D = get_node("RayUp")
@onready var ray_down: RayCast2D = get_node("RayDown")
@onready var ray_left: RayCast2D = get_node("RayLeft")
@onready var ray_right: RayCast2D = get_node("RayRight")

func set_tile_size(tile_size: int) -> void:
	ray_up.position = Vector2(0.0,-tile_size/2.0)
	ray_down.position = Vector2(0.0,tile_size/2.0)
	ray_left.position = Vector2(-tile_size/2.0,0.0)
	ray_right.position = Vector2(tile_size/2.0,0.0)
	
	ray_up.target_position = Vector2(0.0,-tile_size/2.0)
	ray_down.target_position = Vector2(0.0,tile_size/2.0)
	ray_left.target_position = Vector2(-tile_size/2.0,0.0)
	ray_right.target_position = Vector2(tile_size/2.0,0.0)

func get_collider(direction: Entity.Direction) -> Object:
	match direction:
		Entity.Direction.UP:
			return ray_up.get_collider()
		Entity.Direction.DOWN:
			return ray_down.get_collider()
		Entity.Direction.LEFT:
			return ray_left.get_collider()
		Entity.Direction.RIGHT:
			return ray_right.get_collider()
		_:
			push_error("Direction " + str(direction) + " provided to EntityRays.get_collider is invalid.")
			return null


func is_colliding(direction: Entity.Direction) -> Entity.ReasonBlocked:
	var ray: RayCast2D = null
	
	match direction:
		Entity.Direction.UP:
			ray = ray_up
		Entity.Direction.DOWN:
			ray = ray_down
		Entity.Direction.LEFT:
			ray = ray_left
		Entity.Direction.RIGHT:
			ray = ray_right
		_:
			push_error("Direction " + str(direction) + " provided to EntityRays.is_colliding is invalid.")
			return Entity.ReasonBlocked.NONE
	
	if ray.is_colliding():
		if ray.get_collider() is Box:
			return Entity.ReasonBlocked.BOX
		#return Entity.ReasonBlocked.WALL
	
	return Entity.ReasonBlocked.NONE
