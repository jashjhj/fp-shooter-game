class_name IK_Leg_Abstract extends Node

@export var UPPER_LENGTH:float = 1.0;
@export var LOWER_LENGTH:float = 1.0;

@export var ELBOW_IN:bool = false;


##IK_Leg_Abstract Return Class
class IKAngles:
	var hipyaw:float
	var hippitch:float
	var knee:float

class IKResults:
	var upper:Node3D = Node3D.new()
	var lower:Node3D = Node3D.new()
	var end:Node3D   = Node3D.new()

##Input is the delta-pos followed by a forwards vector. Must be in the same (local/global) space. Recommended local space.
## | +tive angles mean towards delta from forwards
func get_angles(delta:Vector3, axis:Vector3) -> IKAngles:
	axis = axis.normalized()
	
	var up:Vector3 = delta.cross(axis).normalized() # Initialise perpendicular vectors
	var forwards:Vector3 = up.cross(axis)
	
	
	var out:IKAngles = IKAngles.new()
	out.hipyaw = delta.signed_angle_to(-forwards, up)# atan2(delta.dot(axis), delta.dot(forwards))
	
	out.knee = -calculate_second_angle(delta.length_squared())
	out.hippitch = -calculate_first_angle(delta.length(), out.knee); #calculate_first_angle(Vector2(delta.dot(forwards), delta.dot(up)), out.knee);
	
	
	return out

###Helper: Calculates an appropriate up-vector from a forwards-vector
#func up_from_forwards(forwards:Vector3) -> Vector3:
	#var up:Vector3 = Vector3.UP  # Initialise perpendicular vectors
	#var right:Vector3 = Vector3.RIGHT
	#if(abs(up.dot(forwards)) < 0.9 ):# forwards isnt pointed towards up
		#right = up.cross(forwards)
		#up = -right.cross(forwards)
	#else: # Forwards is flatter
		#up = -right.cross(forwards)
		#right = up.cross(forwards)
	#return up.normalized()
#
###Helper: Calculates an appropriate right-vector from a forwards-vector
#func right_from_forwards(forwards:Vector3) -> Vector3:
	#var up:Vector3 = Vector3.UP  # Initialise perpendicular vectors
	#var right:Vector3 = Vector3.RIGHT
	#
	#
	#if(abs(up.dot(forwards)) < 0.9 ):# forwards isnt pointed towards up
		#right = up.cross(forwards)
		#up = -right.cross(forwards)
	#else: # Forwards is flatter
		#up = -right.cross(forwards)
		#right = up.cross(forwards)
	#return right.normalized()

##Forcibly set positions of UPPER and LOWER segments to conform to the IK. Forwards is usual forwards vector, ie. z-
func calculate_IK_nodes(delta:Vector3, axis:Vector3) -> IKResults:
	
	axis = axis.normalized(); # As z- is forwards in gdot, but param is true forwards vector.
	
	
	var angles:IKAngles = get_angles(delta, axis);
	
	
	var up:Vector3 = delta.cross(axis).normalized()
	var forwards:Vector3 = up.cross(axis)  # Initialise perpendicular vectors
	
	#print("f", forwards, "- u", up, "- r", right)
	
	var out:IKResults = IKResults.new()
	
	DebugDraw3D.draw_line(get_parent().global_position, get_parent().global_position + -forwards)
	DebugDraw3D.draw_line(get_parent().global_position, get_parent().global_position + delta, Color(0, 1, 0))
	DebugDraw3D.draw_line(get_parent().global_position, get_parent().global_position + up, Color(0, 0, 1))
	DebugDraw3D.draw_line(get_parent().global_position, get_parent().global_position + axis, Color(1, 0, 1))
	
	out.upper.basis.z = forwards
	out.upper.basis.y = up
	out.upper.basis.x = axis
	
	
	
	out.upper.rotate(axis, angles.hippitch)
	out.upper.rotate(up, -angles.hipyaw)
	
	out.lower.basis = out.upper.basis
	
	#out.lower.rotate(up, -angles.hipyaw)
	out.lower.rotate(axis.rotated(up, -angles.hipyaw), angles.knee)
	
	
	#out.lower.basis.z = forwards.rotated(axis, angles.knee)
	#out.lower.basis.y = up.rotated(axis, angles.knee)
	#out.lower.basis.x = axis;
	
	#out.lower.rotate(up, angles.hipyaw)
	
	out.lower.position = -out.upper.basis.z*UPPER_LENGTH
	
	out.end.position = out.lower.position -out.lower.basis.z*LOWER_LENGTH
	out.end.basis = out.lower.basis
	
	
	return out


##In radians, deflected angle @ joint. Elbow-up by default
func calculate_second_angle(distance_squared:float) -> float:
	var cos_angle = ((distance_squared - UPPER_LENGTH*UPPER_LENGTH - LOWER_LENGTH*LOWER_LENGTH)/(2*UPPER_LENGTH*LOWER_LENGTH))
	
	#if(abs(cos_angle) > 1): print("TOO FAR") # Its fine though, just stretches
	var angle = acos(cos_angle)
	
	if(!ELBOW_IN):
		return -abs(angle)
	
	else:
		return(abs(angle))

##In radians
func calculate_first_angle(distance:float, second_angle:float) -> float:
	#Also cosine rule, resolved for other angle
	#var angle = acos((LOWER_LENGTH*LOWER_LENGTH - UPPER_LENGTH*UPPER_LENGTH + distance_squared)/(2*sqrt(distance_squared) * UPPER_LENGTH))
	var angle = acos((UPPER_LENGTH + LOWER_LENGTH*cos(second_angle)) / distance)
	#var angle = acos(sqrt(distance_squared) / (LOWER_LENGTH*cos(second_angle) + UPPER_LENGTH))
	
	return angle;
