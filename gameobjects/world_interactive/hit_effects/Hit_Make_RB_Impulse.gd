class_name Hit_Make_RB_Impulse extends Hit_Component

@export var RB_MAKER:Trig_Make_Rigidbody
@export var IMPULSE_MULTIPLIER:float = 1.0;

func hit(_damage:float) -> void:
	if(RB_MAKER != null):
		RB_MAKER.add_impulse(last_impulse * IMPULSE_MULTIPLIER, last_impulse_pos)
