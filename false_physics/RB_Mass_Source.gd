class_name RB_Mass_Source extends Node3D

##Mass can be negative
@export var MASS:float = 1.0;
@export var BODY:RigidBody3D;

@export var ADD_ON_READY:bool = true


func _ready() -> void:
	assert(BODY != null, "No Body set for RB_Mass_Source")
	await BODY.ready
	BODY.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	
	if(ADD_ON_READY):
		add_mass()
	
	#Shift COM correctly

##Adds mass (default to what is set) to associated rigidbody
func add_mass(mass_to_add:float = MASS):
	BODY.center_of_mass = (BODY.center_of_mass * BODY.mass + BODY.to_local(global_position) * mass_to_add) / (BODY.mass + mass_to_add)
	BODY.mass += mass_to_add

func remove_mass(mass:float = MASS):
	add_mass(-mass)
