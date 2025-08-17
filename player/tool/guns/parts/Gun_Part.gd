class_name Gun_Part extends Node3D

#@export var TRIGGERS:Array[Signal];

##Set to parent gun object
var PARENT_GUN:Gun;


##Float that can be set extrenally. When set, triggers `settable_float_set(with the value)`.
var SETTABLE_FLOAT:float = 0:
	set(value): settable_float_set(value)

func settable_float_set(value):
	SETTABLE_FLOAT = value;

func _process(_delta:float) -> void:
	pass

func connect_listener(listener:Gun_Part_Listener, function:Callable) ->void:
	if(listener == null):
		push_warning("Listener not set!")
	else: listener.trigger.connect(function);

##Triggers all parts in TRIGGERS
#func trigger_all():
#	for trigger_element in TRIGGERS:
#		trigger_element.emit();
