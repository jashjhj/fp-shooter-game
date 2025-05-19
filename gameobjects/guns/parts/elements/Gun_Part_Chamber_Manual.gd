class_name Gun_Part_Chamber_Manual extends Gun_Part_Insertable_Slot

#This is an Insertable slot that can harbour a Gun_Insertable_Chamberable_Round, that is fired when a trigger is triggered.
#Can be modified using an is_pin_connected Action Node

@export var FIRE_TRIGGER:Gun_Part_Listener;

var is_pin_connected:bool = true;



func _ready():
	super._ready()
	assert(FIRE_TRIGGER != null, "No hammer trigger set.")
	FIRE_TRIGGER.trigger.connect(triggered)

func triggered():
	if(is_housed and is_pin_connected and housed_insertable is Gun_Insertable_Chamberable_Round):
		housed_insertable.fire.emit()
