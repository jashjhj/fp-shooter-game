class_name Hittable_RB extends RigidBody3D

##Also stores an inbuilt hitcomponent with no modifiers at index 0 |||
##Auto-adds direct children
@export var HIT_COMPONENTS:Array[Hit_Component]

##Reference to inbuilt hitcomponent
var inbuilt_hit_component:Hit_Component;

func _ready() -> void:
	HIT_COMPONENTS.insert(0, Hit_Component.new())
	
	inbuilt_hit_component = HIT_COMPONENTS[0]
	
	#Add children
	for child in get_children():
		if(child is Hit_Component and !HIT_COMPONENTS.has(child)):
			HIT_COMPONENTS.append(child)
