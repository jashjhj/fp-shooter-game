class_name Gun_Part_Chamber_Manual extends Gun_Part_Insertable_Slot

@export var FIRE_TRIGGER:Gun_Part_Listener;

var is_pin_connected:bool = true;

signal fire


func _ready():
	super._ready()
	assert(FIRE_TRIGGER != null, "No hammer trigger set.")
	FIRE_TRIGGER.triggered.connect(triggered)

func triggered():
	if(is_housed and is_pin_connected and housed_insertable is Gun_Insertable_Chamberable_Round):
		housed_insertable.fire.emit()
