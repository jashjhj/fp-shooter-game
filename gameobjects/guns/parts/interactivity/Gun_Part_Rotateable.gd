class_name Gun_Part_Rotateable extends Gun_Part_Interactive

##This is what is rotated. The collider should (usually) be a child of the Rotateable
@export var ROTATEABLE:Node3D;

@export var ROTATION_AXIS:Vector3 = Vector3.RIGHT;


var start_focus_mouse_pos:Vector3;

func _ready1():
	ROTATION_AXIS = ROTATION_AXIS.normalized()
	INTERACT_PLANE.position = Vector3(0,0,0);
	INTERACT_PLANE.look_at(global_position + global_transform.basis * ROTATION_AXIS) # looks perpendicularly to the rotation axis.



func _process(_delta:float)->void:

	if(is_focused):
		var angle = get_angle_abc(get_mouse_plane_position() ,Vector3.ZERO, start_focus_mouse_pos)
		print(angle)
	




func enable_focus():
	start_focus_mouse_pos = get_mouse_plane_position();

func disable_focus():
	pass


##Gets angle ABC from A, B, C
func get_angle_abc(a:Vector3, b:Vector3, c:Vector3) -> float:
	var A = (a-c).length();#opposite
	var B = (b-a).length();
	var C = (b-c).length();
	var angle = acos((B*B+C*C-A*A)/(2*B*C))
	return angle
