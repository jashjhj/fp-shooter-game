class_name Gunner_State_Shooting extends Gunner_State


func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta:float) -> void:
	pass

func physics_update(delta:float) -> void:
	OWNER.look_at(Globals.PLAYER.global_position);
	OWNER.next_velocity = Vector3.ZERO;
	
	var distance_to_player = (OWNER.global_position - Globals.PLAYER.global_position).length()
	if(distance_to_player > OWNER.STATS.SHOOT_DISTANCE+OWNER.STATS.SHOOT_DISTANCE_TOLERANCE or distance_to_player < OWNER.STATS.SHOOT_DISTANCE-OWNER.STATS.SHOOT_DISTANCE_TOLERANCE):
		transition.emit("Gunner_State_Approaching")
	
	OWNER.GUN.shoot.emit()
