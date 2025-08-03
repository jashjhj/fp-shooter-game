@tool
class_name Pastel_Colour_Mesh extends MeshInstance3D


## float between 0 and 1
@export_range(0.0, 1.0, 0.001) var health:float = 1.0:
	set(v):
		health = min(1.0, max(0.0, v))
		for i in range(0,get_surface_override_material_count()):
			get_surface_override_material(i).set_shader_parameter("life", health)

@export var RANDOMISE_ON_RUNTIME:bool = true;

@export var RERANDOMISE:bool = false:
	set(v):
		RERANDOMISE = false
		randomise_colours()


## randomises colour for editor and to
func _ready() -> void:
	
	if(RANDOMISE_ON_RUNTIME): randomise_colours()

func randomise_colours():
	for i in range(0,get_surface_override_material_count()):
		
		var MAT:ShaderMaterial = load("res://assets/textures/plastics/pastel_colour.tres").duplicate()
		
		#MAT.resource_local_to_scene = true
		MAT.set_shader_parameter("color_seed", randf())
		set_surface_override_material(i, MAT)
