class_name RB_Mass_Source extends Node3D

##Mass can be negative
@export var MASS:float = 1.0;
@export var BODY:RigidBody3D;

@export var IS_ADDED:bool = true
##If true, can change COM each physics tick if moved.
@export var DYNAMIC:bool = false


func _ready() -> void:
	assert(BODY != null, "No Body set for RB_Mass_Source")
	await BODY.ready
	BODY.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	
	if(IS_ADDED):
		add_mass()
	
	#Shift COM correctly

var prev_pos:Vector3
func _physics_process(delta: float) -> void:
	if(DYNAMIC and IS_ADDED):
		remove_mass(MASS, prev_pos)
		add_mass()
	
	
	prev_pos = global_position

##Adds mass (default to what is set) to associated rigidbody
func add_mass(mass_to_add:float = MASS, at:Vector3 = global_position):
	if(BODY is Grand_Body):
		BODY.COM = (BODY.COM * BODY.mass + BODY.to_local(at) * mass_to_add) / (BODY.mass + mass_to_add)
	else:
		BODY.center_of_mass = (BODY.center_of_mass * BODY.mass + BODY.to_local(at) * mass_to_add) / (BODY.mass + mass_to_add)
	
	BODY.mass += mass_to_add
	IS_ADDED = true

func remove_mass(mass:float = MASS, at:Vector3 = global_position):
	add_mass(-mass)
	IS_ADDED = false
