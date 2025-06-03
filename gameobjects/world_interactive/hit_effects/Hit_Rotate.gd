class_name Hit_Rotate extends Hit_Component

@export var OBJECT:Node3D;
@export var HINGE_MULT:float = 0.5;

@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_x:float = -PI/6; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_x:float = PI/6;
@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_y:float = -PI/6; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_y:float = PI/6; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_z:float = -PI/6; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_z:float = PI/6; 

var cumulative_angle_x:float = 0;
var cumulative_angle_y:float = 0;
var cumulative_angle_z:float = 0;

func hit(damage):
	if(last_impulse == Vector3.ZERO or last_impulse_pos == Vector3.ZERO) : return # No impulse applied? Ignore
	
	var hit_offset:Vector3 = (last_impulse_pos - OBJECT.global_position)
	var up:Vector3 = OBJECT.global_basis.y
	var right:Vector3 = OBJECT.global_basis.x
	var forwards:Vector3 = -OBJECT.global_basis.z
	
	var y_moment:float = last_impulse.dot(up) *       cos(asin(hit_offset.normalized().dot(up)))       * hit_offset.length()
	var x_moment:float = last_impulse.dot(right) *    cos(asin(hit_offset.normalized().dot(right)))    * hit_offset.length()
	var z_moment:float = last_impulse.dot(forwards) * cos(asin(hit_offset.normalized().dot(forwards))) * hit_offset.length()
	
	y_moment *= HINGE_MULT
	x_moment *= HINGE_MULT
	z_moment *= HINGE_MULT
	
	cumulative_angle_y += y_moment
	cumulative_angle_x += x_moment
	cumulative_angle_z += z_moment
	
	#Accumulation limits ---------------- i couldnt think of a ncier way to do this, sorry
	if(cumulative_angle_y > max_hinge_y):
		y_moment -= cumulative_angle_y - max_hinge_y;
		cumulative_angle_y = max_hinge_y;
	elif (cumulative_angle_y < min_hinge_y):
		y_moment -= cumulative_angle_y - min_hinge_y
		cumulative_angle_y = min_hinge_y
	
	if(cumulative_angle_x > max_hinge_x):
		x_moment -= cumulative_angle_x - max_hinge_x;
		cumulative_angle_x = max_hinge_x;
	elif (cumulative_angle_x < min_hinge_x):
		x_moment -= cumulative_angle_x - min_hinge_x
		cumulative_angle_x = min_hinge_x
	
	if(cumulative_angle_z > max_hinge_z):
		z_moment -= cumulative_angle_z - max_hinge_z;
		cumulative_angle_z = max_hinge_z;
	elif (cumulative_angle_z < min_hinge_z):
		z_moment -= cumulative_angle_z - min_hinge_z
		cumulative_angle_z = min_hinge_z
	
	
	
	
	
	OBJECT.rotate_object_local(Vector3.RIGHT, y_moment)
	OBJECT.rotate_object_local(Vector3.UP, -x_moment)
	OBJECT.rotate_object_local(Vector3.FORWARD, -z_moment)
