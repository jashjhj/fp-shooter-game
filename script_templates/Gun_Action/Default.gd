extends Gun_Action_Toggle

@export var OBJECT:Gun_Part;

func _ready():
	check_node_is_set(OBJECT, true)
	super._ready()


func activate():
	if check_node_is_set(OBJECT):
		pass
func deactivate():
	if check_node_is_set(OBJECT):
		pass
