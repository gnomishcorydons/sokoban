class_name XMLNode
extends RefCounted
## Represents a node in xml.

## The name of the tag of the node.
var tag: String

## The text/data contained between the start of the node and its closing tag.
var text: String = ""

## The attributes of a node with all data in Strings.
var attributes: Dictionary[String, String]

## The node that this node is a child of.
var parent: XMLNode

## The nodes this node is the parent of.
var children: Array[XMLNode]

## Creates a node from a file from the given path.
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
				
				# Get tag
				current_node.tag = parser.get_node_name()
				
				# Get attributes
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

## Gets the first child with the specified tag.
func get_child(_tag: String) -> XMLNode:
	for child in children:
		if child.tag == _tag:
			return child
	return null

## Adds a child to node's children list and sets its parent as self.
func add_child(new_child: XMLNode) -> XMLNode:
	new_child.parent = self
	children.push_back(new_child)
	return new_child
