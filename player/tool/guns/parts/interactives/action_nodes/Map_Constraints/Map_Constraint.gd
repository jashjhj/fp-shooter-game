class_name Map_Constraint extends Enableable

@export var PRIMARY:Tool_Part_Interactive_1D
@export var SECONDARY:Tool_Part_Interactive_1D

@export var DOMAIN_START:float = 0.0;
@export var DOMAIN_END:float = 0.1;
@export var RANGE_START:float = 0;
@export var RANGE_END:float = 0.1

var is_first_min:bool = true;
var is_first_max:bool = true;
var prev_min_val:float;
var prev_max_val:float


func is_enabled_set():
	super.is_enabled_set()
	if(!is_enabled): # rens enabling/disabling
		if(!is_first_min):
			SECONDARY.remove_min_limit(prev_min_val)
		if(!is_first_max):
			SECONDARY.remove_max_limit(prev_max_val)
		
		else:
			if(!is_first_min):
				SECONDARY.add_min_limit(prev_min_val)
			if(!is_first_max):
				SECONDARY.add_max_limit(prev_max_val)

func apply_constraint_min(val):
	if(is_first_min):
		is_first_min = false
	else:
		SECONDARY.remove_min_limit(prev_min_val) # dont remove on first iteration
	SECONDARY.add_min_limit(val)
	prev_min_val = val

func apply_constraint_max(val):
	if(is_first_max):
		is_first_max = false
	else:
		SECONDARY.remove_max_limit(prev_max_val) # dont remove on first iteration
	SECONDARY.add_max_limit(val)
	prev_max_val = val


func _physics_process(delta: float) -> void:
	if(!is_enabled): return
	
	#Processes. CALCULATE_RANGE_MIN works entirely on remapped, normalised values
	apply_constraint_min(remap(calculate_range_min(min(1.0, max(0.0, remap(PRIMARY.DISTANCE, DOMAIN_START, DOMAIN_END, 0.0, 1.0)))), 0.0, 1.0, RANGE_START, RANGE_END))
	apply_constraint_max(remap(calculate_range_max(min(1.0, max(0.0, remap(PRIMARY.DISTANCE, DOMAIN_START, DOMAIN_END, 0.0, 1.0)))), 0.0, 1.0, RANGE_START, RANGE_END))

##Domain: 0.0 -> 1.0. Return range, 0.0 -> 1.0
func calculate_range_min(domain:float) -> float:
	return -INF

##Domain: 0.0 -> 1.0. Return range, 0.0 -> 1.0
func calculate_range_max(domain:float) -> float:
	return INF
