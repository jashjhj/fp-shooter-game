class_name Instr_Insert extends Instruction_Resolver

@export var INSERTABLE_SLOT:Tool_Part_Insertable_Slot

func check():
	is_done = INSERTABLE_SLOT.is_housed_fully
