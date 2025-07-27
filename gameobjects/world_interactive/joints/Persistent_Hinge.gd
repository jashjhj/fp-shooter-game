class_name Persistent_Hinge extends HingeJoint3D

@export_category("Uses node references to keep persistent joints.")
@export_category("In case of nodepath Chnages")



@export var NODE_A:RigidBody3D:
	set(v):
		NODE_A = v;
		if(is_inside_tree()):
			update_nodes()
@export var NODE_B:RigidBody3D:
	set(v):
		NODE_B = v;
		if(is_inside_tree()):
			update_nodes()

func _ready() -> void:
	update_nodes()
	NODE_A.tree_entered.connect(update_nodes)
	NODE_B.tree_entered.connect(update_nodes)


func update_nodes():
	node_a = get_path_to(NODE_A)
	node_b = get_path_to(NODE_B)
