class_name Gun_Part_Check extends Gun_Part

@export var enabled = true;

@export var LISTENER:Gun_Part_Listener;
@export var NEXT_TRIGGERS:Array[Gun_Part_Listener];




func _ready() -> void:
	#trigger.connect(_trigger)
	if(LISTENER == null):
		push_warning("No Listener set.")
	else:
		LISTENER.triggered.connect(_trigger)

##This is called on the part being triggered
func _trigger():
	if(enabled):
		trigger_all()



##Triggers all parts in TRIGGERS
func trigger_all():
	for trigger_element in NEXT_TRIGGERS:
		trigger_element.trigger();
