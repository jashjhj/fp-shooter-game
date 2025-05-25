class_name Debris_Spawner extends Node3D

##Thing. Must be a rigidbody.
@export var THING:PackedScene

@export var SPAWN_VELOCITY:Vector3;
@export var SPAWN_ANGULAR_VELOCITY:Vector3;

@export var SPAWN_VELOCITY_RANDOM:Vector3;
@export var SPAWN_ANGULAR_VELOCITY_RANDOM:Vector3;

func _ready() -> void:
	assert(THING != null, "No thing exists to spawn.")
	var test_thing = THING.instantiate()
	assert(test_thing is RigidBody3D, "Thing is not a rigidbody.")
	test_thing.free();



#Gets velocities
var prev_pos:Vector3 = Vector3.ZERO;
var velocity:Vector3;
var prev_angles:Vector3 = Vector3.ZERO;
var velocity_angular:Vector3;
func _physics_process(delta: float) -> void:
	velocity = (global_position - prev_pos) / delta
	prev_pos = global_position;
	velocity_angular = (global_rotation - prev_angles) / delta
	prev_angles = global_rotation



func spawn() -> void:
	var new_thing = THING.instantiate() as RigidBody3D
	
	Globals.RUBBISH_COLLECTOR.add_child(new_thing)
	Globals.RUBBISH_COLLECTOR.add_rubbish(new_thing)
	
	new_thing.global_position = global_position
	new_thing.global_basis = global_basis
	new_thing.linear_velocity = velocity + global_basis*(SPAWN_VELOCITY + (randf()-0.5)*2*SPAWN_VELOCITY_RANDOM)
	new_thing.angular_velocity = velocity_angular + global_basis*(SPAWN_ANGULAR_VELOCITY + (randf()-0.5)*2*SPAWN_ANGULAR_VELOCITY_RANDOM)
	
