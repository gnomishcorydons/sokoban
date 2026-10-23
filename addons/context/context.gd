class_name Context
extends Node
## A context is kinda like a room that can have a child room but only 1 at a time.
## Kinda hard to explain but once you use them you get it. 

## Fired when subcontext is changed
signal subcontext_changed(new_subcontext: Context)
#signal change_parent_subcontext(new_subcontext_key: String) // Should be done with individual signals

## The node that subcontext is instantiated under, if left null then its self.
@export var subcontext_container: Node = null
## Dictionary of possible subcontexts.
@export var packed_scene_subcontexts: Dictionary[String, PackedScene]
## The key of the subcontext in packed_scene_subcontexts you wish to start the scene with. If left empty or null then it doesn't start with a subcontext.
@export var starting_subcontext_key: String

## The subcontext herself.
var subcontext: Context = null

func _ready() -> void:
	if subcontext_container == null:
		subcontext_container = self
	if starting_subcontext_key != "":
		change_subcontext(starting_subcontext_key)

## Changes the subcontext. Always use this and never set it directly. Leave new_subcontext_key empty or null if you wish to make subcontext null.
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
