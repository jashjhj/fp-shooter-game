class_name Sexapod_Walk_Tripod extends Sexapod_State

var ray:RayCast3D = RayCast3D.new()

var tripod_swap_distance:float;
var current_tripod:int = 2;

var tripod_1:Array[Crawler_Leg]#= [SEXAPOD.LEG_L0, SEXAPOD.LEG_R1, SEXAPOD.LEG_L2]
var tripod_2:Array[Crawler_Leg]#= [SEXAPOD.LEG_R0, SEXAPOD.LEG_L1, SEXAPOD.LEG_R2]


var tripod_1_legs := 3;
var tripod_2_legs := 3;

var previous_distance;

func init():
	add_child(ray)
	ray.hit_from_inside = true;
	
	tripod_swap_distance = fmod(SEXAPOD.distance_travelled, SEXAPOD.GAIT_STEP_LENGTH)
	previous_distance = SEXAPOD.distance_travelled
	
	
	init_tris()


func init_tris():
	needs_reinit = false;
	
	tripod_1_legs = 3;
	tripod_2_legs = 3;
	tripod_1 = [];
	tripod_2 = [];
	if(SEXAPOD.LEG_L0 == null): # Adds legs to arrays
		tripod_1_legs -= 1;
		tripod_1.append(Crawler_Leg_Ghost.new())
	else:tripod_1.append(SEXAPOD.LEG_L0)
	if(SEXAPOD.LEG_R1 == null):
		tripod_1_legs -= 1;
		tripod_1.append(Crawler_Leg_Ghost.new())
	else:tripod_1.append(SEXAPOD.LEG_R1)
	if(SEXAPOD.LEG_L2 == null):
		tripod_1_legs -= 1;
		tripod_1.append(Crawler_Leg_Ghost.new())
	else:tripod_1.append(SEXAPOD.LEG_L2)
	
	if(SEXAPOD.LEG_R0 == null):
		tripod_2_legs -= 1;
		tripod_2.append(Crawler_Leg_Ghost.new())
	else:tripod_2.append(SEXAPOD.LEG_R0)
	if(SEXAPOD.LEG_L1 == null):
		tripod_2_legs -= 1;
		tripod_2.append(Crawler_Leg_Ghost.new())
	else:tripod_2.append(SEXAPOD.LEG_L1)
	if(SEXAPOD.LEG_R2 == null):
		tripod_2_legs -= 1;
		tripod_2.append(Crawler_Leg_Ghost.new())
	else:tripod_2.append(SEXAPOD.LEG_R2)

var needs_reinit = false;
func process_legs(delta: float) -> void:
	if(needs_reinit):init_tris()
	
	tripod_swap_distance += SEXAPOD.distance_travelled - previous_distance
	previous_distance = SEXAPOD.distance_travelled
	
	if(tripod_swap_distance > SEXAPOD.GAIT_STEP_LENGTH):
		tripod_swap_distance = 0;
		
		if(current_tripod == 2):
			current_tripod = 1;
			
			for i in range(0, len(tripod_1)): # Sit down tripod 1
				tripod_1[i].set_leg_stationary()
			
			#if(duff_tripod != 1):#this ones fine
			tripod_2[0].set_leg_target(ray_from(Vector3( 0.5*SEXAPOD.GAIT_WIDTH, 0, -2.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN), false)
			tripod_2[1].set_leg_target(ray_from(Vector3(-0.5*SEXAPOD.GAIT_WIDTH, 0, -1.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN), false)
			tripod_2[2].set_leg_target(ray_from(Vector3( 0.5*SEXAPOD.GAIT_WIDTH, 0, -0.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN), false)
			
		else:
			current_tripod = 2;
			
			for i in range(0, len(tripod_2)): # Sit down tripod 2
				tripod_2[i].set_leg_stationary()
			
			#if(duff_tripod != 2): #If this ones fine
			tripod_1[0].set_leg_target(ray_from(Vector3(-0.5*SEXAPOD.GAIT_WIDTH, 0, -2.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			tripod_1[1].set_leg_target(ray_from(Vector3( 0.5*SEXAPOD.GAIT_WIDTH, 0, -1.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			tripod_1[2].set_leg_target(ray_from(Vector3(-0.5*SEXAPOD.GAIT_WIDTH, 0, -0.5*SEXAPOD.GAIT_STEP_LENGTH), Vector3.DOWN))
			
			
			
	
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
	

func get_speed_mult() -> float:
	if(current_tripod == 1):
		match tripod_1_legs:
			3: return 1.0;
			2: return 0.7;
			1: return 0.4;
			0: return 0;
	else:
		match tripod_2_legs:
			3: return 1.0;
			2: return 0.7;
			1: return 0.4;
			0: return 0;
	return 1.0;
