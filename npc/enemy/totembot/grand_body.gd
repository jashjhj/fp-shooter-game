class_name Grand_Body extends Hittable_RB

@export var COM:Vector3 = Vector3.ZERO
@export var CONTROLLED_COM:Vector3 = Vector3.ZERO
@export var IS_CONTROLLED_COM_ACTIVE:bool = false;

func _ready() -> void:
	super()
	COM = center_of_mass
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM;



func _physics_process(delta):
	if(IS_CONTROLLED_COM_ACTIVE):
		center_of_mass = CONTROLLED_COM
	else: center_of_mass = COM;
