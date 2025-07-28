class_name Hit_Free extends Hit_HP_Tracker

@export var TO_FREE:Node

func _ready():
	super._ready()
	assert(TO_FREE != null, "Hit_Free with no TO_FREE set")
	on_hp_becomes_negative.connect(TO_FREE.queue_free)


func hit(damage):
	super.hit(damage)
	

#Old script with multiple tiers

#@export var FREE_ON_THRESHOLD:Array[Node];
#var FREES:Array[Node]
#@export var THRESHOLDS:Array[float];
#
#var has_been_freed:Array[bool] = [];
#var number_of_thresholds:int;
#
#
#func _ready() -> void:
	#super._ready()
	#for i in range(0, len(THRESHOLDS)):
		#assert(len(FREE_ON_THRESHOLD) >= i, "Threshold set for unset node.")
		#assert(FREE_ON_THRESHOLD[i] != null, "Threshold set for unset node.")
		#FREES.append(FREE_ON_THRESHOLD[i])
		#has_been_freed.append(false);
	#number_of_thresholds = len(THRESHOLDS)
#
#func hit(damage:float):
	#for i in range(0, number_of_thresholds):
		#if(has_been_freed[i] == false):
			#if(HP < THRESHOLDS[i]):
				#print(FREES[i])
				#if(FREES[i] != null): # If not previously freed,
					#FREES[i].queue_free()
				#has_been_freed[i] = true;
	#
#
#func _destroyed():
	#destroy()
#
#
###Member function
#func destroy():
	#pass
