class_name Gunner_State_Shooting extends Gunner_State

@export var GUN_SHOOT_POS:Node3D;
@export var SHOOT_COOLDOWN:float = 0.25;
@export var SHOOT_ACCURACY:float = 0.1;
@export var SHOT_CONFIDENCE:float = 8.0;

var last_shot:int = Time.get_ticks_msec();
var target_confidence:float = 0;
var locked_on:bool = false;

func enter() -> void:
	OWNER.GUN_TARGET_POS.global_transform = GUN_SHOOT_POS.global_transform
	var owner_vector_to_player := Globals.PLAYER.TORSO.global_position - OWNER.global_position
	var horizontal_owner_vector_to_player := Vector3(owner_vector_to_player.x, 0, owner_vector_to_player.z)
	OWNER.look_at(OWNER.global_position + horizontal_owner_vector_to_player);
	OWNER.next_velocity = Vector3.ZERO;


func physics_update(delta:float) -> void:
	
	if(!staying_in_state()): return
	
	var owner_vector_to_player:Vector3 = Globals.PLAYER.TORSO.global_position - OWNER.global_position
	var horizontal_owner_vector_to_player := Vector3(owner_vector_to_player.x, 0, owner_vector_to_player.z)
	var angle_between_owner_and_player:float = abs(acos(-OWNER.global_basis.z.dot(horizontal_owner_vector_to_player.normalized())))
	
	if(angle_between_owner_and_player > 0.5):
		OWNER.look_at(OWNER.global_position + horizontal_owner_vector_to_player);
	
	
	
	var gun_vector_to_player = Globals.PLAYER.TORSO.global_position - OWNER.GUN.global_position
	var angle_between_gun_and_player = abs(acos(-OWNER.GUN.global_basis.z.dot(gun_vector_to_player.normalized())))
	OWNER.GUN_TARGET_POS.look_at(Globals.PLAYER.TORSO.global_position)
	
	target_confidence -= angle_between_gun_and_player
	#target_confidence = lerp(target_confidence, 1.0, min(1, 0.1*delta));
	
	if(!locked_on and angle_between_gun_and_player < 0.1):
		locked_on = true;
		target_confidence = 0;
	elif(locked_on and angle_between_gun_and_player > 0.3):
		locked_on = false
	
	if(locked_on):
		target_confidence = lerp(target_confidence, 1.0, min(1, SHOT_CONFIDENCE*delta));
		
		if(target_confidence > 0.8):
			if(Time.get_ticks_msec() - last_shot > SHOOT_COOLDOWN*1000):
				last_shot = Time.get_ticks_msec()
				
				OWNER.GUN.shoot.emit()
	
	print(target_confidence)



func staying_in_state() -> bool:
	var distance_to_player = (OWNER.global_position - Globals.PLAYER.global_position).length()
	if(distance_to_player > OWNER.STATS.SHOOT_DISTANCE+OWNER.STATS.SHOOT_DISTANCE_TOLERANCE or distance_to_player < 2.0): # If player is too far away.
		transition.emit("Gunner_State_Approaching")
		return false
	
	OWNER.RAY.target_position = OWNER.RAY.to_local(Globals.PLAYER.TORSO.global_position);
	OWNER.RAY.force_raycast_update()
	if(OWNER.RAY.get_collider() != Globals.PLAYER):
		transition.emit("Gunner_State_Approaching")
		return false
	
	return true

func exit():
	OWNER.GUN_LERP_RATE = 5.0;
