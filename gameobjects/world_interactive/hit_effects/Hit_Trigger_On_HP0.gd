class_name Hit_Trigger_On_HP0 extends Hit_HP_Tracker

##Auto-adds children that are triggerables.
@export var TRIGGERABLES:Array[Triggerable]
var is_active = true;

func _ready() -> void:
	super._ready()
	for c in get_children(): # Auto-adds relevant children
		if(c is Triggerable and !TRIGGERABLES.has(c)):
			TRIGGERABLES.append(c)
	
	
	on_hp_becomes_negative.connect(call_triggers)

func hit(damage):
	super.hit(damage)

func call_triggers():
	if(!is_active): return
	for t in TRIGGERABLES:
		t.trigger()
