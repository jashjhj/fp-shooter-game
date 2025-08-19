class_name One_Way_Constraint extends Enableable

@export var INTERACTIVE:Tool_Part_Interactive_1D

@export var THRESHOLD:float = 0.1;

## Is the limit a min or a max, once its gone past it  |-|  0 == min, 1 == max. 
@export_enum("MIN:0", "MAX:1") var MIN_MAX:int;



var is_limit_set:bool = false:
	set(v):
		if(is_limit_set == v): return
		is_limit_set = v
		#print(is_limit_set)
		if(is_limit_set):
			if(MIN_MAX == 0): # min
				INTERACTIVE.add_min_limit(THRESHOLD)
			if(MIN_MAX == 1): # max
				INTERACTIVE.add_max_limit(THRESHOLD)
		else:
			if(MIN_MAX == 0): # min
				INTERACTIVE.remove_min_limit(THRESHOLD)
			if(MIN_MAX == 1): # max
				INTERACTIVE.remove_max_limit(THRESHOLD)


@onready var THRESHOLD_TRIGGER:Triggerable = Triggerable.new()


func is_enabled_set():
	super.is_enabled_set()
	if(is_enabled):
		if(INTERACTIVE.DISTANCE >= THRESHOLD and MIN_MAX == 0):
			is_limit_set = true
		elif(INTERACTIVE.DISTANCE <= THRESHOLD and MIN_MAX == 1):
			is_limit_set = true
		
	else: # if not enabled, disable limit!
		
		is_limit_set = false


func _ready() -> void:
	INTERACTIVE.TRIGGERS_TRIGGERABLE.append(THRESHOLD_TRIGGER)
	INTERACTIVE.TRIGGERS_DISTANCE.append(THRESHOLD)
	INTERACTIVE.TRIGGERS_DIRECTION.append(INTERACTIVE.TRIGGERS_DIRECTION_ENUM.BOTH)
	THRESHOLD_TRIGGER.on_trigger.connect(passes_threshold)

func passes_threshold():
	if(!is_enabled): return
	
	if(MIN_MAX == 0):#min
		if(INTERACTIVE.DISTANCE >= THRESHOLD): # if just gone beyond
			is_limit_set = true
	elif(MIN_MAX == 1):
		if(INTERACTIVE.DISTANCE <= THRESHOLD): # if just gone beyond
			is_limit_set = true
