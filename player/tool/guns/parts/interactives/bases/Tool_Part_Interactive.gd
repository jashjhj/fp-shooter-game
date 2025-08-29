class_name Tool_Part_Interactive extends Tool_Part

@export var INTERACT_SENSITIVITY:float = 1;

##Area3D
@export var BEGIN_INTERACT_COLLIDER:Area3D;
#@export var INTERACT_PLANE_NORMAL:Node3D;

##Does the mosue hide when interacting?
@export var HIDES_MOUSE:bool = true;

##when this part is selected, it simultaneously focuses others in this array.. Accepts Tool_Part_Interactive, Tool_part_Insertable (Grabs what is housed)
@export var ALSO_SELECT:Array[Node]


var INTERACT_PLANE:Area3D;


const BEGIN_INTERACT_COLLISION_LAYER := 65536 # 2^16
const PLANE_COLLISION_LAYER := 131072 # 2^17

var mouse_focus_pos:Vector3;
var mouse_focus_pos_relative:Vector3;

##Set once been focused.
var has_been_focused = false;

#Can be clicked on
var is_interactive:bool = false:
	set(value):
		is_interactive = value
		if(!is_interactive):
			_disable_focus()

## Is currently being held/clicked on
var is_focused:bool = false: 
	set(v):
		if(is_focused != v):
			is_focused = v
			if(is_focused):
				_enable_focus()
			else:
				_disable_focus()

##Can it be focused? If clicked on, will it Focus?
var is_focusable:bool = true:
	set(value):
		is_focusable = value;
		if(!is_focusable): # cancel focus when this is toggled.
			_disable_focus()
		
		#if(is_focusable): # makes it unregisterable   --- REMOVED so i can use the collider as a bounding box for cosmetics
		BEGIN_INTERACT_COLLIDER.collision_layer = BEGIN_INTERACT_COLLISION_LAYER;
		#else:
		#	BEGIN_INTERACT_COLLIDER.collision_layer = 0;
		






func _ready():
	init();
	if(get_parent() is Gun):
		if(get_parent().inspect):
			is_interactive = true;


func init(): # load the tools required.
	var tools = load("res://player/tool/guns/parts/interactives/Tool_Part_Tools.tscn").instantiate()
	assert(tools != null, "Tool_Part_Tools does not exist @ `res://player/tool/guns/parts/interactives/Tool_Part_Tools.tscn`") # check
	
	assert(BEGIN_INTERACT_COLLIDER != null, "No Begin-Interact collider set.")
	
	add_child(tools, true) # true makes them internal so not as easy to modify
	
	INTERACT_PLANE = tools.INTERACT_PLANE
	INTERACT_PLANE.collision_layer = PLANE_COLLISION_LAYER # layer 18 = Tool_Part_Interaction_Plane
	
	BEGIN_INTERACT_COLLIDER.collision_layer = BEGIN_INTERACT_COLLISION_LAYER
	BEGIN_INTERACT_COLLIDER.collision_mask = 0
	disable_plane_collider()
	


func disable_plane_collider():
	INTERACT_PLANE.process_mode = Node.PROCESS_MODE_DISABLED;

func enable_plane_collider():
	INTERACT_PLANE.process_mode = Node.PROCESS_MODE_INHERIT;
 

var mouse_velocity:Vector2;
func _input(event: InputEvent) -> void: # Handles "is_focused"
	
	if(is_focused):
		if(event is InputEventMouseMotion):
			var pixels:Vector2 = event.screen_relative
			var world_coords:Vector3 = get_viewport().get_camera_3d().delta_pixels_to_world_space(pixels)
			#print(pixels, " -> ", world_coords)
			mouse_movement(INTERACT_SENSITIVITY * world_coords)
	
	elif(is_focusable and is_interactive): # and not focuesed (yet)
		if(event.is_action_pressed("interact_0")):
			var mouse_collider = get_viewport().get_camera_3d().get_mouse_ray(2, BEGIN_INTERACT_COLLISION_LAYER).get_collider(); # Was this begun to be clicked on.
			if(mouse_collider == BEGIN_INTERACT_COLLIDER):
				_enable_focus()
	
	if(event.is_action_released("interact_0")):
		_disable_focus()


##Motion is in global space
func mouse_movement(motion:Vector3):
	pass
	
	#print(motion)


func _process(delta: float) -> void:
	pass
	
	#print(mouse_velocity)



func _enable_focus():
	#Cancel if mouse not visible
	if( not Globals.PLAYER.is_inspecting ) : return
	if(is_focused): return # If already focused, cancel
	if(!is_focusable): return
	
	if(HIDES_MOUSE): Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	has_been_focused = true;
	is_focused = true;
	mouse_focus_pos = get_viewport().get_camera_3d().get_mouse_ray(2, BEGIN_INTERACT_COLLISION_LAYER).get_collision_point();
	mouse_focus_pos_relative = global_basis.inverse()*(mouse_focus_pos - global_position)
	#enable_plane_collider()
	#Do not call scripts that may interfere with further rays in the same moment - e.g. Reparenting, or changing the area collider
	
	for element in ALSO_SELECT: # also select other interactives
		if element is Tool_Part_Interactive:
			element._enable_focus()
		
		elif element is Tool_Part_Insertable_Slot: # select object within slot (slot is just a host)
			if(element.housed_insertable != null):
				element.housed_insertable._enable_focus()
		else:
			push_error("Invalid element in ALSO_SELECT of an Interactive: ", element, " | in interactive: ", self)
	
	enable_focus() # inherited function

##Disables focus if applicable
func _disable_focus():
	if(!is_focused): return
	
	if(HIDES_MOUSE): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	is_focused = false;
	#disable_plane_collider()
	
	disable_focus() # inherited function

#Inherited functions. called when focused and unfocused
func enable_focus():
	pass

func disable_focus():
	pass







##Gets position of mouse on the plane in global space
func get_mouse_plane_position(mask = PLANE_COLLISION_LAYER) -> Vector3:
	enable_plane_collider() # enable collide rwgen necessary
	var ray = get_viewport().get_camera_3d().get_mouse_ray(4, mask);
	disable_plane_collider()
	
	if(ray.is_colliding()):
		return ray.get_collision_point();
	return Vector3.ZERO
	




func set_interact_plane_normal(n:Vector3) -> void:
	INTERACT_PLANE.look_at(INTERACT_PLANE.global_position + global_basis * n)
	#INTERACT_PLANE.look_at(INTERACT_PLANE.global_position + n)
#
#func set_interact_plane_normal_toward_node() ->void:
	#set_interact_plane_normal(INTERACT_PLANE_NORMAL.global_position - global_position)
