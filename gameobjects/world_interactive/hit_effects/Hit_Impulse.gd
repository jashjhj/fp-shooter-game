class_name Hit_Impulse extends Hit_Component

##Can be Owning Hittable_RB or otherwise. Auto-sets to parent if it is Rigidbody3D
@export var IMPULSE_TO:RigidBody3D;
##Multiplier applied to all impulses passing through. Good for simulating suspension, for example.
@export var IMPULSE_MULTIPLIER:float = 1.0;

func _ready() -> void:
	super._ready()
	
	if(get_parent() is RigidBody3D and IMPULSE_TO == null):
		IMPULSE_TO = get_parent()


func hit(damage:float):
	super.hit(damage)
	last_impulse *= IMPULSE_MULTIPLIER
	if IMPULSE_TO == null: return
	IMPULSE_TO.apply_impulse(last_impulse, last_impulse_pos - IMPULSE_TO.global_position)
	
