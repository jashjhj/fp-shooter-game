class_name Humanoid_Legs_State_Stabilising extends Humanoid_Legs_State

func consider_step():
	if(LEGS.stable_legs == 2 and LEGS.unstable_distance > 0.2):
		#pick leg to move - The one with its foot planted further away from the body.
		
		var leg_0_distance:float = (LEGS.LEGS[0].FOOT.global_position - LEGS.body_com_global()).length();#(LEGS[0].FOOT.global_position - calculate_leg_target_idle(LEGS[0], LEGS[1], true)).length()
		var leg_1_distance:float = (LEGS.LEGS[1].FOOT.global_position - LEGS.body_com_global()).length();#(LEGS[1].FOOT.global_position - calculate_leg_target_idle(LEGS[1], LEGS[0], false)).length()
		
		print("step")
		if leg_0_distance > leg_1_distance: # step foot thats in a less stupid (far away) position
			LEGS.LEGS[0].begin_step() # position already set in update_leg_targets().
		else:
			LEGS.LEGS[1].begin_step()

func update_leg_targets():
	LEGS.LEGS[0].set_leg_target(calculate_leg_target_inline(LEGS.LEGS[0], LEGS.LEGS[1]))
	LEGS.LEGS[1].set_leg_target(calculate_leg_target_inline(LEGS.LEGS[1], LEGS.LEGS[0]))

func update_state():
	if LEGS.stability > 0.6:
		LEGS.current_state = LEGS.LEGS_STATE_IDLE



##Inline: in the line that will stabilise, a line through the other leg + the COM with minor consideration for velocity.
func calculate_leg_target_inline(leg:Leg, stable_leg:Leg) -> Vector3:
	
	var stable_leg_stable_point:Vector3 = LEGS.get_centre_of_stable_area(stable_leg.STABLE_FOOT_POINTS) * stable_leg.FOOT.global_basis + stable_leg.global_position
	
	##Calculates body + velocity = roughly where foot needs to go to slow velocity.
	var body_pos:Vector3 = LEGS.body_com_global() + LEGS.BODY.linear_velocity * Vector3(1, 0, 1)
	##Vector from Good foot to COM.
	var stable_com_vector:Vector3 = stable_leg_stable_point - body_pos;
	# Y component does not matter.
	var intersection_components:Vector2 = LEGS.get_intersection_components(stable_leg_stable_point, leg.global_position, stable_com_vector, leg.global_basis.z);
	var stable_foot_point = leg.global_position + intersection_components.y * leg.global_basis.z
	stable_foot_point += LEGS.BODY.linear_velocity * abs(LEGS.BODY.linear_velocity) * 0.1;
	
	
	LEGS.DOWN_RAY.global_position = stable_foot_point
	LEGS.DOWN_RAY.force_raycast_update()
	
	if(LEGS.DOWN_RAY.is_colliding()): # There is floor in reasonable distance down
		var collision:Vector3 = LEGS.DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)): # If collision is within reach of said leg
			
			return collision
	
	return Vector3.ZERO
