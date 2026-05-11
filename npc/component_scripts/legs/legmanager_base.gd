class_name Leg_Manager extends Node3D

@export var BODY:Hittable_RB
##Legs should be direct children of BODY
@export var LEGS:Array[Leg]
@onready var LEGS_INITIAL:int = len(LEGS)

var body_hit_component:Hit_Component; # auto initialised
@export_group("Gait Settings")
@export var IDLE_HEIGHT:float = 1.5;
#@export var FOOT_PLANT_RADIUS:float = 1.0;
##The full force that can be put 'through' a leg of the robot. Consider gravity when setting this value.
##These default values are for an object of 4Kg with 3 Legs
@export var LEG_FORCE_THROUGH:float = 20;
@export var LEG_FORCE_LATERAL:float = 8;
##Amount fo force the physlerper imagiens it has, at full capacity. Disregarding Gravity.
@export var IMAGINED_FORCE:float = 60;

##TARGET for PHYSLERP, Not edited in legmanager_base. Use to control movement.
@onready var TARGET:Node3D = Node3D.new()
@onready var DOWN_RAY:RayCast3D = RayCast3D.new()
@onready var PHYSLERP:Physics_Lerper = Physics_Lerper.new()

var stable_legs:int = 0;

##Distance perpendicularly from the stable zone.
var unstable_distance:float = 0.0;




func _ready() -> void:
	#super._ready()
	
	for leg in LEGS: # first, wait for legs to ready up. This should be automatic if legs are beneath this
		if !leg.is_node_ready(): await leg.ready
		leg.began_step.connect(leg_stepped);
	
	assert(BODY != null, "NO BODY Set for object with Leg_Manager @ " + str(get_path()))
	
	
	add_child(TARGET) # target set to position
	TARGET.top_level = true
	
	for leg in LEGS:
		leg.BODY = BODY
		leg.hit_limit.connect(leg_hit_limit) # when the leg hits a limit @ extent of its reach.
	
	PHYSLERP.RIGIDBODY = BODY
	PHYSLERP.TARGET = TARGET
	
	BODY.ready.connect(connect_body_hit_cmp);
	
	#Init down-ray
	add_child(DOWN_RAY)
	DOWN_RAY.hit_from_inside = true
	DOWN_RAY.target_position = Vector3.DOWN * IDLE_HEIGHT * 2.0;
	DOWN_RAY.collide_with_areas = true
	


func connect_body_hit_cmp(): # connects trigger of when body hit.
	if(len(BODY.HIT_COMPONENTS) >= 1):
		body_hit_component = BODY.HIT_COMPONENTS[0]
		body_hit_component.on_hit.connect(body_hit)
		if len(BODY.HIT_COMPONENTS) >= 2 and BODY.HIT_COMPONENTS[1] is Hit_Impulse:
			push_warning("Impusle automatically applied to Humanoid's Root node - not computed properly. Please remove its Hit_Impulse.");
			
	else:
		push_warning("No Body hit component found! Cannot communicate impulses through to the feet.")


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	#update_stability(delta)
	stable_legs = 0;
	for leg in LEGS:
		if leg.is_stable:
			stable_legs +=1;
	#Physlerper forces to self
	apply_self_forces(delta)
	
	
	#for leg in LEGS:
	#	set_leg_target(leg)
	
	
	apply_offbalance_force(delta)
	#consider_step()



var last_force_applied:Vector3 = Vector3.ZERO # Logging
func apply_self_forces(delta):
	
	
	#Capacity for forces.
	var force_capacity:Vector3 = Vector3.ZERO;
	#var force_capacity_one_directional:Vector3 = Vector3.ZERO;
	
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

##Helper function for apply self forces
func add_1d_force_capacity(capacity:Vector3, add:Vector3) -> Array[Vector3]:
	var old_capacity = capacity
	var nondirectional_capacity:Vector3 = Vector3.ZERO;
	
	capacity += add
	if(sign(old_capacity.x) != sign(add.x)):
		nondirectional_capacity.x += abs(old_capacity.x - capacity.x)
	if(sign(old_capacity.y) != sign(add.y)):
		nondirectional_capacity.y += abs(old_capacity.y - capacity.y)
	if(sign(old_capacity.z) != sign(add.z)):
		nondirectional_capacity.z += abs(old_capacity.z - capacity.z)
	
	
	return [capacity, nondirectional_capacity]


##Last time [sub-leg].begin_step() was called, tick msec.
var last_step_time:int;
##Called every time a leg.begin_step() is called.
func leg_stepped():
	last_step_time = Time.get_ticks_msec();

func body_hit():
	var impulse:Vector3 = body_hit_component.last_impulse;
	var impulse_pos:Vector3 = body_hit_component.last_impulse_pos;
	
	BODY.apply_torque_impulse(Vector3(0, 0, 0))
	BODY.apply_impulse(impulse)
	
	apply_dv_to_feet(impulse/BODY.mass)
	



##Stable area is as a global
func calculate_stable_area() -> Array[Vector3]:
	
	var out:Array[Vector3] = [];
	
	for leg in LEGS:
		if(leg.is_stable):
			for stable_foot_pos in leg.STABLE_FOOT_POINTS:
				var stable_pos:Vector3 = leg.FOOT.global_position + stable_foot_pos * leg.FOOT.global_basis
				out.append(stable_pos)
	
	return out

func get_centre_of_stable_area(arr:Array[Vector3]) -> Vector3:
	var average_position:Vector3 = Vector3.ZERO;# = (LEG1.target + LEG2.target + LEG3.target)/3.0
	
	for i in arr:
		average_position += i
	
	if(len(arr) != 0):#If >=1 contributors:
		return average_position / len(arr)
	
	#Completely unstable
	return Vector3.ZERO



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
	
	
	if(pivot_point == Vector3.INF): # case in which there IS no stable zone
		unstable_distance = INF;
		
		return
	
	 # this line mathematically checks if the nearest stable point places the COM pos outside of the stable area.
	unstable_distance = ((com_global - stable_centre)*Vector3(1,0,1)).length() - ((pivot_point - stable_centre)*Vector3(1, 0, 1)).length();
	if(unstable_distance < 0):
		#ONLY case where this IS actually stable :
		unstable_distance = 0;
		return
	
	
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

func body_com_global() -> Vector3:
	return BODY.global_position + BODY.global_basis * BODY.center_of_mass
