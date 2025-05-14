class_name Gun_Part_Chech extends Gun_Part

@export var enabled = true;

##This is called on the part being triggered
func _trigger() -> bool:
	if(enabled):
		print("click!")
		trigger_all()
		return true;
	return false;
