class_name Tool_Part_Interactive_1D extends Tool_Part_Interactive
##Inheriting classes must set VELOCITY.


##Start position / distance / rotation
var DISTANCE:float = 0.0;
var prev_distance:float = DISTANCE
##Current velocity (Considering: DISTANCE)
var velocity:float = 0.0;

##Tracks last 20 velocity ticks by the mouse (4/frame @ 60fps, 20 ~= 0.8 seconds)
var velocity_tracker:Array[float]



#@export_group("Interaction", "INTERACT_")
@export var INTERACT_POSITIVE_DIRECTION:Vector3 = Vector3.FORWARD




##In metres or rads
@export var MIN_LIMITS:Array[float]
##In metres or rads
@export var MAX_LIMITS:Array[float]


@export_group("Mechanism")
##Spring acceleration - constant component
@export var SPRING_FORCE_CONSTANT:float = 0.0;
##Spring accelearion, multiplied by DISTANCE.  If this wants to be implemented to go 'the other way', make this negative and the constant force higher, meaning MAX force.
@export var SPRING_FORCE_LINEAR:float = 0.0
##Friction force. Acts as constant acceleration opposing motion.
@export var FRICTION_FORCE:float = 0.1;

@export var ELASTICITY_AT_MAX:float = 0.2;
@export var ELASTICITY_AT_MIN:float = 0.1;


@export_group("Triggers", "TRIGGERS_")
enum TRIGGERS_DIRECTION_ENUM {
	FORWARDS = 1,
	BACKWARDS = 2,
	BOTH = 3
}
@export var TRIGGERS_TRIGGERABLE:Array[Triggerable]
@export var TRIGGERS_DISTANCE:Array[float]
@export var TRIGGERS_DIRECTION:Array[TRIGGERS_DIRECTION_ENUM]


var prev_velocity:float;

##Ready
func _ready():
	
	#INTERACT_POSITIVE_DIRECTION = INTERACT_POSITIVE_DIRECTION.normalized() - #doesnt matter, can be iffy for more complex results.
	
	if not (len(TRIGGERS_TRIGGERABLE) == len(TRIGGERS_DISTANCE) and len(TRIGGERS_TRIGGERABLE) == len(TRIGGERS_DIRECTION)):
		print_debug(TRIGGERS_TRIGGERABLE, TRIGGERS_DISTANCE, TRIGGERS_DIRECTION)
		push_error("Triggers Arrays must be matching lengths")
	
	super._ready();

func _process(delta:float) -> void:
	super._process(delta);



func mouse_movement(motion:Vector3):
	super(motion)
	
	var delta = motion.dot(global_basis*INTERACT_POSITIVE_DIRECTION)
	
	frame_mouse_accumulated_dist += delta
	DISTANCE += delta


signal pre_physics_process(delta:float)
signal within_physics_process(delta:float)

var frame_mouse_accumulated_dist:float = 0;

