class_name Tool_Part_Slideable extends Tool_Part_Interactive_1D

@export var MODEL:Node3D;

@export var SLIDE_VECTOR:Vector3 = Vector3(0, 0, 1);
@export var SLIDE_DISTANCE:float = 0.2;
@export var SLIDE_START_POS:float = 0;




@export var LERP_RATE:float = 0.3;


#@export_group("Extras")
#@export var APPLY_FORCES_TO:RigidBody3D;
#@export var SIMULATED_MASS:float = 0.2;

#TODO add is_seated code to tell if can fire.

var model_goal:Node3D = Node3D.new()

#@onready var visual_slide_pos:float = SLIDE_START_POS;
var start_focus_slide_pos:float;



##Ready
func _ready():
	SLIDE_VECTOR = SLIDE_VECTOR.normalized()
	super._ready();
	
	await get_parent().ready
	
	add_child(model_goal)
	assert(len(TRIGGERS_TRIGGERABLE) == len(TRIGGERS_DISTANCE) and len(TRIGGERS_TRIGGERABLE) == len(TRIGGERS_DIRECTION), "Triggers Arrays must be matching lengths")
	assert(MODEL != null, "No model Set for slideable.")


var prev_mouse_delta:float;
var mouse_goal_delta_from_start:float;
var mouse_goal_delta:float;


var prev_velocity:float = 0;
func _process(delta:float) -> void:
	super._process(delta);
	
	if(is_focused): # get inputs in process
		pass
	

var stored_velocity:float = 0.0;

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	prev_velocity = velocity
	
	if(is_focused):
		mouse_goal_delta_from_start = (get_mouse_plane_position()-global_position - global_basis*mouse_focus_pos_relative).dot(global_basis*SLIDE_VECTOR)
		mouse_goal_delta = mouse_goal_delta_from_start - prev_mouse_delta
		
		
		
		DISTANCE += mouse_goal_delta# +start_focus_slide_pos 
		
		velocity = (DISTANCE - prev_distance)/delta
		
		prev_mouse_delta = mouse_goal_delta_from_start
	
	else:#not focused
		DISTANCE += velocity*delta;
	
	if(DISTANCE < 0 or DISTANCE > SLIDE_DISTANCE): velocity = 0;
	DISTANCE = max(0, DISTANCE)
	DISTANCE = min(SLIDE_DISTANCE, DISTANCE)
	
	model_goal.global_position = global_position + DISTANCE*(global_basis*SLIDE_VECTOR)
	
	#Debug.point(model_goal.global_position)
	
	MODEL.global_position = model_goal.global_position
	
	
	#f=ke, (dv) = a*t = f/m * t
	#var spring_force:float = SPRING_CONSTANT*(SPRING_COMPRESSION + DISTANCE) / SIMULATED_MASS
	if(is_focused):
		stored_velocity = lerp(stored_velocity, (DISTANCE - prev_distance) / delta, delta / 0.03) # over 0.5s
		velocity = 0;
		#APPLY_FORCES_TO.apply_force(-spring_force * (global_basis*SLIDE_VECTOR) * 0.1, global_position - APPLY_FORCES_TO.global_position)
	else:
		pass
		#if(APPLY_FORCES_TO != null): # applies DV to object
		#	APPLY_FORCES_TO.apply_impulse(-(velocity - prev_velocity) * (global_basis*SLIDE_VECTOR.normalized()), global_position - APPLY_FORCES_TO.global_position)
			
	
	#aif(APPLY_FORCES_TO != null):
	
	
	
	

#Enable and disable being clicked on
func enable_focus():
	INTERACT_PLANE.global_position = mouse_focus_pos
	
	var plane_normal = (global_basis*SLIDE_VECTOR).cross(get_viewport().get_camera_3d().global_position - global_position).cross(global_basis*SLIDE_VECTOR)
	set_interact_plane_normal(global_basis.inverse()*plane_normal)

	start_focus_slide_pos = DISTANCE
	prev_mouse_delta = 0;

func disable_focus():
	super.disable_focus()
	#velocity = stored_velocity * 0.1
