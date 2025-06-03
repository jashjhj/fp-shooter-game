class_name Seeking_Camera extends Node3D

@export var CAMERA:Node3D;
@export_range(-180, 180, 1.0, "radians_as_degrees") var camera_fov_x = PI/2; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var camera_fov_y = PI/3; 
@export var SIGHT_DISTANCE:float = 10;

@export var HINGE_X:Node3D;
@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_x = -PI/4; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_x = PI/4;
@export var HINGE_SPEED_X:float = 5;
@export var HINGE_Y:Node3D;
@export_range(-180, 180, 1.0, "radians_as_degrees") var min_hinge_y = -PI/6; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var max_hinge_y = PI/6; 
@export var HINGE_SPEED_Y:float = 2;

##Optional - if set, orients this node to point towards the player.
@export var TARGET_TOWARDS_LOOKING_AT:Node3D;
@onready var CAMERA_RAY:RayCast3D = RayCast3D.new();
@onready var TARGET_ORIENTATION_NODE:Node3D = Node3D.new();

var hinge_x_angle:float = 0.0;
var hinge_y_angle:float = 0.0;

var is_active:bool = true;
var can_see_player:bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(CAMERA != null, "No camera set")
	assert(HINGE_X != null, "No hinge(horizontal) set")
	assert(HINGE_Y != null, "No hinge(vertical) set")
	
	CAMERA.add_child(CAMERA_RAY)
	CAMERA_RAY.transform = Transform3D.IDENTITY
	CAMERA_RAY.collision_mask = 1 + 16 # Walls && the player
	
	if(TARGET_TOWARDS_LOOKING_AT == null):
		CAMERA.add_child(TARGET_ORIENTATION_NODE)
	else:
		TARGET_TOWARDS_LOOKING_AT.add_child(TARGET_ORIENTATION_NODE)
	TARGET_ORIENTATION_NODE.transform = Transform3D.IDENTITY
	



func _physics_process(delta: float) -> void:
	if(!is_active): return
	var player_pos:Vector3 = check_for_player()
	if(player_pos != Vector3.ZERO):
		
		var target_local_vector:Vector3 = TARGET_ORIENTATION_NODE.to_local(player_pos);
		var x_angle_to_target:float = asin(target_local_vector.normalized().dot(Vector3.RIGHT));
		var y_angle_to_target:float = asin(target_local_vector.normalized().dot(Vector3.UP));
		
		
		hinge_x_angle += x_angle_to_target * min(1.0, HINGE_SPEED_X*delta)
		hinge_y_angle += y_angle_to_target * min(1.0, HINGE_SPEED_Y*delta)
		#print(hinge_x_angle)
		
	
	hinge_x_angle = max(min_hinge_x, min(max_hinge_x, hinge_x_angle))
	hinge_y_angle = max(min_hinge_y, min(max_hinge_y, hinge_y_angle))
	
	HINGE_X.rotation.y = -hinge_x_angle
	HINGE_Y.rotation.x = hinge_y_angle



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
			return Vector3.ZERO
		if(angle_y > camera_fov_y):
			return Vector3.ZERO
		#Else: It okay 👍
		can_see_player = true
		return CAMERA_RAY.get_collision_point()
	else:
		return Vector3.ZERO
