extends LegBot

@export var IS_ACTIVE:bool = true

@export var SEEKING_CAMERA_GUN:Seeking_Camera;
@export var SEEKING_CAMERA_CAM:Seeking_Camera
@export_group("Parts")
@export var CENTRIFUGE:Body_Segment
##Batteries is amn array of the HP components of the batteries.
@export var BATTERIES:Array[Hit_HP_Tracker]

@export var MID_SWIVEL:Planetary_Gears;
@export var TOP_SWIVEL:Planetary_Gears;
@export var CAMERA_MESH_ROTATOR:Rotator_1D;
@export var GUN_PITCH:Rotator_1D
@export var GUN_CHAINGUN:Chaingun_Rotator;

var max_energy:float;
var energy:float;


func _ready() -> void:
	super._ready()
	max_energy = len(BATTERIES)
	energy = max_energy
	for b in BATTERIES:
		b.on_hp_change.connect(recalculate_energy)
	
	if(CENTRIFUGE != null):CENTRIFUGE.on_destroy.connect(destroy_centrifuge)


func _physics_process(delta: float) -> void:
	if(!IS_ACTIVE): return
	super._physics_process(delta)
	
	
	if(SEEKING_CAMERA_CAM.last_target_pos != Vector3.INF):
		
		MID_SWIVEL.target_global = SEEKING_CAMERA_GUN.last_target_pos
		TOP_SWIVEL.target_global = SEEKING_CAMERA_CAM.last_target_pos
		CAMERA_MESH_ROTATOR.target_global = SEEKING_CAMERA_CAM.last_target_pos
		GUN_PITCH.target_global = SEEKING_CAMERA_GUN.last_target_pos
	
	
	
	if(SEEKING_CAMERA_GUN.target_pos_local.normalized().dot(Vector3(1,0,0)) > 0.90 and !GUN_CHAINGUN.is_spinning): # if gun is msotly aimed at its target
		GUN_CHAINGUN.start_firing()
	elif(!SEEKING_CAMERA_CAM.can_see_player or SEEKING_CAMERA_GUN.target_pos_local.normalized().dot(Vector3(1,0,0)) < 0.85 and GUN_CHAINGUN.is_spinning):
		GUN_CHAINGUN.stop_firing()
	

func recalculate_energy(new_hp:float):
	energy = 0;
	for b in BATTERIES:
		energy += min(1.0, max(0.0, b.HP/b.MAX_HP))
	
	#Apply new energy value
	MID_SWIVEL.ROTATION_ACCELERATION = energy/max_energy * MID_SWIVEL._initial_acceleration
	TOP_SWIVEL.ROTATION_ACCELERATION = energy/max_energy * TOP_SWIVEL._initial_acceleration

func destroy_centrifuge():
	$Body/Angular_Damper.free()
	LEG_FORCE_LATERAL = 0; # Pretend legs dont work well
	LEG_FORCE_THROUGH *= 0.33;
