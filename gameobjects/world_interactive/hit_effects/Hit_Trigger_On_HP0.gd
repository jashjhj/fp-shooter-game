class_name Hit_Trigger_On_HP0 extends Hit_HP_Tracker

@export var TRIGGERABLE:Triggerable

func _ready() -> void:
	super._ready()
	on_hp_becomes_negative.connect(TRIGGERABLE.trigger)
