extends LegBot

@export var MID_SWIVEL:Planetary_Gears;
@export var TOP_SWIVEL:Planetary_Gears;
@export var CAMERA:Seeking_Camera;

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	MID_SWIVEL.target = Globals.PLAYER.global_position - BODY.global_position
	TOP_SWIVEL.target = Globals.PLAYER.global_position - BODY.global_position
