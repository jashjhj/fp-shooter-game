extends Camera3D

@onready var RAY:RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.

var has_been_updated:bool = false;
var current_normal:Vector3;


func _ready() -> void:
	RAY.top_level = true;
	get_tree().get_root().size_changed.connect(recalculate_scalar) # call if resolution changed
	
	recalculate_scalar() # init

var old_fov:float;
func _process(_delta: float):
	has_been_updated = false;
	RAY.transform = transform
	
	if(fov != old_fov): # update if fov change
		recalculate_scalar()
	old_fov = fov

func get_mouse_ray(length:int = 10, mask:int = -1) -> RayCast3D:
	if(!has_been_updated): # Updates if hasnt been updated yet
		var mouse_pos = get_viewport().get_mouse_position()
		RAY.global_position = project_ray_origin(mouse_pos)
		current_normal = project_ray_normal(mouse_pos)
		has_been_updated = true;
	
	#Scans
	RAY.collision_mask = mask
	RAY.target_position = current_normal * length;
	RAY.force_raycast_update();
	
	#print("from: "+ str(RAY.global_position));
	#print("to: " + str(RAY.global_position + RAY.target_position));
	#print(RAY.get_collider())
	return RAY

func get_ray_from_camera_through(pos:Vector3, length:int = 10, mask:int = -1) -> RayCast3D:
	has_been_updated = false; # for other ray script.
	RAY.global_position = global_position;
	RAY.target_position = (pos - global_position).normalized() * length;
	RAY.collision_mask = mask;
	
	RAY.force_raycast_update();
	return RAY;



#var tangent_deg_per_px:float;
var rad_per_px:float;
func recalculate_scalar():
	#print("recalc") This fucntionc alls coreectly when it should.
	var res = DisplayServer.screen_get_size()
	rad_per_px = deg_to_rad(fov / res.y) # fov is vertical, so if its wider doesnt go funny


##Pixels of mosue movement -> M of movement at 1m from camera at (at_distance) away
func delta_pixels_to_world_space(delta_pixels:Vector2, at_distance:float = 0.5) -> Vector3:
	
	return global_basis * Vector3(tan(delta_pixels.x * rad_per_px) * at_distance, tan(-delta_pixels.y * rad_per_px) * at_distance, 0)
