class_name XMLNode
extends RefCounted

var tag: String
var text: String = ""

var attributes: Dictionary[String, String]

var parent: XMLNode
var children: Array[XMLNode]

static func from_file(file_path: String) -> XMLNode:
	var parser = XMLParser.new()
	parser.open(file_path)
	
	var root: XMLNode = XMLNode.new()
	var current_node: XMLNode = root
	
	while parser.read() != ERR_FILE_EOF:
		match parser.get_node_type():
			XMLParser.NODE_NONE:
				pass
			XMLParser.NODE_ELEMENT:
				var node = XMLNode.new()
				current_node.add_child(node)
				current_node = node
				
				current_node.tag = parser.get_node_name()
				
				for i in parser.get_attribute_count():
					var attribute_name: String = parser.get_attribute_name(i)
					var attribute_value: String = parser.get_attribute_value(i)
					current_node.attributes[attribute_name] = attribute_value
			XMLParser.NODE_ELEMENT_END:
				current_node = current_node.parent
			XMLParser.NODE_TEXT:
				current_node.text += parser.get_node_data()
			XMLParser.NODE_COMMENT:
				pass
			XMLParser.NODE_CDATA:
				pass
			XMLParser.NODE_UNKNOWN:
				pass
	
	return root

func get_child(_tag: String) -> XMLNode:
	for child in children:
		if child.tag == _tag:
			return child
	return null

func add_child(new_child: XMLNode) -> void:
	new_child.parent = self
	children.push_back(new_child)
