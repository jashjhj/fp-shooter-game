class_name Gun_Action_Toggle extends Action_Node

@export var ACTIVE:bool = false:
	set(value):
		if(ACTIVE != value):
			ACTIVE = value;
			if(ACTIVE):
				activate();
			else:
				deactivate()

##To activate the action, set bool ACTIVE to true. This method is for the function.
func activate():
	pass
##To deactivate the action, set bool ACTIVE to false. This method is for the function.
func deactivate():
	pass

func _ready():
	if(ACTIVE): activate() # Triggers on startup

func check_node_is_set(n:Node, is_fatal:bool = false) -> bool:
	if(n == null):
		if(is_fatal):
			push_error("Node not set.")
		else:
			push_warning("Node not set.")
		return false
	return true
