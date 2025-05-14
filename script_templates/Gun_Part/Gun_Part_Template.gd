extends Gun_Part

@export var TRIGGERS:Array[Gun_Part];

##This is called on the part being triggered
func _trigger() -> bool:
	for trigger_element in TRIGGERS:
		trigger_element._trigger();
	return true;
