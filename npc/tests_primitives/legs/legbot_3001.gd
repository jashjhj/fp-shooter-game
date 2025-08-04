class_name LegBot extends Node3D

@export var BODY:Hittable_RB


##Legs should be direct children of BODY
@export var LEGS:Array[BotLeg]


@export var ANGLE_HELPER:Angular_Damper;

@export var is_pathfinding:bool = true;
@export var PATHFINDER:NavigationAgent3D

@export_group("Gait Settings")
@export var IDLE_HEIGHT:float = 1.5;
@export var FOOT_PLANT_RADIUS:float = 1.0;
##The full force that can be put 'through' a leg of the robot. Consider gravity when setting this value.
##These default values are for an object of 4Kg with 3 Legs
@export var LEG_FORCE_THROUGH:float = 20;
@export var LEG_FORCE_LATERAL:float = 8;
##Amount fo force the physlerper imagiens it has, at full capacity. Disregarding Gravity.
@export var IMAGINED_FORCE:float = 60;

@onready var TARGET:Node3D = Node3D.new()
@onready var DOWN_RAY:RayCast3D = RayCast3D.new()
@onready var PHYSLERP:Physics_Lerper = Physics_Lerper.new()

##Set this to the body's hit-component.
@export var BODY_HITTABLE:Hit_Component;


@onready var LEGS_INITIAL:int = len(LEGS)


var stability:float = 0.0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	BODY.collision_layer = 64
	BODY.collision_mask = 1;
	
	add_child(TARGET)
	
	for leg in LEGS:
		leg.BODY = BODY
		leg.hit_limit.connect(leg_hit_limit)
	
	PHYSLERP.RIGIDBODY = BODY
	PHYSLERP.TARGET = TARGET
	
	assert(BODY_HITTABLE != null, "No Body hittable set")
	BODY_HITTABLE.on_hit.connect(body_hit)
	
	#Init dow-ray
	add_child(DOWN_RAY)
	DOWN_RAY.hit_from_inside = true
	DOWN_RAY.target_position = Vector3.DOWN * 5;
	DOWN_RAY.collide_with_areas = true



func _physics_process(delta: float) -> void:
	update_stability(delta)
	
	update_target()
	apply_self_forces(delta)
	
	
	for leg in LEGS:
		set_leg_target(leg)
	
	
	apply_offbalance_force(delta)
	consider_step()
	


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
		ideal_height = min(ideal_height, (leg.UPPER_LENGTH+leg.LOWER_LENGTH) * 1.0) # TODO needs better work
	
	
	
	TARGET.global_position = get_centre_of_stable_area(stable_area) + Vector3.UP * ideal_height
	
	
	if(is_pathfinding): ### ---------------- PATHFINDIUNG CODE
		
		PATHFINDER.target_position = Globals.PLAYER.global_position
		
		var path_step_dist:float = stability;
		
		var next_pos:Vector3 = PATHFINDER.get_next_path_position()
		var next_pos_delta_xz:Vector3 = (next_pos - BODY.global_position) * Vector3(1, 0, 1)
		
		
		if(next_pos_delta_xz.length() > path_step_dist):
			next_pos_delta_xz = next_pos_delta_xz.normalized() * path_step_dist
		
		TARGET.global_position += next_pos_delta_xz
		
		#Doesnt work
		#Need to reconsider 'Facingness'
		#ANGLE_HELPER.look_at(ANGLE_HELPER.global_position + next_pos_delta_xz)



var last_force_applied:Vector3 = Vector3.ZERO # Logging
func apply_self_forces(delta):
	
	
	#Capacity for forces.
	var force_capacity:Vector3 = Vector3.ZERO;
	
	for leg in LEGS:
		if(!leg.is_stable): continue
		var leg_through:Vector3 = (leg.global_position - leg.FOOT.global_position).normalized()
		var leg_perp:Vector3 = Vector3.ONE - abs(leg_through)
		leg_perp = leg_perp.normalized();
		
		force_capacity += LEG_FORCE_THROUGH*abs(leg_through) * 3 # Maximum 'through' force that can be applied per leg
		force_capacity += LEG_FORCE_LATERAL*abs(leg_perp)     # Maximum 'lateral' force that can be applied per leg
	
	
	PHYSLERP.FORCE = IMAGINED_FORCE
	PHYSLERP.RESERVE_FORCE = BODY.mass * 12;
	var force_goal = PHYSLERP.calculate_forces(delta)
	
	
	
	# Calculate the force to apply, being the direction intended and the maximum magnitude we want / can enforce
	var force_to_apply:Vector3 = Vector3(                               \
		sign(force_goal.x) * min(abs(force_goal.x), force_capacity.x),  \
		sign(force_goal.y) * min(abs(force_goal.y), force_capacity.y),  \
		sign(force_goal.z) * min(abs(force_goal.z), force_capacity.z),  \
	)
	
	
	#var stable_centre = get_centre_of_stable_area(calculate_stable_area())
	#var closest = get_closest_stable_point_to(BODY.global_position + BODY.center_of_mass)
	#Debug.point(stable_centre)
	
	BODY.apply_central_force(force_to_apply * Vector3(1, 1, 1))
	#BODY.apply_force(force_to_apply * Vector3(0, 1, 0), closest - BODY.global_position)
	
	## -- Moments --
	#ANGLE_HELPER.STIFFNESS = stable_legs * 3
	#ANGLE_HELPER.DAMPING = stable_legs * 0.66 - 1
	
	#Logging for fixing settings - useful for setting values intiially // Not 100% functional code
	#If the force i want is the same,                  and  nothing is happening                 and its not just being intitialised
	#if((PHYSLERP.last_force - force_goal).length() < 1.0 and BODY.linear_velocity.length() < 0.2 and Time.get_ticks_msec() > 1000):
		#print("Percieved under-powered force: ", force_to_apply, "Applied out of", force_goal)
	
	last_force_applied = force_to_apply


