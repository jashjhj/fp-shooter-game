class_name Hit_Gib extends Hit_HP_Tracker

@export var GIBBABLE:Gibbable

func _ready() -> void:
	super._ready()
	on_hp_becomes_negative.connect(GIBBABLE.gib)
