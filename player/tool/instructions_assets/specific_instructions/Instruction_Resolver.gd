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


var ticks_till_check:int = 165
func _process(delta: float) -> void:
	ticks_till_check -= 1
	if(ticks_till_check <= 0):
		ticks_till_check = 15
		check()
	

##Processes 4 times a second
func check():
	pass
