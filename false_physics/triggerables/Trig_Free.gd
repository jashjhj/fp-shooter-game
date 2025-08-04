class_name Trig_Free extends Triggerable

@export var TO_FREE:Array[Node]

func _ready():
	super._ready()

func trigger():
	super.trigger()
	for f in TO_FREE:
		if(f != null):
			f.queue_free()
			
