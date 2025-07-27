@tool
class_name Hit_Impulse extends Hit_Component

##Can be Owning Hittable_RB or otherwise. Auto-sets to parent if it is Rigidbody3D
@export var IMPULSE_TO:RigidBody3D;


func _ready() -> void:
	if(get_parent() is RigidBody3D):
		IMPULSE_TO = get_parent()

func hit(damage:float):
	if IMPULSE_TO == null: return
	IMPULSE_TO.apply_impulse(last_impulse, last_impulse_pos - IMPULSE_TO.global_position)
	
