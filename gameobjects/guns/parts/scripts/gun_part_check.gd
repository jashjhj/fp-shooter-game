class_name gun_part_check extends Gun_Part

@export var TRIGGERS:Array[Gun_Part];

var enabled = true;

##This is called on the part being triggered
func _trigger() -> bool:
	if(enabled):
		for trigger_element in TRIGGERS:
			trigger_element._trigger();
		return true;
	return false;
