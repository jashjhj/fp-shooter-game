class_name Trig_Apply_Velocity_To_Interactive_1D extends Triggerable

@export var I1D:Tool_Part_Interactive_1D
@export var VELOCITY:float = 1.0;

func _ready() -> void:
	super._ready()
	assert(I1D != null, "No Interactive_1D Set")

func trigger():
	super.trigger()
	I1D.velocity = VELOCITY
