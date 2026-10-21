class_name Context
extends Node

signal subcontext_changed(new_subcontext: Context)
signal change_parent_subcontext(new_subcontext_key: String)

@export var subcontext_container: Node = null
@export var packed_scene_subcontexts: Dictionary[String, PackedScene]
@export var starting_subcontext_key: String

var subcontext: Context = null

func _ready() -> void:
	if subcontext_container == null:
		subcontext_container = self
	if starting_subcontext_key != "":
		change_subcontext(starting_subcontext_key)

func change_subcontext(new_subcontext_key: String) -> void:
	if subcontext != null:
		subcontext.queue_free()
	
	subcontext = null
	
	if new_subcontext_key != null and new_subcontext_key != "":
		subcontext = packed_scene_subcontexts[new_subcontext_key].instantiate()
		subcontext.change_parent_subcontext.connect(change_subcontext)
		
		subcontext_container.add_child(subcontext)
	
	subcontext_changed.emit(subcontext)
	
	# Log the change.
	if subcontext == null:
		print(name + "'s subcontext changed to null.")
	else:
		print(name + "'s subcontext changed to " + subcontext.name + ".")
