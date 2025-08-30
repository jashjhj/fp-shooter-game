@tool
class_name Pastel_Colour_Mesh extends Highlightable_Mesh



## float between 0 and 1
@export_range(0.0, 1.0, 0.001) var health:float = 1.0:
	set(v):
		health = min(1.0, max(0.0, v))
		for i in range(0,get_surface_override_material_count()):
			get_surface_override_material(i).next_pass.next_pass.set_shader_parameter("life", health)


##Button to rerandomise
@export var RERANDOMISE:bool = false:
	set(v):
		if(!is_initialised): init()
		RERANDOMISE = false
		for mat in get_all_materials():
			mat.next_pass.next_pass.set_shader_parameter("color_shade", randf())

@export var REINIT:bool = false:
	set(v):
		init()
		RERANDOMISE = false


#
#@export_group("Highlight", "HIGHLIGHT")
#@export var HIGHLIGHT_ENABLED:bool = false:
	#set(v):
		#if(!is_initialised): init()
		#HIGHLIGHT_ENABLED = v
		#HIGHLIGHT_STRENGTH = HIGHLIGHT_STRENGTH # triggers setter
		#
#
#@export var HIGHLIGHT_COLOUR:Color = Color(0.3, 0.2, 0.1):
	#set(v):
		#if(!is_initialised): init()
		#HIGHLIGHT_COLOUR = v
		#for mat in get_all_materials():
			#mat.set_shader_parameter("emission_color", Vector3(HIGHLIGHT_COLOUR.r, HIGHLIGHT_COLOUR.g, HIGHLIGHT_COLOUR.b))
			#mat.next_pass.set_shader_parameter("emission_color", Vector3(HIGHLIGHT_COLOUR.r, HIGHLIGHT_COLOUR.g, HIGHLIGHT_COLOUR.b))
#
#@export var HIGHLIGHT_STRENGTH:float = 0.5:
	#set(v):
		#if(!is_initialised): init()
		#HIGHLIGHT_STRENGTH = v
		#for mat in get_all_materials():
			#if(HIGHLIGHT_ENABLED):
				#
				#if(HIGHLIGHT_THROUGH_OBJECTS): mat.next_pass.set_shader_parameter("emission", HIGHLIGHT_STRENGTH)
				#else:mat.set_shader_parameter("emission", HIGHLIGHT_STRENGTH)
			#else:
				#if(HIGHLIGHT_THROUGH_OBJECTS): mat.next_pass.set_shader_parameter("emission", 0)
				#else:mat.set_shader_parameter("emission", 0)
			#
			#
#
#
###Makes the highlight work through walls.
#@export var HIGHLIGHT_THROUGH_OBJECTS:bool = false:
	#set(v):
		#HIGHLIGHT_THROUGH_OBJECTS = v;
		#for mat in get_all_materials():
			#if(HIGHLIGHT_THROUGH_OBJECTS):
				#mat.next_pass.set_shader_parameter("emission", HIGHLIGHT_STRENGTH if HIGHLIGHT_ENABLED else 0)
				#mat.set_shader_parameter("emission", 0)
			#else:
				#mat.next_pass.set_shader_parameter("emission", 0)
				#mat.set_shader_parameter("emission", HIGHLIGHT_STRENGTH if HIGHLIGHT_ENABLED else 0)



## randomises colour for editor and to
func _ready() -> void:
	
	super()

func init():
	
	
	for i in range(0,get_surface_override_material_count()):
		if (EXCLUDE_SURFACES & (0b1 << i)): continue # IF this value isnt ticked in exclude surfaces
		
		var mat:ShaderMaterial = load("res://assets/textures/pastels/pastel_colour.tres").duplicate()
		#mat.next_pass = load("res://assets/textures/pastels/highlight_shader.tres").duplicate()
		set_surface_override_material(i, mat)
	
	super()
	
	
	if(!Engine.is_editor_hint()): # rerandomise if on runtime
		RERANDOMISE = true;
