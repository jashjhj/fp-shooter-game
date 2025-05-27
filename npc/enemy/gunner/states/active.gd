class_name Gunner_State_Active extends Gunner_State

@export var WALK_SPEED:float = 2;

func _ready() -> void:
	super._ready();



func enter():
	OWNER.NAV_AGENT.velocity_computed.connect(set_velocity)

func physics_update(delta):
	OWNER.NAV_AGENT.target_position = Globals.PLAYER.global_position;
	
	var walk_vector = (OWNER.NAV_AGENT.get_next_path_position() - OWNER.global_position).normalized()
	
	OWNER.NAV_AGENT.velocity = walk_vector * WALK_SPEED;


func set_velocity(safe_velocity:Vector3):
	OWNER.next_velocity = safe_velocity
