extends Context

func _ready() -> void:
	super._ready()
	subcontext_changed.connect(_on_subcontext_changed)
	Console.add_command("load_level", _console_load_level, ["level_pack", "level_id"], 2)
	Console.add_command("open_user_folder", _console_open_user_folder)

func load_level(level_node: XMLNode) -> void:
	change_subcontext("level")
	var level_context: LevelContext = subcontext as LevelContext
	level_context.load_level(level_node)

func _on_subcontext_changed(new_subcontext: Context) -> void:
	if new_subcontext is LevelSelectContext:
		var level_select_context: LevelSelectContext = new_subcontext as LevelSelectContext
		level_select_context.load_level.connect(_on_load_level)

func _on_load_level(level_node: XMLNode) -> void:
	load_level(level_node)

func _console_open_user_folder() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _console_load_level(level_pack: String, level_id: String) -> void:
	var level_pack_folder_locations_file: FileAccess = FileAccess.open("res://resources/level_pack_folder_locations.json", FileAccess.READ)
	var folders_to_load: Array = JSON.parse_string(level_pack_folder_locations_file.get_as_text()) as Array
	
	for folder_path in folders_to_load:
		if not DirAccess.dir_exists_absolute(folder_path):
			PrintUtil.er("Attempted to load " + folder_path + " but it could not be found.")
			return
		
		var dir_access: DirAccess = DirAccess.open(folder_path)
		for file_name in dir_access.get_files():
			if file_name.rstrip(".slc") == level_pack:
				var root: XMLNode = XMLNode.from_file(folder_path + file_name)
				var level_collection: XMLNode = root.get_child("SokobanLevels").get_child("LevelCollection")
				
				for level in level_collection.children:
					if level.attributes["Id"] == level_id:
						load_level(level)
						return
				
				PrintUtil.er("Could not find a level with id " + level_id + " in pack " + level_pack + ".")
				return
			
			PrintUtil.er("Could not find a level pack named " + level_pack + ".")
