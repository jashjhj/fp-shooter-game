extends Node3D

@export var BODY:RigidBody3D;

@export var LEG1:LegBotLeg;
@export var LEG2:LegBotLeg;
@export var LEG3:LegBotLeg;

##Should be placed at "centre" originally, facing forwards.
@export var TARG:Node3D;
@onready var targ_l1:Node3D = Node3D.new();
@onready var targ_l2:Node3D = Node3D.new();
@onready var targ_l3:Node3D = Node3D.new();

@export var GOAL_HEIGHT:float = 1.5;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TARG.add_child(targ_l1)
	TARG.add_child(targ_l2)
	TARG.add_child(targ_l3)
	targ_l1.position = LEG1.global_position - BODY.global_position # Sets offset to that of each leg. TODO: May need tos et this to BODY centre of mass
	targ_l2.position = LEG2.global_position - BODY.global_position
	targ_l3.position = LEG3.global_position - BODY.global_position
	
	LEG1.PHYSLERP.TARGET = targ_l1
	LEG2.PHYSLERP.TARGET = targ_l2
	LEG3.PHYSLERP.TARGET = targ_l3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	#TARG.global_position = get_centre_of_stable_area() + Vector3.UP * GOAL_HEIGHT
	
	consider_for_forces(LEG1, delta)
	consider_for_forces(LEG2, delta)
	consider_for_forces(LEG3, delta)


func consider_for_forces(leg:LegBotLeg, delta:float):
	if(leg.is_on_floor()):
		leg.attempt_apply_force(leg.PHYSLERP.calculate_forces(delta))
	else:
		leg.attempt_apply_force(Vector3.ZERO)

func get_centre_of_stable_area() -> Vector3:
	var average_position:Vector3 = Vector3.ZERO;# = (LEG1.target + LEG2.target + LEG3.target)/3.0
	
	var contributors:int = 0;
	if(LEG1.is_stable):
		average_position += LEG1.FOOT.global_position;
		contributors += 1;
	if(LEG2.is_stable):
		average_position += LEG2.FOOT.global_position;
		contributors += 1;
	if(LEG3.is_stable):
		average_position += LEG3.FOOT.global_position;
		contributors += 1;
	
	if(contributors != 0):
		return average_position / float(contributors)
	
	#Completely unstable
	return Vector3.ZERO