##CallAfter processing / when you want distance to be calculated
func _physics_process(delta:float) -> void:
	
	pre_physics_process.emit(delta)
	
	
	velocity_tracker.append(frame_mouse_accumulated_dist / delta)
	if(len(velocity_tracker) > 20):
		velocity_tracker.remove_at(0)
	
	frame_mouse_accumulated_dist = 0;
	
	
	var accel:float = 0;
	
	#DISTANCE += velocity * delta * 0.5
	var prev_velocity:float = velocity
	
	if(is_focused):
		#pass
		velocity = 0;
	
	else:
		
		velocity += (SPRING_FORCE_CONSTANT + SPRING_FORCE_LINEAR*DISTANCE) * delta
		velocity = sign(velocity) * max(0, abs(velocity) - FRICTION_FORCE * delta)
		
		accel = (velocity - prev_velocity) / delta
		#print("v:",velocity, " pv:", prev_vel, " d: ", DISTANCE)
		DISTANCE += prev_velocity*delta + 0.5*accel*delta*delta # s=ut+1/2at^2.
	
	if(is_focused):
		prev_velocity = read_velocity()
		velocity = read_velocity()
		
	
	
	
	
	# apply limits.                                MAX LIMIT --
	var hit_limit:bool = false;
	for lim in MAX_LIMITS:
		
		if(DISTANCE >= lim):
			DISTANCE = lim # clamped not reflected in case a new limit is imposed.
			hit_limit = true
		
	if(hit_limit):
		
		if(!is_focused and velocity > 0):
			
			#v^2 = u^2 + 2as, calculates Velocity actual at impact
			var u2add2as = prev_velocity*prev_velocity + 2*accel*(DISTANCE-prev_distance);
			velocity = sqrt(abs(u2add2as)) * sign(prev_velocity) 
			
			if(abs(velocity) > 0.001): hit_max_limit(velocity)
			
			velocity = -velocity * ELASTICITY_AT_MAX
			
		elif(is_focused and read_velocity() > 0):
			if(abs(velocity) > 0.001): hit_max_limit(velocity * 0.1)
		
	
	
	hit_limit = false; #                        MIN LIMIT --
	for lim in MIN_LIMITS:
		
		if(DISTANCE <= lim):
			hit_limit = true
			DISTANCE = lim
			
		
	if(hit_limit):
		
		if(!is_focused and velocity < 0):
			
			
			#v^2 = u^2 + 2as, calculates Velocity actual at impact
			var u2add2as = prev_velocity*prev_velocity + 2*(accel)*(DISTANCE-prev_distance);
			velocity = sqrt(abs(u2add2as)) * sign(prev_velocity) 
			
			if(abs(velocity) > 0.001): hit_min_limit(velocity)
			
			velocity = -velocity * ELASTICITY_AT_MIN
		
		elif(is_focused and read_velocity() < 0):
			if(abs(velocity) > 0.001): hit_min_limit(velocity * 0.1) # * 0.1 becasue otherwise ti looks too sensitive
	
	
	within_physics_process.emit(delta)
	
	
	for i in range(0, len(TRIGGERS_TRIGGERABLE)): # check thresholds for triggers
		var triggered:bool = false
		if(TRIGGERS_DIRECTION[i] == 1 or TRIGGERS_DIRECTION[i] == 3): # Forwards
			
			#if(TRIGGERS_TRIGGERABLE[i] is Trig_Set_Enableable):
			#	print("checking trigger", TRIGGERS_TRIGGERABLE[i], " @ DIST ", DISTANCE, " & prev d ", prev_distance)
			
			if(DISTANCE >= TRIGGERS_DISTANCE[i] and prev_distance < TRIGGERS_DISTANCE[i]):
				
				TRIGGERS_TRIGGERABLE[i].trigger()
				triggered = true
				#continue # if trigger, escape this loop. DOnt trigger it twice Somehow
		
		elif(TRIGGERS_DIRECTION[i] == 2 or TRIGGERS_DIRECTION[i] == 3): # Backwards
			if(DISTANCE <= TRIGGERS_DISTANCE[i] and prev_distance > TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()
				triggered = true
		
		#if(triggered):
		#	print(TRIGGERS_TRIGGERABLE[i], " @ ", Time.get_ticks_msec())
	
	prev_distance = DISTANCE
	


func read_velocity() -> float:
	var sum:float;
	for e in velocity_tracker:
		sum += e
	if(len(velocity_tracker) < 5): return 0 # Not enough data
	return sum / len(velocity_tracker)



##Adds a trigegrable at distance in direction to the tirggers
func add_trigger(triggerable:Triggerable, distance:float, direction:TRIGGERS_DIRECTION_ENUM) -> void:
	TRIGGERS_TRIGGERABLE.append(triggerable)
	TRIGGERS_DISTANCE.append(distance)
	TRIGGERS_DIRECTION.append(direction)

##Creates a new trigger at distance in direction and returns the signal called hen the trigger is observed 
func add_new_trigger(distance:float, direction:TRIGGERS_DIRECTION_ENUM) -> Signal:
	var new_trig := Triggerable.new()
	TRIGGERS_TRIGGERABLE.append(new_trig)
	TRIGGERS_DISTANCE.append(distance)
	TRIGGERS_DIRECTION.append(direction)
	return new_trig.on_trigger


var min_limits

func hit_min_limit(velocity:float):
	pass

func hit_max_limit(velocity:float):
	pass


func enable_focus():
	super()

func disable_focus():
	super()
	velocity = read_velocity()





##Adds limit. If it is already written as limit, adds anyway. Only add once at a time.
func add_min_limit(at:float):
	MIN_LIMITS.append(at)

func add_max_limit(at:float):
	MAX_LIMITS.append(at)

func remove_min_limit(at:float) -> bool:
	if(MIN_LIMITS.has(at)):
		MIN_LIMITS.remove_at(MIN_LIMITS.find(at))
		return true
	else:
		return false

func remove_max_limit(at:float) -> bool:
	if(MAX_LIMITS.has(at)):
		MAX_LIMITS.remove_at(MAX_LIMITS.find(at))
		return true
	else:
		return false


##Returns maximum extension allowed for, or -INF if no limit set.
func get_max_distance() -> float:
	var maxest:float = -INF;
	for lim in MAX_LIMITS:
		if(lim > maxest):
			maxest = lim
	return maxest

##Returns maximum extension allowed for, or -INF if no limit set.
func get_min_distance() -> float:
	var minest:float = INF;
	for lim in MIN_LIMITS:
		if(lim < minest):
			minest = lim
	return minest
