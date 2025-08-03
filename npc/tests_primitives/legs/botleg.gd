class_name BotLeg extends Node3D

##Rigidbody sibling to attach to - Must be set at runtime by parent.
var BODY:RigidBody3D:
	set(v):
		BODY = v;
		TARGET.reparent(BODY)
		
		for i in IMPULSE_TO_BODY: # Updates target
			i.IMPULSE_TO = BODY

@export var UPPER:Node3D;
@export var LOWER:Node3D;
@export var UPPER_LENGTH:float = 1.0;
@export var LOWER_LENGTH:float = 1.0;

@export var INVERT_KNEE:bool = false

@export var FOOT:RigidBody3D;


@export var LOWER_HITCMP:Hit_Component;
@export var UPPER_HITCMP:Hit_Component;


@export var logging:bool = false;


@onready var IKCALC:IK_Leg_Abstract = IK_Leg_Abstract.new()
@onready var FOOT_PHYSLERP:Physics_Lerper = Physics_Lerper.new()




@onready var STEP_TARGET:Node3D = Node3D.new()

@onready var TARGET:Node3D = Node3D.new();


#DISMEMBERMENT
@export_group("Dismemberment", "DISMEMBER")
@export var DISMEMBER_ENABLED:bool = true;
@export var DISMEMBER_HIP_TRIGGER:Hit_HP_Tracker;
@export var DISMEMBER_KNEE_TRIGGER:Hit_HP_Tracker;
@export var DISMEMBER_ANKLE_TRIGGER:Hit_HP_Tracker;
@export var DISMEMBER_UPPER_RB_MAKER:Trig_Make_Rigidbody;
@export var DISMEMBER_LOWER_RB_MAKER:Trig_Make_Rigidbody;
@export var DISMEMBER_FOOT_RB_MAKER:Trig_Make_Rigidbody;


@export_group("Extras")
## Each <Hit_Impulse> In this array will be set to the parent body.
@export var IMPULSE_TO_BODY:Array[Hit_Impulse]




class Intactity:
	var hip:bool = true;
	var knee:bool = true;
	var ankle:bool = true;

var intactity:Intactity = Intactity.new()




##Denotes as to whether it is being fully-physically-simulated or locked and stable.
var is_physical:bool = true:
	set(value):
		is_physical = value;
		if(is_physical):
			FOOT.freeze = false;
		else:
			FOOT.freeze = true


# If stable, attached to floor UNTIl pushed up. If not stable, attached to body and any deltas will be appliead appropriately

var is_stable:bool = false

## 0 == Not currently Stepping, 1 == Locating, 2 == Planting
var is_stepping:bool = false
var step_state:int = 0:
	set(v):
		is_stepping = true
		if(v == 0):
			FOOT_PHYSLERP.enabled = false
			is_stepping = false
		elif v == 1:
			FOOT_PHYSLERP.enabled = true
		elif v == 2:
			FOOT_PHYSLERP.enabled = true
		else:
			push_error("Attempted to set step_state of a leg to a value not in the range 0,1,2")
			return
		step_state = v
var step_start:int;
var step_height:float = 0;



#enum CurrentState{
	#STABLE,
	#UNSTABLE,
	#SEEKING,
	#MOVING
#}


