class_name Trig_Counter extends Trig_Propogate_Abstract

@export var STARTING_COUNT:int = 0;
##triggers children every Nth incoming trigger
@export var TRIGGER_EVERY:int = 2;

var counter = 0;

func _ready():
	super._ready()

func trigger():
	super.trigger()
	counter += 1;
	if(counter % TRIGGER_EVERY == 0):
		propogate()
