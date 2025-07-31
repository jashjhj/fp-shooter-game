class_name Hard_Seeking_Camera extends Seeking_Camera

@export var HINGE_X:Node3D;
@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_x = -PI/4; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_x = PI/4;
@export var HINGE_SPEED_X:float = 5;
@export var HINGE_Y:Node3D;
@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_y = -PI/6; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_y = PI/6; 
@export var HINGE_SPEED_Y:float = 2;

@export var IS_HINGE_SPEED_LINEAR:bool = false;


var hinge_x_angle:float = 0.0;
var hinge_y_angle:float = 0.0;

var is_active:bool = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	assert(HINGE_X != null, "No hinge(horizontal) set")
	assert(HINGE_Y != null, "No hinge(vertical) set")
	


func _physics_process(delta: float) -> void:
	if(!is_active): return
	
	super._physics_process(delta)
	
	
	if(target_pos == Vector3.INF): return
		
	var target_local_vector:Vector3 = AIM_THIS_TOWARDS_TARGET.to_local(target_pos);
	var x_angle_to_target:float = asin(target_local_vector.normalized().dot(Vector3.RIGHT));
	var y_angle_to_target:float = asin(target_local_vector.normalized().dot(Vector3.UP));
	
	if(IS_HINGE_SPEED_LINEAR):
		
		if(abs(x_angle_to_target) < HINGE_SPEED_X*delta * 1.2): # Checks to cancel jiterring
			x_angle_to_target = 0;
		if(abs(y_angle_to_target) < HINGE_SPEED_Y*delta * 1.2):
			y_angle_to_target = 0;
		
		
		x_angle_to_target = min(HINGE_SPEED_X*delta, max(-HINGE_SPEED_X*delta, x_angle_to_target))
		y_angle_to_target = min(HINGE_SPEED_Y*delta, max(-HINGE_SPEED_Y*delta, y_angle_to_target))
		
		
		hinge_x_angle += x_angle_to_target
		hinge_y_angle += y_angle_to_target
	else:
		hinge_x_angle += x_angle_to_target * min(1.0, HINGE_SPEED_X*delta)
		hinge_y_angle += y_angle_to_target * min(1.0, HINGE_SPEED_Y*delta)
	#print(hinge_x_angle)
		
	
	hinge_x_angle = max(min_hinge_x, min(max_hinge_x, hinge_x_angle))
	hinge_y_angle = max(min_hinge_y, min(max_hinge_y, hinge_y_angle))
	
	HINGE_X.rotation.y = -hinge_x_angle
	HINGE_Y.rotation.x = hinge_y_angle
