class_name Instr_Load_Round extends Instruction_Resolver

@export var ACTION:Gun_Action

func check():
	is_done = ACTION.current_round != null
