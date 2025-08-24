class_name Mechanism_2Way_Mapper extends Enableable
##Acts like a mapper thign but is two-way. Huh.

@export var PRIMARY:Tool_Part_Interactive_1D
@export var SECONDARY:Tool_Part_Interactive_1D
@export var PRIMARY_START:float = 0.0;
@export var PRIMARY_END:float = 0.1
@export var SECONDARY_START:float = 0.0;
@export var SECONDARY_END:float = 0.1

@export var PRIMARY_START_LIMIT:LIMIT_MODE = LIMIT_MODE.CLAMP
@export var PRIMARY_END_LIMIT:LIMIT_MODE = LIMIT_MODE.CLAMP
@export var SECONDARY_START_LIMIT:LIMIT_MODE = LIMIT_MODE.CLAMP
@export var SECONDARY_END_LIMIT:LIMIT_MODE = LIMIT_MODE.CLAMP
enum LIMIT_MODE{
	CLAMP,
	FREE,
}

##Does this only work on the minimum ends of each?   Means that things can go as far as they want one way but not somuch the other.   Primary applies min limit on secondary, secondary has full motion ( when its > priamry)
#@export var AFFECT_MIN:bool = true
#@export var AFFECT_MAX:bool = false

#operates in l8 physics process

## Primary delta * ratio = Secondary delta.
var ratio:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(PRIMARY != null, "No Primary set")
	assert(SECONDARY != null, "No Secondary set")
	ratio = (SECONDARY_START-SECONDARY_END) / (PRIMARY_START - PRIMARY_END)
	
	#SECONDARY.pre_physics_process.connect(resolve_deltas)
	#PRIMARY.pre_physics_process.connect(resolve_deltas)


func _physics_process(delta: float) -> void:
	pass
	call_deferred("resolve_deltas", delta)

##Late physics process.
func resolve_deltas(delta:float) -> void:
	if(!is_enabled): return
	
	var primary_projection: = PRIMARY.DISTANCE
	var secondary_projection: = SECONDARY.DISTANCE
	
	#CASE Secondary is a slave to primary
	if(PRIMARY.is_focused):
		var primary_wants:float = PRIMARY.DISTANCE
		var primary_maps_to:float = primary_to_secondary(PRIMARY.DISTANCE)
		
		
		secondary_projection = primary_maps_to
		
		
		for lim in SECONDARY.MIN_LIMITS:
			if(secondary_projection <= lim):
				secondary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		for lim in SECONDARY.MAX_LIMITS:
			if(secondary_projection >= lim):
				secondary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		
		primary_projection =  secondary_to_primary(secondary_projection)
		
		for lim in PRIMARY.MIN_LIMITS: # primary checks limits last as primary cna be used to override
			if(primary_projection <= lim):
				primary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		for lim in PRIMARY.MAX_LIMITS:
			if(primary_projection >= lim):
				primary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		
		secondary_projection = primary_to_secondary(primary_projection) # maps back to secondary in case anythign ahs cahnged
		
	
	
	elif(SECONDARY.is_focused):
		
		secondary_projection = SECONDARY.DISTANCE
		
		
		for lim in SECONDARY.MIN_LIMITS:
			if(secondary_projection <= lim):
				secondary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		for lim in SECONDARY.MAX_LIMITS:
			if(secondary_projection >= lim):
				secondary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		
		primary_projection = secondary_to_primary(secondary_projection)
		
		for lim in PRIMARY.MIN_LIMITS: # primary checks limits last as primary cna be used to override
			if(primary_projection <= lim):
				primary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		for lim in PRIMARY.MAX_LIMITS:
			if(primary_projection >= lim):
				primary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		secondary_projection = primary_to_secondary(primary_projection)# maps back to secondary in case anythign ahs cahnged
		
	
	else:#Equal. Fight out over deltas
		var primary_wants:float = PRIMARY.DISTANCE
		var primary_maps_to:float = primary_to_secondary(PRIMARY.DISTANCE)
		var secondary_wants:float = SECONDARY.DISTANCE
		
		var resolved:float = (primary_maps_to + secondary_wants) / 2.0
		
		
		secondary_projection = resolved
		for lim in SECONDARY.MIN_LIMITS:
			if(secondary_projection <= lim):
				secondary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		for lim in SECONDARY.MAX_LIMITS:
			if(secondary_projection >= lim):
				secondary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		
		primary_projection = secondary_to_primary(secondary_projection)
		
		for lim in PRIMARY.MIN_LIMITS: # primary checks limits last as primary cna be used to override
			if(primary_projection <= lim):
				primary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		for lim in PRIMARY.MAX_LIMITS:
			if(primary_projection >= lim):
				primary_projection = lim # clamped not reflected in case a new limit is imposed.
		
		secondary_projection = primary_to_secondary(primary_projection)# maps back to secondary in case anythign ahs cahnged
		
	
	
	
	#Apply projections
	if(primary_normalised() < 0):
		match PRIMARY_START_LIMIT:
			LIMIT_MODE.CLAMP:
				PRIMARY.velocity += (primary_projection - PRIMARY.DISTANCE) / delta
				PRIMARY.DISTANCE = primary_projection
	
	elif(primary_normalised() > 1):
		match PRIMARY_END_LIMIT:
			LIMIT_MODE.CLAMP:
				PRIMARY.velocity += (primary_projection - PRIMARY.DISTANCE) / delta
				PRIMARY.DISTANCE = primary_projection
	else:
		PRIMARY.velocity += (primary_projection - PRIMARY.DISTANCE) / delta
		PRIMARY.DISTANCE = primary_projection
	
	#Secondary
	if(secondary_normalised() < 0):
		match SECONDARY_START_LIMIT:
			LIMIT_MODE.CLAMP:
				SECONDARY.velocity += (secondary_projection - SECONDARY.DISTANCE) / delta
				SECONDARY.DISTANCE = secondary_projection
	
	elif(secondary_normalised() > 1):
		match SECONDARY_END_LIMIT:
			LIMIT_MODE.CLAMP:
				SECONDARY.velocity += (secondary_projection - SECONDARY.DISTANCE) / delta
				SECONDARY.DISTANCE = secondary_projection
	else:
		SECONDARY.velocity += (secondary_projection - SECONDARY.DISTANCE) / delta
		SECONDARY.DISTANCE = secondary_projection
	
	
	
	
	

func secondary_normalised():
	return remap(SECONDARY.DISTANCE, SECONDARY_START, SECONDARY_END, 0.0, 1.0)
func primary_normalised():
	return remap(PRIMARY.DISTANCE, PRIMARY_START, PRIMARY_END, 0.0, 1.0)

func primary_to_secondary(primary_float:float) -> float:
	return remap(mapping_function(min(1.0, max(0.0, remap(primary_float, PRIMARY_START, PRIMARY_END, 0.0, 1.0)))), 0.0, 1.0, SECONDARY_START, SECONDARY_END)

func secondary_to_primary(secondary_float:float) -> float:
	return remap(inverse_mapping_function(min(1.0, max(0.0, remap(secondary_float, SECONDARY_START, SECONDARY_END, 0.0, 1.0)))), 0.0, 1.0, PRIMARY_START, PRIMARY_END)


##Deals with normalsied functions. From PRIMARY to SECONDARY
func mapping_function(input:float)-> float:
	return input

##Deals with normalsied functions. From SECONDARY to PRIMARY
func inverse_mapping_function(input:float) -> float:
	return input
