class_name Planetary_Gears extends Rotator_1D


#Planetary gears: outside is stationary
#Inside can be rotated


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





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GEARS.append(GEAR)
	for i in range(1, GEARS_NUM):
		GEARS.append(GEAR.duplicate())
		add_child(GEARS[i])
		GEARS[i].position = GEARS[i].position.rotated(Vector3.UP, i*(2.0*PI)/GEARS_NUM)


func spin(angle_to_turn: float) -> void:
	
	
	
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
