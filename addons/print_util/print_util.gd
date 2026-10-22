extends Node

## Print
func pr(text: Variant):
	print(text)
	Console.print_line(text)

## Error
func er(text: Variant):
	push_error(text)
	Console.print_error(text)
