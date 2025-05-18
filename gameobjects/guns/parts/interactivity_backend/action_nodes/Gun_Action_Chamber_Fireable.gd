class_name Gun_Action_Chamber_Fireable extends Gun_Action_Toggle

@export var INSERTABLE:Gun_Part_Chamber_Manual;

func _ready():
	super._ready()
	check_node_is_set(INSERTABLE)

#func activate():
	#INSERTABLE.connected_to_pin = true
#
#func deactivate():
	#INSERTABLE.connected_to_pin = false
