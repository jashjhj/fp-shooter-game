class_name Gunner_State_Active extends Gunner_State

@export var WALK_SPEED:float = 2;
var is_active = false;


func _ready() -> void:
	super._ready();



func enter():
	OWNER.NAV_AGENT.velocity_computed.connect(set_velocity)

func physics_update(delta):
	OWNER.NAV_AGENT.target_position = get_radial_target_position(OWNER.STATS.SHOOT_DISTANCE);
	
	var walk_vector = (OWNER.NAV_AGENT.get_next_path_position() - OWNER.global_position).normalized()
	var look_at_dir = walk_vector;
	look_at_dir.y = 0;
	OWNER.look_at(OWNER.global_position + look_at_dir)
	OWNER.NAV_AGENT.velocity = walk_vector * WALK_SPEED;
	
	var distance_to_player = (OWNER.global_position - Globals.PLAYER.global_position).length()
	if(distance_to_player < OWNER.STATS.SHOOT_DISTANCE+OWNER.STATS.SHOOT_DISTANCE_TOLERANCE and distance_to_player > OWNER.STATS.SHOOT_DISTANCE-OWNER.STATS.SHOOT_DISTANCE_TOLERANCE):
		transition.emit("Gunner_State_Shooting")

func exit():
	OWNER.NAV_AGENT.velocity_computed.disconnect(set_velocity)


func get_radial_target_position(distance) -> Vector3:
	var vec_to_player = (OWNER.global_position - Globals.PLAYER.global_position).normalized()
	vec_to_player *= distance;
	return Globals.PLAYER.global_position + vec_to_player;

func set_velocity(safe_velocity:Vector3):
	OWNER.next_velocity = safe_velocity