signal became_stable




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	add_child(TARGET)
	add_child(FOOT_PHYSLERP)
	TARGET.global_position = FOOT.global_position
	
	IKCALC.UPPER_LENGTH = UPPER_LENGTH;
	IKCALC.LOWER_LENGTH = LOWER_LENGTH;
	IKCALC.ELBOW_IN = !INVERT_KNEE
	add_child(IKCALC)
	
	FOOT_PHYSLERP.FORCE = 15;
	FOOT_PHYSLERP.RESERVE_FORCE = 15;
	FOOT_PHYSLERP.RIGIDBODY = FOOT
	FOOT_PHYSLERP.TARGET = TARGET
	
	#parent's parent = RIGIDBODy's Controller
	#await get_parent().get_parent().ready
	
	FOOT.top_level = true
	FOOT.collision_layer = 64
	FOOT.collision_mask = 1
	FOOT.contact_monitor = true
	FOOT.max_contacts_reported = 3;
	
	
	if(UPPER_HITCMP == null):
		push_warning("No upper-leg hit-component set")
	else:
		UPPER_HITCMP.on_hit.connect(upper_hit)
		UPPER_HITCMP.on_hit.connect(generic_hit)
	
	if(LOWER_HITCMP == null):
		push_warning("No lower-leg hit-componennt set")
	else:
		LOWER_HITCMP.on_hit.connect(lower_hit)
		LOWER_HITCMP.on_hit.connect(generic_hit)
	
	#add_child(TARGET) # Reparented when BODy is set
	TARGET.top_level = true
	
	propagate_motion(false)
	
	add_child(STEP_TARGET)
	FOOT_PHYSLERP.TARGET = STEP_TARGET
	STEP_TARGET.global_position = TARGET.global_position
	
	# --- Dismemberment:
	if(DISMEMBER_ENABLED):
		if(DISMEMBER_HIP_TRIGGER != null): DISMEMBER_HIP_TRIGGER.on_hp_becomes_negative.connect(break_hip)
		if(DISMEMBER_KNEE_TRIGGER != null): DISMEMBER_KNEE_TRIGGER.on_hp_becomes_negative.connect(break_knee)
		if(DISMEMBER_ANKLE_TRIGGER != null):
			DISMEMBER_ANKLE_TRIGGER.on_hp_becomes_negative.connect(break_ankle)
			assert(DISMEMBER_FOOT_RB_MAKER != null, "No dismember Rb maker set for foot.")




## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	update_leg()

func update_leg() -> void:
	
	var global_target_delta:Vector3 = FOOT.global_position - global_position
	var local_target_delta:Vector3 = global_basis.inverse()*global_target_delta
	
	#if(!is_stable): return
	#if(logging or true):
	
	#DebugDraw3D.draw_line(global_position, global_position + global_target_delta)
	#DebugDraw3D.draw_line(global_position, global_position + local_target_delta, Color(0, 1, 0))
	#DebugDraw3D.draw_line(global_position, global_position + -global_basis.y, Color(0, 0, 1))
	
	if(LOWER_LENGTH > 0.02):
		
		var ik = IKCALC.calculate_IK_nodes(local_target_delta, Vector3.RIGHT)
		
		UPPER.transform = ik.upper.transform
		LOWER.transform = ik.lower.transform
		
		
		#FOOT.transform = ik.end.transform
	else:
		UPPER.look_at(UPPER.global_position + global_target_delta)


func begin_step(pos:Vector3 = TARGET.global_position):
	step_state = 1;
	step_start = Time.get_ticks_msec()
	step_height = tanh((pos - FOOT.global_position).length())


func _physics_process(delta: float) -> void:
	
	#print(step_state)
	if(!is_physical): return # used to disable, for optimisation.
	
	
	#DebugDraw3D.draw_text(FOOT.global_position + Vector3.UP * 0.1, str(is_stable))
	
	
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
			step_state = 2;
		
	elif step_state == 2:
		STEP_TARGET.global_position = TARGET.global_position + Vector3.UP * -0.35
		if(is_stable):
			step_state = 0;
		pass
	else:
		STEP_TARGET.global_position = TARGET.global_position
	
	#Debug.point(TARGET.global_position)
	
	propagate_motion(!is_stable and is_physical)
	
	if(logging): # Set to output info
		pass
	
	impose_footpos_limits()
	global_basis = global_basis.orthonormalized()


##Impulse; global position at which hit-limit occured. May be necessary
#Currently no use
signal hit_limit(impulse, pos)

