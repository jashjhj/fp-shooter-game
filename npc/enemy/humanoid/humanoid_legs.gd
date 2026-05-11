class_name Humanoid_Legs extends Leg_Manager

var walk_vector:Vector3 = Vector3.ZERO

@export_group("Gait Settings")
#@export var IDLE_HEIGHT:float = 1.5;
@export var FOOT_PLANT_RADIUS:float = 1.0;


var stability:float = 0.0;
var body_height:float;



var LEGS_STATE_IDLE:Humanoid_Legs_State = Humanoid_Legs_State_Idle.new()
var LEGS_STATE_STABILISING:Humanoid_Legs_State = Humanoid_Legs_State_Stabilising.new()
var LEGS_STATE_WALKING:Humanoid_Legs_State = Humanoid_Legs_State_Walking.new()


var current_state:Humanoid_Legs_State = LEGS_STATE_STABILISING;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	assert(len(LEGS) == 2, "Humanoid does not have 2 Legs :( " + str(get_path));
	
	LEGS_STATE_IDLE.LEGS = self
	LEGS_STATE_STABILISING.LEGS = self
	LEGS_STATE_WALKING.LEGS = self;

func _physics_process(delta: float) -> void:
	super(delta)
	
	
	current_state.update_stability(delta) # if error, need to set the legs states.
	current_state.update_state()
	
	current_state.consider_step()
	current_state.update_leg_targets()
	
	update_target_pos()
	
	
	DOWN_RAY.global_position = BODY.global_position # update body height
	DOWN_RAY.force_raycast_update()
	if(DOWN_RAY.is_colliding()):
		body_height = (DOWN_RAY.get_collision_point() - BODY.global_position).y
	
	
	
	Debug.point(TARGET.global_position, 0.1, Color(0.591, 0.912, 0.707))
	DebugDraw3D.draw_text(global_position + 2*Vector3.UP, str("%2f" % stability));


#STATES:
# IF STABLE > 0.6, walk or idle, depends on walking vector.
# IF STABLE < 0.2, stabilise mode.





##Updates self target
func update_target_pos():
	var stable_area := calculate_stable_area()
	var ideal_height = IDLE_HEIGHT
	for leg in LEGS:
		#If foot is extended far out (imagine the splits) cannot stand so tall. Calcualted theoretical max height
		var gradient:float = 1.0;
		
		var max_reachable_height:float = sqrt( (leg.UPPER_LENGTH+leg.LOWER_LENGTH)**2 - ((leg.FOOT.global_position - leg.global_position) * Vector3(1, 0, 1)).length_squared() )
		#if(stability < 0.2): max_reachable_height = leg.UPPER_LENGTH+leg.LOWER_LENGTH
		
		ideal_height = min(ideal_height, gradient * max_reachable_height)
	
	ideal_height = lerp(ideal_height * 0.8, ideal_height, stability)
	
	
	TARGET.global_position = get_centre_of_stable_area(stable_area) + Vector3.UP * ideal_height
	
	if current_state == LEGS_STATE_WALKING: # move target pos to slowly push body forwards.
		
		TARGET.global_position += walk_vector;
