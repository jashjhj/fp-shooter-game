extends Gun_Part

##This is called on the part being triggered
func _trigger() -> bool:
	trigger_all()
	return true;
