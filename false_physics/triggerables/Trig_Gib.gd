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
			if child == Trig_Free:
				child.trigger()
		


func get_all_children(from:Node = self) -> Array[Node]:
	var children:Array[Node];
	
	var unvisited_nodes:Array[Node] = [from]
	#TODO
	
	while(len(unvisited_nodes) > 0):
		var current_node_children = unvisited_nodes.pop_front().get_children(true)
		if(len(current_node_children) == 0): continue
		unvisited_nodes.append_array(current_node_children)
		children.append_array(current_node_children)
	
	
	return children
