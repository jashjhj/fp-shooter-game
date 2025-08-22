class_name Mechanism_Slide_Lock extends Node

@export var SLIDE:Tool_Part_Interactive_1D;
@export var SLIDELOCK:Tool_Part_Interactive_1D;

##Distance at which to limit slide. Sets MIN_DISTANCE there.
@export var SLIDE_LOCK_DISTANCE:float = 0.1;
@export var SLIDE_LOCK_DISTANCE_SET:float = 0.11;
@export var SLIDE_LOCK_DISTANCE_RESET:float = 0.12;
@export var LOCK_IF_MAG_EMPTY:Tool_Part_Insertable_Slot;


@onready var CONSTRAINT_SLIDELOCK_SET:Map_Constraint_Linear_Min = Map_Constraint_Linear_Min.new()
@onready var CONSTRAINT_SLIDELOCK_RESET:Map_Constraint_Linear_Max = Map_Constraint_Linear_Max.new()
@onready var CONSTRAINT_SLIDE:One_Way_Constraint = One_Way_Constraint.new()


var is_slidelock_set:bool = false:
	set(v):
		if v == is_slidelock_set: return
		is_slidelock_set = v
		if(is_slidelock_set):
			CONSTRAINT_SLIDE.is_enabled = true
		else:
			CONSTRAINT_SLIDE.is_enabled = false

func enable_slidelock():
	is_slidelock_set = true;
func disable_slidelock():
	is_slidelock_set = false;

var is_also_select_slide_enabled:bool = false:
	set(v):
		if(v == is_also_select_slide_enabled): return
		is_also_select_slide_enabled = v
		if(is_also_select_slide_enabled):
			SLIDELOCK.ALSO_SELECT.append(SLIDE)
		else:
			var index:int = SLIDELOCK.ALSO_SELECT.find(SLIDE)
			if index >= 0:
				SLIDELOCK.ALSO_SELECT.remove_at(index)

func enable_also_select():
	is_also_select_slide_enabled = true
