class_name Trig_Sound_Effect extends Triggerable

@export var SFX:AudioStreamPlayer3D

@export var PITCH_ORIGIN:float = 1.0;
@export var PITCH_OFFSET:float = 0.1;

func trigger():
	super.trigger()
	SFX.pitch_scale = PITCH_ORIGIN - PITCH_OFFSET + randf() * PITCH_OFFSET * 2.0
	SFX.play()
