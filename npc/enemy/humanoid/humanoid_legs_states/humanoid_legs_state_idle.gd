class_name Humanoid_Legs_State_Idle extends Humanoid_Legs_State;

func consider_step():
	pass

	#var leg_0_distance:float = (LEGS[0].FOOT.global_position - body_com_global()).length();#(LEGS[0].FOOT.global_position - calculate_leg_target_idle(LEGS[0], LEGS[1], true)).length()
	#var leg_1_distance:float = (LEGS[1].FOOT.global_position - body_com_global()).length();#(LEGS[1].FOOT.global_position - calculate_leg_target_idle(LEGS[1], LEGS[0], false)).length()
	#
	#if leg_0_distance > leg_1_distance:
		#if leg_0_distance > 0.1: # tolerance to actually move foot
			#LEGS[0].begin_step()
	#else:
		#if(leg_1_distance > 0.1):
			#LEGS[1].begin_step()


#func update_leg_targets():
	#pass

func update_state():
	if LEGS.stability > 0.6 and !LEGS.walk_vector.is_zero_approx():
		LEGS.current_state = LEGS.LEGS_STATE_WALKING;
	elif LEGS.stability < 0.2:
		LEGS.current_state = LEGS.LEGS_STATE_STABILISING


#func update_stability(delta:float):
	#if LEGS.stable_legs == 2:
		#LEGS.stability = lerp(LEGS.stability, max(0.0, (1-LEGS.BODY.linear_velocity.length())), 0.5*delta)
	#else:
		#LEGS.stability *= 0.4 ** delta # divides by 20 a second
