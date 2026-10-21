class_name State
extends Node
## Class for states in StateMachine.

## Emitted when state needs to be changed, connects to parent StateMachine.
signal change_state(new_state: State)

## If there's already a state queued to change to the higher priority will determine which one is changed to.
@export var priority: int = 0

# General code order for exports should be the state machine parent, 
#  exports for nodes, exports for states, and the rest. 
#  Organize the groups alphabetically.

## Called when state is changed in to.
func enter() -> void: pass
## Called in the parent state machine's _process method when it is the active state
func process(_delta: float) -> void: pass
## Called in the parent state machine's _physics_process method when it is the active state.
func physics_process(_delta: float) -> void: pass
## Called when state is changed out of.
func exit() -> void: pass
