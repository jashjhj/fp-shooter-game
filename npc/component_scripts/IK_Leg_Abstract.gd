class_name IK_Leg_Abstract extends Node

@export var UPPER_LENGTH:float = 1.0;
@export var LOWER_LENGTH:float = 1.0;



##IK_Leg_Abstract Return Class
class IKAngles:
	var hipyaw:float
	var hippitch:float
	var knee:float


##Input is the delta-pos followed by a forwards vector. Must be in the same (local/global) space. Recommended local space.
## | +tive angles mean towards delta from forwards
func get_angles(delta:Vector3, forwards:Vector3 = Vector3.FORWARD) -> IKAngles:
	forwards = forwards.normalized()
	
	var up:Vector3 = Vector3.UP  # Initialise perpendicular vectors
	var right:Vector3 = Vector3.RIGHT
	if(abs(up.dot(forwards)) > 0.9):# forwards is pointed towards up
		right = up.cross(forwards)
		up = -right.cross(forwards)
	else: # Forwards is flatter
		up = -right.cross(forwards)
		right = up.cross(forwards)
	
	var out:IKAngles = IKAngles.new()
	out.hipyaw = atan2(delta.dot(right), delta.dot(forwards))
	
	out.knee = calculate_second_angle(delta.length_squared())
	out.hippitch = calculate_first_angle(Vector2(delta.dot(forwards), delta.dot(up)), out.knee);
	
	
	return out

##In radians, deflected angle @ joint. Elbow-up by default
func calculate_second_angle(distance_squared:float) -> float:
	var cos_angle = ((distance_squared - UPPER_LENGTH*UPPER_LENGTH - LOWER_LENGTH*LOWER_LENGTH)/(2*UPPER_LENGTH*LOWER_LENGTH))
	
	#if(abs(cos_angle) > 1): print("TOO FAR") # Its fine though, just stretches
	var angle = acos(cos_angle)
	
	
	if (angle > 0): # Always return negative for 'elbow-up'
		return -angle
	else:
		return angle

##In radians. Target position should be: (cmp. along forwards, cmp. along upvector)
func calculate_first_angle(target_position:Vector2, second_angle:float) -> float:
	var angle = atan2(target_position.y,target_position.x) - atan2(LOWER_LENGTH*sin(second_angle),(UPPER_LENGTH + LOWER_LENGTH*cos(second_angle)))
	if(angle != NAN):
		return angle;
	return 0
