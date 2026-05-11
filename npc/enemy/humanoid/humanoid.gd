class_name Humanoid extends Node3D

@export var LEGS:Humanoid_Legs;
@export var ANGLE_HELPER:Angular_Damper;

var walk_vector:Vector3 = Vector3(0, 0, 0.2)

enum STABILITY{
	FULL,
	NONE
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	LEGS.walk_vector = walk_vector;
