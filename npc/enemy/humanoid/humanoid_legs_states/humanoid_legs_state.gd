class_name Humanoid_Legs_State extends Node;

@export var LEGS:Humanoid_Legs;

func consider_step():
	pass

func update_leg_targets():
	pass

func update_state():
	pass

func update_stability(delta:float):
	if LEGS.stable_legs == 2:
		LEGS.stability = lerp(LEGS.stability, max(0.0, (1-LEGS.BODY.linear_velocity.length())), 0.5*delta)
	else:
		LEGS.stability *= 0.4 ** delta # divides by 20 a second
