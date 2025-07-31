extends LegBot


@export var SEEKING_CAMERA_GUN:Seeking_Camera;
@export var SEEKING_CAMERA_CAM:Seeking_Camera
@export_group("Joints")
@export var MID_SWIVEL:Planetary_Gears;
@export var TOP_SWIVEL:Planetary_Gears;
@export var CAMERA_MESH_ROTATOR:Rotator_1D;
@export var GUN_PITCH:Rotator_1D


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	
	if(SEEKING_CAMERA_CAM.last_target_pos != Vector3.INF):
		
		MID_SWIVEL.target_global = SEEKING_CAMERA_GUN.last_target_pos
		TOP_SWIVEL.target_global = SEEKING_CAMERA_CAM.last_target_pos
		CAMERA_MESH_ROTATOR.target_global = SEEKING_CAMERA_CAM.last_target_pos
		GUN_PITCH.target_global = SEEKING_CAMERA_GUN.last_target_pos
