extends Context

var folders_to_load: Array[String] = [
	"res://resources/level_packs/",
	"user://level_packs/"
]

@onready var level_pack_buttons_containr: VBoxContainer = %LevelPackButtonContainer
@onready var level_buttons_container: VBoxContainer = %LevelButtonsContainer
@onready var reload_level_packs_button: Button = %ReloadLevelPacksButton

@onready var title_label: Label = %TitleLabel
@onready var email_label: Label = %EmailLabel
@onready var copyright_label: Label = %CopyrightLabel
@onready var max_size_label: Label = %MaxSizeLabel
@onready var description_label: Label = %DescriptionLabel
@onready var level_id_label: Label = %LevelIDlabel
@onready var level_size_label: Label = %LevelSizeLabel

func _ready() -> void:
	super._ready()
	
	load_level_packs()
	reload_level_packs_button.pressed.connect(_on_reload_level_packs_button)

func load_level_packs() -> void:
	clear_level_pack_buttons()
	for folder in folders_to_load:
		load_folder(folder)

func load_folder(folder_path: String) -> void:
	if not DirAccess.dir_exists_absolute(folder_path): return
	var dir_access: DirAccess = DirAccess.open(folder_path)
	for file_name in dir_access.get_files():
		if not file_name.ends_with(".slc"): return
		var button: Button = Button.new()
		button.text = file_name.rstrip(".slc")
		level_pack_buttons_containr.add_child(button)
		
		var file_path: String = folder_path + file_name
		
		button.pressed.connect(_on_level_pack_button_pressed.bind(file_path))

func clear_level_pack_buttons() -> void:
	for child in level_pack_buttons_containr.get_children():
		child.queue_free()

func clear_level_buttons() -> void:
	for child in level_buttons_container.get_children():
		child.queue_free()

func _on_level_pack_button_pressed(file_path: String) -> void:
	var root: XMLNode = XMLNode.from_file(file_path)
	
	var sokoban_levels: XMLNode = root.get_child("SokobanLevels")
	var level_collection: XMLNode = sokoban_levels.get_child("LevelCollection")
	
	#Pack Info section
	title_label.text = sokoban_levels.get_child("Title").text
	email_label.text = sokoban_levels.get_child("Email").text
	description_label.text = sokoban_levels.get_child("Description").text
	
	var max_size: Vector2i = Vector2i.ZERO
	max_size.x = level_collection.attributes["MaxWidth"].to_int()
	max_size.y = level_collection.attributes["MaxHeight"].to_int()
	max_size_label.text = "Max Level Size: " + str(max_size)
	
	copyright_label.text = level_collection.attributes["Copyright"]
	
	# Level buttons
	clear_level_buttons()
	
	for level_node in level_collection.children:
		var button: Button = Button.new()
		button.text = level_node.attributes["Id"]
		button.pressed.connect(_on_level_button_pressed.bind(level_node))
		level_buttons_container.add_child(button)

func _on_level_button_pressed(level_node: XMLNode) -> void:
	var id: String = level_node.attributes["Id"]
	
	var size: Vector2i = Vector2i.ZERO
	size.x = level_node.attributes["Width"].to_int()
	size.y = level_node.attributes["Height"].to_int()
	
	level_id_label.text = id
	level_size_label.text = str(size)

func _on_reload_level_packs_button() -> void:
	load_level_packs()
