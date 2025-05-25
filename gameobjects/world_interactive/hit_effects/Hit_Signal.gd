class_name Hit_Signal extends Hit_Component

signal on_hit

func hit(damage):
	on_hit.emit()
