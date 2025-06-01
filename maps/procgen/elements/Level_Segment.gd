class_name Level_Segment extends Node3D

##This is the starting node of the object
@export var INBOUND:Level_Segment_Connector
@export var OUTBOUND:Array[Level_Segment_Connector]

@export var BOUNDING_BOX:Area3D;

@export var COST:float = 5.0;

func _ready() -> void:
	assert(INBOUND != null, "No inbound connector set.")
	assert(BOUNDING_BOX != null, "No bounding box Area3D set.")
	BOUNDING_BOX.collision_layer = 16777216
	BOUNDING_BOX.collision_mask = 16777216
	
	for collision_shape in BOUNDING_BOX.get_children():
		if(collision_shape is CollisionShape3D):
			collision_shape.shape.margin = 0;
