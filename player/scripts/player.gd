class_name Player extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5


var camera_rot_x = 0; # initial values - set like this so can be set in editor
var camera_rot_y = 0;

var is_mouse_focused = true;
var is_inspecting:bool = false:
	set(v):
		if(equipped_tool == null): # if no current tool
			is_inspecting = false;
			return
		
		if(is_inspecting == v): return # if no update
		
		is_inspecting = v;
		
		if(is_inspecting):
			is_focussing = false
			equipped_tool.inspect = true
			equipped_tool.ANCHOR = CAMERA
			is_mouse_focused = false;
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			equipped_tool.inspect = false
			is_mouse_focused = true;
			equipped_tool.ANCHOR = ANCHOR_HAND # reset to hand
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var is_focussing:bool = false:
	set(v):
		if(is_inspecting):
			is_focussing = false; # cannot focus when inspecting
			return

		if(is_focussing != v):# only run if set to new value
			is_focussing = v
			if(is_focussing):
				Engine.time_scale = 0.5;
				if(equipped_tool != null):
					equipped_tool.ANCHOR = CAMERA
					equipped_tool.focus = true
			else:
				Engine.time_scale = 1.0;
				if(equipped_tool != null):
					equipped_tool.ANCHOR = ANCHOR_HAND
					equipped_tool.focus = false
					#equipped_tool.reparent(TORSO)
		

class PlayerState:
	var move_mult:float = 1.0

var WalkState:PlayerState = PlayerState.new()
var InspectState:PlayerState = PlayerState.new()



@export_range(0, 180, 1.0, "degrees") var LOOK_MAX_VERT = 100;
@export_range(-180, 0, 1.0, "degrees") var LOOK_MIN_VERT = -85


@export_range(0, 180, 0.01, "degrees") var DEFAULT_FOV:float = 70;

@onready var BODY_ORIGIN:Node3D = $Hip
@onready var HEAD:Node3D = $Hip/Torso/Head
@onready var TORSO:Node3D = $Hip/Torso
@onready var CAMERA:Camera3D = $Hip/Torso/Head/Camera3D

@export var PRIMARY_TOOL:PackedScene

@export var HP:float = 5.0:
	set(v):
		HP = v
		update_ui()
		if(HP < 0.1):
			var timer = Timer.new()
			add_child(timer)
			timer.start(2.0)
			timer.timeout.connect(reload)
		
		else:
			hurt_timer.start(0.1)
			show_hurt_overlay()



@export_group("Parts")
@export var ANCHOR_HAND:Node3D;
@export var ANCHOR_POCKET:Node3D
@export var SHOULDER:Node3D

var equipped_tool:Player_Tool:
	set(v):
		if v == null:
			is_inspecting = false
			equipped_tool.interact_0 = false
			equipped_tool.focus = false
			equipped_tool.inspect = false
		equipped_tool = v;


var CAMERA_CAPTURED:bool = false;

		


var hurt_timer:Timer;

var primary_tool:Player_Tool




func _ready():
	Globals.PLAYER = self;
	
	Input.use_accumulated_input = false;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	camera_rot_x = rotation.y; # initial values - set like this so can be set in editor
	camera_rot_y = rotation.x;
	CAMERA.fov = DEFAULT_FOV
	
	update_ui() # initialises thign ie HP bar
	hurt_timer = Timer.new()
	add_child(hurt_timer)
	hurt_timer.timeout.connect(hide_hurt_overlay)
	
	assert(PRIMARY_TOOL != null, "No PRIMARY_TOOL set")
	primary_tool = PRIMARY_TOOL.instantiate()
	add_child(primary_tool)
	
	if(primary_tool is Gun): # straps object to torso if required
		for c in primary_tool.STRAP_TO_TORSO:
			
			var trans:Transform3D = c.transform
			c.reparent(TORSO)
			c.transform = trans; # Keep its local transform
	
	
	primary_tool.ANCHOR = ANCHOR_POCKET
	primary_tool.global_transform = ANCHOR_POCKET.global_transform



var mouse_input:Vector2;
var mouse_velocity:Vector2;

var is_rotating_during_inspect:bool = false
var rotating_during_inspect_mouse_pos:Vector2;

