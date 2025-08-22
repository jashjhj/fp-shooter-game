class_name Map_Constraint extends Enableable

@export var PRIMARY:Tool_Part_Interactive_1D
@export var SECONDARY:Tool_Part_Interactive_1D

@export var DOMAIN_START:float = 0.0;
@export var DOMAIN_END:float = 0.1;
@export var RANGE_START:float = 0;
@export var RANGE_END:float = 0.1

@export var SET_MIN:bool = true:
	set(v):
		SET_MIN = v
		if(SET_MIN == false):
			if(!is_first_min):
				SECONDARY.remove_min_limit(prev_min_val)
			
			is_first_min = true # set for reinitialisation when enabled.

@export var SET_MAX:bool = true:
	set(v):
		SET_MAX = v
		if(SET_MAX == false):
			if(!is_first_max):
				SECONDARY.remove_min_limit(prev_max_val)
			
			is_first_max = true

var is_first_min:bool = true;
var is_first_max:bool = true;
var prev_min_val:float;
var prev_max_val:float

var is_initialised:bool = false

func _ready() -> void:
	super._ready()
	is_initialised = true
	assert(PRIMARY != null, "No primary set")
	assert(SECONDARY != null, "No secondary set")


func is_enabled_set():
	super.is_enabled_set()
	
	if(!is_enabled): # rens enabling/disabling
		if(!is_first_min):
			SECONDARY.remove_min_limit(prev_min_val)
		if(!is_first_max):
			SECONDARY.remove_max_limit(prev_max_val)
		is_first_max = true
		is_first_min = true
	else: # if just enabled
		set_constraints()


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
	
	set_constraints()


func set_constraints():
	if(!is_initialised): return
	#Processes. CALCULATE_RANGE_MIN works entirely on remapped, normalised values
	if(SET_MIN):	apply_constraint_min(remap(calculate_range_min(min(1.0, max(0.0, remap(PRIMARY.DISTANCE, DOMAIN_START, DOMAIN_END, 0.0, 1.0)))), 0.0, 1.0, RANGE_START, RANGE_END))
	if(SET_MAX):	apply_constraint_max(remap(calculate_range_max(min(1.0, max(0.0, remap(PRIMARY.DISTANCE, DOMAIN_START, DOMAIN_END, 0.0, 1.0)))), 0.0, 1.0, RANGE_START, RANGE_END))

##Domain: 0.0 -> 1.0. Return range, 0.0 -> 1.0
func calculate_range_min(domain:float) -> float:
	return -INF # these can break atransform if range start-end are not in ascending order. If so, disable SET_MIN/SET_MAX

##Domain: 0.0 -> 1.0. Return range, 0.0 -> 1.0
func calculate_range_max(domain:float) -> float:
	return INF
