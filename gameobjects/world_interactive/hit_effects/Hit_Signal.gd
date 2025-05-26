class_name Hit_Signal extends Hit_Component

signal on_hit

func hit(damage):
	if(damage > MINIMUM_DAMAGE_THRESHOLD):
		on_hit.emit()
