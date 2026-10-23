class_name LevelContext
extends Context

const GOAL_SOURCE_ID: int = 1
const WALL_SIDE_SOURCE_ID: int = 3
const WALL_TOP_SOURCE_ID: int = 4

var char_to_tile_map: Dictionary[String, String] = { # Should prob put this in a json
	"#": "wall",
	"$": "box",
	".": "goal",
	"@": "player",
	" ": "ground",
	"*": "box on goal",
	"+": "player on goal"
}

@onready var tile_map: TileMapLayer = %TileMapLayer
@onready var camera: Camera2D = %Camera2D
@onready var entities_container: Node2D = %EntitiesContainer

func load_level(level_node: XMLNode) -> void:
	for y in level_node.children.size():
		var child_text: String = level_node.children[y].text
		for x in child_text.length():
			var chara: String = child_text[x]
			var coords: Vector2i = Vector2i(x,y)
			
			var real_coords: Vector2i = coords * Entity.tile_size
			@warning_ignore("integer_division") real_coords.x += Entity.tile_size / 2
			@warning_ignore("integer_division") real_coords.y += Entity.tile_size / 2
			
			match char_to_tile_map[chara]:
				"wall":
					tile_map.set_cell(coords, WALL_SIDE_SOURCE_ID, Vector2i.ZERO)
				"box":
					var box: Box = Box.PACKED_SCENE.instantiate()
					@warning_ignore("integer_division") box.position = real_coords
					entities_container.add_child(box)
				"goal":
					tile_map.set_cell(coords, GOAL_SOURCE_ID, Vector2i.ZERO)
				"player":
					var player: Player = Player.PACKED_SCENE.instantiate()
					@warning_ignore("integer_division") player.position = real_coords
					entities_container.add_child(player)
				"player on goal":
					var player: Player = Player.PACKED_SCENE.instantiate()
					@warning_ignore("integer_division") player.position = real_coords
					entities_container.add_child(player)
					
					tile_map.set_cell(coords, GOAL_SOURCE_ID, Vector2i.ZERO)
				"box on goal":
					tile_map.set_cell(coords, GOAL_SOURCE_ID, Vector2i.ZERO)
					
					var box: Box = Box.PACKED_SCENE.instantiate()
					@warning_ignore("integer_division") box.position = real_coords
					entities_container.add_child(box)
	
	# Fix walls
	var wall_side_positions: Array[Vector2i] = tile_map.get_used_cells_by_id(WALL_SIDE_SOURCE_ID)
	for cell_position in wall_side_positions:
		var bottom_neighbor_source_id: int = tile_map.get_cell_source_id(tile_map.get_neighbor_cell(cell_position, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
		if bottom_neighbor_source_id == WALL_SIDE_SOURCE_ID or bottom_neighbor_source_id == WALL_TOP_SOURCE_ID:
			tile_map.set_cell(cell_position, WALL_TOP_SOURCE_ID, Vector2i.ZERO)
	
	# Camera
	var used_rect: Rect2i = tile_map.get_used_rect()
	used_rect.position *= Entity.tile_size
	used_rect.size *= Entity.tile_size
	@warning_ignore("integer_division") camera.position = used_rect.position + used_rect.size / 2
