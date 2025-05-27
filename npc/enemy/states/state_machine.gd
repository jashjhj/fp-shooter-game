class_name StateMachine extends Node

@export var CURRENT_STATE: State;
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition) # idk what this does
		else:
			push_warning("State machine contains incompatible child node")
	
	await owner.ready
	CURRENT_STATE.enter(); # if error, make sure to set current state to default one

func _process(delta):
	CURRENT_STATE.update(delta)

func _physics_process(delta):
	CURRENT_STATE.physics_update(delta)

func on_child_transition(new_state_name: StringName) -> void:
	# im proud son. i mean daughter
	
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE: # swap states
			CURRENT_STATE.exit();
			new_state.enter();
			CURRENT_STATE = new_state;
	else:
		push_warning("State does not exist");
