class_name Triggerable extends Node

@export var trigger_on_ready:bool = false;

signal on_trigger

func _ready() -> void:
	if(trigger_on_ready): trigger()

func trigger() -> void:
	on_trigger.emit()
