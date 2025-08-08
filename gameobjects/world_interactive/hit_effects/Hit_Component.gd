class_name Hit_Component extends Node


var last_damage:float = 0;

##Emitted after any hit.
signal on_hit

var last_impulse:Vector3 = Vector3.ZERO
##Impulse pos = IMPULSE_GLOBAL_POS
var last_impulse_pos:Vector3 = Vector3.ZERO

func _ready() -> void:
	pass;

##Impulse pos = IMPULSE_GLOBAL_POS
func trigger(damage:float, impulse:Vector3 = Vector3.ZERO, impulse_pos:Vector3 = Vector3.ZERO) -> void:
	last_impulse = impulse
	last_impulse_pos = impulse_pos
	last_damage = damage
	
	
	on_hit.emit()
	hit(damage)

func hit(damage:float) -> void:
	pass
