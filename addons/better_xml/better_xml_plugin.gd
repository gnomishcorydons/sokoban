@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("XMLNode", "Node", preload("res://addons/better_xml/xml_node.gd"), null);

func _exit_tree() -> void:
	remove_custom_type("XMLNode")
