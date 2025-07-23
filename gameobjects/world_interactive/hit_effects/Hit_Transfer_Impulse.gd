class_name Hit_Transfer_Impusle extends Hit_Component

@export var TRANSFER_RB:RigidBody3D;

func hit(damage:float):
	if TRANSFER_RB == null: return
	else:
		TRANSFER_RB.apply_impulse(last_impulse, last_impulse_pos)
	
