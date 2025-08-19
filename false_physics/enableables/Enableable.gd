class_name Enableable extends Node

@export var is_enabled:bool = true:
	set(v):
		if(v == is_enabled): return
		is_enabled = v
		is_enabled_set()


func is_enabled_set():
	pass
