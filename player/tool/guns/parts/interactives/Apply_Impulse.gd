class_name Apply_Impulse extends Node

@export var RIGIDBODY:RigidBody3D;

##POS is in global space
func apply_impulse(impulse:Vector3, pos:Vector3 = RIGIDBODY.global_position):
	if(RIGIDBODY != null):
		RIGIDBODY.apply_impulse(impulse, pos - RIGIDBODY.global_position)
