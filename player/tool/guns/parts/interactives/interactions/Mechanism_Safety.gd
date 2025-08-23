class_name Mechanism_Safety extends Node

@export var SAFETY:Tool_Part_Interactive_1D
@export var SAFETY_STARTS_ON:bool = true

@export var HAMMER:Gun_Part_DAHammer
@export var SLIDE:Tool_Part_Interactive_1D

@onready var CONSTRAINT_HAMMER:Map_Constraint_Linear_Max = Map_Constraint_Linear_Max.new();



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(SAFETY != null, "No Safety set")
	assert(HAMMER != null, "No Hammer set")
	
	CONSTRAINT_HAMMER.PRIMARY = SAFETY
	CONSTRAINT_HAMMER.SECONDARY = HAMMER
	if(SAFETY_STARTS_ON):
		CONSTRAINT_HAMMER.DOMAIN_START = SAFETY.get_min_distance()
		CONSTRAINT_HAMMER.DOMAIN_END = SAFETY.get_max_distance()
	else: # have opposite way round otherwise
		CONSTRAINT_HAMMER.DOMAIN_START = SAFETY.get_max_distance()
		CONSTRAINT_HAMMER.DOMAIN_END = SAFETY.get_min_distance()
	CONSTRAINT_HAMMER.RANGE_START = HAMMER.get_min_distance()
	CONSTRAINT_HAMMER.RANGE_END = HAMMER.get_max_distance()
	CONSTRAINT_HAMMER.SET_MIN = false
	CONSTRAINT_HAMMER.SET_MAX = true
	CONSTRAINT_HAMMER.is_enabled = true
	
	if(SAFETY_STARTS_ON):
		SAFETY.add_new_trigger((SAFETY.get_max_distance() * 3 + SAFETY.get_min_distance()) / 4.0, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(disable_safety)
		SAFETY.add_new_trigger((SAFETY.get_min_distance() * 3 + SAFETY.get_max_distance()) / 4.0, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.BACKWARDS).connect(enable_safety)
		enable_safety()
	else:
		SAFETY.add_new_trigger((SAFETY.get_min_distance() * 3 + SAFETY.get_max_distance()) / 4.0, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.BACKWARDS).connect(disable_safety)
		SAFETY.add_new_trigger((SAFETY.get_max_distance() * 3 + SAFETY.get_min_distance()) / 4.0, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(enable_safety)
	
	add_child(CONSTRAINT_HAMMER)

var is_slide_limit_set:bool = false
func enable_safety():
	HAMMER.release_hammer()
	if(SLIDE != null and !is_slide_limit_set):
		SLIDE.add_max_limit(0.003)
		is_slide_limit_set = true

func disable_safety():
	if(SLIDE != null and is_slide_limit_set):
		SLIDE.remove_max_limit(0.003)
		is_slide_limit_set = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print_debug(HAMMER.MAX_LIMITS)
	pass
