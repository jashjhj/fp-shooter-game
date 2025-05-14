class_name Gun_Part_SAHammer extends Gun_Part

@export_group("Listeners")
@export var COCK_LISTENER:Gun_Part_Listener;
@export var RELEASE_LISTENER:Gun_Part_Listener;

@export var TRIGGER:Gun_Part_Listener;

@export_group("Mechanism")
##Node3D that rotates like the hammer.
@export var VISUAL_HAMMER:Node3D;
@export_range(0, 180, 1.0, "radians_as_degrees") var COCKED_ANGLE = PI/6;
@export var ROTATE_AROUND:Vector3 = Vector3.RIGHT;

@export var cock_speed := 0.05
@export var decock_speed := 1.0



## 0 is decocked, 1 is cocked
var cock_decock_progress := 1.0;
var cock_decock_goal := 1.0;

var hammer_stationary = true;

var hammer_falling := false;

var original_hammer_basis:Basis;

func _ready() -> void:
	if(RELEASE_LISTENER == null):
		push_warning("Listener not set!")
	else: RELEASE_LISTENER.triggered.connect(_release);
	
	if(COCK_LISTENER == null):
		push_warning("listener not set!")
	else: COCK_LISTENER.triggered.connect(_cock)
	
	if(VISUAL_HAMMER != null): original_hammer_basis = VISUAL_HAMMER.transform.basis;


func _release():
	if(!hammer_falling): # if not fallign forwards
		if(get_is_cocked()):
			hammer_falling = true;
			cock_decock_goal = 0.0;
			hammer_stationary = false;

func hammer_hit():
	TRIGGER.trigger();
	_cock()

func _cock():
	cock_decock_goal = 1.0;
	hammer_stationary = false;




func _process(delta: float) -> void:
	
	if(!hammer_stationary):
		if(abs(cock_decock_progress - 0.5) > 0.48): # If hit goal: ( more than 48% away from middle - accepts clamping
			if(hammer_falling and cock_decock_progress < 0.02): # If just hit top while hammer falling
				hammer_falling = false;
				hammer_hit()
			
			#Snap to it:
			if(abs(cock_decock_progress - cock_decock_goal) < 0.02): # if really close
				cock_decock_progress = cock_decock_goal # snap to it
				hammer_stationary = true;
		
		var next_step_size
		if(get_is_cocked()):
			next_step_size = -(delta/cock_speed);
		else:
			next_step_size = (delta/decock_speed);
		
		cock_decock_progress += next_step_size
	
	
	#Cosmetics
	if(VISUAL_HAMMER != null):
		var current_angle:float;
		if(get_is_cocked()): # If decocking
			current_angle = map_hammer_cocking(cock_decock_progress) * COCKED_ANGLE
		else:
			current_angle = map_hammer_decocking(cock_decock_progress) * COCKED_ANGLE
		VISUAL_HAMMER.transform.basis = original_hammer_basis
		VISUAL_HAMMER.transform = VISUAL_HAMMER.transform.rotated_local(ROTATE_AROUND, -current_angle);


#returns true if currently cocked, until it is next decocked
func get_is_cocked():
	return bool(round(cock_decock_goal)) if hammer_stationary else cock_decock_progress > cock_decock_goal # wish.com ternary operator

func map_hammer_decocking(input:float) -> float:
	return input

func map_hammer_cocking(input:float) -> float:
	return 1-(1-input)*(1-input)*(1-input)
