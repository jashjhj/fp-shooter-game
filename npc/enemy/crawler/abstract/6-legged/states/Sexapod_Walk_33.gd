class_name Sexapod_Walk_33 extends Sexapod_State

var ray:RayCast3D = RayCast3D.new()

var tripod_swap_distance:float;
var current_tripod:int = 2;

var tripod_1:Array[Crawler_Leg]#= [SEXAPOD.LEG_L0, SEXAPOD.LEG_R1, SEXAPOD.LEG_L2]
var tripod_2:Array[Crawler_Leg]#= [SEXAPOD.LEG_R0, SEXAPOD.LEG_L1, SEXAPOD.LEG_R2]


var previous_distance;

func init():
	add_child(ray)
	ray.hit_from_inside = true;
	
	tripod_swap_distance = fmod(SEXAPOD.distance_travelled, SEXAPOD.GAIT_STEP_LENGTH)
	previous_distance = SEXAPOD.distance_travelled
	
	tripod_1 = [SEXAPOD.LEG_L0, SEXAPOD.LEG_R1, SEXAPOD.LEG_L2]
	tripod_2 = [SEXAPOD.LEG_R0, SEXAPOD.LEG_L1, SEXAPOD.LEG_R2]


func process_legs(delta: float) -> void:
	
	tripod_swap_distance += SEXAPOD.distance_travelled - previous_distance
	previous_distance = SEXAPOD.distance_travelled
	
	if(tripod_swap_distance > SEXAPOD.GAIT_STEP_LENGTH):
		tripod_swap_distance = 0;
		
		if(current_tripod == 2):
			current_tripod = 1;
			
			tripod_1[0].set_leg_stationary()
			tripod_1[1].set_leg_stationary()
			tripod_1[2].set_leg_stationary()
			
			tripod_2[0].set_leg_target(ray_from(Vector3( 0.5*SEXAPOD.GAIT_WIDTH, 0, -2.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			tripod_2[1].set_leg_target(ray_from(Vector3(-0.5*SEXAPOD.GAIT_WIDTH, 0, -1.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			tripod_2[2].set_leg_target(ray_from(Vector3( 0.5*SEXAPOD.GAIT_WIDTH, 0, -0.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			
			#tripod_2[0].set_leg_target(SEXAPOD.to_global(Vector3( 0.5*SEXAPOD.GAIT_WIDTH ,-SEXAPOD.GAIT_HEIGHT, -2.5*SEXAPOD.GAIT_STEP_LENGTH)), false)
			#tripod_2[1].set_leg_target(SEXAPOD.to_global(Vector3(-0.5*SEXAPOD.GAIT_WIDTH ,-SEXAPOD.GAIT_HEIGHT, -1.5*SEXAPOD.GAIT_STEP_LENGTH)), false)
			#tripod_2[2].set_leg_target(SEXAPOD.to_global(Vector3( 0.5*SEXAPOD.GAIT_WIDTH ,-SEXAPOD.GAIT_HEIGHT, -0.5*SEXAPOD.GAIT_STEP_LENGTH)), false)
			
		else:
			current_tripod = 2;
			
			tripod_1[0].set_leg_target(ray_from(Vector3(-0.5*SEXAPOD.GAIT_WIDTH, 0, -2.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			tripod_1[1].set_leg_target(ray_from(Vector3( 0.5*SEXAPOD.GAIT_WIDTH, 0, -1.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			tripod_1[2].set_leg_target(ray_from(Vector3(-0.5*SEXAPOD.GAIT_WIDTH, 0, -0.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			
			#tripod_1[0].set_leg_target(SEXAPOD.to_global(Vector3(-0.5*SEXAPOD.GAIT_WIDTH ,-SEXAPOD.GAIT_HEIGHT, -2.5*SEXAPOD.GAIT_STEP_LENGTH)), false)
			#tripod_1[1].set_leg_target(SEXAPOD.to_global(Vector3( 0.5*SEXAPOD.GAIT_WIDTH ,-SEXAPOD.GAIT_HEIGHT, -1.5*SEXAPOD.GAIT_STEP_LENGTH)), false)
			#tripod_1[2].set_leg_target(SEXAPOD.to_global(Vector3(-0.5*SEXAPOD.GAIT_WIDTH ,-SEXAPOD.GAIT_HEIGHT, -0.5*SEXAPOD.GAIT_STEP_LENGTH)), false)
			
			tripod_2[0].set_leg_stationary()
			tripod_2[1].set_leg_stationary()
			tripod_2[2].set_leg_stationary()
			
	
	var progress = tripod_swap_distance/SEXAPOD.GAIT_STEP_LENGTH;
	tripod_1[0].set_leg_progress(progress)
	tripod_1[1].set_leg_progress(progress)
	tripod_1[2].set_leg_progress(progress)
	tripod_2[0].set_leg_progress(progress)
	tripod_2[1].set_leg_progress(progress)
	tripod_2[2].set_leg_progress(progress)
	


func ray_from(pos:Vector3, dir:Vector3) -> Vector3:
	ray.global_position = SEXAPOD.to_global(pos);
	ray.target_position = (dir.normalized())
	
	ray.force_raycast_update()
	if(ray.is_colliding()):
		return ray.get_collision_point()
	else:
		#Return ray start pos
		return SEXAPOD.to_global(pos)
	
