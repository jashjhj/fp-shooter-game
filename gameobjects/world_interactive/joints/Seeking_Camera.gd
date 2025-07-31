class_name Seeking_Camera extends Node

##The actual position that the viewport is generated from (-z is forwards)
@export var CAMERA:Node3D;
@export_range(-180, 180, 1.0, "radians_as_degrees") var camera_fov_x = PI/2;
@export_range(-180, 180, 1.0, "radians_as_degrees") var camera_fov_y = PI/3;
@export var SIGHT_DISTANCE:float = 10;

##IF set, target_pos is relative to this node. I.e. if I want the camera to point a separately attached gun at the player. (-z is forward)
@export var AIM_THIS_TOWARDS_TARGET:Node3D

@onready var CAMERA_RAY:RayCast3D = RayCast3D.new();


var can_see_player:bool = false;

##Global position of target to look at, Vector3.INF IF cannot see.
var target_pos:Vector3;
var target_pos_local:Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(CAMERA != null, "No camera set")
	CAMERA.add_child(CAMERA_RAY)
	
	CAMERA_RAY.transform = Transform3D.IDENTITY
	CAMERA_RAY.collision_mask = 1 + 16 # Walls && the player
	
	if AIM_THIS_TOWARDS_TARGET == null:
		AIM_THIS_TOWARDS_TARGET = CAMERA


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	target_pos = check_for_player()
	if(AIM_THIS_TOWARDS_TARGET != null):
		target_pos_local = AIM_THIS_TOWARDS_TARGET.to_local(target_pos)
	else:
		target_pos_local = CAMERA.to_local(target_pos)




func check_for_player() -> Vector3:
	can_see_player = false;
	if(CAMERA == null): return Vector3.ZERO

	CAMERA_RAY.target_position = (CAMERA_RAY.to_local(Globals.PLAYER.TORSO.global_position) * SIGHT_DISTANCE) # Roughly COM
	
	if(CAMERA_RAY.is_colliding() and CAMERA_RAY.get_collider() is Player):
		var ray_vector := CAMERA_RAY.get_collision_point() - CAMERA_RAY.global_position
		
		#                 not Y segment
		var angle_x := acos((ray_vector * (Vector3(1, 0, 1))).normalized().dot(-CAMERA.global_basis.z))
		var angle_y:float = abs(atan((ray_vector * (CAMERA.global_basis*Vector3(0, 1, 0))).length()/(ray_vector * Vector3(1, 0, 1)).length()))
		
		
		if(angle_x > camera_fov_x):
			return Vector3.INF
		if(angle_y > camera_fov_y):
			return Vector3.INF
		#Else: It okay 👍
		can_see_player = true
		return CAMERA_RAY.get_collision_point()
	else:
		return Vector3.INF
