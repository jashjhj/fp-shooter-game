class_name Gunner_State_Shooting extends Gunner_State

@export var GUN_SHOOT_POS:Node3D;

func enter() -> void:
	OWNER.GUN_TARGET_POS.global_transform = GUN_SHOOT_POS.global_transform

func exit() -> void:
	pass

func update(delta:float) -> void:
	pass

func physics_update(delta:float) -> void:
	OWNER.look_at(Globals.PLAYER.global_position);
	OWNER.next_velocity = Vector3.ZERO;
	
	var distance_to_player = (OWNER.global_position - Globals.PLAYER.global_position).length()
	if(distance_to_player > OWNER.STATS.SHOOT_DISTANCE+OWNER.STATS.SHOOT_DISTANCE_TOLERANCE or distance_to_player < 2.0):
		transition.emit("Gunner_State_Approaching")
	
	OWNER.RAY.target_position = OWNER.RAY.to_local(Globals.PLAYER.TORSO.global_position);
	OWNER.RAY.force_raycast_update()
	if(OWNER.RAY.get_collider() != Globals.PLAYER):
		transition.emit("Gunner_State_Approaching")
	OWNER.GUN.shoot.emit()
