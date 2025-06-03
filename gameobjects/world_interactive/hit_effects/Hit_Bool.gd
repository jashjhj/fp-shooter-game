class_name Hit_Bool extends Hit_Component

var is_true:bool = true
signal became_false

func hit(health):
	if(is_true):
		if(HP < 0):
			is_true = false;
			became_false.emit()
	
