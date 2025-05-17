extends Camera3D

@onready var RAY:RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.

var has_been_updated:bool = false;
var current_normal:Vector3;


func _ready() -> void:
	RAY.top_level = true;

func _process(_delta: float):
	has_been_updated = false;

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
