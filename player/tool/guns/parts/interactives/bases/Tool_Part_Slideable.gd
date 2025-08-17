class_name Tool_Part_Slideable extends Tool_Part_Interactive

@export var MODEL:Node3D;

@export var SLIDE_VECTOR:Vector3 = Vector3(0, 0, 1);
@export var SLIDE_DISTANCE:float = 0.2;
@export var SLIDE_START_POS:float = 0;


@export_group("Triggers", "TRIGGERS_")
enum TRIGGERS_DIRECTION_ENUM {
	FORWARDS = 1,
	BACKWARDS = 2,
	BOTH = 3
}
@export var TRIGGERS_TRIGGERABLE:Array[Triggerable]
@export var TRIGGERS_DISTANCE:Array[float]
@export var TRIGGERS_DIRECTION:Array[TRIGGERS_DIRECTION_ENUM]
#@export_enum("Forwards", "Backwards", "Both") var EJECT_WHEN_DIR:int = 1;

@export var LERP_RATE:float = 0.3;


@export_group("Extras")
@export var SPRING_CONSTANT:float = 0.0;
##Simulated compressed length, added to extension. Use negative for negative forces.
@export var SPRING_COMPRESSION:float = 0.05;
@export var APPLY_FORCES_TO:RigidBody3D;
@export var SIMULATED_MASS:float = 0.2;

#TODO add is_seated code to tell if can fire.

var model_goal:Node3D = Node3D.new()

@onready var slide_pos:float = SLIDE_START_POS
@onready var visual_slide_pos:float = SLIDE_START_POS;
var start_focus_slide_pos:float;


var velocity:float = 0.0;

##Ready
func _ready():
	SLIDE_VECTOR = SLIDE_VECTOR.normalized()
	super._ready();
	
	await get_parent().ready
	
	add_child(model_goal)
	assert(len(TRIGGERS_TRIGGERABLE) == len(TRIGGERS_DISTANCE) and len(TRIGGERS_TRIGGERABLE) == len(TRIGGERS_DIRECTION), "Triggers Arrays must be matching lengths")
	assert(MODEL != null, "No model Set for slideable.")


var prev_mouse_delta:float;
var prev_slide_pos:float = 0;
var prev_velocity:float = 0;
func _process(delta:float) -> void:
	super._process(delta);
	
	
	


func _physics_process(delta: float) -> void:
	
	prev_slide_pos = slide_pos;
	prev_velocity = velocity
	
	if(is_focused):
		var mouse_goal_delta_from_start = (get_mouse_plane_position()-global_position - global_basis*mouse_focus_pos_relative).dot(global_basis*SLIDE_VECTOR)
		var mouse_goal_delta = mouse_goal_delta_from_start - prev_mouse_delta
		slide_pos += mouse_goal_delta# +start_focus_slide_pos 
		
		velocity = (slide_pos - prev_slide_pos)/delta
		
		prev_mouse_delta = mouse_goal_delta_from_start
	
	else:#not focused
		slide_pos += velocity*delta;
	
	if(slide_pos < 0 or slide_pos > SLIDE_DISTANCE): velocity = 0;
	slide_pos = max(0, slide_pos)
	slide_pos = min(SLIDE_DISTANCE, slide_pos)
	
	model_goal.global_position = global_position + slide_pos*(global_basis*SLIDE_VECTOR)
	
	#Debug.point(model_goal.global_position)
	
	MODEL.global_position = model_goal.global_position
	visual_slide_pos = slide_pos
	
	
	#f=ke, (dv) = a*t = f/m * t
	var spring_force:float = SPRING_CONSTANT*(SPRING_COMPRESSION + slide_pos) / SIMULATED_MASS
	if(is_focused):
		velocity = (slide_pos - prev_slide_pos) / delta
		
		APPLY_FORCES_TO.apply_force(-spring_force * (global_basis*SLIDE_VECTOR) * 0.1, global_position - APPLY_FORCES_TO.global_position)
	else:
		velocity += spring_force*delta;
		if(APPLY_FORCES_TO != null): # applies DV to object
			APPLY_FORCES_TO.apply_impulse(-(velocity - prev_velocity) * (global_basis*SLIDE_VECTOR.normalized()), global_position - APPLY_FORCES_TO.global_position)
			
	
	#aif(APPLY_FORCES_TO != null):
	
	
	
	for i in range(0, len(TRIGGERS_TRIGGERABLE)): # check thresholds
		
		if(TRIGGERS_DIRECTION[i] == 1 or TRIGGERS_DIRECTION[i] == 3): # Forwards
			if(slide_pos >= TRIGGERS_DISTANCE[i] and prev_slide_pos < TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()
		
		if(TRIGGERS_DIRECTION[i] == 2 or TRIGGERS_DIRECTION[i] == 3): # Backwards
			if(slide_pos <= TRIGGERS_DISTANCE[i] and prev_slide_pos > TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()
	
	
	
	

#Enable and disable being clicked on
func enable_focus():
	INTERACT_PLANE.global_position = mouse_focus_pos
	
	var plane_normal = (global_basis*SLIDE_VECTOR).cross(get_viewport().get_camera_3d().global_position - global_position).cross(global_basis*SLIDE_VECTOR)
	set_interact_plane_normal(global_basis.inverse()*plane_normal)

	start_focus_slide_pos = slide_pos
	prev_mouse_delta = 0;

func disable_focus():
	pass
