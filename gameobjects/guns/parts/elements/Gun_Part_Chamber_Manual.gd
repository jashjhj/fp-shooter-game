class_name Gun_Part_Chamber_Manual extends Gun_Part_Insertable_Slot

@export var FIRE_TRIGGER:Gun_Part_Listener;

var connected_to_pin:bool = true;

func housed_set():
	pass
#
#func _ready():
	#super._ready()
	#assert(FIRE_TRIGGER != null, "No hammer trigger set.")
	#FIRE_TRIGGER.triggered.connect(triggered)

#func triggered():
	#if(housed and connected_to_pin):
		#INSERTABLE_OBJECT.fire.emit()
