extends Node3D

@onready var INTERACT_PLANE:Area3D = $Interact_Plane
@export var VISUALISER:MeshInstance3D;

var is_visualiser_visible:bool;
func _ready() -> void:
	is_visualiser_visible = VISUALISER.visible;

func _process(_delta: float) -> void:
	if(is_visualiser_visible): # Only shows visualiser if visualiser is visible at start (setting) and currently active, to reduce clutter.
		VISUALISER.visible = true if INTERACT_PLANE.process_mode != Node.PROCESS_MODE_DISABLED else false;
