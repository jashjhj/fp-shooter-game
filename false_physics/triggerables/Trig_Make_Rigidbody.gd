class_name Trig_Make_Rigidbody extends Triggerable

@export var RIGIDBODY:RigidBody3D
@export var RIGIDBODY_BASIS_CLONE:Node3D;
@export var NEW_CHILDREN:Array[Node]
@export var TO_BE_REMOVED:Array[Node]

@export var AUTO_SET_COLLISION:bool = true;
@export_enum("Small debris:4096", "Medium Debris:8192", "Large Debris:16384", "Small debris NoHit:256", "Medium Debris NoHit:512", "Large Debris NoHit:1024") var collision_layer:int = 8192;

var is_rb_active:bool = false;

func  _ready() -> void:
	super._ready()
	
	assert(RIGIDBODY != null, "No rigidbody set.")
	RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
	
	if(AUTO_SET_COLLISION):
		RIGIDBODY.collision_layer = collision_layer;
		RIGIDBODY.collision_mask = 1 + 64 + 512 + 1028 + 8192 + 16384;


func trigger():
	super.trigger()
	
	is_rb_active = true
	
	if(RIGIDBODY_BASIS_CLONE != null):
		RIGIDBODY.global_transform = RIGIDBODY_BASIS_CLONE.global_transform
	else:
		push_error("No basis to apply rigidbody to.")
		return
	
	
	RIGIDBODY.reparent(Globals.RUBBISH_COLLECTOR)
	

	for c in NEW_CHILDREN:
		if(c != null):
			c.call_deferred("reparent", RIGIDBODY)
	
	Globals.RUBBISH_COLLECTOR.add_rubbish(RIGIDBODY)
	enable_rb_processing()
	
	for i in range(0, len(impulses)):
		RIGIDBODY.apply_impulse(impulses[i], impulses_pos[i] - RIGIDBODY.global_position)
	
	
	#Clears removables finally
	for c in TO_BE_REMOVED:
		if(c != null):
			c.queue_free()
	

func enable_rb_processing():
	RIGIDBODY.process_mode = Node.PROCESS_MODE_INHERIT

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
