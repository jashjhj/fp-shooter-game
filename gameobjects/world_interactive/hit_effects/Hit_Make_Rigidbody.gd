class_name Hit_Make_Rigidbody extends Hit_Component

@export var RIGIDBODY:RigidBody3D
@export var RIGIDBODY_BASIS_CLONE:Node3D;
@export var NEW_CHILDREN:Array[Node3D]
@export var TO_BE_REMOVED:Array[Node3D]

@export var AT_THRESHOLD:float = 0;

func  _ready() -> void:
	assert(RIGIDBODY != null, "No rigidbody set.")
	RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
	RIGIDBODY.collision_layer = 4096;
	RIGIDBODY.collision_mask = 1;

func hit(damage):
	if(HP > AT_THRESHOLD): return
	
	if(RIGIDBODY_BASIS_CLONE != null):
		RIGIDBODY.global_transform = RIGIDBODY_BASIS_CLONE.global_transform
	
	for removable in TO_BE_REMOVED:
		if(removable != null):
			removable.queue_free()
	for new_child in NEW_CHILDREN:
		if(new_child != null):
			new_child.reparent(RIGIDBODY)
	
	RIGIDBODY.reparent(Globals.RUBBISH_COLLECTOR)
	Globals.RUBBISH_COLLECTOR.add_rubbish(RIGIDBODY)
	RIGIDBODY.process_mode = Node.PROCESS_MODE_INHERIT
	
