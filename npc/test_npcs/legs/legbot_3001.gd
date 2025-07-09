extends Node3D

@export var BODY:RigidBody3D

##Legs should be direct children of BODY
@export var LEG1:LegBotLeg;
@export var LEG2:LegBotLeg;
@export var LEG3:LegBotLeg;


@export var TARGET:Node3D;

@export var DOWN_RAY:RayCast3D
@onready var PHYSLERP:Physics_Lerper = Physics_Lerper.new()

@onready var L1Delta:Vector3 = LEG1.position - BODY.position
@onready var L2Delta:Vector3 = LEG2.position - BODY.position
@onready var L3Delta:Vector3 = LEG3.position - BODY.position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	LEG1.BODY = BODY
	LEG2.BODY = BODY
	LEG3.BODY = BODY
	
	PHYSLERP.RIGIDBODY = BODY
	PHYSLERP.TARGET = TARGET
	PHYSLERP.FORCE = 10;
	PHYSLERP.RESERVE_FORCE = 40;
	


var first = true
func _physics_process(delta: float) -> void:
	
	var stable_area := calculate_stable_area()
	var stable_legs := len(stable_area)
	
	PHYSLERP.FORCE = 8 * stable_legs
	PHYSLERP.RESERVE_FORCE = 16 * stable_legs
	
	PHYSLERP.apply_forces(delta)
	
	if (Time.get_ticks_msec() < 2000):
		
		set_leg_target(LEG1)
		set_leg_target(LEG2)
		set_leg_target(LEG3)
	
	apply_offbalance_force()
	
	Debug.point(BODY.global_position +  get_centre_of_stable_area(calculate_stable_area()));
	first = false


#func _process(delta: float) -> void:
	
	#call_deferred("update_legs")

#func update_legs():
	#LEG1.update_leg()
	#LEG2.update_leg()
	#LEG3.update_leg()

func set_leg_target(leg:LegBotLeg) -> void:
	var target_pos = calculate_leg_target(leg)
	if target_pos == Vector3.ZERO: return # If no readings, stay as was
	leg.TARGET.global_position = target_pos

func calculate_leg_target(leg:LegBotLeg) -> Vector3:
	var leg_delta:Vector3 = leg.position # Leg must be a direct child
	#leg_delta *= global_basis.inverse()
	var leg_delta_xz:Vector3 = (leg_delta * Vector3(1, 0, 1))
	
	var leg_prospective_xz = leg_delta_xz*1 + get_point_velocity(leg.global_position - BODY.global_position)*Vector3(1, 0, 1) # Calculates prospective pos. Needs work
	
	DOWN_RAY.position = leg_prospective_xz
	DOWN_RAY.force_raycast_update()
	if(DOWN_RAY.is_colliding()):
		var collision:Vector3 = DOWN_RAY.get_collision_point()
		if((collision - leg.global_position).length() < (leg.UPPER_LENGTH + leg.LOWER_LENGTH)):
			return collision
	
	else:#No collision
		return DOWN_RAY.global_position
	
	return Vector3.ZERO

##Stable area is in a global delta from body
func calculate_stable_area() -> Array[Vector3]:
	
	var out:Array[Vector3] = [];
	
	if(LEG1.is_stable):
		out.append(LEG1.FOOT.global_position - BODY.global_position)
	if(LEG2.is_stable):
		out.append(LEG2.FOOT.global_position - BODY.global_position)
	if(LEG3.is_stable):
		out.append(LEG3.FOOT.global_position - BODY.global_position)
	
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

func apply_offbalance_force():
	var stable_area := calculate_stable_area()
	
	var stable_centre := get_centre_of_stable_area(stable_area)
	var com_delta = BODY.center_of_mass - stable_centre
	
	#Calculate closest point of the stable area
	var pivot_point:Vector3;
	if(len(stable_area) == 0):
		return
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
				
				var components := get_intersection_components(stable_area[i], BODY.position + BODY.center_of_mass, line_delta, line_normal);
				
				
				if(components.x >= 0.0 and components.x <= 1.0): # lines intersect.
					
					var piv_pos = stable_area[i].lerp(stable_area[j], components.x)
					
					
					
					#If pivot pos is further out than COM pos, ie. COM is within the polygon
					if(((stable_centre - piv_pos)*Vector3(1, 0, 1)).length_squared() > ((stable_centre - (BODY.position + BODY.center_of_mass))*Vector3(1,0,1)).length_squared()):
						continue # This point can be disregarded.
					else:
						#Check case where its on other side, so dot product would be negative indicating they are not on the same side of the stable_centre
						if(((stable_centre - piv_pos)*Vector3(1, 0, 1)).dot((stable_centre - (BODY.position + BODY.center_of_mass))*Vector3(1,0,1)) < 0):
							continue
						likeliest_pair = [i, j]
						likeliest_piv_pos = piv_pos
		
		
		if(likeliest_pair[0] == -1 or likeliest_pair[1] == -1): # No good line - get nearest point

			var nearest_point:Vector3 = Vector3.INF
			var nearest_distance_squared:float = INF
			for i in range(0, len(stable_area)):
				var point_dist_squared := (stable_area[i] - (BODY.position + BODY.center_of_mass)).length_squared()
				if(point_dist_squared < nearest_distance_squared): # New point is closer
					nearest_point = stable_area[i]
					nearest_distance_squared = point_dist_squared
			
			pivot_point = nearest_point
		else:
			pivot_point = likeliest_piv_pos # Use previous result from nearest line
		
		#Finally - ensure that COM is actually outside of the calculated nearest point on perimeter of polygon
		
		if(((pivot_point - stable_centre)*Vector3(1, 0, 1)).length_squared() >= ((BODY.center_of_mass - stable_centre)*Vector3(1,0,1)).length_squared()):
			# Within shape
			
			return
		
		#print("im unstable hahah")
		Debug.point(pivot_point + BODY.global_position, 1, Color.RED)
	
	#We now have pivot_point
	var com_pivot_delta:Vector3 = BODY.center_of_mass - pivot_point
	var com_pivot_delta_xz = com_pivot_delta * Vector3(1,0,1)
	#Angle between floor and pivot(on floor) to COM
	var angle = atan(abs(com_pivot_delta.y) / com_pivot_delta_xz.length())
	var moment_component:float = BODY.mass * ProjectSettings.get_setting("physics/3d/default_gravity") * sin(angle)
	print(angle)
	var moment_direction:Vector3 = (com_pivot_delta_xz.normalized() - (Vector3.UP / tan(angle))).normalized() # prommy this works
	print(moment_component)
	DebugDraw3D.draw_line(BODY.global_position + Vector3.UP, BODY.global_position + Vector3.UP + moment_direction * moment_component / 40)
	BODY.apply_central_force(moment_component * moment_direction)
	

#Where pos = global offset from Body origin (irrespective of current rotation/basis).
func get_point_velocity(pos:Vector3) -> Vector3:
	return BODY.linear_velocity + BODY.angular_velocity.cross(pos - BODY.center_of_mass)
