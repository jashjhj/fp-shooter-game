class_name Trig_Destroy_Body_Segment extends Triggerable

@export var BODY_SEGMENT:Body_Segment

func trigger():
	super.trigger()
	if(BODY_SEGMENT != null):
		BODY_SEGMENT.destroy()
