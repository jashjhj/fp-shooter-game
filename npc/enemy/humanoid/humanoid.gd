class_name Humanoid extends Node3D

@export var LEGS:Humanoid_Legs;
@export var ANGULAR_DAMPER:Angular_Damper;

var walk_vector:Vector3 = Vector3(0, 0, -1.0)
var facing_vector3:Vector3 = Vector3.FORWARD;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	walk_vector = ((Globals.PLAYER.global_position - LEGS.global_position) * Vector3(1, 0, 1)).normalized()
	LEGS.walk_vector = walk_vector;
	
	#ANGULAR_DAMPER.rotate(Vector3.UP, 0.1*delta)
	if LEGS.current_state is Humanoid_Legs_State_Walking:
		ANGULAR_DAMPER.set_node_facing(ANGULAR_DAMPER.global_position - walk_vector, Vector3.UP);
		DebugDraw3D.draw_position(ANGULAR_DAMPER.global_transform.translated(Vector3.UP * 3))
