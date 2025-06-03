class_name Breakable_Camera extends Seeking_Camera

@export var HIT_CMP:Hit_Component;

func _ready() -> void:
	super._ready()
	assert(HIT_CMP != null, "No associated hit component set.")
	HIT_CMP.on_hp_becomes_negative.connect(deactivate)

func deactivate():
	is_active = false