func impose_footpos_limits():
	# Function disabled temporaily
	
	var foot_vector = FOOT.global_position - global_position
	var rebound_coefficient:float = 0.4
	
	var foot_dv:Vector3;
	
	#Outer limit
	var max_extension:float = UPPER_LENGTH + LOWER_LENGTH
	if(foot_vector.length() > max_extension + 0.05): # If foot trying to escape
		FOOT.global_position = global_position + foot_vector.normalized() * (max_extension)
		
		hit_limit.emit(FOOT.linear_velocity * -(1+rebound_coefficient) * FOOT.mass, FOOT.global_position)
		foot_dv += FOOT.linear_velocity.dot(foot_vector.normalized()) * foot_vector.normalized() * -(1 + rebound_coefficient); # Rebound. Here, e=0.4
	
	
	#Inner Limit
	var min_extension:float = 0.08 * (UPPER_LENGTH + LOWER_LENGTH)
	if(foot_vector.length() < min_extension - 0.05): # If foot trying to escape
		#FOOT.global_position = global_position + foot_vector.normalized() * (min_extension)
		
		hit_limit.emit(FOOT.linear_velocity * -(1+rebound_coefficient) * FOOT.mass, FOOT.global_position)
		foot_dv += FOOT.linear_velocity.dot(foot_vector.normalized()) * foot_vector.normalized() * -(1 + rebound_coefficient); # Rebound. Here, e=0.4
	
	apply_foot_impulse(FOOT.mass * foot_dv)
	






#------------ IMPLUSE REDISTRIBUTION -------------#
func upper_hit():
	var pos := UPPER_HITCMP.last_impulse_pos - UPPER.global_position
	var along := pos.dot(-UPPER.global_basis.z) / UPPER_LENGTH
	along = min(1.0, max(0.0, along))
	#Along is in the range -1 @ hip -> 0 at knee
	along -= 1.0;
	var impulse_pos:Vector3 = LOWER.global_position - BODY.global_position + pos
	distribute_impulse(UPPER_HITCMP.last_impulse, impulse_pos, along)

func lower_hit():
	var pos := LOWER_HITCMP.last_impulse_pos - LOWER.global_position
	var along := pos.dot(-LOWER.global_basis.z) / LOWER_LENGTH
	along = min(1.0, max(0.0, along))
	#Along is in the range 0 @ knee -> 1 at toes
	var impulse_pos:Vector3 = LOWER.global_position - BODY.global_position + pos
	distribute_impulse(LOWER_HITCMP.last_impulse, impulse_pos, along)

##Along is a measure of hwo far along the impulse is: -1:Hip, 0:Knee, 1:Toes
func distribute_impulse(impulse:Vector3, impulse_pos:Vector3, along:float):
	#Lines: Vert is through foot to hip, Forward is into the crux of the knee, (ie. would buckle it), perpendicular is the axis by which the knee rotates
	var vert:Vector3 = (global_position - FOOT.global_position).normalized()
	##Perpendicular to knee.
	var perpendicular:Vector3 = LOWER.global_basis.x
	var forwards:Vector3 = UPPER.global_basis.y.slerp(LOWER.global_basis.y, 0.5) # Middle angle is into crux of knee, hence forwards
	
	var cmp_vert:Vector3 = impulse.dot(vert) * vert
	var cmp_forward:Vector3 = impulse.dot(forwards) * forwards
	var cmp_perp:Vector3 = impulse.dot(perpendicular) * perpendicular
	
	##Resultant forces
	var resultant_top:Vector3 = Vector3.ZERO
	var resultant_bottom:Vector3 = Vector3.ZERO
	
	#PERPENDICULAR
	var proportion_top:float = sin(-PI*along/2) * 0.5 + 0.5 # Sin function where top = 1 and bottom = 0
	
	var hoz_distance_to_hit_pos = (impulse_pos * Vector3(1, 0, 1)).length()
	
	resultant_top += cmp_perp * hoz_distance_to_hit_pos**2 * proportion_top
	resultant_bottom += cmp_perp * hoz_distance_to_hit_pos * (1-proportion_top)
	
	#VERTICAL
	resultant_top += cmp_vert * proportion_top
	resultant_bottom += cmp_vert * (1-proportion_top)
	
	#FORWARDS (INTO/OUT OF KNEE)
	
	resultant_top += cmp_forward * proportion_top
	resultant_bottom += cmp_forward * (1-proportion_top)
	
	#+ is into knee, - is down (push body up)
	var vert_cmp = impulse.dot(forwards)# * 3
	var extend_cmp:float = 1-(proportion_top**2)
	resultant_top += vert_cmp * -vert * extend_cmp# Push it down too
	resultant_bottom -= vert_cmp * -vert * extend_cmp  # Push it up because impulse, can cause leg to jolt interestingly
	
	#APPLY
	BODY.apply_impulse(resultant_top, global_position - BODY.global_position)
	apply_foot_impulse(resultant_bottom)

