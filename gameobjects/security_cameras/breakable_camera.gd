class_name Breakable_Camera extends Seeking_Camera

@export var HIT_CMP:Hit_Component;
@export var MESH_TO_DISABLE_EMISSION:MeshInstance3D;

func _ready() -> void:
	super._ready()
	assert(HIT_CMP != null, "No associated hit component set.")
	HIT_CMP.on_hp_becomes_negative.connect(deactivate)

func deactivate():
	is_active = false
	if(MESH_TO_DISABLE_EMISSION != null):
		for i in range(0, MESH_TO_DISABLE_EMISSION.get_surface_override_material_count()):
			MESH_TO_DISABLE_EMISSION.get_surface_override_material(i).emission_enabled = false;
