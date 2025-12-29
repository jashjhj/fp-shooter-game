class_name Humanoid_Legs extends Leg_Manager

@export var ANGLE_HELPER:Angular_Damper;

@export var is_pathfinding:bool = true;
@export var PATHFINDER:NavigationAgent3D

@export_group("Gait Settings")
#@export var IDLE_HEIGHT:float = 1.5;
@export var FOOT_PLANT_RADIUS:float = 1.0;

@export_category("LEGS: Left leg first")

##The direction it attempts to look
var GOAL_HEADING:Vector3 = Vector3.FORWARD

var stability:float = 0.0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	assert(len(LEGS) == 2, "Humanoid does not have 2 Legs :( " + str(get_path));

func _physics_process(delta: float) -> void:
	super(delta)

	
	
	update_stability(delta) # just guessed how stable - not useful
	
	
	consider_step()
	update_leg_targets()
	
	
	

func update_stability(delta:float) -> void:
	if stable_legs == 2:
		stability = lerp(stability, max(0.0, (1-BODY.linear_velocity.length())), 0.5*delta)
	
	
	else:
		stability *= 0.4 ** delta # divides by 20 a second
	
	print(stability)

var last_leg_movement:int;
var percieved_stability:float = 0.0;
func consider_step():
	var stable_area := calculate_stable_area()

	
	if(!is_above_stable_zone and stable_legs == 2 and unstable_distance > 0.2):
		#print(unstable_distance)
		#pick leg to move - The one with its foot planted further away from the body.
		var leg_to_move:Leg = LEGS[0] if ((LEGS[0].FOOT.global_position - BODY.global_position) * (BODY.global_basis.x)).length_squared() > ((LEGS[1].FOOT.global_position - BODY.global_position) * (BODY.global_basis.x)).length_squared() else LEGS[1];
		
		#var leg_to_move:Leg = LEGS[0] if ((LEGS[0].FOOT.global_position - BODY.global_position)).length_squared() > ((LEGS[1].FOOT.global_position - BODY.global_position)).length_squared() else LEGS[1];
		leg_to_move.begin_step()
		
	elif(stability > 0.6):
		var leg_to_move:Leg = LEGS[0] if ((LEGS[0].FOOT.global_position - BODY.global_position) * (BODY.global_basis.x)).length_squared() > ((LEGS[1].FOOT.global_position - BODY.global_position) * (BODY.global_basis.x)).length_squared() else LEGS[1];
		leg_to_move.begin_step()


func update_leg_targets():
	var stable_area := calculate_stable_area()
	#var stable_legs:float = len(stable_area)
	
	#Calculate IDLE_HEIGHT Actual
	var ideal_height = IDLE_HEIGHT
	for leg in LEGS:
		ideal_height = min(ideal_height, (leg.UPPER_LENGTH+leg.LOWER_LENGTH) * 0.8) # TODO needs better work
	
	
	
	TARGET.global_position = get_centre_of_stable_area(stable_area) + Vector3.UP * ideal_height
	Debug.point(TARGET.global_position, 0.1)
	
	if(stable_legs == 1): # making a step
		var stable_leg:Leg;
		var unstable_leg:Leg;
		if LEGS[0].is_stable:
			stable_leg = LEGS[0]
			unstable_leg = LEGS[1]
		else:
			unstable_leg = LEGS[0]
			stable_leg = LEGS[1]
		
		if(stability > 0.2): # if making a step stably, to balance
			
			if(LEGS[0].is_stable): # detech if is left or right leg
				unstable_leg.set_leg_target(calculate_leg_target_idle(unstable_leg, stable_leg, true))
			else:
				unstable_leg.set_leg_target(calculate_leg_target_idle(unstable_leg, stable_leg, false))
		else:
			unstable_leg.set_leg_target(calculate_leg_target_stabilise(unstable_leg, stable_leg))
	
	else:
		
		LEGS[0].set_leg_target(calculate_leg_target_idle(LEGS[0], LEGS[1], true))
		LEGS[1].set_leg_target(calculate_leg_target_idle(LEGS[1], LEGS[0], false))
	
	#if(is_pathfinding): ### ---------------- PATHFINDIUNG CODE
		#
		##PATHFINDER.target_position = Globals.PLAYER.global_position
		#
		#var path_step_dist:float = stability;
		#
		#var next_pos:Vector3 = PATHFINDER.get_next_path_position()
		#var next_pos_delta_xz:Vector3 = (next_pos - BODY.global_position) * Vector3(1, 0, 1)
		#
		#
		#if(next_pos_delta_xz.length() > path_step_dist):
			#next_pos_delta_xz = next_pos_delta_xz.normalized() * path_step_dist
		#
		#TARGET.global_position += next_pos_delta_xz
		#
		##Doesnt work
		##Need to reconsider 'Facingness'
		##ANGLE_HELPER.look_at(ANGLE_HELPER.global_position + next_pos_delta_xz)

