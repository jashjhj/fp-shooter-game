class_name Trig_Force_Set_1_Way_Constraint extends Triggerable

@export var ONE_WAY_CONSTRAINT:One_Way_Constraint
@export var SET_TO:bool = true;

func _ready() -> void:
	super._ready();
	
	

func trigger() -> void:
	super.trigger();
	ONE_WAY_CONSTRAINT.FORCE_ENABLE = SET_TO
	
