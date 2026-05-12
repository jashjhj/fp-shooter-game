class_name Humanoid_Legs_State_Walking extends Humanoid_Legs_State

@export var STRIDE_LENGTH:float = 1.0;

var step_cooldown:int = 20;
var last_leg:int = -1;
var leg_reps:int = 0;

func consider_step():
	if Time.get_ticks_msec() - LEGS.last_step_land_time < step_cooldown: return; # dont step since last step, slows gait
	if Time.get_ticks_msec() - LEGS.last_step_time < 200: return; # dont step since last step, prevents jumping
	
	if(LEGS.stable_legs == 2): # if fully stable, take next step
		
		var stable_area = LEGS.calculate_stable_area()
		var stable_centre:Vector3 = LEGS.get_centre_of_stable_area(stable_area);
		
		if((LEGS.global_position - stable_centre).dot(LEGS.walk_vector) < -0.01): return # Dotn step till youre past equlibrium point, ready for enxt step.
		
		
		var leg_0_distance:float = (LEGS.LEGS[0].FOOT.global_position - LEGS.body_com_global()).dot(LEGS.walk_vector);#(LEGS[0].FOOT.global_position - calculate_leg_target_idle(LEGS[0], LEGS[1], true)).length()
		var leg_1_distance:float = (LEGS.LEGS[1].FOOT.global_position - LEGS.body_com_global()).dot(LEGS.walk_vector);#(LEGS[1].FOOT.global_position - calculate_leg_target_idle(LEGS[1], LEGS[0], false)).length()
		
		if leg_0_distance < leg_1_distance: # step leg that is behind
			if(last_leg == 0):
				leg_reps += 1;
			else:
				last_leg = 0
				leg_reps = 1
			
			if leg_reps < 2: # if ive kept using this leg, swap.
				LEGS.LEGS[0].begin_step()
			else:
				LEGS.LEGS[1].begin_step()
				last_leg = 1;
				leg_reps = 1;
			
		else:
			if(last_leg == 1):
				leg_reps += 1;
			else:
				last_leg = 1
				leg_reps = 1
			
			if leg_reps < 2: # if ive kept using this leg, swap.
				LEGS.LEGS[1].begin_step()
			else:
				LEGS.LEGS[0].begin_step()
				last_leg = 0;
				leg_reps = 1;


func update_leg_targets():
	LEGS.LEGS[0].set_leg_target(calculate_leg_target(LEGS.LEGS[0], LEGS.LEGS[1]))
	LEGS.LEGS[1].set_leg_target(calculate_leg_target(LEGS.LEGS[1], LEGS.LEGS[0]))

func update_state():
	if LEGS.stability < 0.2:
		pass
		#LEGS.current_state = LEGS.LEGS_STATE_STABILISING
	elif LEGS.walk_vector.is_zero_approx():
		LEGS.current_state = LEGS.LEGS_STATE_IDLE



##Inline: in the line that will stabilise, a line through the other leg + the COM with minor consideration for velocity.
func calculate_leg_target(leg:Leg, stable_leg:Leg) -> Vector3:
	
	var forwards_angle:float = (LEGS.global_basis.z).signed_angle_to(LEGS.walk_vector, Vector3.UP);
	var project_forward_orthogonal:Vector3 = -(leg.position - stable_leg.position).rotated(Vector3.UP, -forwards_angle);
	var project_forward:Vector3 = (STRIDE_LENGTH * 0.5 * Vector3.FORWARD).rotated(Vector3.UP, forwards_angle); 
	
	LEGS.DOWN_RAY.global_position = stable_leg.global_position + project_forward + project_forward_orthogonal;
	LEGS.DOWN_RAY.force_raycast_update()
	
	if(LEGS.DOWN_RAY.is_colliding()): # There is floor in reasonable distance down
		var collision:Vector3 = LEGS.DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)): # If collision is within reach of said leg
			
			return collision
	
	return Vector3.ZERO



var stand_height:float = 1.9;
func update_target_pos():
	
	var height:float = 1.0;
	for leg in LEGS.LEGS:
		if leg.is_stable:
			var leg_delta:Vector3 = (LEGS.global_position - leg.ground_contact_point) * Vector3(1, 0, 1);
			height = max(height, sqrt(stand_height*stand_height - leg_delta.length_squared()));
	
	if(LEGS.LEGS[0].is_stable and LEGS.LEGS[1].is_stable): # case both legs are stable, stand normally.
		var stable_area = LEGS.calculate_stable_area()
		var stable_centre:Vector3 = LEGS.get_centre_of_stable_area(stable_area);
		LEGS.TARGET.global_position = stable_centre + Vector3.UP * stand_height  + (STRIDE_LENGTH * LEGS.walk_vector * 0.25)
	
	elif(LEGS.LEGS[0].is_stable): # case only leg 0 is stable.
		
		#var forwards_angle:float = (LEGS.global_basis.z).signed_angle_to(LEGS.walk_vector, Vector3.UP); # Script to push the target towards the middle, to make it look less of a waddle.
		#var project_forward_orthogonal:Vector3 = -(LEGS.LEGS[1].position - LEGS.LEGS[0].position).rotated(Vector3.UP, -forwards_angle) * 0.5;
		
		LEGS.TARGET.global_position = LEGS.LEGS[0].ground_contact_point + Vector3.UP * height + (STRIDE_LENGTH * LEGS.walk_vector * 0.5)
		
	elif(LEGS.LEGS[1].is_stable): # case only leg 0 is stable.
		LEGS.TARGET.global_position = LEGS.LEGS[1].ground_contact_point + Vector3.UP * height + (STRIDE_LENGTH * LEGS.walk_vector * 0.5)
	
	else: # case neither leg is stable. falling, oh dear.
		pass
		
