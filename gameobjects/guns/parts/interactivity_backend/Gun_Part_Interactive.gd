class_name Gun_Part_Interactive extends Gun_Part

@export var BEGIN_INTERACT_COLLIDER:Area3D;

var INTERACT_PLANE:Area3D;


const BEGIN_INTERACT_COLLISION_LAYER := 65536
const PLANE_COLLISION_LAYER := 131072

var is_interactive:bool = false; # Interactivity - e.g. when playeris currently 'Inspecting'
var is_focused:bool = false; # Is currently being held/clicked on


#Inherited functions. called when focused and unfocused
func enable_focus():
	pass

func disable_focus():
	pass



func enable_interactive():
	is_interactive = true;
func disable_interactive():
	is_interactive = false;


func _ready():
	init();


func init(): # load the tools required.
	var tools = load("res://gameobjects/guns/parts/interactivity_backend/Gun_Part_Tools.tscn").instantiate()
	assert(tools != null, "Gun_Part_Tools does not exist @ `res://gameobjects/guns/parts/interactivity_backend/Gun_Part_Tools.tscn`") # check
	
	assert(BEGIN_INTERACT_COLLIDER != null, "No Interact collider set.")
	
	add_child(tools, true) # true makes them internal so not as easy to modify
	
	INTERACT_PLANE = tools.INTERACT_PLANE
	INTERACT_PLANE.collision_layer = PLANE_COLLISION_LAYER # layer 18 = Gun_Part_Interaction_Plane
	
	BEGIN_INTERACT_COLLIDER.collision_layer = BEGIN_INTERACT_COLLISION_LAYER
	BEGIN_INTERACT_COLLIDER.collision_mask = 0
	disable_plane_collider()
	


func disable_plane_collider():
	INTERACT_PLANE.process_mode = Node.PROCESS_MODE_DISABLED;

func enable_plane_collider():
	INTERACT_PLANE.process_mode = Node.PROCESS_MODE_INHERIT;


func _input(event: InputEvent) -> void: # Handles "is_focused"
	if(is_interactive):
		if(event.is_action_pressed("interact_0")):
			var mouse_collider = get_viewport().get_camera_3d().get_mouse_ray(2, BEGIN_INTERACT_COLLISION_LAYER).get_collider(); # Was this begun to be clicked on.
			if(mouse_collider == BEGIN_INTERACT_COLLIDER):
				_enable_focus()
		if(event.is_action_released("interact_0")):
			_disable_focus()

func _enable_focus():
	if(is_focused): return # If already focused, cancel
	is_focused = true;
	enable_plane_collider()
	
	enable_focus() # inherited function

func _disable_focus():
	if(!is_focused): return
	is_focused = false;
	disable_plane_collider()
	
	disable_focus() # inherited function

##Gets position of mouse on the plane in local space
func get_mouse_plane_position() -> Vector3:
	var ray = get_viewport().get_camera_3d().get_mouse_ray(4, PLANE_COLLISION_LAYER);
	if(ray.is_colliding()):
		return ray.get_collision_point() - global_position;
	return Vector3.ZERO
	


func _process(_delta: float) -> void:
	#super._process(delta);

	if(is_focused):
		if(!is_interactive):_disable_focus() # If no longer interactive
	
