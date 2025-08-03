#@tool
class_name Plastic_Colour_Mesh extends MeshInstance3D

var colour_seed:float;
## float between 0 and 1
var health:float = 1.0:
	set(v):
		health = v
		for i in range(0,get_surface_override_material_count()):
			get_surface_override_material(i).set_shader_parameter("life", health)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in range(0,get_surface_override_material_count()):
		var MAT:ShaderMaterial = preload("res://assets/textures/plastics/plastic_colour.tres").duplicate()
		
		#MAT.resource_local_to_scene = true
		colour_seed = randf()
		print(colour_seed)
		MAT.set_shader_parameter("color_seed", colour_seed)
		set_surface_override_material(i, MAT)
