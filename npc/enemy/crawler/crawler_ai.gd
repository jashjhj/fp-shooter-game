class_name Crawler extends RigidBody3D

@export_group("Walk Qualities")
@export var GAIT_WIDTH:float = 0.65;
@export var GAIT_HEIGHT:float = 0.2;
@export var GAIT_STEP_LENGTH:float = 0.36;

#@export var STATE_WALK_33:Sexapod_State;
@export var STATE_WALK:Sexapod_State;

@export_group("Legs")
@export var LEG_L0:Crawler_Leg;
@export var LEG_L1:Crawler_Leg;
@export var LEG_L2:Crawler_Leg;
@export var LEG_R0:Crawler_Leg;
@export var LEG_R1:Crawler_Leg;
@export var LEG_R2:Crawler_Leg;

@onready var nav_agent := $NavigationAgent3D

var CURRENT_WALK_STATE:Sexapod_State

var current_velocity:Vector3# = Vector3(0, 0, 0.5)
var current_speed:float = 1.8#1.8
var effective_speed:float;

var legs_working:int = 6;
var distance_travelled:float = 0

func _ready():
	assert(STATE_WALK != null, "No walk cycle set")
	STATE_WALK.SEXAPOD = self;
	#assert(STATE_WALK_32 != null, "No walk cycle set")
	#STATE_WALK_32.SEXAPOD = self;
	
	CURRENT_WALK_STATE = STATE_WALK
	
	
	LEG_L0.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_L1.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_L2.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_R0.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_R1.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_R2.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	
	
	nav_agent.height = GAIT_HEIGHT + 0.1
	nav_agent.path_height_offset = -GAIT_HEIGHT + 0.3


func remove_leg():
	legs_working -= 1;
	current_speed *= 0.8
	if(CURRENT_WALK_STATE == STATE_WALK):
		CURRENT_WALK_STATE.needs_reinit = true;



func _physics_process(delta):
	effective_speed = current_speed;
	effective_speed *= CURRENT_WALK_STATE.get_speed_mult()
	
	update_nav_location(Globals.PLAYER.global_position)
	
	var next_vector = to_local(nav_agent.get_next_path_position()).normalized()
	current_velocity = next_vector*effective_speed# * 60 * delta;
	#current_velocity = current_velocity.rotated(Vector3.UP, PI/2)
	
	#current_velocity *= min(0.9, 40*delta)
	
	global_position.y = nav_agent.get_next_path_position().y
	#if((global_position - nav_agent.get_next_path_position()) * Vector3(1,0,1)).length() != 0:
	look_at(Globals.PLAYER.global_position + Vector3(0, 1, 0), Vector3.UP)
	
	#rotate_y(PI/2)
	
	position -= global_basis.z*current_velocity.length()*delta
	
	
	distance_travelled += current_velocity.length()*delta
	do_legs(delta)




var targets_left:Array[Node3D];
var targets_right:Array[Node3D];

var left_step_number:int = 0;
var right_step_number:int = 0;



func do_legs(delta:float):
	#if(legs_working == 6):
	#	CURRENT_WALK_STATE = STATE_WALK_33
	#elif legs_working == 5:
	#	CURRENT_WALK_STATE = STATE_WALK_32
	CURRENT_WALK_STATE._process_legs(delta)


func update_nav_location(target_location):
	nav_agent.target_position = target_location;
