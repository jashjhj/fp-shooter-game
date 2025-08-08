extends LegBot

@export var IS_ACTIVE:bool = true

@export var SEEKING_CAMERA_GUN:Seeking_Camera;
@export var SEEKING_CAMERA_CAM:Seeking_Camera
@export_group("Parts")
@export var MID_SWIVEL:Planetary_Gears;
@export var TOP_SWIVEL:Planetary_Gears;
@export var CAMERA_MESH_ROTATOR:Rotator_1D;
@export var GUN_PITCH:Rotator_1D
@export var GUN_CHAINGUN:Chaingun_Rotator;


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
	
