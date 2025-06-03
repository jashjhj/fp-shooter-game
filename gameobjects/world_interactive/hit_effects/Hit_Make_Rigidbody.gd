class_name Hit_Make_Rigidbody extends Hit_Component

@export var RIGIDBODY:RigidBody3D
@export var RIGIDBODY_BASIS_CLONE:Node3D;
@export var NEW_CHILDREN:Array[Node3D]
@export var TO_BE_REMOVED:Array[Node3D]

@export var AT_THRESHOLD:float = 0;

func  _ready() -> void:
	assert(RIGIDBODY != null, "No rigidbody set.")
	RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
	RIGIDBODY.collision_layer = 8192;
	RIGIDBODY.collision_mask = 1 + 8192 + 16384;

func hit(damage):
	if(HP > AT_THRESHOLD): return
	
	
	
	if(RIGIDBODY_BASIS_CLONE != null):
		RIGIDBODY.global_transform = RIGIDBODY_BASIS_CLONE.global_transform
	else:
		push_error("No basis to apply rigidbody to.")
	
	RIGIDBODY.reparent(Globals.RUBBISH_COLLECTOR)
	
	for removable in TO_BE_REMOVED:
		if(removable != null):
			removable.queue_free()
	for new_child in NEW_CHILDREN:
		if(new_child != null):
			new_child.reparent(RIGIDBODY)
	
	Globals.RUBBISH_COLLECTOR.add_rubbish(RIGIDBODY)
	RIGIDBODY.process_mode = Node.PROCESS_MODE_INHERIT
	
	
	RIGIDBODY.apply_impulse(last_impulse, last_impulse_pos - RIGIDBODY.global_position)
