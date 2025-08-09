class_name Hit_Affect_Rot_1D extends Hit_HP_Tracker

@export var ROTATOR:Rotator_1D

##The maximum proportion by which the speed my be affected
@export var SPEED_AFFECT:float = 1.0;
##The maximum proportion by which the acceleration may be affaceted.
@export var ACCELERATION_AFFECT:float = 0.8;


var rotator_speed:float;
var rotator_acceleration:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	assert(ROTATOR != null, "NO rotator set")
	
	rotator_speed = ROTATOR.ROTATION_MAX_SPEED
	rotator_acceleration = ROTATOR.ROTATION_ACCELERATION;
	


func hit(damage):
	super.hit(damage)
	if(ROTATOR == null): return
	
	#Update valeus if changed elsewhere
	if(ROTATOR.ROTATION_MAX_SPEED < rotator_speed): rotator_speed = ROTATOR.ROTATION_MAX_SPEED
	if(ROTATOR.ROTATION_ACCELERATION < rotator_acceleration): rotator_acceleration = ROTATOR.ROTATION_ACCELERATION
	
	ROTATOR.ROTATION_MAX_SPEED = rotator_speed * (1.0-((1.0-max(0, HP/MAX_HP)) * SPEED_AFFECT))
	ROTATOR.ROTATION_ACCELERATION = rotator_acceleration * (1.0-((1.0-max(0, HP/MAX_HP)) * ACCELERATION_AFFECT))
