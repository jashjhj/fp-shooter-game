class_name Gunner extends CharacterBody3D

@export var STATE_MACHINE:StateMachine;
@export var STATS:Gunner_Stats

@export_range(0, 180, 1.0, "radians_as_degrees") var VISION_FOV_X:float = PI/3
@export_range(0, 180, 1.0, "radians_as_degrees") var VISION_FOV_Y:float = PI/4
@export var VIEW_DISTANCE:float = 5.0;

@onready var HEAD:Node3D = $Torso/Head
@onready var RAY:RayCast3D = $Torso/Head/RayCast3D
@onready var NAV_AGENT:NavigationAgent3D = $NavigationAgent3D;
@onready var GUN_POS:Node3D = $Torso/Gun_Pos;
@onready var GUN = $Torso/Gun_Pos/Bullet_Source

func _ready() -> void:
	assert(STATE_MACHINE != null, "No State Machine Set")

var next_velocity:Vector3;
var persistent_velocity:Vector3 = Vector3.ZERO
func _physics_process(delta: float) -> void:
	velocity = next_velocity + persistent_velocity
	
	if not is_on_floor():
		#ppass
		persistent_velocity += get_gravity()*delta
	else:
		persistent_velocity= Vector3.ZERO;
	
	move_and_slide()
