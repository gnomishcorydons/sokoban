class_name StateMachine
extends Node
## A simple finite state machine.

signal state_changed(state: State)

## The starting state of the state machine.
@export var starting_state: State

## The current state of the machine.
var current_state: State
## The state to change to on the beginning of the next frame.
var state_to_change_to: State

func _ready() -> void:
	for state in get_states():
		state.change_state.connect(change_state)
	
	assert(starting_state != null, "starting_state was null.")
	change_state(starting_state)

func _process(delta: float) -> void:
	current_state.process(delta)

func _physics_process(delta: float) -> void:
	if state_to_change_to:
		if current_state:
			current_state.exit()
		current_state = state_to_change_to
		state_changed.emit(current_state)
		state_to_change_to = null
		current_state.enter()
	
	current_state.physics_process(delta)

## Changes current_state to new_state.
func change_state(new_state: State) -> void:
	assert(new_state != null, "Could not find state to change to.")
	if new_state != null:
		if state_to_change_to != null:
			if new_state.priority >= state_to_change_to.priority:
				state_to_change_to = new_state
		else:
			state_to_change_to = new_state

## Gets all children of type State in an array.
func get_states() -> Array[State]:
	var states: Array[State]
	for child in get_children():
		if child is State:
			states.append(child)
	return states
