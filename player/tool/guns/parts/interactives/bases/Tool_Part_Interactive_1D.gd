class_name Tool_Part_Interactive_1D extends Tool_Part_Interactive

##Start position / distance / rotation.
@export var DISTANCE:float = 0.0;
var prev_distance:float = DISTANCE

##Ready
func _ready():
	super._ready();

func _process(delta:float) -> void:
	super._process(delta);

func _physics_process(delta:float) -> void:
	
	optional_extras()
	prev_distance = DISTANCE
	#super(delta)


@export_group("Triggers", "TRIGGERS_")
enum TRIGGERS_DIRECTION_ENUM {
	FORWARDS = 1,
	BACKWARDS = 2,
	BOTH = 3
}
@export var TRIGGERS_TRIGGERABLE:Array[Triggerable]
@export var TRIGGERS_DISTANCE:Array[float]
@export var TRIGGERS_DIRECTION:Array[TRIGGERS_DIRECTION_ENUM]

func optional_extras():
	for i in range(0, len(TRIGGERS_TRIGGERABLE)): # check thresholds
		
		if(TRIGGERS_DIRECTION[i] == 1 or TRIGGERS_DIRECTION[i] == 3): # Forwards
			if(DISTANCE >= TRIGGERS_DISTANCE[i] and prev_distance < TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()
		
		if(TRIGGERS_DIRECTION[i] == 2 or TRIGGERS_DIRECTION[i] == 3): # Backwards
			if(DISTANCE <= TRIGGERS_DISTANCE[i] and prev_distance > TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()
