class_name Crawler_Leg extends Node3D

@export var UPPER_LEG:Node3D;
@export var LOWER_LEG:Node3D;
@export var UPPER_LEG_LENGTH:float = 0.2;
@export var LOWER_LEG_LENGTH:float = 0.4;

#@export var SKEW:float = 0.0; #Not yet implemented
#@export var CURRENT_TARGET:Node3D;


func _ready() -> void:
	assert(UPPER_LEG != null, "No upper-leg set")
	assert(LOWER_LEG != null, "No lower-leg set")


var step_magnitude:float = 0.2;
func update_leg_slerp(from:Node3D, to:Node3D, progress:float):
	var from_pos:Vector3 = to_local(from.global_position)
	var to_pos:Vector3 = to_local(to.global_position)
	
	var target:Vector3 = (from_pos).lerp(to_pos, progress)
	
	target.y += 0.05*sin(PI*progress)
	target.z -= 0.2*sin(PI*progress)
	
	set_leg_ik(target)
	

func update_leg_ik(target:Node3D):
	set_leg_ik(to_local(target.global_position))



func set_leg_ik(pos:Vector3):
	
	var relative_pos_3d = pos
	
	var relative_pos:Vector2;
	relative_pos.x = (relative_pos_3d*Vector3(1,0,1)).length()
	if(relative_pos_3d.z > 0): relative_pos.x *= -1 # Makes it the right sign, so can touch target under body
	relative_pos.y = relative_pos_3d.dot(Vector3.UP)#.rotated(Vector3.FORWARD, SKEW)
	
	var a2 := calculate_second_angle(relative_pos_3d.length_squared())
	var a1 := calculate_first_angle(relative_pos, a2)

	
	UPPER_LEG.basis.z = -Vector3.FORWARD.rotated(Vector3.RIGHT, a1)
	UPPER_LEG.basis.y = Vector3.UP.rotated(Vector3.RIGHT, a1)
	UPPER_LEG.basis.x = Vector3.RIGHT;
	

	UPPER_LEG.rotate(Vector3.UP, atan(relative_pos_3d.x/relative_pos_3d.z)) # put in plane with point
	#UPPER_LEG.rotate(Vector3.FORWARD, SKEW)
	
	
	LOWER_LEG.basis.z = -Vector3.FORWARD.rotated(Vector3.RIGHT, a1+a2)
	LOWER_LEG.basis.y = Vector3.UP.rotated(Vector3.RIGHT, a1+a2)
	LOWER_LEG.basis.x = Vector3.RIGHT;
	
	
	LOWER_LEG.rotate(Vector3.UP, atan(relative_pos_3d.x/relative_pos_3d.z)) #put in plane with point
	#LOWER_LEG.rotate(Vector3.FORWARD, SKEW)
	
	LOWER_LEG.position = -UPPER_LEG.basis.z*UPPER_LEG_LENGTH

func calculate_second_angle(distance_squared:float) -> float:
	var cos_angle = ((distance_squared - UPPER_LEG_LENGTH*UPPER_LEG_LENGTH - LOWER_LEG_LENGTH*LOWER_LEG_LENGTH)/(2*UPPER_LEG_LENGTH*LOWER_LEG_LENGTH))
	
	#if(abs(cos_angle) > 1): print("TOO FAR") # Its fine though, just stretches
	var angle = acos(cos_angle)
	
	if (angle > 0): # Always return positive for 'elbow-down'
		return -angle
	else:
		return angle

func calculate_first_angle(target_position:Vector2, second_angle:float) -> float:
	return atan2(target_position.y,target_position.x) - atan2(LOWER_LEG_LENGTH*sin(second_angle),(UPPER_LEG_LENGTH + LOWER_LEG_LENGTH*cos(second_angle)))
