extends Triggerable

@export var SAFETY:Mechanism_Safety;

func _ready() -> void:
	assert(SAFETY != null, "No Safety set")
	super()
	
	

func trigger() -> void:
	super.trigger();
	
	if(SAFETY.SAFETY_STARTS_ON):
		SAFETY.SAFETY.DISTANCE = SAFETY.SAFETY.get_max_distance()
	else:
		SAFETY.SAFETY.DISTANCE = SAFETY.SAFETY.get_min_distance()
