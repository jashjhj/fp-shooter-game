class_name BulletTrail extends MeshInstance3D

var direction:Vector3;
var length:Vector3;

var camera:Camera3D;

var init_tick:int = 0;

@export var lifetime := 2000;

var current_alpha_mult := 1.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	init_tick = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var lifetime_spent = Time.get_ticks_msec() - init_tick;
	if(lifetime_spent > lifetime):
		queue_free()
		return
	
	current_alpha_mult = pow(1.0 - (float(lifetime_spent)/float(lifetime)), 2); # power for smoother alpha dropoff
	
	mesh.material.set("shader_parameter/alpha_mult", current_alpha_mult);
	mesh.material.set("shader_parameter/albedo_mult", 1-0.5*(1-current_alpha_mult));
	
	
	#look_at(direction, (global_position-camera.global_position).normalized()); # look right way, perpendicular to cam
