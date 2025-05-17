class_name Gun_Action_Insertable_Lock extends Gun_Action_Toggle

@export var INSERTABLE:Gun_Part_Insertable;

func activate():
	if(INSERTABLE == null):
		push_error("Insertable not set.")
		return
	INSERTABLE.is_locked = true

func deactivate():
	if(INSERTABLE == null):
		push_error("Insertable not set.")
		return
	INSERTABLE.is_locked = false
