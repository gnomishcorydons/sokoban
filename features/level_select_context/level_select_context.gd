class_name LevelSelectContext
extends Context

signal load_level(level_node: XMLNode)

# Could just be arrays but maps are supposed to be dictionaries.
var item_index_file_path_map: Dictionary[int, String]
var item_index_level_node_map: Dictionary[int, XMLNode]

@onready var level_pack_list: ItemList = %LevelPackList
@onready var level_list: ItemList = %LevelList
@onready var reload_level_packs_button: Button = %ReloadLevelPacksButton
@onready var play_button: Button = %PlayButton
@onready var open_folder_button: Button = %OpenFolderButton

@onready var title_label: Label = %TitleLabel
@onready var email_label: Label = %EmailLabel
@onready var copyright_label: Label = %CopyrightLabel
@onready var max_size_label: Label = %MaxSizeLabel
@onready var description_label: Label = %DescriptionLabel
@onready var level_id_label: Label = %LevelIDlabel
@onready var level_size_label: Label = %LevelSizeLabel

func _ready() -> void:
	super._ready()
	
	level_pack_list.item_selected.connect(_on_level_pack_list_item_selected)
	level_list.item_selected.connect(_on_level_list_item_selected)
	reload_level_packs_button.pressed.connect(_on_reload_level_packs_button_pressed)
	
	play_button.pressed.connect(_on_play_button_pressed)
	open_folder_button.pressed.connect(_on_open_folder_button_pressed)
	
	load_level_packs()

func load_level_packs() -> void:
	clear_level_pack_list()
	
	var level_pack_folder_locations_file: FileAccess = FileAccess.open("res://resources/level_pack_folder_locations.json", FileAccess.READ)
	var folders_to_load: Array = JSON.parse_string(level_pack_folder_locations_file.get_as_text()) as Array
	for folder in folders_to_load:
		load_folder(folder)
	
	level_pack_list.select(0)
	_on_level_pack_list_item_selected(0)  # Select doesnt trigger the signal for some reason

func load_folder(folder_path: String) -> void:
	if not DirAccess.dir_exists_absolute(folder_path):
		PrintUtil.pr("Attempted to load " + folder_path + " but it could not be found.")
		return
	
	var dir_access: DirAccess = DirAccess.open(folder_path)
	for file_name in dir_access.get_files():
		if not file_name.ends_with(".slc"): return
		
		var item_index: int = level_pack_list.add_item(file_name.rstrip(".slc"))
		var file_path: String = folder_path + file_name
		
		item_index_file_path_map[item_index] = file_path

func clear_level_pack_list() -> void:
	level_pack_list.clear()
	item_index_file_path_map.clear()

func clear_level_list_items() -> void:
	level_list.clear()
	item_index_level_node_map.clear()

func _on_play_button_pressed() -> void:
	var level_node: XMLNode = item_index_level_node_map[level_list.get_selected_items()[0]]
	load_level.emit(level_node)

func _on_level_pack_list_item_selected(index: int) -> void:
	var file_path: String = item_index_file_path_map[index]
	var root: XMLNode = XMLNode.from_file(file_path)
	
	var sokoban_levels: XMLNode = root.get_child("SokobanLevels")
	var level_collection: XMLNode = sokoban_levels.get_child("LevelCollection")
	
	# Pack Info
	title_label.text = sokoban_levels.get_child("Title").text
	email_label.text = sokoban_levels.get_child("Email").text
	description_label.text = sokoban_levels.get_child("Description").text
	
	var max_size: Vector2i = Vector2i.ZERO
	max_size.x = level_collection.attributes["MaxWidth"].to_int()
	max_size.y = level_collection.attributes["MaxHeight"].to_int()
	max_size_label.text = "Max Level Size: " + str(max_size)
	
	copyright_label.text = level_collection.attributes["Copyright"]
	
	# Level list
	clear_level_list_items()
	
	for level_node in level_collection.children:
		var item_index: int = level_list.add_item(level_node.attributes["Id"])
		item_index_level_node_map[item_index] = level_node
	
	level_list.select(0)
	_on_level_list_item_selected(0) # Select doesnt trigger the signal for some reason

func _on_level_list_item_selected(index: int) -> void:
	var level_node: XMLNode = item_index_level_node_map[index]
	var id: String = level_node.attributes["Id"]
	
	var size: Vector2i = Vector2i.ZERO
	size.x = level_node.attributes["Width"].to_int()
	size.y = level_node.attributes["Height"].to_int()
	
	level_id_label.text = id
	level_size_label.text = str(size)

func _on_open_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _on_reload_level_packs_button_pressed() -> void:
	load_level_packs()