func body_hit():
	var impulse = BODY_HITTABLE.last_impulse
	apply_dv_to_feet(impulse/BODY.mass)

func set_leg_target(leg:BotLeg) -> void:
	var target_pos = calculate_leg_target(leg)
	#Debug.point(target_pos)
	if target_pos == Vector3.ZERO: return # If no readings, stay as was
	leg.TARGET.global_position = leg.TARGET.global_position.lerp(target_pos, 0.2)

func calculate_leg_target(leg:BotLeg) -> Vector3:
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

##Stable area is as a global
func calculate_stable_area() -> Array[Vector3]:
	
	var out:Array[Vector3] = [];
	
	for leg in LEGS:
		if(leg.is_stable):
			out.append(leg.FOOT.global_position)
	
	return out

func get_centre_of_stable_area(arr:Array[Vector3]) -> Vector3:
	var average_position:Vector3 = Vector3.ZERO;# = (LEG1.target + LEG2.target + LEG3.target)/3.0
	
	for i in arr:
		average_position += i
	
	if(len(arr) != 0):#If >=1 contributors:
		return average_position / len(arr)
	
	#Completely unstable
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



func pick_leg_to_move(stability:float = 0.5) -> BotLeg:
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


##S = start of line, D = delta. Considers X,Z. returns component lambda of 1 as x and 2 as y. |     Simple mathematical solver.
func get_intersection_components(s1:Vector3, s2:Vector3, d1:Vector3, d2:Vector3) -> Vector2:
	var a = s1.x
	var b = s1.z
	var x = d1.x
	var y = d1.z
	
	var d = s2.x
	var e = s2.z
	var u = d2.x
	var v = d2.z
	
	var lambda = (e-b + (v/u)*(a-d)) / (y - x*v/u) # Solves to find collision
	var mu = (lambda*y + b - e)/v
	
	return Vector2(lambda, mu)

func apply_offbalance_force(delta:float):
	var stable_area := calculate_stable_area()
	
	var stable_centre := get_centre_of_stable_area(stable_area)
	var com_global:Vector3 = BODY.global_position + BODY.global_basis * BODY.center_of_mass
	#var com_delta = BODY.center_of_mass - stable_centre
	
	#Calculate closest point of the stable area
	var pivot_point:Vector3 = get_closest_stable_point_to(com_global)
		
		#Finally - ensure that COM is actually outside of the calculated nearest point on perimeter of polygon
		
	if(((pivot_point - stable_centre)*Vector3(1, 0, 1)).length_squared() >= ((com_global - stable_centre)*Vector3(1,0,1)).length_squared() \
		or pivot_point == Vector3.INF): # INF means no stable point, cancel
		
		return
		
		#print("im unstable hahah")
		#Debug.point(pivot_point + BODY.global_position, 1, Color.RED)
	
	#We now have pivot_point
	var com_pivot_delta:Vector3 = com_global - pivot_point
	var com_pivot_delta_xz = com_pivot_delta * Vector3(1,0,1)
	#Angle between floor and pivot(on floor) to COM
	var angle = atan(abs(com_pivot_delta.y) / com_pivot_delta_xz.length())
	var moment_component:float = BODY.mass * ProjectSettings.get_setting("physics/3d/default_gravity") * sin(angle)
	var moment_direction:Vector3 = (com_pivot_delta_xz.normalized() - (Vector3.UP / tan(angle))).normalized() # prommy this works
	
	#DebugDraw3D.draw_line(BODY.global_position + Vector3.UP*0.3, BODY.global_position + Vector3.UP*0.3 + moment_direction * moment_component / 40)
	BODY.apply_central_force(moment_component * moment_direction)
	
	apply_dv_to_feet(moment_component * moment_direction / BODY.mass * delta)
	
	#This torqic application may be unnecessary and glitzy
	var torque_direction := moment_direction.rotated(Vector3.UP, PI/2)
	BODY.apply_torque(torque_direction * moment_component / 40)

