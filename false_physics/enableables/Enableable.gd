class_name Enableable extends Node

@export var is_enabled:bool = false:
	set(v):
		if(v == is_enabled): return
		is_enabled = v
		is_enabled_set()

func _ready():
	pass

func is_enabled_set():
	pass
