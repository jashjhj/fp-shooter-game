class_name BotLeg extends Node3D

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
@onready var PROPAGATION_HELPER:Node3D = Node3D.new()

@export var VERT_IMPULSE_TO_UPROOT:float = 1.0;

@export var logging:bool = false;

##Denotes as to whether it is being fully-physically-simulated or locked and stable.


var is_physical:bool = true:
	set(value):
		is_physical = value;
		if(is_physical):
			FOOT.freeze = false;
		else:
			FOOT.freeze = true


# If stable, attached to floor UNTIl pushed up. If not stable, attached to body and any deltas will be appliead appropriately

var is_stable:bool = false;
## 0 == Not currently Stepping, 1 == Locating, 2 == Planting
var step_state:int = 0:
	set(v):
		if(v == 0):
			FOOT_PHYSLERP.enabled = false
		elif v == 1:
			FOOT_PHYSLERP.enabled = true
		elif v == 2:
			FOOT_PHYSLERP.enabled = true
		else:
			push_error("Attempted tos et step_state of a leg to a value not in the range 0,1,2")
			return
		step_state = v
var step_start:int;
var step_height:float = 0;
@onready var STEP_TARGET:Node3D = Node3D.new()

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
	
	add_child(PROPAGATION_HELPER)
	propagate_motion(false)
	
	add_child(STEP_TARGET)
	FOOT_PHYSLERP.TARGET = STEP_TARGET
	STEP_TARGET.global_position = TARGET.global_position




## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	update_leg()

func update_leg() -> void:
	
	var global_target_delta:Vector3 = FOOT.global_position - global_position
	var local_target_delta:Vector3 = global_basis.inverse()*global_target_delta
	
	#if(!is_stable): return
	
	var ik = IKCALC.calculate_IK_nodes(local_target_delta, Vector3.DOWN)
	UPPER.transform = ik.upper.transform
	LOWER.transform = ik.lower.transform
	#FOOT.transform = ik.end.transform


func begin_step(pos:Vector3 = TARGET.global_position):
	step_state = 1;
	step_start = Time.get_ticks_msec()
	step_height = tanh((pos - FOOT.global_position).length())

func _physics_process(delta: float) -> void:
	
	#print(step_state)
	if(!is_physical): return # used to disable, for optimisation.
	
	
	
	if(is_on_floor() and FOOT.linear_velocity.length() < 0.001): # If foot is now stable
		#step_state = 0;
		is_stable = true
		#print("landed")
		#is_physical = false;
		
	else:
		is_stable = false
	
	# Physical, flailing, stepping
	
	#Stepping computation
	#print("m")
	if(step_state == 1):
		STEP_TARGET.global_position = TARGET.global_position + Vector3.UP * 0.3
		var dist_to_target:float = ((FOOT.global_position - STEP_TARGET.global_position) * Vector3(1,0,1)).length()
		 # State exits
		if(dist_to_target < 0.04):
			step_state = 2
		elif (Time.get_ticks_msec() - step_start > 400): # >400ms have passed
			step_state = 0;
		
	elif step_state == 2:
		STEP_TARGET.global_position = TARGET.global_position + Vector3.UP * -0.35
		if(is_stable):
			step_state = 0;
		pass
	else:
		STEP_TARGET.global_position = TARGET.global_position
	
	
	propagate_motion(!is_stable and is_physical)
	
	if(logging):
		FOOT_PHYSLERP.enabled
	
	impose_footpos_limits()
	

##Impulse; global position at which hit-limit occured.
signal hit_limit(impulse, pos)

func impose_footpos_limits():
	var foot_vector = FOOT.global_position - global_position
	var rebound_coefficient:float = 0.4
	
	#Outer limit
	var max_extension:float = UPPER_LENGTH + LOWER_LENGTH
	if(foot_vector.length() > max_extension): # If foot trying to escape
		FOOT.global_position = global_position + foot_vector.normalized() * (max_extension)
		
		hit_limit.emit(FOOT.linear_velocity * -(1+rebound_coefficient) * FOOT.mass, FOOT.global_position)
		FOOT.linear_velocity += FOOT.linear_velocity.dot(foot_vector.normalized()) * foot_vector.normalized() * -(1 + rebound_coefficient); # Rebound. Here, e=0.4
	
	
	#Inner Limit
	var min_extension:float = 0.08 * (UPPER_LENGTH + LOWER_LENGTH)
	if(foot_vector.length() < min_extension): # If foot trying to escape
		#FOOT.global_position = global_position + foot_vector.normalized() * (min_extension)
		
		hit_limit.emit(FOOT.linear_velocity * -(1+rebound_coefficient) * FOOT.mass, FOOT.global_position)
		FOOT.linear_velocity += FOOT.linear_velocity.dot(foot_vector.normalized()) * foot_vector.normalized() * -(1 + rebound_coefficient); # Rebound. Here, e=0.4
	
	
	






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
	apply_foot_impulse(resultant_bottom)
	


##Called upon any hit
func generic_hit():
	is_physical = true

##Force is in global coords. Applies foot force if it would 'uproot the foot.
func apply_foot_force(force:Vector3):
	if(is_stable):
		FOOT.apply_central_force(force)
	
	else:
		FOOT.apply_central_force(force)

func apply_foot_impulse(impulse:Vector3):
	if(is_stable):
		if(impulse.y > VERT_IMPULSE_TO_UPROOT or true):
			is_stable = false;
			FOOT.apply_central_impulse(impulse)
	
	else:
		FOOT.apply_central_impulse(impulse)


func is_on_floor() -> bool:
	var contacts = FOOT.get_colliding_bodies()
	for body in contacts:
		if(body is StaticBody3D or body is CSGBox3D): # If foot is colliding with a staticbody, YES is on floor
			return true;
	#Else, no staticbody in contact
	return false;


var prop_old_pos:Vector3;
##Must be called each 'tick' to get accurate deltas. if arg == true, actually updates position.
func propagate_motion(propagating:bool = true):
	if(!propagating):
		prop_old_pos = PROPAGATION_HELPER.global_position
		return
	
	
	var delta_pos:Vector3 = PROPAGATION_HELPER.global_position - prop_old_pos
	
	FOOT.global_position += delta_pos
	
	prop_old_pos = PROPAGATION_HELPER.global_position
