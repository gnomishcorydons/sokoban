class_name LevelContext
extends Context

const DESTINATION_SOURCE_ID: int = 1
const WALL_SIDE_SOURCE_ID: int = 3
const WALL_TOP_SOURCE_ID: int = 4

var char_to_tile_map: Dictionary[String, String] = {
	"#": "wall",
	"$": "box",
	".": "destination",
	"@": "player",
	" ": "ground"
}

@onready var tile_map: TileMapLayer = %TileMapLayer

func load_level(level_node: XMLNode) -> void:
	for y in level_node.children.size():
		var child_text: String = level_node.children[y].text
		for x in child_text.length():
			var chara: String = child_text[x]
			var coords: Vector2i = Vector2i(x,y)
			
			match char_to_tile_map[chara]:
				"wall":
					tile_map.set_cell(coords, WALL_SIDE_SOURCE_ID, Vector2i.ZERO)
				"box":
					pass
				"destination":
					tile_map.set_cell(coords, DESTINATION_SOURCE_ID, Vector2i.ZERO)
				"player":
					pass
	
	# Fix walls
	var wall_side_positions: Array[Vector2i] = tile_map.get_used_cells_by_id(WALL_SIDE_SOURCE_ID)
	for cell_position in wall_side_positions:
		var bottom_neighbor_source_id: int = tile_map.get_cell_source_id(tile_map.get_neighbor_cell(cell_position, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
		if bottom_neighbor_source_id == WALL_SIDE_SOURCE_ID or bottom_neighbor_source_id == WALL_TOP_SOURCE_ID:
			tile_map.set_cell(cell_position, WALL_TOP_SOURCE_ID, Vector2i.ZERO)
