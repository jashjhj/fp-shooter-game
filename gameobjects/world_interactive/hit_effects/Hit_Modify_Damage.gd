class_name Hit_Multiply_Damage extends Hit_Component

@export var HIT_CMP:Hit_Component;
@export var DAMAGE_MULTIPLIER:float = 1.0;
@export var IMPULSE_MULTIPLIER:float = 1.0;

func hit(damage):
	super(damage)
	if(HIT_CMP == null): return
	HIT_CMP.trigger(damage * DAMAGE_MULTIPLIER, last_impulse * IMPULSE_MULTIPLIER, last_impulse_pos)
