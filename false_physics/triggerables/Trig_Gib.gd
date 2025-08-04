class_name Trig_Gib extends Triggerable

@export var TO_GIB:Node

func trigger():
	super()
	
	for child in get_all_children(TO_GIB):
		if child is Hit_HP_Tracker:
			child.HP = 0;
		


func get_all_children(from:Node = self):
	var children:Array[Node];
	
	if(len(from.get_children(true))) == 0: return [from]
	
	for child in from.get_children(true):
		children.append_array(get_all_children(child))
	
	return children
