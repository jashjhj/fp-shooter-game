class_name Hittable_Collider extends Area3D

##Also stores an inbuilt hitcomponent with no modifiers at index 0 |||
##Auto-adds direct children
@export var HITTABLE:Array[Hit_Component]

##Reference to inbuilt hitcomponent
var inbuilt_hit_component:Hit_Component;

func _ready() -> void:
	HITTABLE.insert(0, Hit_Component.new())
	
	inbuilt_hit_component = HITTABLE[0]
	
	#Add children
	for child in get_children():
		if(child is Hit_Component and !HITTABLE.has(child)):
			HITTABLE.append(child)
