class_name Gun_Part_DAHammer extends Gun_Part_Rotateable

@export_group("Listeners")
@export var RELEASE_LISTENER:Gun_Part_Listener;

@export var TRIGGER:Gun_Part_Listener;

@export_group("Settings")
##Cocked angle. strikes at angle == 0
@export_range(0, 180, 1.0, "radians_as_degrees") var COCKED_ANGLE = PI/4;


##Rads^-1. Minimum velocity to strike, and trigger.
@export var VELOCITY_THRESHOLD:float = 0.4
## IF TRUE, cannot be manipulated past cock unless triggered to release.
@export var LOCK_IN_COCK:bool = false;


var is_cocked:bool = false;

##Ready
func _ready():
	
	connect_listener(RELEASE_LISTENER, release);
	super._ready();

func release():
	if(is_cocked):
		functional_min = MIN_ANGLE
		is_cocked = false;
	

func enable_focus():
	super.enable_focus()
	if(!LOCK_IN_COCK): # limit @ cock when held
		functional_min = MIN_ANGLE

func disable_focus():
	super.disable_focus()
	if(is_cocked):
		functional_min = COCKED_ANGLE


func hit_min_angle(speed:float) -> void:
	if current_angle == MIN_ANGLE and abs(speed) > VELOCITY_THRESHOLD:
		#print(current_angle)
		if(TRIGGER != null):
			TRIGGER.trigger();
		else:
			print("bang!")
func hit_max_angle(_speed:float) -> void:
	pass



func _process(delta:float) -> void:
	super._process(delta);

func _physics_process(delta:float) -> void:
	super._physics_process(delta);
	
	if(is_focused):
		if(current_angle >= COCKED_ANGLE):
			is_cocked = true;
			if(LOCK_IN_COCK):
				functional_min = COCKED_ANGLE
		else:
			is_cocked = false;
		#if(LOCK_IN_COCK):
		#	MIN_ANGLE = COCKED_ANGLE;
