class_name Hit_Reduce_Mass extends Hit_HP_Tracker

@export var BODY_TO_REDUCE_MASS:RigidBody3D
@export var MASS:float;

func _ready() -> void:
	super._ready()
	on_hp_becomes_negative.connect(reduce_mass)

func reduce_mass():
	BODY_TO_REDUCE_MASS.mass -= MASS