##INPUT SCRIPT
func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		if (is_mouse_focused or Input.is_action_pressed("look_during_inspect")):
			#Handle mouse movement
			
			if(!CAMERA_CAPTURED): # if free-roaming
				
				var viewport_transform: Transform2D = get_tree().root.get_final_transform() # resolves stretches
				mouse_input += event.xformed_by(viewport_transform).relative
		
		if(equipped_tool != null and equipped_tool.inspect == true and Input.is_action_pressed("rotate_during_inspect")):
			if(!is_rotating_during_inspect):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				rotating_during_inspect_mouse_pos = get_viewport().get_mouse_position()
				is_rotating_during_inspect = true;
			equipped_tool.rotate_inspect_node(event.relative * Settings.MouseSensitivity)

		else:
			if(is_rotating_during_inspect):
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Input.warp_mouse(rotating_during_inspect_mouse_pos)
				is_rotating_during_inspect = false
				
	
	
	if(equipped_tool != null):
		if(is_mouse_focused == true):
			if event.is_action_pressed("interact_0"): # Left click
				equipped_tool.interact_0 = true
			
			if event.is_action_released("interact_0"):
				equipped_tool.interact_0 = false
			
		
		if event.is_action_pressed("inspect"):
			is_inspecting = !is_inspecting
			
		
		
	
	
	if(event.is_action_pressed("focus")):
		is_focussing = true

	if(event.is_action_released("focus")):
		is_focussing = false
	
	if(event.is_action_pressed("equip_primary")): # equip/dequip primary.
		is_focussing = false
		if(equipped_tool == null):
			equipped_tool = primary_tool
			equipped_tool.ANCHOR = ANCHOR_HAND
			#equipped_tool.reparent(self)
		else:
			equipped_tool.ANCHOR = ANCHOR_POCKET
			#equipped_tool.reparent(TORSO)
			equipped_tool = null;
			
	
	
	
	if event.is_action_pressed("free_mouse"):
		is_mouse_focused = !is_mouse_focused;
		if(is_mouse_focused):Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		else:Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	
	if event.is_action_pressed("exit"): # Kill program
		get_tree().quit()




func _process(delta:float) -> void:
	#ANCHOR_HAND.basis = HEAD.basis
	SHOULDER.basis = HEAD.basis
	
	mouse_velocity *= Settings.MouseAcceleration * (1-delta);
	mouse_velocity += mouse_input/delta;
	
	#Camera rotation
	#camera_rot_x += mouse_velocity.x * -Settings.MouseSensitivity.x * delta
	#camera_rot_y += mouse_velocity.y * -Settings.MouseSensitivity.y * delta
	var mouse_vector := mouse_input * -Settings.MouseSensitivity
	if(is_focussing): mouse_vector *= Settings.ADS_Sensitivity_Mult
	camera_rot_x += mouse_vector.x
	camera_rot_y += mouse_vector.y
	
	
	transform.basis = Basis();
	
	BODY_ORIGIN.rotate_object_local(Vector3(0, 1, 0), mouse_vector.x); # yaw
	
	camera_rot_y = min(camera_rot_y, deg_to_rad(LOOK_MAX_VERT)); # impose limits
	camera_rot_y = max(camera_rot_y, deg_to_rad(LOOK_MIN_VERT))
	
	TORSO.basis = Basis(); # pitch
	TORSO.rotate_object_local(Vector3(1, 0, 0), camera_rot_y/4);
	HEAD.basis = Basis();
	HEAD.rotate_object_local(Vector3(1, 0, 0), 3*camera_rot_y/4);
	
	mouse_input = Vector2.ZERO;
	
	#if(is_focussing and equipped_tool != null and equipped_tool.CAM_FOCUS_POS != null):
		#CAMERA.position = CAMERA.position.lerp(HEAD.global_basis.inverse()*(equipped_tool.CAM_FOCUS_POS.global_position - HEAD.global_position), min(1, delta*15));
		#CAMERA.basis = Quaternion(CAMERA.basis).slerp(Quaternion(HEAD.global_basis.inverse()*GUN.ADS_CAM_POS.global_basis), min(1, delta*5))
	#else:
	CAMERA.position = CAMERA.position.lerp(Vector3.ZERO, min(1, delta*5));
		#CAMERA.basis = Quaternion(CAMERA.basis).slerp(Quaternion(Basis.IDENTITY), min(1, delta*5))
	
	
	if(!is_focussing): # change fov when ADS
		CAMERA.fov = lerp(CAMERA.fov, DEFAULT_FOV, 5.0*delta)
	else:
		CAMERA.fov = lerp(CAMERA.fov, DEFAULT_FOV * 0.4, 1.0*delta)


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
	var direction := (BODY_ORIGIN.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if(is_inspecting):
			velocity.x *= 0.2;
			velocity.z *= 0.2;
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 8) # returns over 1/8 of a second
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 8)
	
	#velocity.y = 0
	move_and_slide()

func update_ui():
	$Control/RichTextLabel.text = "HP: "+str(int(HP))
	if(HP <= 0.1):
		print("showing you died")
		$"You DIED".visible = true

func reload():
	get_tree().change_scene_to_file("res://maps/sandy_arena/Sandy_Arena.tscn")

func show_hurt_overlay():
	$Hurt.visible = true
func hide_hurt_overlay():
	$Hurt.visible = false
