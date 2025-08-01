class_name Triggerable extends Node

signal on_trigger

func _ready() -> void:
	pass

func trigger() -> void:
	on_trigger.emit()
