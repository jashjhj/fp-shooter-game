class_name Hit_Propogate extends Hit_Component

@export var HIT_COMPONENTS:Array[Hit_Component]

func _ready() -> void:
	super._ready()
	
	for c in get_children():
		if c is Hit_Component and !HIT_COMPONENTS.has(c):
			HIT_COMPONENTS.append(c)

func hit(damage):
	super.hit(damage)
	for h in HIT_COMPONENTS:
		h.trigger(last_damage, last_impulse, last_impulse_pos)
