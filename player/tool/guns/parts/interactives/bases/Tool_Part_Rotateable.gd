class_name Tool_Part_Rotateable extends Tool_Part_Interactive_1D


@export var ROTATION_AXIS:Vector3 = Vector3.RIGHT;

@export var MODEL:Node3D;


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
	set_interact_plane_normal(ROTATION_AXIS) # looks perpendicularly to the rotation axis.
	



func _process(delta:float)->void:
	super._process(delta);
	
	if(is_focused):
		#print(get_mouse_plane_position())
		var next_focus_mouse_pos:Vector3 = get_mouse_plane_position() - global_position
		
		var clockwise_right_vector = previous_focus_mouse_pos.normalized().cross(INTERACT_PLANE.global_basis.z);
		angle_change_delta = asin(clockwise_right_vector.dot(next_focus_mouse_pos.normalized())) # Gets angle
		
		previous_focus_mouse_pos = next_focus_mouse_pos
		
		angle_change_goal += angle_change_delta
		angle_goal += angle_change_delta
		
		velocity = 0;
		#mouse_torque_radm = (angle_change_goal + start_focus_angle - DISTANCE) * min(next_focus_mouse_pos.length(), MAX_MOUSE_TORQUE_DIST);
		#print(torque_radm)
	
	if(MODEL != null):
		MODEL.transform.basis = Basis.IDENTITY
		MODEL.rotate_object_local(ROTATION_AXIS, DISTANCE)




func enable_focus():
	super.enable_focus()
	INTERACT_PLANE.global_position = mouse_focus_pos #get_viewport().get_camera_3d().get_mouse_ray(2, BEGIN_INTERACT_COLLISION_LAYER).get_collision_point();
	start_focus_mouse_pos = get_mouse_plane_position() - global_position;
	previous_focus_mouse_pos = start_focus_mouse_pos
	angle_change_goal = 0.0;
	start_focus_angle = DISTANCE;
	angle_goal = DISTANCE;

func disable_focus():
	angle_change_goal = 0.0;
	super.disable_focus()


# -- Extra computations - for visuals and/or deeper calculation ---------
# =======================================================================



#@export_range(-360, 360, 1.0, "radians_as_degrees") var MIN_ANGLE = 0.0;
#@export_range(-360, 360, 1.0, "radians_as_degrees") var MAX_ANGLE = 2*PI/3;



###Maximum mouse torque. Beyond this point, will be capped as if.
#@export var MAX_MOUSE_TORQUE_DIST:float = 0.1;



	
	


var forces:float = 0; # Outside of loop so can be altered by inherited functions
func _physics_process(delta:float) -> void:
	
	if(is_focused): #Manual controls
		velocity = 0; # make it grabbed
		#Glorified lerp, following curve to add resistance
		var follow_delta = (angle_goal - DISTANCE)# * min(FOCUS_RESISTANCE_CURVE.sample(DISTANCE/functional_max), 0.8)
		DISTANCE += follow_delta
		
		
		#DISTANCE = max(min(DISTANCE, functional_max), functional_min);
	super._physics_process(delta)
