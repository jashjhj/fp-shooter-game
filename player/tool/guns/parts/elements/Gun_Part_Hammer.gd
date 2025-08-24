class_name Gun_Part_DAHammer extends Tool_Part_Rotateable

@export_group("Listeners")
@export var RELEASE_LISTENER:Triggerable;

@export var TRIGGER:Triggerable;

@export_group("Settings")
##Cocked angle. strikes at angle == 0
@export_range(0, 180, 1.0, "radians_as_degrees") var COCKED_ANGLE = PI/4;
##Angle at which hammer hits what it wants to trigger
@export_range(0, 180, 1.0, "radians_as_degrees") var TRIGGER_ANGLE = 0;


##Rads^-1. Minimum velocity to strike, and trigger.
@export var VELOCITY_THRESHOLD:float = 0.04
## IF TRUE, cannot be manipulated past cock unless triggered to release.
@export var LOCK_IN_COCK:bool = false;



@export_group("DEBUG")
@export var show_hit_speed:bool = false;

var is_cock_limit_set:bool = false:
	set(v):
		if(v != is_cock_limit_set): # applies / removes limit
			is_cock_limit_set = v;
			if(is_cock_limit_set):
				add_min_limit(COCKED_ANGLE)
			else:
				remove_min_limit(COCKED_ANGLE)

#Is it behind the cocking point
var is_cocked:bool = false:
	set(v):
		is_cocked = v
		#if(is_cocked and !is_cock_limit_set):
			#if(!is_focused or LOCK_IN_COCK):
				#is_cock_limit_set = true
		#
		#if(!is_cocked and is_cock_limit_set):
			#is_cock_limit_set = false

##Ready
func _ready():
	
	RELEASE_LISTENER.on_trigger.connect(release_hammer)
	
	super._ready();


#var last_release_tick:int;
#const release_window:int = 17; # window in which being told to relase does not hold abck the hammer
var release_timer:float = 0.0


func release_hammer():
	#print("release")
	is_cock_limit_set = false;
	release_timer = 0.1
	


func enable_focus():
	super.enable_focus()
	if(!LOCK_IN_COCK):
		is_cock_limit_set = false

func disable_focus():
	super.disable_focus()
	if(!LOCK_IN_COCK and is_cocked): # set on mosue focus release if its cocked but not locked YET
		is_cock_limit_set = true


func hit_min_limit() -> void:
	if(show_hit_speed):print(velocity)
	
	super.hit_min_limit()
	if DISTANCE <= TRIGGER_ANGLE and abs(velocity) > abs(VELOCITY_THRESHOLD):
		#print(velocity)
		#print(current_angle)
		if(TRIGGER != null):
			TRIGGER.trigger()
		else: # if no trigger set, just say BANG to communicate while debugging.
			print("bang!")

func hit_max_angle(_speed:float) -> void:
	pass



func _process(delta:float) -> void:
	super._process(delta);

func _physics_process(delta:float) -> void:
	super._physics_process(delta);
	#print(velocity)
	
	
	
	if(DISTANCE >= COCKED_ANGLE):
		
		if(!is_focused and !is_cocked):# Checker for if its made to be cocked during play.
			is_cock_limit_set = true # called the first time the hammer is cocked
		
		
		release_timer -= delta # Essentially: If it was 'told' to fall, and does not for 0.1 seconds (remains cocked throughout), it resets the cock
		if(!is_focused and !is_cock_limit_set): 
			if(release_timer < 0):
				is_cock_limit_set = true

		
		
		
		is_cocked = true;
	else:
		release_timer = INF
		is_cocked = false;
		#if(LOCK_IN_COCK):
		#	MIN_ANGLE = COCKED_ANGLE;
