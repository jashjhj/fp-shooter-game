class_name Gun_Action_Toggle extends Node

@export var ACTIVE:bool = false:
	set(value):
		if(ACTIVE != value):
			ACTIVE = value;
			if(ACTIVE):
				activate();
			else:
				deactivate()

func activate():
	pass
func deactivate():
	pass

func _ready():
	pass
	#if(ACTIVE): activate() # Triggers on startup

func check_node_is_set(n:Node):
	if(n == null):
		push_error("Node not set.")
		return
