class_name Hittable_Collider extends Area3D

##Auto-adds children
@export var HITTABLE:Array[Hit_Component]

func _ready() -> void:
	for child in get_children():
		if(child is Hit_Component and !HITTABLE.has(child)):
			HITTABLE.append(child)
