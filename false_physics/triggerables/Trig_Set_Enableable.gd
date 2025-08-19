class_name Trig_Set_Enableable extends Triggerable

@export var ENABLEABLE:Enableable
@export var SET_ENABLED_TO:bool;

func trigger():
	super()
	
	ENABLEABLE.is_enabled = SET_ENABLED_TO
