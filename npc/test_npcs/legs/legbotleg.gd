class_name LegBotLeg extends Node3D

#Rigidbody sibling to attach to
@export var BODY:RigidBody3D;

@export var HIP:Generic6DOFJoint3D;
@export var KNEE:HingeJoint3D;



var target_position:Vector3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(BODY != null):
		HIP.node_a = BODY.get_path()
	
	var ik = $IK_Leg_Abstract.get_angles(Vector3(0, -1, 0), Vector3.FORWARD)
	print(ik.hippitch)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