##Pos is global, returns global position of point on stable polygon.
func get_closest_stable_point_to(pos:Vector3) -> Vector3:
	var stable_area := calculate_stable_area()
	var stable_centre := get_centre_of_stable_area(stable_area)
	
	
	#Calculate closest point of the stable area
	var pivot_point:Vector3;
	if(len(stable_area) == 0):
		
		#push_warning("attempted to calculate Closest-Stable-Point when there is no stable area at all.")
		return Vector3.INF # Returns this as warning, failure
		
		
	elif(len(stable_area) == 1):
		pivot_point = stable_area[0]
	else: # This function to calculate closest poitn can be optimised by only considering the edges connected to clsoest vertex. Will not have to consider 'other side'
		var likeliest_pair:Array[int] = [-1, -1];
		var likeliest_piv_pos:Vector3 = Vector3.ZERO;
		
		# For each line - if delta is perpendicular to a line.
		for i in range(0, len(stable_area) - 1):
			for j in range(i+1, len(stable_area)):
				var line_delta = (stable_area[j] - stable_area[i]) * Vector3(1, 1, 1)
				var line_normal = line_delta.cross(Vector3.UP) # direction not specified. could be in or out
				
				var components := get_intersection_components(stable_area[i], pos, line_delta, line_normal);
				
				
				if(components.x >= 0.0 and components.x <= 1.0): # lines intersect.
					
					var piv_pos = stable_area[i].lerp(stable_area[j], components.x)
					
					
					
					#If pivot pos is further out than COM pos, ie. COM is within the polygon
					if(((stable_centre - piv_pos)*Vector3(1, 0, 1)).length_squared() > ((stable_centre - (pos))*Vector3(1,0,1)).length_squared()):
						continue # This point can be disregarded.
					else:
						#Check case where its on other side, so dot product would be negative indicating they are not on the same side of the stable_centre
						if(((stable_centre - piv_pos)*Vector3(1, 0, 1)).dot((stable_centre - (pos))*Vector3(1,0,1)) < 0):
							continue
						likeliest_pair = [i, j]
						likeliest_piv_pos = piv_pos
		
		
		if(likeliest_pair[0] == -1 or likeliest_pair[1] == -1): # No good line - get nearest point

			var nearest_point:Vector3 = Vector3.INF
			var nearest_distance_squared:float = INF
			for i in range(0, len(stable_area)):
				var point_dist_squared := (stable_area[i] - (pos)).length_squared()
				if(point_dist_squared < nearest_distance_squared): # New point is closer
					nearest_point = stable_area[i]
					nearest_distance_squared = point_dist_squared
			
			pivot_point = nearest_point
		else:
			pivot_point = likeliest_piv_pos # Use previous result from nearest line
	return pivot_point


##TODO REDO THIS FUNCTION idk how it works
##All global space, applies a delta velocity around the moment of stability to feet. Takes the DV @ com
func apply_dv_to_feet(dv:Vector3):
	var com_global := BODY.global_position + BODY.global_basis*BODY.center_of_mass
	var pivot_pos:Vector3 = get_closest_stable_point_to(com_global + dv * 100)
	if(pivot_pos == Vector3.INF):#No stable area whatsoever
		for leg in LEGS:
			leg.apply_foot_impulse(leg.FOOT.mass * dv)
	
	
	var com_delta := com_global - pivot_pos
	var pivot_axis:Vector3 = Vector3.UP.cross(com_delta).normalized();
	
	var delta_dv:float = dv.dot(-pivot_axis.cross(com_delta.normalized()))
	
	
	for leg in LEGS:
		if(leg.is_stable):
			
			#This is unreliable - ignore it. Meant to lift up opposite leg when losing balance. - Inr eality causes everythign to fall
			
			var foot_pivot_delta := leg.FOOT.global_position - pivot_pos
			var foot_dv_dir:Vector3 = foot_pivot_delta.cross(pivot_axis).normalized()
			var foot_dv = delta_dv * foot_pivot_delta.length()
			
			#leg.apply_foot_impulse(foot_dv * foot_dv_dir * leg.FOOT.mass) # Does this only consider pivotal forces?
			
			
			pass
		else:
			leg.apply_foot_impulse(leg.FOOT.mass * dv) # If ungrounded, simply propagate
		
		#print(foot_dv)
	

func leg_hit_limit(impulse:Vector3, pos:Vector3):
	#BODY.apply_impulse(impulse, pos - BODY.global_position)
	#apply_dv_to_feet(impulse) #TODO: IDK the maths to apply this correctly to the other feet.
	pass

#Where pos = global offset from Body origin (irrespective of current rotation/basis).
func get_point_velocity(pos:Vector3) -> Vector3:
	return BODY.linear_velocity + BODY.angular_velocity.cross(pos - BODY.center_of_mass)
