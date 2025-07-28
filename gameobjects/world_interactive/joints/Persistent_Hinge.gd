class_name Persistent_Hinge extends HingeJoint3D

@export_category("Uses node references to keep persistent joints.")
#This unfortunately resets the joint positions when set. IE limits are from when set.

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

#Used to reinitialise the hinge.
var node_a_start_trans:Transform3D
var node_b_start_trans:Transform3D
var my_start_trans:Transform3D
var intiial_angle:float


func _ready() -> void:
	
	node_a_start_trans = NODE_A.global_transform
	node_b_start_trans = NODE_B.global_transform
	my_start_trans = global_transform
	
	update_nodes()
	NODE_A.tree_entered.connect(update_nodes)
	NODE_B.tree_entered.connect(update_nodes)
	


func update_nodes():
	#if(!is_inside_tree()): return # - if in the middle of reparenting an object, <tree_entered> is called multiple times - SO only do it on final (When THIS node is in the tree with it)
	#print("updating")
	##Resets transform positions to re-apply the 
	#var natrans = NODE_A.global_transform
	#var nbtrans = NODE_B.global_transform
	#var mytrans = global_transform
	#
	#NODE_A.global_transform = node_a_start_trans
	#NODE_B.global_transform = node_b_start_trans
	#global_transform = my_start_trans
	
	
	node_a = get_path_to(NODE_A)
	node_b = get_path_to(NODE_B)
	#
	#NODE_A.global_transform = natrans
	#NODE_B.global_transform = nbtrans
	#global_transform = mytrans
	#
	#print(node_a)
	#print(node_b)
