class_name Gun_Part_SAHammer extends Gun_Part

@export var COCK_LISTENER:Gun_Part_Listener;
@export var RELEASE_LISTENER:Gun_Part_Listener;

@export var TRIGGER:Gun_Part_Listener;

var cocked := true;

@export_range(0, 180, 1.0, "radians_as_degrees") var COCKED_ANGLE = PI/6;
@export var ROTATE_AROUND:Vector3 = Vector3.RIGHT;


var current_angle = 15;

func _ready() -> void:
	RELEASE_LISTENER.triggered.connect(_release);


func _release():
	if(cocked):
		cocked = false;
		TRIGGER.trigger()
		return true;
	
	return false;

var original_basis:Basis;
func _process(delta: float) -> void:
	original_basis = transform.basis
	transform = transform.rotated_local(ROTATE_AROUND, current_angle);

func loose_hammer():
	pass;
