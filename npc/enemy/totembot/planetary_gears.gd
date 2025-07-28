class_name Planetary_Gears extends Node3D


#Planetary gears: outside is stationary
#Inside can be rotated


##Maximum degrees/Second
@export_range(0, 360, 0.1, "radians_as_degrees") var TURN_SPEED:float = 1.0;
##Decides whether inside is stationary, or outside.
@export var FROM_INNER:bool = false;

@export var ATTACHED_RB:RigidBody3D;
@export var SIMULATED_MASS_ABOVE:float = 0.0;

@export_group("Components")
@export var OUTER_RING:Node3D
##Inside
@export var SUN:Node3D
@export var GEAR:Node3D
@export var GEARS_NUM:int = 6;
##Ratio of Circumference/Radius of Planet gears TO Sun gear
@export var GEAR_RATIO:float = 1.0;


var GEARS:Array[Node3D]

##A vector representing which way the SUBJECT should look towards (-z) || In GLOBAL Space
var target:Vector3 = Vector3(0, 0, -1);




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GEARS.append(GEAR)
	for i in range(1, GEARS_NUM):
		GEARS.append(GEAR.duplicate())
		add_child(GEARS[i])
		GEARS[i].position = GEARS[i].position.rotated(Vector3.UP, i*(2.0*PI)/GEARS_NUM)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var angle = global_basis.z.signed_angle_to(target, global_basis.y)
	
	var angle_to_turn = sign(angle) * min(abs(angle), TURN_SPEED*delta)
	
	
	#angle_to_turn = TURN_SPEED * delta
	
	rotate(basis.y, angle_to_turn)
	
	
	
	for gear in GEARS:
		
		gear.rotate_object_local(Vector3.UP, -angle_to_turn) # First undo local rotation
		gear.position = gear.position.rotated(Vector3.UP, -angle_to_turn)
		
		if(!FROM_INNER):
			
			gear.rotate_object_local(Vector3.UP, -angle_to_turn / GEAR_RATIO)
			gear.position = gear.position.rotated(Vector3.UP, angle_to_turn *  GEAR_RATIO / (PI))
		
		else:
			
			gear.rotate_object_local(Vector3.UP, angle_to_turn / GEAR_RATIO)
			gear.position = gear.position.rotated(Vector3.UP, angle_to_turn *  GEAR_RATIO / (PI))
	
	
	if(OUTER_RING != null and !FROM_INNER):
		OUTER_RING.global_basis = get_parent_node_3d().global_basis
	if(SUN != null and FROM_INNER):
		SUN.global_basis = get_parent_node_3d().global_basis
	
	if(ATTACHED_RB != null): # Equal and opposite type stuff
		ATTACHED_RB.apply_torque(-angle_to_turn * Vector3.UP * SIMULATED_MASS_ABOVE)
