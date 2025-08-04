class_name Top_Level_Rigidbody extends Hittable_RB

@export_category("Becomes Top-Level on ready")

func _ready() -> void:
	super._ready()
	top_level = true
