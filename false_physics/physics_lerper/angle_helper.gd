@tool

class_name Angular_Damper extends Generic6DOFJoint3D

@export var STIFFNESS:float = 8.0:
	set(v):
		STIFFNESS = v
		update_stiffness(v)
@export var DAMPING:float = 2.0:
	set(v):
		DAMPING = v
		update_damping(v)
@export var enabled:bool = true:
	set(v):
		enabled = v
		set_spring(v)
@export var locked:bool = false:
	set(v):
		locked = v
		set_locked(locked)

var offset:Vector3;
var parent:Node3D
var initial_angles:Vector3;

func _ready() -> void:
	update_damping(DAMPING)
	update_stiffness(STIFFNESS)
	set_spring(enabled)
	set_locked(locked)
	
	set("linear_limit_x/enabled", false)
	set("linear_limit_y/enabled", false)
	set("linear_limit_z/enabled", false)
	
	top_level = true;
	transform.basis = Basis.IDENTITY
	
	if not Engine.is_editor_hint(): # At runtime
		parent = get_parent()
		offset = global_position - parent.global_position

func _physics_process(delta: float) -> void:
	global_position = parent.global_position + offset

##Uses a global delta, i.e. (0, 0, -1) looks towards -Z
func set_forward(v:Vector3):
	#set("angular_spring_x/equilibrium_point", atan2(v.y,v.z))
	#set("angular_spring_y/equilibrium_point", atan2(v.z,v.x))
	#print(atan2(v.z,v.x))
	#set("angular_spring_z/equilibrium_point", atan2(v.x,v.y))
	pass


func update_damping(d):
	set("angular_spring_z/damping", d)
	set("angular_spring_y/damping", d)
	set("angular_spring_x/damping", d)
	
	#set("angular_limit_z/damping", d) # Not supported by physics, relies only on spring
	#set("angular_limit_y/damping", d)
	#set("angular_limit_x/damping", d)

func update_stiffness(s):
	set("angular_spring_z/stiffness", s)
	set("angular_spring_y/stiffness", s)
	set("angular_spring_x/stiffness", s)

func set_spring(s:bool):
	set("angular_spring_z/enabled", s)
	set("angular_spring_y/enabled", s)
	set("angular_spring_x/enabled", s)

func set_locked(l:bool):
	set("angular_limit_x/enabled", l)
	set("angular_limit_y/enabled", l)
	set("angular_limit_z/enabled", l)
