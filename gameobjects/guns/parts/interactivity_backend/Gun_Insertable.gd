class_name Gun_Insertable extends Node3D

@export var GRABBABLE_AREA:Area3D
const GRABBABLE_AREA_LAYER:int = 65536; #Gun interaction layer.


signal grabbed
signal ungrabbed

var is_grabbable:bool = true:
	set(value):
		is_grabbable = value; # Toggles collision if set.
		if(is_grabbable): GRABBABLE_AREA.collision_layer = GRABBABLE_AREA_LAYER;
		else: GRABBABLE_AREA.collision_mask = 0;
			


func _ready() -> void:
	assert(GRABBABLE_AREA != null, "No Grabbable Area set!")
	GRABBABLE_AREA.collision_mask = 0;
	GRABBABLE_AREA.collision_layer = GRABBABLE_AREA_LAYER;



func _input(event: InputEvent) -> void: # Handles "is_focused"
	if(is_grabbable):
		if(event.is_action_pressed("interact_0")):
			var mouse_collider = get_viewport().get_camera_3d().get_mouse_ray(2, GRABBABLE_AREA_LAYER).get_collider(); # Was this begun to be clicked on.
			if(mouse_collider == GRABBABLE_AREA):
				grabbed.emit();
		if(event.is_action_released("interact_0")):
			ungrabbed.emit();
