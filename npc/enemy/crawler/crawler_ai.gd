class_name Crawler extends RigidBody3D

@export_group("Walk Qualities")
@export var GAIT_WIDTH:float = 0.4;
@export var GAIT_HEIGHT:float = 0.32;
@export var GAIT_STEP_LENGTH:float = 0.25;


@export_group("Legs")
@export var LEG_L0:Crawler_Leg;
@export var LEG_L1:Crawler_Leg;
@export var LEG_L2:Crawler_Leg;
@export var LEG_R0:Crawler_Leg;
@export var LEG_R1:Crawler_Leg;
@export var LEG_R2:Crawler_Leg;

@onready var nav_agent := $NavigationAgent3D

var TARGET_L0:Node3D = Node3D.new()
var TARGET_L1:Node3D = Node3D.new()
var TARGET_L2:Node3D = Node3D.new()
var TARGET_L3:Node3D = Node3D.new()
var TARGET_L4:Node3D = Node3D.new()
var TARGET_R0:Node3D = Node3D.new()
var TARGET_R1:Node3D = Node3D.new()
var TARGET_R2:Node3D = Node3D.new()
var TARGET_R3:Node3D = Node3D.new()
var TARGET_R4:Node3D = Node3D.new()

var LEAD_L:Node3D = Node3D.new();
var LEAD_R:Node3D = Node3D.new();

var current_velocity:Vector3# = Vector3(0, 0, 0.5)
var current_speed:float = 1.8

var legs_working = 6;


func _ready():
	add_child(LEAD_L)
	add_child(LEAD_R)
	LEAD_L.position = Vector3(-GAIT_WIDTH/2.0, -GAIT_HEIGHT, -GAIT_STEP_LENGTH)
	LEAD_R.position = Vector3( GAIT_WIDTH/2.0, -GAIT_HEIGHT, -GAIT_STEP_LENGTH)
	setup_target(TARGET_L0, -1)
	setup_target(TARGET_L1, -1)
	setup_target(TARGET_L2, -1)
	setup_target(TARGET_L3, -1)
	setup_target(TARGET_L4, -1)
	
	targets_left.append(TARGET_L0)
	targets_left.append(TARGET_L1)
	targets_left.append(TARGET_L2)
	targets_left.append(TARGET_L3)
	targets_left.append(TARGET_L4)
	
	setup_target(TARGET_R0, 1)
	setup_target(TARGET_R1, 1)
	setup_target(TARGET_R2, 1)
	setup_target(TARGET_R3, 1)
	setup_target(TARGET_R4, 1)
	
	targets_right.append(TARGET_R0)
	targets_right.append(TARGET_R1)
	targets_right.append(TARGET_R2)
	targets_right.append(TARGET_R3)
	targets_right.append(TARGET_R4)
	
	
	LEG_L0.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_L1.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_L2.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_R0.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_R1.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	LEG_R2.DESTROY_SIGNAL.on_hit.connect(remove_leg)
	
	#nav_agent.path_height_offset = -GAIT_HEIGHT
	nav_agent.height = GAIT_HEIGHT + 0.1


func remove_leg():
	legs_working -= 1;
	current_speed *= 0.8
	
	#if(legs_working == 3): # FIX LATER
		#rotate_z(PI/3)
		#nav_agent.path_height_offset += 0.1

func setup_target(t:Node3D, side:float):
	t.position = Vector3(side*GAIT_WIDTH/2.0, -GAIT_HEIGHT, 0)
	add_child(t)
	t.top_level = true

func _physics_process(delta):
	
	update_nav_location(Globals.PLAYER.global_position)
	
	var next_vector = to_local(nav_agent.get_next_path_position()).normalized()
	current_velocity = next_vector*current_speed# * 60 * delta;
	
	#current_velocity *= min(0.9, 40*delta)
	
	global_position.y = nav_agent.get_next_path_position().y
	if((global_position - nav_agent.get_next_path_position()) * Vector3(1,0,1)).length() != 0:
		look_at(nav_agent.get_next_path_position(), global_basis.y)
	
	
	
	position -= global_basis.z*current_velocity.length()*delta
	
	
	
	distance_till_left += current_velocity.length() * delta;
	distance_till_right += current_velocity.length() * delta
	
	do_legs()


var distance_till_left:float = 0.1;
var distance_till_right:float = 0.1 + GAIT_STEP_LENGTH/2
var targets_left:Array[Node3D];
var targets_right:Array[Node3D];

var left_step_number:int = 0;
var right_step_number:int = 0;



func do_legs():
	#LEFT:
	if(distance_till_left > GAIT_STEP_LENGTH):
		distance_till_left = 0;
		
		
		targets_left[4].global_position = LEAD_L.global_position
		targets_left[4].global_position += global_basis*current_velocity.normalized() * GAIT_STEP_LENGTH
		#Debug.point(targets_left[4].global_position)
		targets_left.push_front(targets_left.pop_back())
		left_step_number += 1;
	
	var left_step_progress:float = distance_till_left/GAIT_STEP_LENGTH;
	
	if(left_step_number % 2 == 0):
		if(LEG_L0 != null):
			LEG_L0.update_leg_ik(targets_left[1])
		if(LEG_L1 != null):
			LEG_L1.update_leg_slerp(targets_left[3], targets_left[1], left_step_progress)
		if(LEG_L2 != null):
			LEG_L2.update_leg_ik(targets_left[3])
	else:
		if(LEG_L0 != null):
			LEG_L0.update_leg_slerp(targets_left[2], targets_left[0], left_step_progress)
		if(LEG_L1 != null):
			LEG_L1.update_leg_ik(targets_left[2])
		if(LEG_L2 != null):
			LEG_L2.update_leg_slerp(targets_left[4], targets_left[2], left_step_progress)
	
	
	#RIGHT:
	
	if(distance_till_right > GAIT_STEP_LENGTH):
		distance_till_right = 0;
		
		
		targets_right[4].global_position = LEAD_R.global_position
		targets_right[4].global_position += global_basis*current_velocity.normalized() * GAIT_STEP_LENGTH
		#Debug.point(targets_right[4].global_position)
		targets_right.push_front(targets_right.pop_back())
		right_step_number += 1;
	
	var right_step_progress:float = distance_till_right/GAIT_STEP_LENGTH;
	
	if(right_step_number % 2 == 1):
		if(LEG_R0 != null):
			LEG_R0.update_leg_ik(targets_right[1])
		if(LEG_R1 != null):
			LEG_R1.update_leg_slerp(targets_right[3], targets_right[1], right_step_progress)
		if(LEG_R2 != null):
			LEG_R2.update_leg_ik(targets_right[3])
	else:
		if(LEG_R0 != null):
			LEG_R0.update_leg_slerp(targets_right[2], targets_right[0], right_step_progress)
		if(LEG_R1 != null):
			LEG_R1.update_leg_ik(targets_right[2])
		if(LEG_R2 != null):
			LEG_R2.update_leg_slerp(targets_right[4], targets_right[2], right_step_progress)



func update_nav_location(target_location):
	nav_agent.target_position = target_location;
