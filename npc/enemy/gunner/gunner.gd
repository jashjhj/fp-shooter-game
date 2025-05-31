class_name Gunner extends CharacterBody3D

@export var STATE_MACHINE:StateMachine;
@export var STATS:Gunner_Stats

@export_range(0, 180, 1.0, "radians_as_degrees") var VISION_FOV_X:float = PI/3
@export_range(0, 180, 1.0, "radians_as_degrees") var VISION_FOV_Y:float = PI/4
@export var VIEW_DISTANCE:float = 5.0;

@onready var HEAD:Node3D = $Torso/Head
@onready var RAY:RayCast3D = $Torso/Head/RayCast3D
@onready var NAV_AGENT:NavigationAgent3D = $NavigationAgent3D;
@onready var GUN_TARGET_POS:Node3D = Node3D.new();
@onready var GUN_POS:Node3D = $Torso/Gun_Pos;
@onready var GUN:Node3D = $Torso/Gun_Pos/Bullet_Source

@export var GUN_LERP_RATE:float = 4.0;

func _ready() -> void:
	assert(STATE_MACHINE != null, "No State Machine Set")
	add_child(GUN_TARGET_POS)
	GUN_TARGET_POS.global_transform = GUN_POS.global_transform;


var next_velocity:Vector3;
var persistent_velocity:Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	velocity = next_velocity + persistent_velocity
	
	if not is_on_floor():
		#ppass
		persistent_velocity += get_gravity()*delta
	else:
		persistent_velocity= Vector3.ZERO;
	
	GUN_POS.global_position = GUN_POS.global_position.lerp(GUN_TARGET_POS.global_position, min(1.0, delta*GUN_LERP_RATE))
	GUN_POS.global_basis = Basis(Quaternion(GUN_POS.global_basis).slerp(Quaternion(GUN_TARGET_POS.global_basis), min(1.0, delta*GUN_LERP_RATE)))
	GUN_POS.global_basis = GUN_POS.global_basis.orthonormalized()
	GUN_TARGET_POS.global_basis = GUN_TARGET_POS.global_basis.orthonormalized()
	
	move_and_slide()
