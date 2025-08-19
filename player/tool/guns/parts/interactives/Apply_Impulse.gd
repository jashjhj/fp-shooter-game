class_name Apply_Impulse extends Triggerable

@export var RIGIDBODY:RigidBody3D;
@export var IMPULSE:Vector3 = Vector3.ZERO;
@export var IMPULSE_RANDOM:Vector3 = Vector3.ZERO
##Global
@export var IMPULSE_POS:Vector3;
##If node is set, applies impulse fRom that node (Also using its basis)
@export var IMPULSE_POS_NODE:Node3D

func trigger():
	super.trigger()
	var impulse:Vector3 = IMPULSE;
	impulse += Vector3(randf_range(-1, 1)* IMPULSE_RANDOM.x, randf_range(-1, 1)* IMPULSE_RANDOM.y, randf_range(-1, 1)* IMPULSE_RANDOM.z)
	
	
	if(IMPULSE_POS_NODE != null):
		apply_impulse(IMPULSE_POS_NODE.global_basis * impulse, IMPULSE_POS_NODE.global_position)
	else:
		apply_impulse(impulse, IMPULSE_POS)
	

##POS is in global space
func apply_impulse(impulse:Vector3, pos:Vector3 = RIGIDBODY.global_position):
	if(RIGIDBODY != null):
		RIGIDBODY.apply_impulse(impulse, pos - RIGIDBODY.global_position)
