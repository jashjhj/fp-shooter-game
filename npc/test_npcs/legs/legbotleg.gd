class_name LegBotLeg extends Node3D

#Rigidbody sibling to attach to - Must be set at runtime by parent.
@export var BODY:RigidBody3D;

@export var UPPER:Node3D;
@export var LOWER:Node3D;
@export var UPPER_LENGTH:float = 1.0;
@export var LOWER_LENGTH:float = 1.0;

@export var FOOT:RigidBody3D;
@export var FOOT_PHYSLERP:Physics_Lerper;

@export var LOWER_HIT:Hit_Component;
@export var UPPER_HIT:Hit_Component;

@onready var IKCALC:IK_Leg_Abstract = IK_Leg_Abstract.new()
#@onready var DOWN_RAY:RayCast3D = RayCast3D.new()

@export var logging:bool = false;

##Denotes as to whether it is being fully-physically-simulated or locked and stable.


var is_physical:bool = true:
	set(value):
		is_physical = value;
		if(is_physical):
			FOOT.freeze = false;
			FOOT_PHYSLERP.enabled = true;
		else:
			FOOT.freeze = true
			FOOT_PHYSLERP.enabled = false;


var is_stable:bool = false;

@export var TARGET:Node3D;


#enum CurrentState{
	#STABLE,
	#UNSTABLE,
	#SEEKING,
	#MOVING
#}


signal became_stable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	IKCALC.UPPER_LENGTH = UPPER_LENGTH;
	IKCALC.LOWER_LENGTH = LOWER_LENGTH;
	IKCALC.ELBOW_IN = true
	
	
	#DOWN_RAY.target_position = Vector3(0, -2.5, 0)
	
	await get_parent().ready
	
	FOOT.top_level = true
	UPPER_HIT.on_hit.connect(upper_hit)
	LOWER_HIT.on_hit.connect(lower_hit)
	UPPER_HIT.on_hit.connect(generic_hit)
	LOWER_HIT.on_hit.connect(generic_hit)
	
	TARGET.reparent(BODY)
	TARGET.top_level = true


#------------ IMPLUSE REDISTRIBUTION -------------#
func upper_hit():
	var pos = UPPER_HIT.last_impulse_pos
	var along = pos.dot(-UPPER.global_basis.z) / UPPER_LENGTH
	along = min(1.0, max(0.0, along))
	#Along is in the range 0 @ hip -> 1 at knee
	along -= 1.0;
	distribute_impulse(UPPER_HIT.last_impulse, along)
func lower_hit():
	var pos = LOWER_HIT.last_impulse_pos
	var along = pos.dot(-LOWER.global_basis.z) / LOWER_LENGTH
	along = min(1.0, max(0.0, along))
	#Along is in the range 0 @ knee -> 1 at toes
	distribute_impulse(LOWER_HIT.last_impulse, along)

##Along is a measure of hwo far along the impulse is: -1:Hip, 0:Knee, 1:Toes
func distribute_impulse(impulse:Vector3, along:float):
	#Lines: Vert is through foot to hip, Forward is into the crux of the knee, (ie. would buckle it), perpendicular is the axis by which the knee rotates
	var vert:Vector3 = (global_position - FOOT.global_position).normalized()
	var perpendicular:Vector3 = LOWER.global_basis.x
	var forwards:Vector3 = UPPER.global_basis.y.slerp(LOWER.global_basis.y, 0.5) # Middle angle is into crux of knee
	
	var cmp_vert:Vector3 = impulse.dot(vert) * vert
	var cmp_forward:Vector3 = impulse.dot(forwards) * forwards
	var cmp_perp:Vector3 = impulse.dot(perpendicular) * perpendicular
	
	##Resultant forces
	var resultant_top:Vector3 = Vector3.ZERO
	var resultant_bottom:Vector3 = Vector3.ZERO
	
	#PERPENDICULAR
	var proportion_top:float = 1.0 - (along + 1.0) / 2.0
	
	resultant_top += cmp_perp * proportion_top
	resultant_bottom += cmp_perp * (1-proportion_top)
	
	#VERTICAL
	resultant_top += cmp_vert * proportion_top
	resultant_bottom += cmp_vert * (1-proportion_top)
	
	#Forwards
	resultant_top += cmp_forward * proportion_top
	resultant_bottom += cmp_forward * (1-proportion_top)
	
	var distance_to_knee = (1-abs(along));
	resultant_top += cmp_forward.length() * -vert * distance_to_knee * 3 # Push it down too
	resultant_bottom -= cmp_forward.length() * -vert * distance_to_knee  # Push it up because impulse, can cause leg to jolt interestingly
	
	#APPLY
	BODY.apply_impulse(resultant_top, global_position - BODY.global_position)
	FOOT.apply_impulse(resultant_bottom)
	


##Called upon any hit
func generic_hit():
	is_physical = true



func is_on_floor() -> bool:
	var contacts = FOOT.get_colliding_bodies()
	for body in contacts:
		if(body is StaticBody3D or body is CSGBox3D): # If foot is colliding with a staticbody, YES is on floor
			return true;
	#Else, no staticbody in contact
	return false;


func update_leg() -> void:
	
	var global_target_delta:Vector3 = FOOT.global_position - global_position
	var local_target_delta:Vector3 = global_basis.inverse()*global_target_delta
	
	#if(!is_stable): return
	
	var ik = IKCALC.calculate_IK_nodes(local_target_delta, Vector3.DOWN)
	UPPER.transform = ik.upper.transform
	LOWER.transform = ik.lower.transform
	#FOOT.transform = ik.end.transform




## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	update_leg()


func _physics_process(delta: float) -> void:
	
	if(is_physical):
		
		is_stable = is_on_floor()
		
		if(is_on_floor() and FOOT.linear_velocity.length() < 0.001): # If foot is stable
			#print("landed")
			#is_physical = false;
			pass
		else:# Physical, flailing
			var foot_forces:Vector3 = FOOT_PHYSLERP.apply_forces(delta)
			#BODY.apply_force(-foot_forces, global_position - BODY.global_position);
	
	#if(!is_on_floor()):print("n")
	
	
	
	var foot_vector = FOOT.global_position - global_position
	if(foot_vector.length() > UPPER_LENGTH + LOWER_LENGTH): # If foot trying to escape
		FOOT.global_position = global_position + foot_vector.normalized() * (UPPER_LENGTH + LOWER_LENGTH)
		FOOT.linear_velocity += FOOT.linear_velocity.dot(foot_vector.normalized()) * foot_vector.normalized() * -(1 + 0.4);
	
