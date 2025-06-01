class_name StaticBody3D_Mat extends StaticBody3D

@export var MATERIAL:StaticMaterial

func get_material() -> StaticMaterial:
	if(MATERIAL == null):
		push_warning("No material set for StaticBody3D_Mat")
		return StaticMaterial.new()
	return MATERIAL
