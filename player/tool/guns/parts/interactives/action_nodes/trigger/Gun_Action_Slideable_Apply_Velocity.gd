class_name Gun_Action_Slideable_Apply_Velocity extends Gun_Action_Trigger

@export var SLIDEABLE:Gun_Part_Slideable
@export var VELOCITY:float = 1.0;

func triggered():
	SLIDEABLE.velocity = VELOCITY
