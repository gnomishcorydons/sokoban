class_name LevelContext
extends Context

signal level_changed

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

var player: Player = null
var boxes: Array[Box] = []

@onready var tile_map: TileMapLayer = %TileMapLayer
@onready var camera: Camera2D = %Camera2D
@onready var entities_container: Node2D = %EntitiesContainer

func _ready() -> void:
	super._ready()
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func check_if_win() -> bool:
	var won = true
	var goal_cell_positions: Array[Vector2i] = tile_map.get_used_cells_by_id(GOAL_SOURCE_ID, Vector2i.ZERO)
	for box in boxes:
		var box_on_goal: bool = false
		for position in goal_cell_positions:
			if real_coords_to_coords(box.position) == position:
				box_on_goal = true
				break
		if !box_on_goal: won = false
	return won

func spawn_box(coords: Vector2i) -> Box:
	var box: Box = Box.PACKED_SCENE.instantiate()
	@warning_ignore("integer_division") box.position = coords_to_real_coords(coords)
	entities_container.add_child(box)
	boxes.append(box)
	return box
	
func spawn_player(coords: Vector2i) -> Player:
	player = Player.PACKED_SCENE.instantiate()
	@warning_ignore("integer_division") player.position = coords_to_real_coords(coords)
	entities_container.add_child(player)
	return player

func coords_to_real_coords(coords: Vector2i) -> Vector2i:
	var real_coords: Vector2i = coords * Entity.tile_size
	@warning_ignore("integer_division") real_coords.x += Entity.tile_size / 2
	@warning_ignore("integer_division") real_coords.y += Entity.tile_size / 2
	return real_coords

func real_coords_to_coords(real_coords: Vector2i) -> Vector2i:
	@warning_ignore("integer_division") return real_coords / Entity.tile_size

func load_level(level_node: XMLNode) -> void:
	# Clean up old level
	if player: player.queue_free()
	player = null
	
	for box in boxes: box.queue_free()
	boxes.clear()
	
	tile_map.clear()
	
	# Loop through level text data and fill tilemap and spawn entities
	for y in level_node.children.size():
		var child_text: String = level_node.children[y].text
		for x in child_text.length():
			var chara: String = child_text[x]
			var coords: Vector2i = Vector2i(x,y)
			
			match char_to_tile_map[chara]:
				"wall":
					tile_map.set_cell(coords, WALL_SIDE_SOURCE_ID, Vector2i.ZERO)
				"box":
					spawn_box(coords)
				"goal":
					tile_map.set_cell(coords, GOAL_SOURCE_ID, Vector2i.ZERO)
				"player":
					spawn_player(coords)
				"player on goal":
					spawn_player(coords)
					tile_map.set_cell(coords, GOAL_SOURCE_ID, Vector2i.ZERO)
				"box on goal":
					tile_map.set_cell(coords, GOAL_SOURCE_ID, Vector2i.ZERO)
					spawn_box(coords)
	level_changed.emit()
	
	# Fix walls
	var wall_side_positions: Array[Vector2i] = tile_map.get_used_cells_by_id(WALL_SIDE_SOURCE_ID)
	for cell_position in wall_side_positions:
		var bottom_neighbor_source_id: int = tile_map.get_cell_source_id(tile_map.get_neighbor_cell(cell_position, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
		if bottom_neighbor_source_id == WALL_SIDE_SOURCE_ID or bottom_neighbor_source_id == WALL_TOP_SOURCE_ID:
			tile_map.set_cell(cell_position, WALL_TOP_SOURCE_ID, Vector2i.ZERO)
	
	# Camera
	adjust_camera()

func adjust_camera() -> void:
	var used_rect: Rect2i = tile_map.get_used_rect()
	used_rect.position *= tile_map.tile_set.tile_size
	used_rect.size *= tile_map.tile_set.tile_size
	# Position
	@warning_ignore("integer_division") camera.position = used_rect.position + used_rect.size / 2
	
	# Zoom
	
	used_rect.size += tile_map.tile_set.tile_size * 2 # add padding so its not right up agaisnt the view borders
	
	var viewport_size: Vector2i = get_viewport().get_visible_rect().size
	
	var zoom_scale: Vector2 = Vector2(viewport_size) / Vector2(used_rect.size)
	var zoom: float = min(zoom_scale.x, zoom_scale.y)
	camera.zoom = Vector2(zoom, zoom)

func _on_viewport_size_changed() -> void:
	adjust_camera()
