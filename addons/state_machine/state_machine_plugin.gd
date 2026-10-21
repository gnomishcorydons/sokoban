@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("StateMachine", "Node", preload("res://addons/state_machine/state_machine.gd"), null);
	add_custom_type("State", "Node", preload("res://addons/state_machine/state.gd"), null);

func _exit_tree() -> void:
	remove_custom_type("StateMachine")
	remove_custom_type("State")
