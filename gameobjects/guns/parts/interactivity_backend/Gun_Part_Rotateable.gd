class_name Gun_Part_Rotateable extends Gun_Part_Interactive


@export var ROTATION_AXIS:Vector3 = Vector3.LEFT;

##Maximum mouse torque. Beyond this point, will be capped as if.
@export var MAX_MOUSE_TORQUE_DIST:float = 0.1;


var start_focus_mouse_pos:Vector3;
var previous_focus_mouse_pos:Vector3;
var start_focus_angle:float = 0;
var angle_change_goal:float = 0;
var angle_goal:float = 0;
var angle_change_delta:float = 0;


@export var current_angle:float = 0;
## In rad*m = radians being pulled at distance in m
var mouse_torque_radm:float = 0;

func _ready():
	super._ready();
	ROTATION_AXIS = ROTATION_AXIS.normalized()
	INTERACT_PLANE.position = Vector3(0,0,0);
	INTERACT_PLANE.look_at(global_position + global_transform.basis * ROTATION_AXIS) # looks perpendicularly to the rotation axis.



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
