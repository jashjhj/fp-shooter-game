class_name Hit_Component extends Node

@export var MAX_HP:float = 5;
@export var MINIMUM_DAMAGE_THRESHOLD:float = 1;

var HP = MAX_HP;

func _hit(damage:float) -> void:
	if(damage > MINIMUM_DAMAGE_THRESHOLD):
		HP -= damage - MINIMUM_DAMAGE_THRESHOLD
	hit(damage)

func hit(damage:float) -> void:
	pass
