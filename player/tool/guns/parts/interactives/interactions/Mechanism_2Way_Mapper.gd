class_name Mechanism_2Way_Mapper extends Node
##Acts like a mapper thign but is two-way. Huh.

@export var PRIMARY:Tool_Part_Interactive_1D
@export var SECONDARY:Tool_Part_Interactive_1D
@export var PRIMARY_START:float = 0.0;
@export var PRIMARY_END:float = 0.1
@export var SECONDARY_START:float = 0.0;
@export var SECONDARY_END:float = 0.1

##Does primary affect the min of secondary, and the inverse.
@export var AFFECT_MIN:bool = true
@export var AFFECT_MAX:bool = true

#operates in l8 physics process

## Primary delta * ratio = Secondary delta.
var ratio:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(PRIMARY != null, "No Primary set")
	assert(SECONDARY != null, "No Secondary set")
	ratio = (SECONDARY_START-SECONDARY_END) / (PRIMARY_START - PRIMARY_END)


func _physics_process(delta: float) -> void:
	call_deferred("resolve_deltas", delta)

##Late physics process.
func resolve_deltas(delta:float) -> void:
	
	return
	
	#CASE Secondary is a slave to primary
	if(PRIMARY.is_focused):
		var primary_wants:float = PRIMARY.DISTANCE
		var primary_maps_to:float = remap(mapping_function(min(1.0, max(0.0, remap(PRIMARY.DISTANCE, PRIMARY_START, PRIMARY_END, 0.0, 1.0)))), 0.0, 1.0, SECONDARY_START, SECONDARY_END)
		
		
		SECONDARY.velocity += (primary_maps_to - SECONDARY.DISTANCE) / delta # sets new velocity by hwo much it was forced.
		SECONDARY.DISTANCE = primary_maps_to
	
	elif(SECONDARY.is_focused):
		pass
	
	else:#Equal. Fight out over deltas
		var primary_wants:float = PRIMARY.DISTANCE
		var primary_maps_to:float = remap(mapping_function(min(1.0, max(0.0, remap(PRIMARY.DISTANCE, PRIMARY_START, PRIMARY_END, 0.0, 1.0)))), 0.0, 1.0, SECONDARY_START, SECONDARY_END)
		var secondary_wants:float = SECONDARY.DISTANCE
		
		var resolved:float = (primary_maps_to + secondary_wants) / 2.0


##Deals with normalsied functions. From PRIMARY to SECONDARY
func mapping_function(input:float)-> float:
	return input

##Deals with normalsied functions. From SECONDARY to PRIMARY
func inverse_mapping_function(input:float) -> float:
	return input
