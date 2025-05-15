extends Gun_Part


@export var LISTENER:Gun_Part_Listener;
@export var TRIGGERS:Array[Gun_Part_Listener];


func _ready() -> void:
	#trigger.connect(_trigger)
	LISTENER.triggered.connect(_trigger)


##Asks to perform an action. does it?
func _trigger():
	trigger_all()


##Triggers all parts in TRIGGERS
func trigger_all():
	for trigger_element in TRIGGERS:
		trigger_element.trigger();
