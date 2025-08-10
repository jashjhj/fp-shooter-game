class_name Player extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5


var camera_rot_x = 0; # initial values - set like this so can be set in editor
var camera_rot_y = 0;

var is_mouse_focused = true;

@export_range(0, 180, 1.0, "degrees") var LOOK_MAX_VERT = 100;
@export_range(-180, 0, 1.0, "degrees") var LOOK_MIN_VERT = -85


@onready var HEAD:Node3D = $Hip/Torso/Head
@onready var TORSO:Node3D = $Hip/Torso
@onready var CAMERA:Camera3D = $Hip/Torso/Head/Camera3D

@export var GUN:Gun;


var CAMERA_CAPTURED:bool = false;
var aiming_down_sights:bool = false:
	set(v):
		aiming_down_sights = v
		if(aiming_down_sights):
			Engine.time_scale = 0.33;
		else:
			Engine.time_scale = 1.0;



func _ready():
	Globals.PLAYER = self;
	
	Input.use_accumulated_input = false;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	camera_rot_x = rotation.y; # initial values - set like this so can be set in editor
	camera_rot_y = rotation.x;

var mouse_input:Vector2;
var mouse_velocity:Vector2;
##INPUT SCRIPT
func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		if (is_mouse_focused or Input.is_action_pressed("look_during_inspect")):
			#Handle mouse movement
			
			if(!CAMERA_CAPTURED): # if free-roaming
				
				var viewport_transform: Transform2D = get_tree().root.get_final_transform() # resolves stretches
				mouse_input += event.xformed_by(viewport_transform).relative
		
		if(GUN.is_inspecting == true and Input.is_action_pressed("rotate_during_inspect")):
			GUN.rotate_inspect_node(event.relative * Settings.MouseSensitivity)
		
	if(GUN.is_inspecting == false):
		if(event.is_action_pressed("aim_down_sights")):
			aiming_down_sights = true;
		if(event.is_action_released("aim_down_sights")):
			aiming_down_sights = false;
	else:
		aiming_down_sights = false;
	
	
	if(is_mouse_focused == true):
		if event.is_action_pressed("interact_0"): # Left click
			GUN.trigger.emit();
	
	if event.is_action_pressed("inspect"):
		GUN.start_inspect();
		is_mouse_focused = false;
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_released("inspect"):
		GUN.end_inspect();
		is_mouse_focused = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	
	
	
	
	
	if event.is_action_pressed("free_mouse"):
		is_mouse_focused = !is_mouse_focused;
		if(is_mouse_focused):Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		else:Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	
	if event.is_action_pressed("exit"): # Kill program
		get_tree().quit()

func _process(delta:float) -> void:
	
	
	mouse_velocity *= Settings.MouseAcceleration * (1-delta);
	mouse_velocity += mouse_input/delta;
	
	#Camera rotation
	#camera_rot_x += mouse_velocity.x * -Settings.MouseSensitivity.x * delta
	#camera_rot_y += mouse_velocity.y * -Settings.MouseSensitivity.y * delta
	var mouse_vector := mouse_input * -Settings.MouseSensitivity
	if(aiming_down_sights): mouse_vector *= Settings.ADS_Sensitivity_Mult
	camera_rot_x += mouse_vector.x
	camera_rot_y += mouse_vector.y
	
	
	transform.basis = Basis();
	
	rotate_object_local(Vector3(0, 1, 0), camera_rot_x);
	
	camera_rot_y = min(camera_rot_y, deg_to_rad(LOOK_MAX_VERT)); # impose limits
	camera_rot_y = max(camera_rot_y, deg_to_rad(LOOK_MIN_VERT))
	
	TORSO.basis = Basis();
	TORSO.rotate_object_local(Vector3(1, 0, 0), camera_rot_y/2);
	HEAD.basis = Basis();
	HEAD.rotate_object_local(Vector3(1, 0, 0), camera_rot_y/2);
	
	mouse_input = Vector2.ZERO;
	
	if(aiming_down_sights):
		CAMERA.position = CAMERA.position.lerp(HEAD.global_basis.inverse()*(GUN.ADS_CAM_POS.global_position - HEAD.global_position), min(1, delta*15));
		#CAMERA.basis = Quaternion(CAMERA.basis).slerp(Quaternion(HEAD.global_basis.inverse()*GUN.ADS_CAM_POS.global_basis), min(1, delta*5))
	else:
		CAMERA.position = CAMERA.position.lerp(Vector3.ZERO, min(1, delta*5));
		#CAMERA.basis = Quaternion(CAMERA.basis).slerp(Quaternion(Basis.IDENTITY), min(1, delta*5))
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		#ppass
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):# and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/8)
		velocity.z = move_toward(velocity.z, 0, SPEED/8)
	
	#velocity.y = 0
	move_and_slide()
