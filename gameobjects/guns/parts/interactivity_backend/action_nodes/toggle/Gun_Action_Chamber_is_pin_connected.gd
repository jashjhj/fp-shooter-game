class_name Gun_Action_Chamber_is_pin_connected extends Gun_Action_Toggle

@export var CHAMBER:Gun_Part_Chamber_Manual;

func _ready():
	check_node_is_set(CHAMBER, true)
	super._ready()

func activate():
	if check_node_is_set(CHAMBER):
		CHAMBER.is_pin_connected = true;

func deactivate():
	if check_node_is_set(CHAMBER):
		CHAMBER.is_pin_connected = false;
