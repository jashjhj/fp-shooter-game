class_name Trig_Gib extends Triggerable

@export var TO_GIB:Node

func trigger():
	super()
	
	#print(len(get_all_children(TO_GIB)))
	for child in get_all_children(TO_GIB):
		if child is Hit_HP_Tracker:
			child.HP = 0;
			pass
			#child.trigger(9999, Vector3.ZERO, Vector3.INF)
		
		
		#Bit too extreme, but funny 
		elif child is Triggerable:
			child.trigger()
		


func get_all_children(from:Node = self):
	var children:Array[Node];
	
	#TODO
	
	if(len(from.get_children(true))) == 0: return [from]
	
	
	for child in from.get_children(true):
		children.append_array(get_all_children(child))
	
	#print(children)
	return children
