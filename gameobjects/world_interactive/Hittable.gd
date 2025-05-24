class_name Hittable extends RigidBody3D

@export var MAX_HP:float = 1000;
@export var MINIMUM_DAMAGE_THRESHOLD:float = 200;

@export var FREE_ON_THRESHOLD:Array[Node];
@export var THRESHOLDS:Array[float];

@onready var hp = MAX_HP;
var has_been_freed:Array[bool] = [];
var number_of_thresholds:int;

func _ready() -> void:
	for i in range(0, len(THRESHOLDS)):
		assert(len(FREE_ON_THRESHOLD) >= i, "Threshold set for unset node.")
		assert(FREE_ON_THRESHOLD[i] != null, "Threshold set for unset node.")
		
		has_been_freed.append(false);
	number_of_thresholds = len(THRESHOLDS)

func hit(energy:float):
	
	if(energy > MINIMUM_DAMAGE_THRESHOLD):
		hp -= energy - MINIMUM_DAMAGE_THRESHOLD
	
	for i in range(0, number_of_thresholds):
		if(has_been_freed[i] == false):
			if(hp < THRESHOLDS[i]):
				FREE_ON_THRESHOLD[i].queue_free()
				has_been_freed[i] = true;
		

func _destroyed():
	destroy()


##Member function
func destroy():
	pass
