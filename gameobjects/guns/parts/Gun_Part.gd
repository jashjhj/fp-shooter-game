class_name Gun_Part extends Node3D

@export var TRIGGERS:Array[Gun_Part];

##Asks to perform an action. does it?
func _trigger() -> bool:
	return true;

##Triggers all parts in TRIGGERS
func trigger_all():
	for trigger_element in TRIGGERS:
		trigger_element._trigger();
