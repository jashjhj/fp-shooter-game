@tool
class_name Tool_Instruction extends Resource

@export var instruction:StringName = "";


enum Case{
	ALWAYS,
	HAS_DEPENDENT
}
@export var case:Case

@export var conditional_to:Array[Tool_Instruction]

var is_done:bool = false;
