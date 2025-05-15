class_name Gun_Part_DAHammer extends Gun_Part_Rotateable

@export_group("Listeners")
@export var RELEASE_LISTENER:Gun_Part_Listener;

@export var TRIGGER:Gun_Part_Listener;

@export_group("Mechanism")
##Node3D that rotates like the hammer.
@export var VISUAL_HAMMER:Node3D;
@export_range(0, 180, 1.0, "radians_as_degrees") var COCKED_ANGLE = PI/4;
@export_range(0, 180, 1.0, "radians_as_degrees") var MAX_ANGLE = PI/3;

##Spring force in (arbitrary)*metres
@export var SPRING_FORCE:float = 10.0;
## 0 -> 1 = 0 -> MAX_ANGLE
@export var FOCUS_RESISTANCE_CURVE:Curve;

@export var ELASTICITY_TOP:float = 0.2;
@export var ELASTICITY_BOTTOM:float = 0.1;

##Rads^-1. Minimum velocity to strike, and trigger. Maximum from cock ~=< sqrt(2*SPRING_FORCE*COCKED_ANGLE)/10
@export var VELOCITY_THRESHOLD:float = 0.4

var current_angular_velocity:float;

var is_cocked:bool = false;

##Ready
func _ready():
	if(FOCUS_RESISTANCE_CURVE == null):
		push_error("No Resistance Curve set.")
	elif(FOCUS_RESISTANCE_CURVE.point_count <= 0):
		push_warning("No points set on Resistance Curve.")
		FOCUS_RESISTANCE_CURVE.add_point(Vector2(0, 0.1));
	
	connect_listener(RELEASE_LISTENER, release);
	super._ready();

func release():
	is_cocked = false;



func _process(delta:float) -> void:
	super._process(delta);
	
	if(VISUAL_HAMMER != null):
		VISUAL_HAMMER.transform.basis = Basis.IDENTITY
		VISUAL_HAMMER.rotate_object_local(ROTATION_AXIS, current_angle)
	

func _physics_process(delta:float) -> void:
	
	if(is_focused):
		current_angular_velocity = 0; # make it grabbed
		#Glorified lerp, following curve to add resistance
		var follow_delta = (angle_goal - current_angle) * min(FOCUS_RESISTANCE_CURVE.sample(current_angle/MAX_ANGLE), 0.8)
		current_angle += follow_delta
		
		
		current_angle = max(min(current_angle, MAX_ANGLE), 0);
		
		if(is_cocked):
			current_angle = max(current_angle, COCKED_ANGLE)
		
	else:
		var forces:float = -SPRING_FORCE
		
		
		current_angular_velocity += forces*delta;
		current_angle += current_angular_velocity
		
		if(current_angle < 0):
			print(current_angular_velocity)
			if(abs(current_angular_velocity) > VELOCITY_THRESHOLD): # If hits hard enough, trigger!
				print("BANG")
				if(TRIGGER != null):
					TRIGGER.trigger()#!!!
			
			
			current_angle = 0;
			current_angular_velocity *= -ELASTICITY_TOP;
		elif(current_angle < COCKED_ANGLE and is_cocked):
			current_angle = COCKED_ANGLE;
			current_angular_velocity = 0;
		
	
	if(!is_cocked): # If not yet cocked, test to see if so.
		if(current_angle > COCKED_ANGLE):
			is_cocked = true;

#Enable and disable being clicked on
func enable_focus():
	super.enable_focus()

func disable_focus():
	super.disable_focus()
