class_name Gun_Action_Insertable_Lock extends Gun_Action_Toggle

@export var SLOT:Gun_Part_Insertable_Slot;

func _ready():
	check_node_is_set(SLOT, true)
	super._ready()

func activate():
	if(check_node_is_set(SLOT)):
		SLOT.is_locked = true

func deactivate():
	if(check_node_is_set(SLOT)):
		SLOT.is_locked = false
