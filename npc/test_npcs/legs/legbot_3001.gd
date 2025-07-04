extends Node3D

@export var BODY:RigidBody3D
@export var LEG1:LegBotLeg;
@export var LEG2:LegBotLeg;
@export var LEG3:LegBotLeg;


@export var TARGET:Node3D;


@onready var PHYSLERP:Physics_Lerper = Physics_Lerper.new()

@onready var L1Delta:Vector3 = LEG1.position - BODY.position
@onready var L2Delta:Vector3 = LEG2.position - BODY.position
@onready var L3Delta:Vector3 = LEG3.position - BODY.position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	LEG1.BODY = BODY
	LEG2.BODY = BODY
	LEG3.BODY = BODY
	
	PHYSLERP.RIGIDBODY = BODY
	PHYSLERP.TARGET = TARGET
	PHYSLERP.FORCE = 10;
	PHYSLERP.RESERVE_FORCE = 40;



func _physics_process(delta: float) -> void:
	
	var stable_area := calculate_stable_area()
	var stable_legs := len(stable_area)
	
	PHYSLERP.FORCE = 8 * stable_legs
	PHYSLERP.RESERVE_FORCE = 16 * stable_legs
	
	PHYSLERP.apply_forces(delta)



func calculate_stable_area() -> Array[Vector3]:
	
	var out:Array[Vector3] = [];
	
	if(LEG1.is_stable):
		out.append(LEG1.contact_point)
	if(LEG2.is_stable):
		out.append(LEG2.contact_point)
	if(LEG3.is_stable):
		out.append(LEG3.contact_point)
	
	return out

func get_centre_of_stable_area(arr:Array[Vector3]) -> Vector3:
	var average_position:Vector3 = Vector3.ZERO;# = (LEG1.target + LEG2.target + LEG3.target)/3.0
	
	for i in arr:
		average_position += i
	
	if(len(average_position) != 0):#If >=1 contributors:
		return average_position / len(average_position)
	
	#Completely unstable
	return Vector3.ZERO
