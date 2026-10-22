extends Node

## Print
func pr(string: String):
	print(string)
	Console.print_line(string)

## Error
func er(string: String):
	push_error(string)
	Console.print_error(string)
