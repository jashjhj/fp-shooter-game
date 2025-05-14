class_name Gun_Part_SAHammer extends Gun_Part

var cocked := true;

func _trigger():
	if(cocked):
		cocked = false;
		trigger_all()
		return true;
	
	return false;
