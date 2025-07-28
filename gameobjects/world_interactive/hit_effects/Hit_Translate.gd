class_name Hit_Translate extends Hit_HP_Tracker

@export var TRANSLATE_NODE:Node3D;

@export var TRANSLATION:Vector3;

func _ready() -> void:
	super._ready()
	on_hp_becomes_negative.connect(translate)

func translate():
	if(TRANSLATE_NODE != null):
		TRANSLATE_NODE.position += TRANSLATION
