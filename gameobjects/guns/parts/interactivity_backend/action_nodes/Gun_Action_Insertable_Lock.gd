class_name Gun_Action_Insertable_Lock extends Gun_Action_Toggle

@export var SLOT:Gun_Part_Insertable_Slot;

func _ready():
	super._ready()
	check_node_is_set(SLOT)

func activate():
	SLOT.is_locked = true

func deactivate():
	SLOT.is_locked = false
