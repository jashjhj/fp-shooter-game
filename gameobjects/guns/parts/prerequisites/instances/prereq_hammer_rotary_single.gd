class_name GunPrerequisite_HammerRotarySingle extends GunPrerequisite

var cocked := true;

func _trigger(_parent:Gun)->bool:
	if(cocked):
		cocked = false;
		return true;
	
	return false;
