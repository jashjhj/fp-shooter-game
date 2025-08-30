class_name Instr_Depleted_Mag extends Instruction_Resolver

@export var MAG_SLOT:Tool_Part_Insertable_Slot;

func _ready() -> void:
	assert(MAG_SLOT != null, "NO mag slot set.")

func check():
	if(MAG_SLOT.is_housed):
		if(MAG_SLOT.housed_insertable is Gun_Insertable_Mag):
			if(MAG_SLOT.housed_insertable.STORING == 0):
				is_done = false
				return
	
	#ELSE
	is_done = true
	
