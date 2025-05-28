class_name Gunner_State_Idle extends Gunner_State;

func _ready() -> void:
	super._ready()

func physics_update(delta:float) -> void:
	if(Globals.PLAYER.global_position - OWNER.global_position).length() < OWNER.VIEW_DISTANCE:
		#Player within range
		var player_pos:Vector3 = OWNER.HEAD.to_local(Globals.PLAYER.HEAD.global_position)
		if(player_pos.z < 0.1): # If in front
			var angle_x = abs(atan(player_pos.x/player_pos.z));
			var angle_y = abs(atan(player_pos.y/player_pos.z));
			
			if(angle_x < OWNER.VISION_FOV_X and angle_y < OWNER.VISION_FOV_Y): # If within FOV
				
				OWNER.RAY.target_position = OWNER.RAY.to_local(Globals.PLAYER.global_position).normalized()*OWNER.VIEW_DISTANCE
				OWNER.RAY.collision_mask = 1 + 16;
				
				OWNER.RAY.force_raycast_update();
				if(OWNER.RAY.is_colliding()):
					if(OWNER.RAY.get_collider() == Globals.PLAYER):
						#Can see the player
						transition.emit("Gunner_State_Approaching")
	
	
