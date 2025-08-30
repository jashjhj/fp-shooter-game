class_name Instruction_UI extends Node
@export var TEXTBOX:RichTextLabel
@export var PLAYER:Player;

var equipped_tool:Player_Tool;

var loaded_instructions:Array[Tool_Instruction]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	assert(PLAYER != null, "No Player host set")
	assert(TEXTBOX != null, "No textbox set")
	PLAYER.changed_equipped.connect(player_changed_equipped)
	





func player_changed_equipped(new_item:Player_Tool):
	
	for instr in loaded_instructions: # bind new signals
		instr.is_done_set.disconnect(update)
	
	loaded_instructions = []
	if new_item != null:
		for instr in new_item.INSTRUCTIONS.instructions:
			instr.is_done_set.connect(update)
			loaded_instructions.append(instr)
	
	if(new_item == null):
		TEXTBOX.text = ""
	else:
		pass
		
		
		
		
	
	equipped_tool = new_item
	update()

func update():
	
	var text = ""
	for instr in loaded_instructions:
		text = text + instr.instruction + "\n"
	
	TEXTBOX.text = text
