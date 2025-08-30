@tool
class_name Tool_Instruction extends Resource

@export var instruction:StringName = "";


enum Case{
	ALWAYS,
	HAS_DEPENDENT
}
@export var case:Case

@export var conditional_to:Array[Tool_Instruction]

signal is_done_set
var is_done:bool = false:
	set(v):
		if(is_done == v): return
		is_done = v;
		is_done_set.emit()
