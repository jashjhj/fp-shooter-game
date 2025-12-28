class_name Humanoid_Legs extends Leg_Manager

@export var ANGLE_HELPER:Angular_Damper;

@export var is_pathfinding:bool = true;
@export var PATHFINDER:NavigationAgent3D

@export_group("Gait Settings")
@export var IDLE_HEIGHT:float = 1.5;
@export var FOOT_PLANT_RADIUS:float = 1.0;








var stability:float = 0.0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	



func _physics_process(delta: float) -> void:
	super(delta)
	
	update_stability(delta)
	update_target()
	
	
	for leg in LEGS:
		set_leg_target(leg)
	
	consider_step()
	


	#update_stability(delta)
	#
	#update_target()
	#apply_self_forces(delta)
	#
	#
	#for leg in LEGS:
		#set_leg_target(leg)
	#
	#
	#apply_offbalance_force(delta)
	#consider_step()

func update_stability(delta:float):

	
	var stable_legs:int = 0;
	for leg in LEGS:
		if leg.is_stable:
			stable_legs += 1;
	
	if(stable_legs >= 3):
		stability = lerp(stability, 1.0, min(1.0, 0.5*delta))
	else:
		stability = lerp(stability, 0.0, min(1.0, 1.0*delta))
	
	stability -= BODY.linear_velocity.length() ** 3 * 0.001
	stability -= BODY.angular_velocity.length() ** 3 * 0.001
	
	stability = min(1.0, max(0.0, stability))
	
	#DebugDraw3D.draw_text(BODY.global_position + Vector3.UP * 0.8, str(stability))

func update_target():
	var stable_area := calculate_stable_area()
	var stable_legs:float = len(stable_area)
	
	#Calculate IDLE_HEIGHT Actual
	var ideal_height = IDLE_HEIGHT
	for leg in LEGS:
		ideal_height = min(ideal_height, (leg.UPPER_LENGTH+leg.LOWER_LENGTH) * 0.8) # TODO needs better work
	
	
	
	TARGET.global_position = get_centre_of_stable_area(stable_area) + Vector3.UP * ideal_height
	Debug.point(TARGET.global_position, 0.1)
	
	if(is_pathfinding): ### ---------------- PATHFINDIUNG CODE
		
		#PATHFINDER.target_position = Globals.PLAYER.global_position
		
		var path_step_dist:float = stability;
		
		var next_pos:Vector3 = PATHFINDER.get_next_path_position()
		var next_pos_delta_xz:Vector3 = (next_pos - BODY.global_position) * Vector3(1, 0, 1)
		
		
		if(next_pos_delta_xz.length() > path_step_dist):
			next_pos_delta_xz = next_pos_delta_xz.normalized() * path_step_dist
		
		TARGET.global_position += next_pos_delta_xz
		
		#Doesnt work
		#Need to reconsider 'Facingness'
		#ANGLE_HELPER.look_at(ANGLE_HELPER.global_position + next_pos_delta_xz)



func set_leg_target(leg:Leg) -> void:
	var target_pos = calculate_leg_target(leg)
	#Debug.point(target_pos)
	if target_pos == Vector3.ZERO: return # If no readings, stay as was
	leg.TARGET.global_position = leg.TARGET.global_position.lerp(target_pos, 0.2)

func calculate_leg_target(leg:Leg) -> Vector3:
	var leg_delta:Vector3 = leg.global_position - BODY.global_position # Leg must be a direct child 
	#leg_delta *= global_basis.inverse()
	var leg_delta_xz:Vector3 = (leg_delta * Vector3(1, 0, 1))
	
	##Pre-muddied by velocity
	var leg_idle_goal_xz:Vector3 = leg_delta_xz.normalized() * FOOT_PLANT_RADIUS
	
	var leg_prospective_xz = leg_idle_goal_xz + get_point_velocity(leg.global_position - BODY.global_position)*Vector3(1, 0, 1)*0.2 # Calculates prospective pos. Needs work
	
	DOWN_RAY.global_position = BODY.global_position + leg_prospective_xz
	DOWN_RAY.force_raycast_update()
	if(DOWN_RAY.is_colliding()):
		var collision:Vector3 = DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)): # If collision is within reach of said leg
			return collision
	
	else:#No collision
		return DOWN_RAY.global_position
	
	return Vector3.ZERO


var last_leg_movement:int;
var percieved_stability:float = 0.0;
func consider_step():
	var stable_area := calculate_stable_area()
	var stable_legs:float = len(stable_area)
	
	##calculate percieved stability
	#if(stable_legs != len(LEGS)):
		#percieved_stability = lerp(percieved_stability, 0.0, 0.01)
	#else:
		#percieved_stability  = lerp(percieved_stability, 1.0, 0.01)
	#
	#percieved_stability -= BODY.linear_velocity.length() * 0.01
	
	#Special case - 1 leg is unstable: Make it take a step
	if(stable_legs == LEGS_INITIAL - 1): # If one elg unstable
		for leg in LEGS:
			if(!leg.is_stable and !leg.is_stepping):
				leg.begin_step()
				return
	
	if Time.get_ticks_msec() - last_leg_movement > 1500: # TODO: Add better criteria for when stepping.
		last_leg_movement = Time.get_ticks_msec()
		var leg_to_move := pick_leg_to_move(percieved_stability)
		if(leg_to_move != null):
			leg_to_move.begin_step()



func pick_leg_to_move(stability:float = 0.5) -> Leg:
	var legs := LEGS.duplicate()
	var i = len(legs) - 1;
	while i >= 0:
		if(legs[i].is_stable == false):
			legs.remove_at(i)
		i -= 1
	if(len(legs) == 0): return null # If all legs are unstable
	
	var best_leg:int = 0;
	var best_leg_score:float = -INF
	
	for j in range(0, len(legs)):
		var leg_goal_delta = legs[j].TARGET.global_position - legs[j].FOOT.global_position
		var score = leg_goal_delta.length() + leg_goal_delta.dot(get_point_velocity(legs[j].global_position - BODY.global_position)) * 2 # COnsiders rate at which moving away more.
		if score > best_leg_score:
			best_leg_score = score
			best_leg = j
	
	#Best leg si the one in the worst position and needs moving next.
	if(best_leg_score > 0.33): # Minimum score to require moving - basically  1/3m unless velocity is involved.
		return legs[best_leg]
	else:
		return null
