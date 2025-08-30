class_name Tool_Part_Slideable extends Tool_Part_Interactive_1D

@export var MODEL:Node3D;

@export var SLIDE_VECTOR:Vector3 = Vector3(0, 0, 1);




#@export var LERP_RATE:float = 0.3;




#TODO add is_seated code to tell if can fire.

var model_goal:Node3D = Node3D.new()



##Ready
func _ready():
	SLIDE_VECTOR = SLIDE_VECTOR.normalized()
	super._ready();
	
	
	await get_parent().ready
	
	add_child(model_goal)

		
	assert(MODEL != null, "No model Set for slideable.")



#var prev_velocity:float = 0;
func _process(delta:float) -> void:
	super._process(delta);
	
	if(is_focused): # get inputs in process
		pass
	

var stored_velocity:float = 0.0;

func _physics_process(delta: float) -> void:
	
	super._physics_process(delta)
	
	
	model_goal.global_position = global_position + DISTANCE*(global_basis*SLIDE_VECTOR)
	MODEL.global_position = model_goal.global_position


#Enable and disable being clicked on
func enable_focus():
	super()
	INTERACT_PLANE.global_position = mouse_focus_pos
	
	var plane_normal = (global_basis*SLIDE_VECTOR).cross(get_viewport().get_camera_3d().global_position - global_position).cross(global_basis*SLIDE_VECTOR)
	set_interact_plane_normal(global_basis.inverse()*plane_normal)



func disable_focus():
	super.disable_focus()
	#velocity = stored_velocity * 0.1

func hit_min_limit(v):
	super(v);
	#if(APPLY_FORCES_TO == null): return
	#APPLY_FORCES_TO.apply_impulse(global_basis *INTERACT_POSITIVE_DIRECTION * v * (1+ELASTICITY_AT_MIN) * SIMULATED_MASS, global_position - APPLY_FORCES_TO.global_position)

func hit_max_limit(v):
	super(v)
	#if(APPLY_FORCES_TO == null): return
	#APPLY_FORCES_TO.apply_impulse(global_basis *INTERACT_POSITIVE_DIRECTION * v * (1+ELASTICITY_AT_MIN) * SIMULATED_MASS, global_position - APPLY_FORCES_TO.global_position)
