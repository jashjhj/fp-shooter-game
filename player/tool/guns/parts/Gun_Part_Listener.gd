class_name Gun_Part_Listener extends Node

#This sinply allows communication between different gun-parts.

signal trigger


func _trigger() -> void:
	trigger.emit()
