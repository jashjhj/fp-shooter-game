class_name Hit_Component extends Node

@export var MAX_HP:float = 5;
@export var MINIMUM_DAMAGE_THRESHOLD:float = 1;

var HP = MAX_HP;
var previous_damage:float = 0;
@onready var is_hp_positive:bool = MAX_HP >= 0

##Emitted after any hit.
signal on_hit
##Emitted after a hit which reduces HP to <0
signal on_hp_becomes_negative

var last_impulse:Vector3 = Vector3.ZERO
var last_impulse_pos:Vector3 = Vector3.ZERO

func _hit(damage:float, impulse:Vector3 = Vector3.ZERO, impulse_pos:Vector3 = Vector3.ZERO) -> void:
	last_impulse = impulse
	last_impulse_pos = impulse_pos
	
	
	if(damage > MINIMUM_DAMAGE_THRESHOLD):
		HP -= damage - MINIMUM_DAMAGE_THRESHOLD
		
		if(is_hp_positive and HP < 0): # check positivity
			is_hp_positive = false
			on_hp_becomes_negative.emit()
		
	hit(damage)

func hit(damage:float) -> void:
	pass
