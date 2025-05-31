class_name Gunner_State_Active extends Gunner_State

@export var WALK_SPEED:float = 2;
var is_active = false;

@export var GUN_IDLE_POS:Node3D;

var SEE_PLAYER_TILL_SHOOT_TICKS:int = 30;
var can_see_player_duration:int = 0;


func _ready() -> void:
	super._ready();



func enter():
	OWNER.NAV_AGENT.velocity_computed.connect(set_velocity)
	OWNER.GUN_TARGET_POS.global_transform = GUN_IDLE_POS.global_transform;
	can_see_player_duration = 0;

func physics_update(delta):
	
	OWNER.RAY.target_position = OWNER.RAY.to_local(Globals.PLAYER.TORSO.global_position);
	OWNER.RAY.force_raycast_update()
	if(OWNER.RAY.get_collider() == Globals.PLAYER):
		
		OWNER.NAV_AGENT.target_position = get_radial_target_position(OWNER.STATS.SHOOT_DISTANCE);
		#can_see_player_duration += 1;
		#if(can_see_player_duration > SEE_PLAYER_TILL_SHOOT_TICKS):
		#	OWNER.NAV_AGENT.target_position = get_radial_target_position(OWNER.STATS.SHOOT_DISTANCE);
		#else:
		#	OWNER.NAV_AGENT.target_position = Globals.PLAYER.global_position
	else:
		can_see_player_duration = 0;
		OWNER.NAV_AGENT.target_position = Globals.PLAYER.global_position
	
	
	var walk_vector = (OWNER.NAV_AGENT.get_next_path_position() - OWNER.global_position).normalized()
	var look_at_dir = walk_vector;
	look_at_dir.y = 0;
	if(look_at_dir != Vector3.ZERO):
		OWNER.look_at(OWNER.global_position + look_at_dir)
	OWNER.NAV_AGENT.velocity = walk_vector * WALK_SPEED;
	
	var distance_to_player = (OWNER.global_position - Globals.PLAYER.global_position).length()
	if(distance_to_player < OWNER.STATS.SHOOT_DISTANCE+OWNER.STATS.SHOOT_DISTANCE_TOLERANCE and distance_to_player > OWNER.STATS.SHOOT_DISTANCE-OWNER.STATS.SHOOT_DISTANCE_TOLERANCE): # If can see player
		can_see_player_duration += 1;
		if(can_see_player_duration > SEE_PLAYER_TILL_SHOOT_TICKS):
			transition.emit("Gunner_State_Shooting")
	else:
		can_see_player_duration = 0;

func exit():
	OWNER.NAV_AGENT.velocity_computed.disconnect(set_velocity)


func get_radial_target_position(distance) -> Vector3:
	var vec_to_player = (OWNER.global_position - Globals.PLAYER.global_position).normalized()
	vec_to_player *= distance;
	return Globals.PLAYER.global_position + vec_to_player;

func set_velocity(safe_velocity:Vector3):
	OWNER.next_velocity = safe_velocity
