extends Node3D

@export var BODY:RigidBody3D
@export var BODY_HITTABLE:Hit_Component;

##Legs should be direct children of BODY
@export var LEG1:LegBotLeg;
@export var LEG2:LegBotLeg;
@export var LEG3:LegBotLeg;


@export var TARGET:Node3D;

@export var DOWN_RAY:RayCast3D

@export var ANGLE_HELPER:Angular_Damper;
@onready var PHYSLERP:Physics_Lerper = Physics_Lerper.new()

@onready var L1Delta:Vector3 = LEG1.position - BODY.position
@onready var L2Delta:Vector3 = LEG2.position - BODY.position
@onready var L3Delta:Vector3 = LEG3.position - BODY.position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var legs:Array[LegBotLeg] = [LEG1, LEG2, LEG3]
	
	for leg in legs:
		leg.BODY = BODY
		leg.hit_limit.connect(leg_hit_limit)
	
	PHYSLERP.RIGIDBODY = BODY
	PHYSLERP.TARGET = TARGET
	PHYSLERP.FORCE = 10;
	PHYSLERP.RESERVE_FORCE = 40;
	
	BODY_HITTABLE.on_hit.connect(body_hit)


func _physics_process(delta: float) -> void:
	
	apply_self_forces(delta)
	
	
	if (Time.get_ticks_msec() < 2000 or true):
		
		set_leg_target(LEG1)
		set_leg_target(LEG2)
		set_leg_target(LEG3)
	
	apply_offbalance_force(delta)
	consider_step()

func apply_self_forces(delta):
	var stable_area := calculate_stable_area()
	var stable_legs:float = len(stable_area)
	
	TARGET.global_position = get_centre_of_stable_area(stable_area) + Vector3.UP * 1.5
	PHYSLERP.FORCE = 8 * stable_legs
	PHYSLERP.RESERVE_FORCE = 16 * stable_legs
	var force_goal = PHYSLERP.calculate_forces(delta)
	
	
	#Capacity for forces.
	var force_capacity:Vector3 = Vector3.ZERO;
	
	var legs:Array[LegBotLeg] = [LEG1, LEG2, LEG3]
	for leg in legs:
		var leg_through:Vector3 = (leg.global_position - leg.FOOT.global_position).normalized()
		var leg_perp:Vector3 = Vector3.ONE - abs(leg_through)
		leg_perp = leg_perp.normalized();
		
		force_capacity += 40*abs(leg_through) # Maximum 'through' force that can be applied per leg
		force_capacity += 10*abs(leg_perp)     # Maximum 'lateral' force that can be applied per leg
	
	#print("Goal force: ", force_goal, ". Capacity: ", force_capacity)
	
	# Calculate the force to apply, being the direction intended and the maximum magnitude we want / can enforce
	var force_to_apply:Vector3 = Vector3(\
		sign(force_goal.x) * min(abs(force_goal.x), force_capacity.x),\
		sign(force_goal.y) * min(abs(force_goal.y), force_capacity.y),\
		sign(force_goal.z) * min(abs(force_goal.z), force_capacity.z),\
	)
	
	BODY.apply_central_force(force_to_apply)
	
	## -- Moments --
	ANGLE_HELPER.STIFFNESS = stable_legs * 3
	ANGLE_HELPER.DAMPING = stable_legs * 0.66 - 1



func body_hit():
	var impulse = BODY_HITTABLE.last_impulse
	apply_dv_to_feet(impulse/BODY.mass)

func set_leg_target(leg:LegBotLeg) -> void:
	var target_pos = calculate_leg_target(leg)
	if target_pos == Vector3.ZERO: return # If no readings, stay as was
	leg.TARGET.global_position = leg.TARGET.global_position.lerp(target_pos, 0.2)

