class_name Trig_Propogate_Abstract extends Triggerable

@export var TRIGGERABLES:Array[Triggerable];

func _ready() -> void:
	super._ready()
	for c in get_children():
		if(c is Triggerable and !TRIGGERABLES.has(c)):
			TRIGGERABLES.append(c)

func trigger():
	super.trigger();


func propogate():
	for trigger in TRIGGERABLES:
		if(trigger != null):
			trigger.trigger()
