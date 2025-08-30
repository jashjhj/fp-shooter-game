class_name Highlightable_Mesh extends MeshInstance3D


@export_flags("0","1","2","3","4") var EXCLUDE_SURFACES:int = 0;

@export_group("Highlight", "HIGHLIGHT")
@export var HIGHLIGHT_ENABLED:bool = false:
	set(v):
		if(!is_initialised): init()
		HIGHLIGHT_ENABLED = v
		HIGHLIGHT_STRENGTH = HIGHLIGHT_STRENGTH # triggers setter
		

@export var HIGHLIGHT_COLOUR:Color = Color(0.3, 0.2, 0.1):
	set(v):
		if(!is_initialised): init()
		HIGHLIGHT_COLOUR = v
		for mat in get_all_materials():
			mat.set_shader_parameter("emission_color", Vector3(HIGHLIGHT_COLOUR.r, HIGHLIGHT_COLOUR.g, HIGHLIGHT_COLOUR.b))
			mat.next_pass.set_shader_parameter("emission_color", Vector3(HIGHLIGHT_COLOUR.r, HIGHLIGHT_COLOUR.g, HIGHLIGHT_COLOUR.b))

@export var HIGHLIGHT_STRENGTH:float = 0.5:
	set(v):
		if(!is_initialised): init()
		HIGHLIGHT_STRENGTH = v
		for mat in get_all_materials():
			if(HIGHLIGHT_ENABLED):
				
				if(HIGHLIGHT_THROUGH_OBJECTS): mat.next_pass.set_shader_parameter("emission", HIGHLIGHT_STRENGTH)
				else:mat.set_shader_parameter("emission", HIGHLIGHT_STRENGTH)
			else:
				if(HIGHLIGHT_THROUGH_OBJECTS): mat.next_pass.set_shader_parameter("emission", 0)
				else:mat.set_shader_parameter("emission", 0)
			


var is_initialised:bool = false




##Makes the highlight work through walls.
@export var HIGHLIGHT_THROUGH_OBJECTS:bool = false:
	set(v):
		HIGHLIGHT_THROUGH_OBJECTS = v;
		for mat in get_all_materials():
			if(HIGHLIGHT_THROUGH_OBJECTS):
				mat.next_pass.set_shader_parameter("emission", HIGHLIGHT_STRENGTH if HIGHLIGHT_ENABLED else 0)
				mat.set_shader_parameter("emission", 0)
			else:
				mat.next_pass.set_shader_parameter("emission", 0)
				mat.set_shader_parameter("emission", HIGHLIGHT_STRENGTH if HIGHLIGHT_ENABLED else 0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()

func init():
	is_initialised = true
	
	var highlight_mat = load("res://assets/textures/highlight/highlight.tres")
	var highlight_through_mat = load("res://assets/textures/highlight/highlight_through.tres")
	
	for i in range(0, get_surface_override_material_count()):
		# Sets matrial such that:
		# mat = highlight normal
		# mat.next_pass = highlight through
		# mat.next_pass.next_pass = as it was.
		
		add_prepass(highlight_through_mat.duplicate(), i)
		add_prepass(highlight_mat.duplicate(), i)
	
	#Calls getters to initialise
	HIGHLIGHT_THROUGH_OBJECTS = HIGHLIGHT_THROUGH_OBJECTS
	HIGHLIGHT_COLOUR = HIGHLIGHT_COLOUR
	HIGHLIGHT_ENABLED = HIGHLIGHT_ENABLED


func add_prepass(material:Material, surface:int):
	
	material.next_pass = get_surface_override_material(surface)
	set_surface_override_material(surface, material)

##starts at zeroeth pass
func get_nth_pass(surface:int, n:int):
	var mat = get_surface_override_material(surface)
	for i in range(n):
		mat = mat.next_pass
	return mat

func get_all_materials():
	var out:Array[ShaderMaterial]
	for i in range(0,get_surface_override_material_count()):
		if (EXCLUDE_SURFACES & (0b1 << i)): continue # IF this value isnt ticked in exclude surfaces
		
		out.append(get_surface_override_material(i))
	return out
