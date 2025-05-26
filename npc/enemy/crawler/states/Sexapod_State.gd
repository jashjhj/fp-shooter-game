class_name Sexapod_State extends Node

var SEXAPOD:Crawler;

var initialised:bool = false;

func init():
	pass

func _process_legs(delta:float)->void:
	if(!initialised):
		initialised = true
		init()
	process_legs(delta)

func process_legs(delta:float) -> void:
	pass

func get_speed_mult() -> float:
	return 1.0;
