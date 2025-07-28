class_name Hit_Reduce_Mass extends Hit_HP_Tracker

@export var BODY_TO_REDUCE_MASS:RigidBody3D
##Can aslo reduce SIMULATED_MASS_ABOVE of Planetary_Gears
@export var PLANETARY_GEARS_TO:Planetary_Gears;
@export var MASS:float;

func _ready() -> void:
	super._ready()
	on_hp_becomes_negative.connect(reduce_mass)

func reduce_mass():
	if(BODY_TO_REDUCE_MASS != null):
		BODY_TO_REDUCE_MASS.mass -= MASS
	if(PLANETARY_GEARS_TO != null):
		PLANETARY_GEARS_TO.SIMULATED_MASS_ABOVE -= MASS
