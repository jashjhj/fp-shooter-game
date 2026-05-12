class_name Humanoid_Legs_State extends Node;

@export var LEGS:Humanoid_Legs;

func consider_step():
	pass

func update_leg_targets():
	pass

func update_state():
	pass

##Update legs whole bodys target pos. Sets [LEGS.] TARGET.global_position
func update_target_pos():
	var stable_area := LEGS.calculate_stable_area()
	var ideal_height = LEGS.IDLE_HEIGHT
	
	for leg in LEGS.LEGS:
		#If foot is extended far out (imagine the splits) cannot stand so tall. Calcualted theoretical max height
		var gradient:float = 1.0;
		
		var max_reachable_height:float = sqrt( (leg.UPPER_LENGTH+leg.LOWER_LENGTH)**2 - ((leg.FOOT.global_position - leg.global_position) * Vector3(1, 0, 1)).length_squared() )
		#if(stability < 0.2): max_reachable_height = leg.UPPER_LENGTH+leg.LOWER_LENGTH
		
		ideal_height = min(ideal_height, gradient * max_reachable_height)
	
	ideal_height = lerp(ideal_height * 0.8, ideal_height, LEGS.stability)
	
	
	LEGS.TARGET.global_position = LEGS.get_centre_of_stable_area(stable_area) + Vector3.UP * ideal_height
	


func update_stability(delta:float):
	if LEGS.stable_legs == 2:
		LEGS.stability = lerp(LEGS.stability, max(0.0, (1-LEGS.BODY.linear_velocity.length())), 0.5*delta)
	else:
		LEGS.stability *= 0.4 ** delta # divides by 20 a second
