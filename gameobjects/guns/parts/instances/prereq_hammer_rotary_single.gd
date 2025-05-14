class_name Gun_Part_SAHammer extends Gun_Part

var cocked := true;

func _trigger(_arent:Gun)->bool:
	if(cocked):
		cocked = false;
		return true;
	
	return false;