func disable_also_select():
	is_also_select_slide_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(SLIDE != null, "No Slide set")
	assert(SLIDELOCK != null, "No Slidelock set")
	
	
	if(!SLIDE.is_node_ready()): await SLIDE.ready
	if(!SLIDELOCK.is_node_ready()): await SLIDELOCK.ready
	
	CONSTRAINT_SLIDELOCK_SET.PRIMARY = SLIDE
	CONSTRAINT_SLIDELOCK_SET.SECONDARY = SLIDELOCK
	CONSTRAINT_SLIDELOCK_SET.DOMAIN_START = SLIDE_LOCK_DISTANCE_RESET
	CONSTRAINT_SLIDELOCK_SET.DOMAIN_END = SLIDE_LOCK_DISTANCE_SET
	CONSTRAINT_SLIDELOCK_SET.RANGE_START = SLIDELOCK.get_min_distance()
	CONSTRAINT_SLIDELOCK_SET.RANGE_END = SLIDELOCK.get_max_distance()
	CONSTRAINT_SLIDELOCK_SET.is_enabled = false;
	CONSTRAINT_SLIDELOCK_SET.SET_MAX = false
	
	CONSTRAINT_SLIDELOCK_RESET.PRIMARY = SLIDE
	CONSTRAINT_SLIDELOCK_RESET.SECONDARY = SLIDELOCK
	CONSTRAINT_SLIDELOCK_RESET.DOMAIN_START = SLIDE_LOCK_DISTANCE_SET
	CONSTRAINT_SLIDELOCK_RESET.DOMAIN_END = SLIDE_LOCK_DISTANCE_RESET
	CONSTRAINT_SLIDELOCK_RESET.RANGE_START = SLIDELOCK.get_max_distance()
	CONSTRAINT_SLIDELOCK_RESET.RANGE_END = SLIDELOCK.get_min_distance()
	CONSTRAINT_SLIDELOCK_RESET.is_enabled = false
	CONSTRAINT_SLIDELOCK_RESET.SET_MIN = false
	
	CONSTRAINT_SLIDE.INTERACTIVE = SLIDE
	CONSTRAINT_SLIDE.THRESHOLD = SLIDE_LOCK_DISTANCE
	CONSTRAINT_SLIDE.MIN_MAX = 0;
	CONSTRAINT_SLIDE.is_enabled = false
	
	add_child(CONSTRAINT_SLIDELOCK_SET)
	add_child(CONSTRAINT_SLIDELOCK_RESET)
	add_child(CONSTRAINT_SLIDE)
	
	SLIDELOCK.add_new_trigger((SLIDELOCK.get_min_distance() + SLIDELOCK.get_max_distance()) / 2, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(enable_slidelock)
	SLIDELOCK.add_new_trigger((SLIDELOCK.get_min_distance() + SLIDELOCK.get_max_distance()) / 2, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.BACKWARDS).connect(disable_slidelock)
	SLIDELOCK.add_new_trigger((SLIDELOCK.get_min_distance() + SLIDELOCK.get_max_distance()) / 2, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.BACKWARDS).connect(enable_also_select)
	SLIDELOCK.add_new_trigger((SLIDELOCK.get_min_distance() + SLIDELOCK.get_max_distance()) / 2, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.FORWARDS).connect(disable_also_select)
	
	SLIDE.add_new_trigger(SLIDE_LOCK_DISTANCE, Tool_Part_Interactive_1D.TRIGGERS_DIRECTION_ENUM.BACKWARDS).connect(check_force_slidelock)
	
	enable_also_select()



func _physics_process(delta: float) -> void:
	#print("MINS: ", SLIDELOCK.MIN_LIMITS, "           MAXS: ", SLIDELOCK.MAX_LIMITS)
	CONSTRAINT_SLIDELOCK_RESET.is_enabled = !SLIDELOCK.is_focused and SLIDE.DISTANCE >= SLIDE_LOCK_DISTANCE and SLIDE.velocity >= 0;
	#if(LOCK_IF_MAG_EMPTY != null and LOCK_IF_MAG_EMPTY.housed_insertable is Gun_Insertable_Mag):
		#
		## lock if mag instered is empty
		#CONSTRAINT_SLIDELOCK_SET.is_enabled = !SLIDELOCK.is_focused and SLIDE.DISTANCE >= SLIDE_LOCK_DISTANCE and SLIDE.velocity <= 0 and \
				#LOCK_IF_MAG_EMPTY.is_housed_fully and \
				#LOCK_IF_MAG_EMPTY.housed_insertable.STORING == 0;
			#
			#
	#else:
		#CONSTRAINT_SLIDELOCK_SET.is_enabled = !SLIDELOCK.is_focused and SLIDE.DISTANCE >= SLIDE_LOCK_DISTANCE and SLIDE.velocity <= 0;
	#print(CONSTRAINT_SLIDELOCK_RESET.is_enabled)

##called when slide goes past forwards
func check_force_slidelock():
	var do_force:bool = false
	
	#FInd cases to enable force slidelock.
	# IF (SLIDELOCK IS NOT FOCUSED) and if(LOCK_IS_MOUSE_EMPTY IS SET) then CHECK ITS FULLY HOUSED and if ITS A MAG check if MAG IS EMPTY (lock slide on empty mag. 
	#
	if(LOCK_IF_MAG_EMPTY):
		if(LOCK_IF_MAG_EMPTY.housed_insertable is Gun_Insertable_Mag):
			if(!SLIDELOCK.is_focused and LOCK_IF_MAG_EMPTY.is_housed_fully and LOCK_IF_MAG_EMPTY.housed_insertable.STORING == 0):
				do_force = true
		else:
			if(LOCK_IF_MAG_EMPTY.is_housed_fully):
				do_force = true
	
	elif(!SLIDELOCK.is_focused):
		do_force = true
	
	
	if(do_force):
		SLIDELOCK.DISTANCE = SLIDELOCK.get_max_distance()
		
		SLIDE.DISTANCE = SLIDE_LOCK_DISTANCE # set disatcne first, becasue enabling the slidelock's one-way setter checks it itself
		enable_slidelock()
		
