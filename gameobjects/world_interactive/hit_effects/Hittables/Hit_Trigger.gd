class_name Hit_Trigger extends Hit_Component

@export var MIN_DAMAGE:float = 1.0;

func hit(damage):
	if(damage > MIN_DAMAGE):
		for c in get_children():
			if(c is Triggerable): c.trigger()
