class_name Hit_Weakpoint extends Hit_Component

@export var WEAKPOINT:Weakpoint;

func hit(damage):
	if(WEAKPOINT == null): return
	
	WEAKPOINT.trigger(damage, last_impulse, last_impulse_pos) # as normal
