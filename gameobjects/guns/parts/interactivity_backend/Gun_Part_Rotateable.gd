class_name Gun_Part_Rotateable extends Gun_Part_Interactive


@export var ROTATION_AXIS:Vector3 = Vector3.LEFT;




var start_focus_mouse_pos:Vector3;
var previous_focus_mouse_pos:Vector3;
var start_focus_angle:float = 0;
var angle_change_goal:float = 0;
var angle_goal:float = 0;
var angle_change_delta:float = 0;


## In rad*m = radians being pulled at distance in m
var mouse_torque_radm:float = 0;

func _ready():
	super._ready();
	ROTATION_AXIS = ROTATION_AXIS.normalized()
	INTERACT_PLANE.position = Vector3(0,0,0);
	INTERACT_PLANE.look_at(global_position + global_transform.basis * ROTATION_AXIS) # looks perpendicularly to the rotation axis.
	
	#Extras
	
	_ready2()



func _process(delta:float)->void:
	super._process(delta);
	
	if(is_focused):
		#print(get_mouse_plane_position())
		var next_focus_mouse_pos:Vector3 = get_mouse_plane_position()
		
		var clockwise_right_vector = previous_focus_mouse_pos.normalized().cross(INTERACT_PLANE.global_basis.z);
		angle_change_delta = asin(clockwise_right_vector.dot(next_focus_mouse_pos.normalized())) # Gets angle
		
		previous_focus_mouse_pos = next_focus_mouse_pos
		
		angle_change_goal += angle_change_delta
		angle_goal += angle_change_delta
		
		mouse_torque_radm = (angle_change_goal + start_focus_angle - current_angle) * min(next_focus_mouse_pos.length(), MAX_MOUSE_TORQUE_DIST);
		#print(torque_radm)
	
	_process2()




func enable_focus():
	super.enable_focus()
	start_focus_mouse_pos = get_mouse_plane_position();
	previous_focus_mouse_pos = start_focus_mouse_pos
	angle_change_goal = 0.0;
	start_focus_angle = current_angle;
	angle_goal = current_angle;

func disable_focus():
	angle_change_goal = 0.0;
	super.disable_focus()


# -- Extra computations - for visuals and/or deeper calculation ---------
# =======================================================================

@export var VISUAL_HAMMER:Node3D;

@export_range(-360, 360, 1.0, "radians_as_degrees") var MIN_ANGLE = 0;
@export_range(-360, 360, 1.0, "radians_as_degrees") var MAX_ANGLE = 2*PI/3;

##Starting angle
@export var current_angle:float = 0;

@export_group("Mechanism")
##Spring force, arbitrary units. Constant.
@export var SPRING_FORCE:float = 0.0;
##Gravity force, arbitrary units. Dependent on angle player is lookign at.
@export var GRAVITY_FORCE:float = 0.0;

## 0 -> 1 = 0 -> MAX_ANGLE
@export var FOCUS_RESISTANCE_CURVE:Curve;

@export var ELASTICITY_TOP:float = 0.2;
@export var ELASTICITY_BOTTOM:float = 0.1;


##Maximum mouse torque. Beyond this point, will be capped as if.
@export var MAX_MOUSE_TORQUE_DIST:float = 0.1;


var current_angular_velocity:float;

func _ready2():
	if(FOCUS_RESISTANCE_CURVE == null):
		push_error("No Resistance Curve set.")
	elif(FOCUS_RESISTANCE_CURVE.point_count <= 0):
		push_warning("No points set on Resistance Curve.")
		FOCUS_RESISTANCE_CURVE.add_point(Vector2(0, 0.1));

func _process2():
	if(VISUAL_HAMMER != null):
		VISUAL_HAMMER.transform.basis = Basis.IDENTITY
		VISUAL_HAMMER.rotate_object_local(ROTATION_AXIS, current_angle)


func _physics_process(delta:float) -> void:
	
	if(is_focused): #Manual controls
		current_angular_velocity = 0; # make it grabbed
		#Glorified lerp, following curve to add resistance
		var follow_delta = (angle_goal - current_angle) * min(FOCUS_RESISTANCE_CURVE.sample(current_angle/MAX_ANGLE), 0.8)
		current_angle += follow_delta
		
		
		current_angle = max(min(current_angle, MAX_ANGLE), 0);
		
		
	else:
		var forces:float = -SPRING_FORCE
		forces += GRAVITY_FORCE * cos(acos(global_basis.y.dot(Vector3.UP)) + current_angle); # gravity calculation
		
		#Initial checks:
		if(current_angle <= MIN_ANGLE and current_angular_velocity >= 0): # Previously...
			current_angle = MIN_ANGLE
			current_angular_velocity = 0;
			if(forces > 0): # if forces will push it away ,
				current_angular_velocity += forces*delta;
				
		elif(current_angle >= MAX_ANGLE and current_angular_velocity <= 0):
			current_angle = MAX_ANGLE
			current_angular_velocity = 0;
			if(forces < 0): # if forces will push it away
				current_angular_velocity += forces*delta;
		else: # Not anywhere in particular - between MIN and MAX
			current_angular_velocity += forces*delta;
		
		
		current_angle += current_angular_velocity
		
		if(current_angle <= MIN_ANGLE and current_angular_velocity < 0): # if JUST hit the wall
			print(current_angular_velocity)
			current_angle = MIN_ANGLE;
			
			hit_min_angle(current_angular_velocity)
			
			current_angular_velocity *= -ELASTICITY_TOP;
		
		if(current_angle >= MAX_ANGLE and current_angular_velocity > 0): # if JUST hit the wall
			print(current_angular_velocity)
			current_angle = MIN_ANGLE;
			
			hit_max_angle(current_angular_velocity)
			
			current_angular_velocity *= -ELASTICITY_TOP;
		


##Function is called when the mechanism hits the {angle==zero} position
func hit_min_angle(speed:float) -> void:
	pass
##Function is called when the mechanism hits the {angle==MAX} position
func hit_max_angle(speed:float) -> void:
	pass
