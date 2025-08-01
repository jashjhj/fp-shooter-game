class_name Triggerable_More extends Triggerable

@export var TRIGGERS:Array[Triggerable];

func trigger():
	super.trigger();
	
	for trigger in TRIGGERS:
		if(trigger != null):
			trigger.trigger()