func calculate_leg_target(leg:LegBotLeg) -> Vector3:
	var leg_delta:Vector3 = leg.position # Leg must be a direct child
	#leg_delta *= global_basis.inverse()
	var leg_delta_xz:Vector3 = (leg_delta * Vector3(1, 0, 1))
	
	#1.5 is a measure of Splay. Should eb standardised.
	var leg_prospective_xz = leg_delta_xz*3.0 + get_point_velocity(leg.global_position - BODY.global_position)*Vector3(1, 0, 1)*0.2 # Calculates prospective pos. Needs work
	
	DOWN_RAY.position = leg_prospective_xz
	DOWN_RAY.force_raycast_update()
	if(DOWN_RAY.is_colliding()):
		var collision:Vector3 = DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)):
			return collision
	
	else:#No collision
		return DOWN_RAY.global_position
	
	return Vector3.ZERO

##Stable area is as a global
func calculate_stable_area() -> Array[Vector3]:
	
	var out:Array[Vector3] = [];
	
	if(LEG1.is_stable):
		out.append(LEG1.FOOT.global_position)
	if(LEG2.is_stable):
		out.append(LEG2.FOOT.global_position)
	if(LEG3.is_stable):
		out.append(LEG3.FOOT.global_position)
	
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
	
	#calculate percieved stability
	if(stable_legs != 3):
		percieved_stability = lerp(percieved_stability, 0.0, 0.01)
	else:
		percieved_stability  = lerp(percieved_stability, 1.0, 0.01)
	
	percieved_stability -= BODY.linear_velocity.length() * 0.01
	
	if Time.get_ticks_msec() - last_leg_movement > 1500: # TODO: Add better criteria for when stepping.
		last_leg_movement = Time.get_ticks_msec()
		var leg_to_move := pick_leg_to_move(percieved_stability)
		if(leg_to_move != null):
			leg_to_move.begin_step()



func pick_leg_to_move(stability:float = 0.5) -> LegBotLeg:
	var legs:Array[LegBotLeg] = [LEG1, LEG2, LEG3]
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
		var score = leg_goal_delta.length() + leg_goal_delta.dot(get_point_velocity(legs[j].global_position - BODY.global_position))
		if score > best_leg_score:
			best_leg_score = score
			best_leg = j
	
	#Best leg si the one in the worst position and needs moving next.
	if(best_leg_score > 0.2): # Minimum score to require moving
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
		
		push_warning("attempted to calculate Closest-Stable-Point when there is no stable area at all.")
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


##All global space, applies a delta velocity around the moment of stability to feet. Takes the DV @ com
func apply_dv_to_feet(dv:Vector3):
	var com_global := BODY.global_position + BODY.global_basis*BODY.center_of_mass
	var pivot_pos:Vector3 = get_closest_stable_point_to(com_global + dv * 100)
	var com_delta := com_global - pivot_pos
	var pivot_axis:Vector3 = dv.cross(com_delta).normalized();
	
	var delta_dv:float = dv.dot(-pivot_axis.cross(com_delta)) / com_delta.length()
	
	
	var legs:Array[LegBotLeg] = [LEG1, LEG2, LEG3]
	for leg in legs:
		var foot_pivot_delta := leg.FOOT.global_position - pivot_pos
		var foot_dv_dir:Vector3 = foot_pivot_delta.cross(pivot_axis).normalized()
		var foot_dv = delta_dv * foot_pivot_delta.length()
		
		leg.apply_foot_impulse(foot_dv * foot_dv_dir * leg.FOOT.mass)
		
		#print(foot_dv)
	

func leg_hit_limit(impulse:Vector3, pos:Vector3):
	#BODY.apply_impulse(impulse, pos - BODY.global_position)
	#apply_dv_to_feet(impulse) #TODO: IDK the maths to apply this correctly to the other feet.
	pass

#Where pos = global offset from Body origin (irrespective of current rotation/basis).
func get_point_velocity(pos:Vector3) -> Vector3:
	return BODY.linear_velocity + BODY.angular_velocity.cross(pos - BODY.center_of_mass)
