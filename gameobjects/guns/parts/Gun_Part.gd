class_name Gun_Part extends Node3D

#@export var TRIGGERS:Array[Signal];



func connect_listener(listener:Gun_Part_Listener, function:Callable) ->void:
	if(listener == null):
		push_warning("Listener not set!")
	else: listener.triggered.connect(function);

##Triggers all parts in TRIGGERS
#func trigger_all():
#	for trigger_element in TRIGGERS:
#		trigger_element.emit();
