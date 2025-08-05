class_name Rotator_1D extends Body_Segment

@export_category("Rotation axis = around the local Y+")

@export_group("Rotation Settings")
##Maximum degrees/Second
@export_range(0, 360, 0.1, "radians_as_degrees") var ROTATION_MAX_SPEED:float = 1.0;
##In rads/second/second
@export var ROTATION_ACCELERATION:float = 1.0;

@export var ANGLE_LIMITS_ENABLED:bool = false
@export_range(-180, 180, 1.0, "radians_as_degrees") var MIN_ANGLE = -PI/4; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var MAX_ANGLE = PI/4;

##Amount of slop allowed. If Zero, does the ebst it can without jittering.
@export_range(0, 30, 0.1, "radians_as_degrees") var SLOP:float = 0.0;



@export var IS_ACTIVE:bool = true;

@export_group("Optional Settings")
@export var ATTACHED_RB:RigidBody3D;
##Also used for rotational impulses from super class.
@export var SIMULATED_MASS_ABOVE:float = 1.0;



@export var DEBUG_AXES:bool = false;




var current_angle:float = 0.0;
var current_speed:float = 0.0;

##A vector representing which way this Rotator_1D should look towards (-z) || In GLOBAL Space
var target:Vector3:
	set(v):
		target = v;
		#Cannot set target-global as leads to inf. recursion. Also no need as thats onyl really extenral for convenience ofs etting
		#target_global = v + global_position

##Abject global position of the target.
var target_global:Vector3:
	set(v):
		target_global = v;
		target = v - global_position

func _ready() -> void:
	super()
	target = Vector3.INF


func _process(delta: float) -> void:
	pass



func _physics_process(delta: float) -> void:
	if(!IS_ACTIVE or target == Vector3.INF): return
	
	#                                           target component that is perpendiculr to basis.y
	var angle = global_basis.z.signed_angle_to(target - global_basis.y* target.dot(global_basis.y), global_basis.y)
	
	var angle_to_turn:float;
	
	
	if(DEBUG_AXES):
		DebugDraw3D.draw_position(global_transform)
		print(abs(angle), " = angle, speed = ", ROTATION_MAX_SPEED * delta)
	
	#ROTATION CODE
	
	var max_speed:float = sqrt(abs(2*angle * ROTATION_ACCELERATION * delta)) * 0.8
	var projected_delta_speed:float = ROTATION_ACCELERATION * delta * sign(angle);
	
	if(abs(current_speed + projected_delta_speed) > max_speed):
		
		var goal_dv = sign(angle)*max_speed - (current_speed)
		projected_delta_speed = sign(goal_dv) * min(abs(goal_dv), ROTATION_ACCELERATION * delta) # accel to get it back to right speed
		
		#current_speed = sign(angle)*max_speed
		#projected_delta_speed = 0
		#Limit it abck down to max accel
		projected_delta_speed = sign(projected_delta_speed) * min(ROTATION_ACCELERATION * delta, abs(projected_delta_speed))
	
	current_speed += projected_delta_speed
	
	
	
	angle_to_turn = current_speed
	
	
	
	if(abs(angle) < SLOP):
		angle_to_turn = 0;
	#
	#if(abs(angle) < ROTATION_MAX_SPEED * delta * 1.5): ## prevent jittering by not turning if close.
		#angle_to_turn = 0;
		#
	#
	
	
	#angle_to_turn = TURN_SPEED * delta
	
	if(ANGLE_LIMITS_ENABLED):
		if(current_angle + angle_to_turn > MAX_ANGLE):
			angle_to_turn = MAX_ANGLE - current_angle
			current_angle = MAX_ANGLE
		
		elif(current_angle + angle_to_turn < MIN_ANGLE):
			angle_to_turn = MIN_ANGLE - current_angle
			current_angle = MIN_ANGLE
		else:
			current_angle += angle_to_turn
	
	rotate(basis.y, angle_to_turn)
	
	if(ATTACHED_RB != null): # Equal and opposite type stuff
		ATTACHED_RB.apply_torque(-projected_delta_speed * Vector3.UP * SIMULATED_MASS_ABOVE)
	
	spin(angle_to_turn)

##Called every frame _process()
func spin(angle_to_turn:float):
	pass
	
