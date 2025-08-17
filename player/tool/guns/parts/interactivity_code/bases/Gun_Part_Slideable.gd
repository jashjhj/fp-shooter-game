class_name Gun_Part_Slideable extends Gun_Part_Interactive

@export var MODEL:Node3D;

@export var SLIDE_VECTOR:Vector3 = Vector3(0, 0, 1);
@export var SLIDE_DISTANCE:float = 0.2;
@export var SLIDE_START_POS:float = 0;

@export var LERP_RATE:float = 0.3;


@export_group("Extras")
@export var SPRING:float = 0.0;

#TODO add is_seated code to tell if can fire.

var model_goal:Node3D = Node3D.new()

@onready var slide_pos:float = SLIDE_START_POS
@onready var visual_slide_pos:float = SLIDE_START_POS;
var start_focus_slide_pos:float;


var velocity:float = 0.0;

##Ready
func _ready():
	SLIDE_VECTOR = SLIDE_VECTOR.normalized()
	assert(MODEL != null, "No model set")
	super._ready();
	
	add_child(model_goal)



var prev_mouse_delta:float;
var prev_slide_pos:float = 0;
var prev_velocity:float = 0;
func _process(delta:float) -> void:
	super._process(delta);
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
	
	if(is_focused):
		MODEL.global_position = MODEL.global_position.lerp(model_goal.global_position, LERP_RATE)
		visual_slide_pos = lerp(visual_slide_pos, slide_pos, LERP_RATE)
	else:
		MODEL.global_position = model_goal.global_position
		visual_slide_pos = slide_pos
	
	prev_slide_pos = slide_pos;
	
	


func _physics_process(delta: float) -> void:
	
	if(not is_focused):
		velocity += SPRING*delta;


#Enable and disable being clicked on
func enable_focus():
	INTERACT_PLANE.global_position = mouse_focus_pos
	
	var plane_normal = (global_basis*SLIDE_VECTOR).cross(get_viewport().get_camera_3d().global_position - INTERACT_PLANE.global_position).cross(global_basis*SLIDE_VECTOR)
	set_interact_plane_normal(global_basis.inverse()*plane_normal)

	start_focus_slide_pos = slide_pos
	prev_mouse_delta = 0;

func disable_focus():
	pass
