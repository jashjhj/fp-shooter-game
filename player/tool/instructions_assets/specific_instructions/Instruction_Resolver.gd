class_name Instruction_Resolver extends Node

@export var MY_INSTRUCTION:Tool_Instruction

var is_done:bool = false:
	set(v):
		if(is_done == v): return
		is_done = v
		MY_INSTRUCTION.is_done = is_done;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
