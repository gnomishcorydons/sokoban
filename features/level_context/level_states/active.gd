class_name LevelActiveState
extends State

@export var level_context: LevelContext
@export var win_state: LevelWinState

@onready var win_menu: Control = %WinMenu

func enter() -> void:
	win_menu.visible = false
	level_context.player.moved.connect(_on_player_moved)

func exit() -> void:
	level_context.player.moved.disconnect(_on_player_moved)

func _on_player_moved() -> void:
	if level_context.check_if_win():
		change_state.emit(win_state)
