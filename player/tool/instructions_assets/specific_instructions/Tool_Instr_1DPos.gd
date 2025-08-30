class_name Tool_Instr_1DPos extends Instruction_Resolver

@export var interactive:Tool_Part_Interactive_1D
@export var distance:float;
@export var successful_if_above:bool = true
@export var successful_if_below:bool = false

func _ready() -> void:
	super._ready()
	assert(interactive != null, "No interactiev set.")
	if(!interactive.is_node_ready()): await interactive.ready
	
	interactive.add_new_trigger(distance, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(set_above)
	interactive.add_new_trigger(distance, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.BACKWARDS).connect(set_below)
	

func set_below():
	is_done = successful_if_below
func set_above():
	is_done = successful_if_above
