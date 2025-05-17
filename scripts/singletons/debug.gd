extends Node



const GHOST_POINT = preload("res://scripts/debug/fading_node.tscn");
func point(position:Vector3, lifetime:float = 1, colour: Color = Color(1,1,1)):
	var ghost = GHOST_POINT.instantiate()
	ghost.LIFETIME = lifetime
	ghost.COLOUR = colour
	get_tree().get_current_scene().add_child(ghost)
	ghost.global_position = position
