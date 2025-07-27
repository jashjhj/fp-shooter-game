class_name Weakpoint extends Node3D

@export_category("Place Hit_Weakpoint's on concerning Hittables")

##Also stores an inbuilt hitcomponent with no modifiers at index 0 |||
##Auto-adds direct children
@export var HIT_COMPONENTS:Array[Hit_Component]


##Curve speciying damage multiplier / distance. Should trail off to Zero.
@export var DAMAGE_CURVE:Curve;

# ---------- HITTABLE CODE


##Reference to inbuilt hitcomponent
var inbuilt_hit_component:Hit_Component;

func _ready() -> void:
	HIT_COMPONENTS.insert(0, Hit_Component.new())
	
	inbuilt_hit_component = HIT_COMPONENTS[0]
	
	#Add children
	for child in get_children():
		if(child is Hit_Component and !HIT_COMPONENTS.has(child)):
			HIT_COMPONENTS.append(child)


# -------- WEAKPOINT UNIQUE SCRIPT

##Hit with impusle info and everything
func trigger(damage:float, impulse:Vector3 = Vector3.ZERO, impulse_pos:Vector3 = Vector3.INF):
	damage *= DAMAGE_CURVE.sample((impulse_pos - global_position).length()) # Samples the distance for the multiplier.
	
	var i:int = 0;
	while i < len(HIT_COMPONENTS):
		var hit_comp = HIT_COMPONENTS[i]
		
		if(hit_comp == null): # If hit component has been freed for any reason
			HIT_COMPONENTS.remove_at(i)
		else:
			hit_comp.trigger(damage, impulse, impulse_pos)
			i+=1;
	
