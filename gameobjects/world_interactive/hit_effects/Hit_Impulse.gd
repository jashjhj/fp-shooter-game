class_name Hit_Impulse extends Hit_Component

##Can be Owning Hittable_RB or otherwise.
@export var IMPULSE_TO:RigidBody3D;

func hit(damage:float):
	if IMPULSE_TO == null: return
	
	IMPULSE_TO.apply_impulse(last_impulse, last_impulse_pos)
	
