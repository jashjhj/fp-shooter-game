class_name Angular_Damper extends Generic6DOFJoint3D

@export var STIFFNESS:float = 8.0;
@export var DAMPING:float = 2.0;

func _ready() -> void:
	set("angular_limit_x/enabled", false)
	set("angular_spring_x/enabled", true)
	set("angular_spring_x/damping", DAMPING)
	set("angular_spring_x/stiffness", STIFFNESS)

	set("angular_limit_y/enabled", false)
	set("angular_spring_y/enabled", true)
	set("angular_spring_y/damping", DAMPING)
	set("angular_spring_y/stiffness", STIFFNESS)

	set("angular_limit_z/enabled", false)
	set("angular_spring_z/enabled", true)
	set("angular_spring_z/damping", DAMPING)
	set("angular_spring_z/stiffness", STIFFNESS)
