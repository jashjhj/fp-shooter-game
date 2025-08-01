class_name Triggerable_Bullet_Source extends Triggerable

@export var BULLET_SOURCE:Bullet_Source;

func trigger():
	super.trigger()
	
	if(BULLET_SOURCE != null):
		BULLET_SOURCE.trigger()