##Called upon any hit
func generic_hit():
	is_physical = true

##Force is in global coords. Applies foot force if it would 'uproot the foot.
func apply_foot_force(force:Vector3):
	if(is_stable):
		var VERT_FORCE_TO_UPROOT:float = FOOT.mass * abs(ProjectSettings.get_setting("physics/3d/default_gravity"));
		if(force.y > VERT_FORCE_TO_UPROOT):
			FOOT.apply_central_force(force)
			
	else:
		FOOT.apply_central_force(force * Vector3(1, 0, 1))

func apply_foot_impulse(impulse:Vector3):
	if(is_stable):
		var VERT_IMPULSE_TO_UPROOT:float = FOOT.mass * abs(ProjectSettings.get_setting("physics/3d/default_gravity")) * (1/60); # Divided by expected 'delta' as impulse is Ns
		if(impulse.y > VERT_IMPULSE_TO_UPROOT):
			is_stable = false;
			FOOT.apply_central_impulse(impulse)
			step_state = 2 # try to stamp down
		else:
			FOOT.apply_central_impulse(impulse * Vector3(1, 0, 1))
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
var prop_foot_old_pos:Vector3
var prop_old_basis:Basis = Basis.IDENTITY
##Must be called each 'tick' to get accurate deltas. if arg == true, actually updates position.
func propagate_motion(propagating:bool = true):
	if(propagating):
		
		
		
		var delta_pos:Vector3 = global_position - prop_old_pos
		
		
		var delta_basis:Basis = prop_old_basis * global_basis.inverse()
		
		#Evil fucked up maths to apply a delta-position based on Basis change (Applies rotation)
		#TODO not convicned this works
		var delta_basis_pos = (FOOT.global_position - global_position) - (prop_foot_old_pos - prop_old_pos) * prop_old_basis.inverse() * global_basis
		#print(delta_basis_pos)
		
		#if this is funny, check the .psotion/global
		FOOT.position += delta_pos + delta_basis_pos
	
	prop_old_pos = global_position
	prop_foot_old_pos = FOOT.global_position
	prop_old_basis = global_basis



# -------- DISMEMBERMENT ---------
##Cripples The leg. Whoops!
func break_hip():
	if(intactity.hip == false): return
	intactity.hip = false
	
	UPPER_LENGTH = 0.2;
	DISMEMBER_UPPER_RB_MAKER.add_impulse(DISMEMBER_HIP_TRIGGER.last_impulse, DISMEMBER_HIP_TRIGGER.last_impulse_pos)
	DISMEMBER_UPPER_RB_MAKER.trigger()
	
	break_knee()
	

## owie
func break_knee():
	if(intactity.knee == false): return
	intactity.knee = false
	
	
	if(intactity.ankle):#If ankle is intact, make ankle rb too
		DISMEMBER_FOOT_RB_MAKER.trigger()
		intactity.ankle = false
	
	DISMEMBER_LOWER_RB_MAKER.add_impulse(DISMEMBER_KNEE_TRIGGER.last_impulse, DISMEMBER_KNEE_TRIGGER.last_impulse_pos)
	DISMEMBER_LOWER_RB_MAKER.trigger()
	
	LOWER_LENGTH = 0;
	

##Breaking the ankle will ideally allow the robot to still walk, however with no shoes on. Effectively shorten the FOOT hitbox (or raise it)
func break_ankle():
	if(intactity.ankle == false): return
	intactity.ankle = false;
	
	
	
	DISMEMBER_FOOT_RB_MAKER.add_impulse(DISMEMBER_ANKLE_TRIGGER.last_impulse, DISMEMBER_ANKLE_TRIGGER.last_impulse_pos)
	DISMEMBER_FOOT_RB_MAKER.trigger()
	#DISMEMBER_FOOT_RB_MAKER.RIGIDBODY.global_position += Vector3.UP * 0.5
	
	
	
	#Shortens leg - TODO Check that leg is still. exists.
	for child in FOOT.get_children():
		if(child is CollisionShape3D):
			child.position += Vector3.UP * 0.1 # Raises collider by 0.05, making leg shorter.
	LOWER_LENGTH -= 0.1
