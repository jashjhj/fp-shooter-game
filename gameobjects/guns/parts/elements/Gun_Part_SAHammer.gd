class_name Gun_Part_DAHammer extends Gun_Part_Rotateable

@export_group("Listeners")
@export var RELEASE_LISTENER:Gun_Part_Listener;

@export var TRIGGER:Gun_Part_Listener;

@export_group("Settings")
##Cocked angle. strikes at angle == 0
@export_range(0, 180, 1.0, "radians_as_degrees") var COCKED_ANGLE = PI/4;

@onready var MIN_ANGLE_RESET = MIN_ANGLE;

##Rads^-1. Minimum velocity to strike, and trigger.
@export var VELOCITY_THRESHOLD:float = 0.4


var is_cocked:bool = false;

##Ready
func _ready():
	
	connect_listener(RELEASE_LISTENER, release);
	super._ready();

func release():
	is_cocked = false;
	MIN_ANGLE = MIN_ANGLE_RESET;



func hit_min_angle(speed:float) -> void:
	if current_angle == MIN_ANGLE_RESET and abs(speed) > VELOCITY_THRESHOLD:
		#print(current_angle)
		TRIGGER.trigger();
func hit_max_angle(speed:float) -> void:
	pass



func _process(delta:float) -> void:
	super._process(delta);

func _physics_process(delta:float) -> void:
	super._physics_process(delta);
	
	if(!is_cocked and current_angle > COCKED_ANGLE):
		is_cocked = true;
		MIN_ANGLE = COCKED_ANGLE;
