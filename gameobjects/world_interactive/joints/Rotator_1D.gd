class_name Rotator_1D extends Node3D

@export_category("Rotation axis = around the local Y+")

##Maximum degrees/Second
@export_range(0, 360, 0.1, "radians_as_degrees") var ROTATION_SPEED:float = 1.0;


##A vector representing which way the SUBJECT should look towards (-z) || In GLOBAL Space
var target:Vector3 = Vector3(0, 0, -1);

func _process(delta: float) -> void:
	
	var angle = global_basis.z.signed_angle_to(target, global_basis.y)
	
	var angle_to_turn = sign(angle) * min(abs(angle), ROTATION_SPEED*delta)
	
	
	#angle_to_turn = TURN_SPEED * delta
	
	rotate(basis.y, angle_to_turn)
	
	spin(angle_to_turn)

##Called every frame _process()
func spin(angle_to_turn:float):
	pass
