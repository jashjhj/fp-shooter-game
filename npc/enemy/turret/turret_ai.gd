class_name Turret_AI extends Node


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
@export var BULLET_SOURCE:Bullet_Source;

@export var FIRE_DELAY:float = 0.13;

@export var POWER_SOURCE:Node3D;
@export var CAMERA_LIGHT:Light3D;
@export var EXPEL_CARTRIDGES:Debris_Spawner




@onready var CAMERA_RAY:RayCast3D = RayCast3D.new();
@onready var RIFLE_POS:Node3D = RayCast3D.new();



var active = true;
var is_locked_on = false;

var hinge_x_angle:float = 0.0;
var hinge_y_angle:float = 0.0;


func _ready():
	assert(CAMERA != null, "No camera set")
	assert(HINGE_X != null, "No hinge(horizontal) set")
	assert(HINGE_Y != null, "No hinge(vertical) set")
	assert(BULLET_SOURCE != null, "No bullet Source set")
	assert(EXPEL_CARTRIDGES != null, "Nowhere to expel cartridges set")
	
	CAMERA.add_child(CAMERA_RAY)
	CAMERA_RAY.transform = Transform3D.IDENTITY
	CAMERA_RAY.collision_mask = 1 + 16
	#CAMERA_RAY.hit_from_inside = true
	
	HINGE_Y.add_child(RIFLE_POS)
	RIFLE_POS.global_transform = BULLET_SOURCE.global_transform;
	
	assert(POWER_SOURCE != null, "No power source set")


func _physics_process(delta: float) -> void:
	##In global coords
	if(POWER_SOURCE == null): disable()
	
	if !active:
		hinge_y_angle = min_hinge_y;
		HINGE_Y.rotation.x = lerp(HINGE_Y.rotation.x, hinge_y_angle, min(1.0, 2*delta));
		return
	
	var player_pos:Vector3 = check_for_player()
	if(player_pos != Vector3.ZERO):
		
		var target_local_vector:Vector3 = RIFLE_POS.to_local(player_pos);
		var x_angle_to_target:float = asin(target_local_vector.normalized().dot(Vector3.RIGHT));
		var y_angle_to_target:float = asin(target_local_vector.normalized().dot(Vector3.UP));
		
		
		hinge_x_angle += x_angle_to_target * min(1.0, HINGE_SPEED_X*delta)
		hinge_y_angle += y_angle_to_target * min(1.0, HINGE_SPEED_Y*delta)
		#print(hinge_x_angle)
		
		#Decide if to shoot:
		if(!is_locked_on):
			if abs(x_angle_to_target) + abs(y_angle_to_target) < 0.005: # if close
				is_locked_on = true
		else:
			if(abs(x_angle_to_target) + abs(y_angle_to_target) > 0.3):
				is_locked_on = false;
			consider_fire()
	else:is_locked_on = false
	
	hinge_x_angle = max(min_hinge_x, min(max_hinge_x, hinge_x_angle))
	hinge_y_angle = max(min_hinge_y, min(max_hinge_y, hinge_y_angle))
	
	HINGE_X.rotation.y = -hinge_x_angle
	HINGE_Y.rotation.x = hinge_y_angle


var last_shot_fired:int = 0
#~Decide if to shoot. considers things like the delay.
func consider_fire():
	if(Time.get_ticks_msec() - last_shot_fired > FIRE_DELAY*1000):
		fire()
		last_shot_fired = Time.get_ticks_msec();



func fire():
	BULLET_SOURCE.shoot.emit()
	EXPEL_CARTRIDGES.spawn()

func check_for_player() -> Vector3:
	if(CAMERA == null): return Vector3.ZERO

	CAMERA_RAY.target_position = (CAMERA_RAY.to_local(Globals.PLAYER.global_position + Vector3(0, 1, 0))).normalized() * SIGHT_DISTANCE # Roughly COM
	
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
		return CAMERA_RAY.get_collision_point()
	else:
		return Vector3.ZERO

func disable():
	active = false;
	if(CAMERA_LIGHT != null):
		CAMERA_LIGHT.queue_free()
