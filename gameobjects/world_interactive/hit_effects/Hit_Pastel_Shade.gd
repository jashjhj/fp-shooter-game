class_name Hit_Pastel_Shade extends Hit_HP_Tracker

@export var PASTEL:Pastel_Colour_Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	

func hit(damage:float) -> void:
	super.hit(damage)
	
	PASTEL.health -= (damage-MINIMUM_DAMAGE_THRESHOLD) / float(MAX_HP)
