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
	
	
	
	#contact_monitor = true
	#max_contacts_reported = 3;
#
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#for i in range(0, state.get_contact_count()):
		#var impulse:Vector3 = state.get_contact_impulse(i) * (global_basis * state.get_contact_local_normal(i))
		#if(impulse.length() > 1):
			#
			#for h in HIT_COMPONENTS:
				#print(h.get_path())
				#h.trigger(impulse.length(), Vector3.ZERO, global_position)
