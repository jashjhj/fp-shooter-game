class_name Player_Leg extends IK_Leg





var DOWN:Node3D = Node3D.new();
var CURRENT:Node3D = Node3D.new();

var DOWN_RAY:RayCast3D = RayCast3D.new()


func _ready() -> void:
	super._ready()
	
	add_child(DOWN)
	add_child(CURRENT)
	add_child(DOWN_RAY)
	DOWN.top_level = false;
	CURRENT.top_level = true;
	
	DOWN_RAY.target_position = Vector3.DOWN * (UPPER_LENGTH + LOWER_LENGTH + 0.2);
	
	#Initialsie to be standing
	DOWN_RAY.force_raycast_update()
	DOWN.global_position = DOWN_RAY.get_collision_point()
	set_leg_target(DOWN.global_position, true)
	set_leg_progress(1)


func _physics_process(delta: float) -> void:
	if(DOWN_RAY.is_colliding()):
		DOWN.global_position = DOWN_RAY.get_collision_point()
#
#
#func compute():
	#if(FLOOR_RAY.is_colliding()):
		#DOWN.global_position = FLOOR_RAY.get_collision_point()
	#
	#var distance_to_DOWN:float = DOWN.global_position.distance_to(CURRENT.global_position)
	#set_leg_progress(distance_to_DOWN/DISTANCE_TO_STEP)
	#
	#if(distance_to_DOWN > DISTANCE_TO_STEP):
		#CURRENT.global_position = DOWN.global_position
		#set_leg_target(DOWN.global_position, false)
