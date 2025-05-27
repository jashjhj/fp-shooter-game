class_name Gunner_State extends State

var OWNER:Gunner;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await(owner.ready)
	OWNER = owner
