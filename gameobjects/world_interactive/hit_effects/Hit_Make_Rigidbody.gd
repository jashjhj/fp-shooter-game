class_name Hit_Make_Rigidbody extends Hit_HP_Tracker

##Can be gleaned from children
@export var MAKE_RIGIDBODY:Make_Rigidbody;

@export var AT_THRESHOLD:float = 0;

func  _ready() -> void:
	super._ready()
	if(MAKE_RIGIDBODY == null):
		for child in get_children():
			if(child is Make_Rigidbody):
				MAKE_RIGIDBODY = child;
				break
	
	assert(MAKE_RIGIDBODY != null, "No make-rigidbody set, and no direct-child available.")
	
	on_hp_becomes_negative.connect(trigger_make_rb)

func trigger_make_rb():
	MAKE_RIGIDBODY.add_impulse(last_impulse, last_impulse_pos)
	MAKE_RIGIDBODY.trigger()
