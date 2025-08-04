class_name Trig_Propogate_Abstract extends Triggerable

@export var TRIGGERABLES:Array[Triggerable];

func trigger():
	super.trigger();


func propogate():
	for trigger in TRIGGERABLES:
		if(trigger != null):
			trigger.trigger()
