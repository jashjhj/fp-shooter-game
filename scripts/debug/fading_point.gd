extends Node3D

@export var LIFETIME:float = 1.0;
@export var COLOUR:Color = Color(0, 1, 1);

#var timer:float

const OPAQUENESS:float = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".set_surface_override_material(0, $".".get_surface_override_material(0).duplicate())
	$".".get_surface_override_material(0).albedo_color = Color(COLOUR, OPAQUENESS)
	$Timer.start(LIFETIME)
	$Timer.timeout.connect(queue_free)

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if timer > LIFETIME:
		#timer = LIFETIME
	#timer -= delta
	#if timer < 0:
		#queue_free()
