class_name Tool_Part_Interactive_1D extends Tool_Part_Interactive
##Inheriting classes must set VELOCITY.


##Start position / distance / rotation.
@export var DISTANCE:float = 0.0;
var prev_distance:float = DISTANCE

##In metres or rads
@export var MIN_LIMITS:Array[float]
##In metres or rads
@export var MAX_LIMITS:Array[float]


var velocity:float = 0.0;


@export_group("Mechanism")
##Spring force, arbitrary units. Constant. Treat As acceleration by spring
@export var SPRING_FORCE:float = 0.0;
##Friction force. Acts as constant acceleration opposing motion.
@export var FRICTION_FORCE:float = 0.1;

@export var ELASTICITY_AT_MAX:float = 0.2;
@export var ELASTICITY_AT_MIN:float = 0.1;




##Ready
func _ready():
	super._ready();

func _process(delta:float) -> void:
	super._process(delta);

##Call before processing.
func _physics_process(delta:float) -> void:
	
	prev_distance = DISTANCE
	
	
	call_deferred("late_physics", delta)
	
	
	
	#super(delta)

func late_physics(delta:float):
	if(!is_focused): 
		velocity += SPRING_FORCE * delta
		velocity = sign(velocity) * max(0, abs(velocity) - FRICTION_FORCE * delta)
	
	DISTANCE += velocity
	
	# apply limits.
	for lim in MAX_LIMITS:
		var hit_limit:bool = false;
		
		if(DISTANCE > lim):
			DISTANCE = lim # clamped not reflected in case a new limit is imposed.
			
		
		if(hit_limit):
			hit_max_limit()
			if velocity > (SPRING_FORCE*delta): # if going wrogn way, with more force than this tick
				velocity = -velocity * ELASTICITY_AT_MIN
				hit_min_limit()
			elif velocity > 0: # if not goign evry fast, reste to Zero
				velocity = 0;
		
	for lim in MIN_LIMITS:
		var hit_limit:bool = false;
		
		if(DISTANCE < lim):
			hit_limit = true
			DISTANCE = lim
			
		
		if(hit_limit):
			
			if velocity < (SPRING_FORCE*delta): # if going wrogn way, with more force than this tick
				velocity = -velocity * ELASTICITY_AT_MIN
				hit_min_limit()
			elif velocity < 0: # if not goign evry fast, reste to Zero
				velocity = 0;
	
	optional_extras()
	
	



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

@export_group("Triggers", "TRIGGERS_")
enum TRIGGERS_DIRECTION_ENUM {
	FORWARDS = 1,
	BACKWARDS = 2,
	BOTH = 3
}
@export var TRIGGERS_TRIGGERABLE:Array[Triggerable]
@export var TRIGGERS_DISTANCE:Array[float]
@export var TRIGGERS_DIRECTION:Array[TRIGGERS_DIRECTION_ENUM]

func optional_extras():
	for i in range(0, len(TRIGGERS_TRIGGERABLE)): # check thresholds
		
		if(TRIGGERS_DIRECTION[i] == 1 or TRIGGERS_DIRECTION[i] == 3): # Forwards
			if(DISTANCE >= TRIGGERS_DISTANCE[i] and prev_distance < TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()
		
		if(TRIGGERS_DIRECTION[i] == 2 or TRIGGERS_DIRECTION[i] == 3): # Backwards
			if(DISTANCE <= TRIGGERS_DISTANCE[i] and prev_distance > TRIGGERS_DISTANCE[i]):
				TRIGGERS_TRIGGERABLE[i].trigger()


	
