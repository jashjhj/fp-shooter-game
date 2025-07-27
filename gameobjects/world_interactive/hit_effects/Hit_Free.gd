class_name Hit_Free extends Hit_HP_Tracker


@export var FREE_ON_THRESHOLD:Array[Node];
@export var THRESHOLDS:Array[float];

var has_been_freed:Array[bool] = [];
var number_of_thresholds:int;


func _ready() -> void:
	super._ready()
	for i in range(0, len(THRESHOLDS)):
		assert(len(FREE_ON_THRESHOLD) >= i, "Threshold set for unset node.")
		assert(FREE_ON_THRESHOLD[i] != null, "Threshold set for unset node.")
		
		has_been_freed.append(false);
	number_of_thresholds = len(THRESHOLDS)

func hit(damage:float):
	for i in range(0, number_of_thresholds):
		if(has_been_freed[i] == false):
			if(HP < THRESHOLDS[i]):
				if(FREE_ON_THRESHOLD[i] != null): # If not previously freed,
					FREE_ON_THRESHOLD[i].queue_free()
				has_been_freed[i] = true;
	

func _destroyed():
	destroy()


##Member function
func destroy():
	pass
