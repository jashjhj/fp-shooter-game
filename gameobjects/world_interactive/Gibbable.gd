class_name Gibbable extends Node3D

@export_category("Sets HP to of ALL HitCMPS to ZERO on gib() call")

@export var ATTACHED_TO:RigidBody3D
@export var IMPULSE_REDISTS:Array[Hit_Impulse]
@export var MASS_REDUCERS:Array[Hit_Reduce_Mass]


func _ready() -> void:
	if(ATTACHED_TO != null):
		for im in IMPULSE_REDISTS:
			im.IMPULSE_TO = ATTACHED_TO
		
		for mr in MASS_REDUCERS:
			mr.BODY_TO_REDUCE_MASS = ATTACHED_TO


func gib():
	for c in get_all_children():
		if c is Hit_HP_Tracker:
			c.HP = 0; # Triggers on_hp_becomes_negative, runs gibs etc.

func get_all_children(from:Node = self):
	var children:Array[Node];
	
	if(len(from.get_children())) == 0: return [from]
	
	for child in from.get_children():
		children.append_array(get_all_children(child))
	
	return children
