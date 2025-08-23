class_name Tool_Part_Interactive_1D extends Tool_Part_Interactive
##Inheriting classes must set VELOCITY.


##Start position / distance / rotation
var DISTANCE:float = 0.0;
var prev_distance:float = DISTANCE

##In metres or rads
@export var MIN_LIMITS:Array[float]
##In metres or rads
@export var MAX_LIMITS:Array[float]


var velocity:float = 0.0;


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




##Ready
func _ready():
	
	super._ready();

func _process(delta:float) -> void:
	super._process(delta);

##CallAfter processing / when you want distance to be calculated
func _physics_process(delta:float) -> void:
	
	
	
	
	
	var accel:float = 0;
	
	#DISTANCE += velocity * delta * 0.5
	var prev_vel:float = velocity
	
	if(is_focused):
		velocity = 0;
	
	else:
		
		velocity += (SPRING_FORCE_CONSTANT + SPRING_FORCE_LINEAR*DISTANCE) * delta
		velocity = sign(velocity) * max(0, abs(velocity) - FRICTION_FORCE * delta)
		
		accel = (velocity - prev_vel) / delta
		#print("v:",velocity, " pv:", prev_vel, " d: ", DISTANCE)
		DISTANCE += prev_vel*delta + 0.5*accel*delta*delta # s=ut+1/2at^2.
	
	# apply limits.
	var hit_limit:bool = false;
	for lim in MAX_LIMITS:
		
		if(DISTANCE >= lim):
			DISTANCE = lim # clamped not reflected in case a new limit is imposed.
			hit_limit = true
		
	if(hit_limit):
		
		if(velocity > 0):
			
			#v^2 = u^2 + 2as, calculates Velocity actual at impact
			var u2add2as = prev_vel*prev_vel + 2*accel*(DISTANCE-prev_distance);
			velocity = sqrt(abs(u2add2as)) * sign(u2add2as) 
			
			if(abs(velocity) > 0.001): hit_max_limit()
			
			velocity = -velocity * ELASTICITY_AT_MAX
		
	
	
	hit_limit = false;
	for lim in MIN_LIMITS:
		
		if(DISTANCE <= lim):
			hit_limit = true
			DISTANCE = lim
			
		
	if(hit_limit):
		
		if(velocity < 0):
			
			
			#v^2 = u^2 + 2as, calculates Velocity actual at impact
			var u2add2as = prev_vel*prev_vel + 2*((velocity - prev_vel)/delta)*(DISTANCE-prev_distance);
			velocity = sqrt(abs(u2add2as)) * sign(u2add2as) 
			
			if(abs(velocity) > 0.001): hit_min_limit()
			
			velocity = -velocity * ELASTICITY_AT_MIN
	
	
	
	
	
	
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

func hit_min_limit():
	pass

func hit_max_limit():
	pass

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
