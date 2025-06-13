class_name IK_Leg extends Node3D

@export var UPPER_LEG:Node3D;
@export var LOWER_LEG:Node3D;
@export var UPPER_LEG_LENGTH:float = 0.2;
@export var LOWER_LEG_LENGTH:float = 0.4;


#@export var SKEW:float = 0.0; #Not yet implemented

#IK LEG
# set_leg_target(global pos, on ground) to set position
# On ground makes it interpolate linearly, otheerwise adds a curve to it.
# set_leg_stationary() - Set position as is.
# set_leg_progress(progress) - interpolates leg with float progress 0->1



func _ready() -> void:
	assert(UPPER_LEG != null, "No upper-leg set")
	assert(LOWER_LEG != null, "No lower-leg set")
	


var following_ground:bool = true

#Default pos @ start
@onready var prev_pos:Vector3 = global_position + Vector3(0, UPPER_LEG_LENGTH - LOWER_LEG_LENGTH, 0);
var goal_pos:Vector3;

func set_leg_target(target:Vector3, on_ground:bool = true ):
	following_ground = on_ground
	prev_pos = goal_pos
	goal_pos = target;



func set_leg_stationary():
	following_ground = true;
	prev_pos = goal_pos
	



func set_leg_progress(progress:float) -> float:
	var target = to_local(prev_pos).lerp(to_local(goal_pos), progress)
	
	if(!following_ground):
		target.y += 0.05*sin(PI*progress)
		target.z -= 0.1*sin(PI*progress)*sin(PI*progress)
	
	return set_leg_ik(target)





func set_leg_ik(pos:Vector3) -> float:
	
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
	
	
	if(relative_pos_3d.z != 0):
		UPPER_LEG.rotate(Vector3.UP, atan(relative_pos_3d.x/relative_pos_3d.z)) # put in plane with point
	#UPPER_LEG.rotate(Vector3.FORWARD, SKEW)
	
	
	
	LOWER_LEG.basis.z = -Vector3.FORWARD.rotated(Vector3.RIGHT, a1+a2)
	LOWER_LEG.basis.y = Vector3.UP.rotated(Vector3.RIGHT, a1+a2)
	LOWER_LEG.basis.x = Vector3.RIGHT;
	
	if(relative_pos_3d.z != 0):
		LOWER_LEG.rotate(Vector3.UP, atan(relative_pos_3d.x/relative_pos_3d.z)) #put in plane with point
	#LOWER_LEG.rotate(Vector3.FORWARD, SKEW)
	
	LOWER_LEG.position = -UPPER_LEG.basis.z*UPPER_LEG_LENGTH
	return PI - a2 # Returns crux angle

func calculate_second_angle(distance_squared:float) -> float:
	var cos_angle = ((distance_squared - UPPER_LEG_LENGTH*UPPER_LEG_LENGTH - LOWER_LEG_LENGTH*LOWER_LEG_LENGTH)/(2*UPPER_LEG_LENGTH*LOWER_LEG_LENGTH))
	
	#if(abs(cos_angle) > 1): print("TOO FAR") # Its fine though, just stretches
	var angle = acos(cos_angle)
	
	
	if (angle > 0): # Always return negative for 'elbow-up'
		return -angle
	else:
		return angle

func calculate_first_angle(target_position:Vector2, second_angle:float) -> float:
	var angle = atan2(target_position.y,target_position.x) - atan2(LOWER_LEG_LENGTH*sin(second_angle),(UPPER_LEG_LENGTH + LOWER_LEG_LENGTH*cos(second_angle)))
	if(angle != NAN):
		return angle;
	return 0
