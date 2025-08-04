class_name Trig_Alter_Mass extends Triggerable

@export var BODY:RigidBody3D

@export var MASS_SOURCE:RB_Mass_Source
@export var IS_REMOVING:bool = true;

func trigger():
	super.trigger()
	if(BODY == null or MASS_SOURCE == null): return
	
	if(IS_REMOVING):
		MASS_SOURCE.remove_mass()
	else:
		MASS_SOURCE.add_mass()
