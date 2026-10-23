class_name LevelWinState
extends State

@export var level_context: LevelContext

@onready var win_menu = %WinMenu

func enter() -> void:
	win_menu.visible = true
	level_context.player.frozen = true
