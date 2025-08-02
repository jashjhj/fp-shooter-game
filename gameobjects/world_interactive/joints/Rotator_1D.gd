class_name Rotator_1D extends Node3D

@export_category("Rotation axis = around the local Y+")

##Maximum degrees/Second
@export_range(0, 360, 0.1, "radians_as_degrees") var ROTATION_SPEED:float = 1.0;

@export var ANGLE_LIMITS_ENABLED:bool = false
@export_range(-180, 180, 1.0, "radians_as_degrees") var MIN_ANGLE = -PI/4; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var MAX_ANGLE = PI/4;

##Amount of slop allowed. If Zero, does the ebst it can without jittering.
@export_range(0, 30, 0.1, "radians_as_degrees") var SLOP:float = 0.0;

##otherwise, it lerps.
@export var IS_HINGE_SPEED_LINEAR:bool = true;

@export var IS_ACTIVE:bool = true;
@export var DEBUG_AXES:bool = false;


var current_angle:float = 0.0;

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
	target = Vector3.INF


func _process(delta: float) -> void:
	if(!IS_ACTIVE or target == Vector3.INF): return
	
	#                                           target component that is perpendiculr to basis.y
	var angle = global_basis.z.signed_angle_to(target - global_basis.y* target.dot(global_basis.y), global_basis.y)
	
	var angle_to_turn;
	
	
	if(DEBUG_AXES):
		DebugDraw3D.draw_position(global_transform)
		print(abs(angle), " = angle, speed = ", ROTATION_SPEED * delta)
	
	
	if(IS_HINGE_SPEED_LINEAR):
		
		angle_to_turn = sign(angle) * min(abs(angle), ROTATION_SPEED*delta)
		
		
		
		
		if(abs(angle) < SLOP):
			angle_to_turn = 0;
		
		if(abs(angle) < ROTATION_SPEED * delta * 1.5): ## prevent jittering by not turning if close.
			angle_to_turn = 0;
		
	else:
		angle_to_turn = angle * ROTATION_SPEED * delta
	
	
	
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
	spin(angle_to_turn)

##Called every frame _process()
func spin(angle_to_turn:float):
	pass
