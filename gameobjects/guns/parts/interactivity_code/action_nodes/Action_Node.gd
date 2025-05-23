class_name Action_Node extends Node



func check_node_is_set(n:Node, is_fatal:bool = false) -> bool:
	if(n == null):
		if(is_fatal):
			push_error("Node not set.")
		else:
			push_warning("Node not set.")
		return false
	return true
