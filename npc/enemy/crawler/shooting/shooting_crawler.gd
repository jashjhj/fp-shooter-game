class_name Shooting_Crawler extends Node3D

##Four-legged robot crawler that harbours a gun. Two logn legs at front and 2 short legs at the back, to aim upwards.

@export_group("Components")
@export var BODY:RigidBody3D;
@export var LEG_L:IK_Leg;
@export var LEG_R:IK_Leg;
@export var REAR_WHEEL:Node3D;

##Should be a child of the Body
@export var STABILISE_POS_L:Node3D;
@export var STABILISE_POS_R:Node3D;

@onready var STABILISE_TARG_L:Node3D = Node3D.new()
@onready var STABILISE_TARG_R:Node3D = Node3D.new()

@export_group("Settings")
@export var WALK_NOSE_HEIGHT:float = 0.4;

@onready var GROUND_RAY:RayCast3D = $Body/Ground_Ray
@onready var LEG_L_RAY:RayCast3D = $Body/Ray_Left
@onready var LEG_R_RAY:RayCast3D = $Body/Ray_Right
@onready var nav_agent := $NavigationAgent3D

@onready var POS:Node3D = Node3D.new()

var is_stable:bool = true;



func _ready() -> void:
	assert(LEG_L != null, "No Left Leg Set")
	assert(LEG_R != null, "No Right Leg Set")
	
	
	add_child(POS)
	POS.global_transform = global_transform
	
	
	POS.add_child(STABILISE_TARG_L)
	POS.add_child(STABILISE_TARG_R)
	STABILISE_TARG_L.global_transform = STABILISE_POS_R.global_transform # Dont ask my why. whta. I have no idea why these have to be swapped
	STABILISE_TARG_R.global_transform = STABILISE_POS_L.global_transform
	#STABILISE_TARG_L.position += Vector3.UP * 0.04
	#STABILISE_TARG_R.position += Vector3.UP * 0.04
	#LEG_L.free()
	#LEG_R.free()

const FORCE_OFFSET:float = 12;
const FORCE_MULT:float = 500.0

func _physics_process(delta: float) -> void:
	
	
	var new_is_stable:bool = check_stable()
	if(new_is_stable != is_stable):#Just changed
		if(new_is_stable):#Just became stable:
			#print("Just becomign stable")
			POS.global_transform = BODY.global_transform
			if(GROUND_RAY.is_colliding()):
				POS.global_position = GROUND_RAY.get_collision_point()
				
				#Update basis
				var floor_normal:Vector3 = GROUND_RAY.get_collision_normal()
				POS.global_basis.y = floor_normal
				POS.global_basis.x = floor_normal.cross(-BODY.global_basis.z)
				POS.global_basis.z = -floor_normal.cross(BODY.global_basis.x)
				
		else:# Becoming unstable
			pass#print("Just became unstable")
	
	is_stable = new_is_stable
	
	if(is_stable):
		
		var left_goal_dir:Vector3 = STABILISE_TARG_L.global_position - STABILISE_POS_L.global_position
		var right_goal_dir:Vector3 = STABILISE_TARG_R.global_position - STABILISE_POS_R.global_position
		var left_force:Vector3 = left_goal_dir * FORCE_MULT + Vector3.UP*FORCE_OFFSET
		var right_force:Vector3 = right_goal_dir * FORCE_MULT + Vector3.UP*FORCE_OFFSET
		print("L", left_force)
		print("R", right_force)
		BODY.apply_force(left_force, STABILISE_POS_L.global_position - BODY.global_position)
		BODY.apply_force(right_force, STABILISE_POS_R.global_position - BODY.global_position)
		
		# Walk
		#position += -basis.z * delta
	
	DebugDraw3D.draw_position(STABILISE_TARG_L.global_transform, Color(0, 0, 1), 0)
	DebugDraw3D.draw_position(STABILISE_TARG_R.global_transform, Color(1, 0, 0), 0)
	#DebugDraw3D.draw_position(POS.global_transform, Color(1, 0, 1), 0)
	
	#var left_height:float = (1.0/WALK_NOSE_HEIGHT) * min(WALK_NOSE_HEIGHT, max(0, (LEG_L_RAY.get_collision_point() - LEG_L_RAY.global_position).length())) # As a float where 1 is fully extended and 0 is on floor
	#var right_height:float = (1.0/WALK_NOSE_HEIGHT) * min(WALK_NOSE_HEIGHT, max(0, (LEG_R_RAY.get_collision_point() - LEG_R_RAY.global_position).length())) # As a float where 1 is fully extended and 0 is on floor
	#
	#var left_force:float = (min(0, left_height - WALK_NOSE_HEIGHT))**2 * FORCE_MULT
	#var right_force:float = (min(0, right_height - WALK_NOSE_HEIGHT))**2 * FORCE_MULT
	#
	##print("l", left_force, "H: ", left_height)
	##print(right_force, "H: ", right_height)
	#
	#
	#
	#BODY.apply_force(-LEG_L_RAY.global_position + BODY.global_position, left_force * -(LEG_L_RAY.global_basis.inverse()*LEG_L_RAY.target_position))
	#BODY.apply_force(-LEG_R_RAY.global_position + BODY.global_position, right_force * -(LEG_R_RAY.global_basis.inverse()*LEG_R_RAY.target_position))
	#
	
	
	
	
	LEG_L.set_leg_target(LEG_L_RAY.get_collision_point())
	LEG_R.set_leg_target(LEG_R_RAY.get_collision_point())
	LEG_L.set_leg_progress(1.0)
	LEG_R.set_leg_progress(1.0)

func check_stable() -> bool:
	var result = true
	
	var body_upness:float = BODY.global_basis.y.dot(Vector3.UP) # If not upright
	if(body_upness < 0.3): result = false
	
	#If neither leg can reach floor
	if(!LEG_L_RAY.is_colliding() and !LEG_R_RAY.is_colliding()): result = false
	
	if(!GROUND_RAY.is_colliding()): result = false;
	
	return result;