#func set_leg_target(leg:Leg) -> void:
	#var target_pos:Vector3;
	#if(stability > 0.2):
		#target_pos = calculate_leg_target_idle(leg)
	#else:
		#target_pos = calculate_leg_target_stabilise(leg, )
	##Debug.point(target_pos)
	#if target_pos == Vector3.ZERO: return # If no readings, stay as was
	#leg.TARGET.global_position = leg.TARGET.global_position.lerp(target_pos, 0.2)

##Is left leg is about the first leg
func calculate_leg_target_idle(leg:Leg, other_leg:Leg, is_left_leg:bool) -> Vector3:
	
	#Calculates where the leg would LIKE to be if it could be in the correct place relative to the other leg.
	
	var offset_direction:Vector3
	
	var goal_heading:Vector3 = BODY.global_basis.z;
	
	if(is_left_leg):
		offset_direction = goal_heading.rotated(Vector3.UP, PI/2).normalized()
	else:
		offset_direction = goal_heading.rotated(Vector3.UP, -PI/2).normalized()
	
	var goal_pos:Vector3 = other_leg.global_position + (leg.global_position-other_leg.global_position).length() * offset_direction
	
	DOWN_RAY.global_position = goal_pos
	DOWN_RAY.force_raycast_update()
	if(DOWN_RAY.is_colliding()): # There is floor in reasonable distance down
		var collision:Vector3 = DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)): # If collision is within reach of said leg
			return collision
	
	return Vector3.ZERO

	
	
	##Delta to the origin of the leg. Global
	
	#var leg_delta:Vector3 = leg.global_position - BODY.global_position # Leg must be a direct child 
	###Hporizontal component
	#var leg_delta_xz:Vector3 = (leg_delta * Vector3(1, 0, 1))
	#
	###Leg idle goal pos. By default, under the hip. Could be altered for a combat stance.
	#var leg_idle_goal_xz:Vector3 = leg_delta_xz.normalized()
	#
	##var leg_prospective_xz = leg_idle_goal_xz + get_point_velocity(leg.global_position - BODY.global_position)*Vector3(1, 0, 1)*0.2 # Calculates prospective pos. Needs work
	#var leg_goal_xz:Vector3 = leg_idle_goal_xz;
	#
	#DOWN_RAY.global_position = BODY.global_position + leg_goal_xz
	#DOWN_RAY.force_raycast_update()
	#if(DOWN_RAY.is_colliding()): # There is floor in reasonable distance down
		#var collision:Vector3 = DOWN_RAY.get_collision_point()
		#if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)): # If collision is within reach of said leg
			#return collision
	#
	#return Vector3.ZERO

func calculate_leg_target_stabilise(leg:Leg, stable_leg:Leg) -> Vector3:
	# -- -calculate new pos
	var stable_offset_xz:Vector3 = (BODY.global_position - stable_leg.FOOT.global_position) * Vector3(1, 0, 1);
	#stable_offset_xz *= 2.0; # Find where to plant foot to make it stable
	stable_offset_xz += BODY.linear_velocity * 0.3 # Add velocity for small amount of preempting
	
	
	#-- Apply it
	
	#Stable offset xz is where to plant the foot to make the body stable.
	DOWN_RAY.global_position = BODY.global_position + stable_offset_xz;
	DOWN_RAY.force_raycast_update()
	
	if(DOWN_RAY.is_colliding()): # There is floor in reasonable distance down
		var collision:Vector3 = DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)): # If collision is within reach of said leg
			return collision
	
	return Vector3.ZERO
	#return calculate_leg_target_idle(leg) # Fallback on putting foot DOWN if it cant find a floor
