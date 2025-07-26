class_name Make_Rigidbody extends Node

@export var RIGIDBODY:RigidBody3D
@export var RIGIDBODY_BASIS_CLONE:Node3D;
@export var NEW_CHILDREN:Array[NodePath]
@export var TO_BE_REMOVED:Array[NodePath]

@export_enum("Small debris:4096", "Medium Debris:8192", "Large Debris:16384") var collision_layer:int = 8192;

var is_rb_active:bool = false;

func  _ready() -> void:
	assert(RIGIDBODY != null, "No rigidbody set.")
	RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
	RIGIDBODY.collision_layer = collision_layer;
	RIGIDBODY.collision_mask = 1 + 8192 + 16384;

func trigger():
	
	is_rb_active = true
	
	if(RIGIDBODY_BASIS_CLONE != null):
		RIGIDBODY.global_transform = RIGIDBODY_BASIS_CLONE.global_transform
	else:
		push_error("No basis to apply rigidbody to.")
		return
	
	
	RIGIDBODY.reparent(Globals.RUBBISH_COLLECTOR)
	
	for removable in TO_BE_REMOVED:
		var c = get_node(removable)
		if(c != null):
			c.queue_free()
	for new_child in NEW_CHILDREN:
		var c = get_node(new_child)
		if(c != null):
			c.reparent(RIGIDBODY)
	
	Globals.RUBBISH_COLLECTOR.add_rubbish(RIGIDBODY)
	RIGIDBODY.process_mode = Node.PROCESS_MODE_INHERIT
	
	for i in range(0, len(impulses)):
		RIGIDBODY.apply_impulse(impulses[i], impulses_pos[i] - RIGIDBODY.global_position)


#Impulses handling

var impulses:Array[Vector3]
var impulses_pos:Array[Vector3]

##If called before freeing the RB, it queues the impulse. Pos is in global positions, as does not yet know where the part will gib to.

func add_impulse(impulse:Vector3, pos:Vector3):
	if(is_rb_active):
		RIGIDBODY.apply_impulse(impulse, pos - RIGIDBODY.global_position)
		return
	else:
		impulses.append(impulse) # If not active, queues.
		impulses_pos.append(pos)
