class_name LegBotLeg extends Node3D

#Rigidbody sibling to attach to - Must be set at runtime by parent.
@export var BODY:RigidBody3D;

@export var HIP:Generic6DOFJoint3D;
@export var KNEE:Generic6DOFJoint3D;
@export var UPPER:RigidBody3D;
@export var LOWER:RigidBody3D;
@export var UPPER_LENGTH:float = 1.0;
@export var LOWER_LENGTH:float = 1.0;

@export var FOOT:RigidBody3D;
@export var ORIGIN:Node3D;

@onready var IKCALC:IK_Leg_Abstract = IK_Leg_Abstract.new()
@onready var PHYSLERP:Physics_Lerper = Physics_Lerper.new()
@onready var DOWN_RAY:RayCast3D = RayCast3D.new()

@export var logging:bool = false;

var is_stable:bool = true;

var TARGET:Vector3;


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
	
	
	DOWN_RAY.target_position = Vector3(0, -2.5, 0)
	
	await get_parent().ready
	
	if(BODY != null):
		HIP.node_a = BODY.get_path()
	
	PHYSLERP.RIGIDBODY = BODY
	PHYSLERP.FORCE = 100;
	PHYSLERP.RESERVE_FORCE = 22
	PHYSLERP.RIGIDBODY_PEG = ORIGIN
	
	
	#var ik = $IK_Leg_Abstract.get_angles(Vector3(0, -1, 0), Vector3.FORWARD)
	#print(ik.hippitch)

func set_new_target(new_target:Vector3):
	is_stable = false;
	
	
	TARGET = new_target


func is_on_floor() -> bool:
	var contacts = FOOT.get_colliding_bodies()
	for body in contacts:
		if(body is StaticBody3D or body is CSGBox3D): # If foot is colliding with a staticbody, YES is on floor
			return true;
	#Else, no staticbody in contact
	return false;

##Force in global space. Will bend/extend etc to attempt to apply such a force.
##This should be set every frame and set to ZERO when unused, else remains constant force.
func attempt_apply_force(force:Vector3):
	var loc_force:Vector3 = force * ORIGIN.global_basis.inverse();
	
	if((loc_force * Vector3(0, 1, 1)).is_zero_approx()): # If its zero, cancel and move on
		KNEE.set("angular_motor_x/enabled", true);
		KNEE.set("angular_motor_x/target_velocity", 0);
		HIP.set("angular_motor_x/enabled", true);
		HIP.set("angular_motor_x/target_velocity", 0);
		
	else:
		#Find directions of travel
		
		#var ik_considered_delta = (ORIGIN.to_local(FOOT.global_position) - loc_force.normalized() * 0.01) * Vector3(0, 1, 1); # Omit X as this can only be fixed via hip yaw. Quantized to small amounts for simple delta-angles as per calculations
		#var angles = IKCALC.get_angles(ik_considered_delta, Vector3.DOWN)
		
		##From downwards
		var angle_hip = UPPER.rotation.x
		##From Downwards
		var angle_knee = PI/2 + UPPER.rotation.x - LOWER.rotation.x# - angle_hip;
		
		#var ik_delta_angle_hip = angles.hippitch - angle_hip;
		#var ik_delta_angle_knee = angles.knee - angle_knee;
		
		
		
		#var hip_to_knee_moment_ratio:float = ik_delta_angle_hip/ik_delta_angle_knee;
		
		
		##Calculate Force limit(in Nm) per each joint knee, hip
		
		#TODO knee moment is fucked oup. gets very large.
		
		var moment_hip = ((loc_force.y - tan(angle_knee)*loc_force.z) *UPPER_LENGTH) / (sin(angle_hip) - tan(angle_knee)*cos(angle_hip))
		var moment_knee = (loc_force.y - (moment_hip/UPPER_LENGTH)*cos(angle_hip)) * LOWER_LENGTH/cos(angle_knee)
		
		#Old
		#var moment_knee = (loc_force.z + loc_force.y) / (sin(angle_hip)*cos(angle_knee)/sin(angle_knee) + cos(angle_hip))
		#var moment_hip = (loc_force.z - moment_knee*cos(angle_hip)) / cos(angle_knee)
		#moment_hip *= IKCALC.UPPER_LENGTH;
		#moment_knee *= IKCALC.LOWER_LENGTH;
		
		KNEE.set("angular_motor_x/enabled", true);
		KNEE.set("angular_motor_x/target_velocity", sign(moment_knee)*10); # Previosuly these were sign(ik_delta_angle) with no magnitude
		KNEE.set("angular_motor_x/force_limit", min(100, abs(moment_knee)))
		
		HIP.set("angular_motor_x/enabled", true);
		HIP.set("angular_motor_x/target_velocity", sign(moment_hip)*10);
		HIP.set("angular_motor_x/force_limit", min(100, abs(moment_hip)))
		
		
		HIP.set("angular_motor_y/enabled", false);
		HIP.set("angular_motor_y/target_velocity", -sign(loc_force.y) * 0.4)
		var moment_hip_yaw:float = abs(loc_force.y) * PHYSLERP.TARGET.global_position.distance_to(BODY.to_global(BODY.center_of_mass))
		HIP.set("angular_motor_y/force_limit", moment_hip_yaw)
		
		
		
		if(logging):
			print(KNEE.get("angular_motor_x/force_limit"))
			
			#Line to target
			DebugDraw3D.draw_line(ORIGIN.global_position, PHYSLERP.TARGET.global_position)
		
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func get_new_target():
	#target_position = 
