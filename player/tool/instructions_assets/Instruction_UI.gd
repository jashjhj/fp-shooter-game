class_name Instruction_UI extends Node
@export var TEXTBOX:RichTextLabel
@export var PLAYER:Player;

var equipped_tool:Player_Tool;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(PLAYER != null, "No Player host set")
	assert(TEXTBOX != null, "No textbox set")
	PLAYER.changed_equipped.connect(player_changed_equipped)




func player_changed_equipped(new_item):
	equipped_tool = new_item
	update()

func update():
	
	pass
