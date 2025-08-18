class_name Map_Constraints extends Node

@export var PRIMARY:Tool_Part_Interactive_1D
@export var SECONDARY:Tool_Part_Interactive_1D

@export var DOMAIN_START:float = 0.0;
@export var DOMAIN_END:float = 0.1;
@export_range(-180, 180, 0.1, "radians_as_degrees") var RANGE_START:float = 0;
@export_range(-180, 180, 0.1, "radians_as_degrees") var RANGE_END:float = PI/2

var is_first:bool = true;
var prev_out_float:float;

func _physics_process(delta: float) -> void:
	#Converts primary distance to range between 0 -> 1
	var in_float:float = (min(DOMAIN_END, max(DOMAIN_START, PRIMARY.DISTANCE)) - DOMAIN_START) / (DOMAIN_END-DOMAIN_START)
	var out_float := asin(in_float)
	out_float = ((out_float + RANGE_START) / (PI/2)) * (RANGE_END - RANGE_START)
	
	if(is_first):
		is_first = false
	else:
		SECONDARY.remove_min_limit(prev_out_float) # dont remove on first iteration
	SECONDARY.add_min_limit(out_float)
	prev_out_float = out_float
