class_name Trig_Debris_Spawner extends Triggerable

##Thing. Must be a rigidbody.
@export var THING:PackedScene
@export var SPAWN_AT:Node3D


@export var SPAWN_VELOCITY:Vector3;
@export var SPAWN_VELOCITY_RANDOM:Vector3;

@export var SPAWN_ANGULAR_VELOCITY:Vector3;


@export var SPAWN_ANGULAR_VELOCITY_RANDOM:Vector3;

func _ready() -> void:
	super._ready()
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
	if(SPAWN_AT == null):
		velocity = Vector3.ZERO
		velocity_angular = Vector3.ZERO
		return
	velocity = (SPAWN_AT.global_position - prev_pos) / delta
	prev_pos = SPAWN_AT.global_position;
	velocity_angular = (SPAWN_AT.global_rotation - prev_angles) / delta
	prev_angles = SPAWN_AT.global_rotation



func trigger() -> void:
	super.trigger()
	
	var new_thing = THING.instantiate() as RigidBody3D
	
	Globals.RUBBISH_COLLECTOR.add_child(new_thing)
	Globals.RUBBISH_COLLECTOR.add_rubbish(new_thing)
	
	if(SPAWN_AT != null):
		new_thing.global_position = SPAWN_AT.global_position
		new_thing.global_basis = SPAWN_AT.global_basis
		new_thing.linear_velocity = velocity + SPAWN_AT.global_basis*(SPAWN_VELOCITY + (randf()-0.5)*2*SPAWN_VELOCITY_RANDOM)
		new_thing.angular_velocity = velocity_angular + SPAWN_AT.global_basis*(SPAWN_ANGULAR_VELOCITY + (randf()-0.5)*2*SPAWN_ANGULAR_VELOCITY_RANDOM)
	else:
		push_error("No SPAWN_AT set")
