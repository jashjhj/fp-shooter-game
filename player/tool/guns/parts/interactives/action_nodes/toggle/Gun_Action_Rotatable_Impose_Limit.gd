class_name Gun_Action_Rotateable_Impose_Limit extends Gun_Action_Toggle

@export var ROTATEABLE:Tool_Part_Rotateable;
@export_range(-360, 360, 0.1, "radians_as_degrees") var LIMIT:float

@export_enum("MIN", "MAX") var EDGE:int = 0

func _ready():
	check_node_is_set(ROTATEABLE, true)
	super._ready()

func activate():
	if check_node_is_set(ROTATEABLE):
		if(EDGE == 0):
			ROTATEABLE.functional_min = LIMIT;
		else:
			ROTATEABLE.functional_max = LIMIT;

func deactivate():
	if check_node_is_set(ROTATEABLE):
		if(EDGE == 0):
			ROTATEABLE.functional_min = ROTATEABLE.MIN_ANGLE;
		else:
			ROTATEABLE.functional_max = ROTATEABLE.MAX_ANGLE;
