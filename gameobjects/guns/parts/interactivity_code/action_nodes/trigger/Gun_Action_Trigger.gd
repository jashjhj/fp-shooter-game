class_name Gun_Action_Trigger extends Action_Node

signal trigger

func _ready():
	trigger.connect(triggered)

func triggered():
	pass
