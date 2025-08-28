class_name Tool_Rack extends Node3D

##Set this to head
@export var VIEW_ANCHOR:Node3D;

@export var CAMERA_POS:Node3D;
@onready var ANCHOR:Node3D
var original_parent;

var is_inspecting:bool = false:
	set(v):
		if(is_inspecting == v): return
		is_inspecting = v
		
		
		if(is_inspecting):
			ANCHOR.reparent(VIEW_ANCHOR)
			ANCHOR.position = CAMERA_POS.basis.inverse()* - CAMERA_POS.position
			ANCHOR.basis = CAMERA_POS.basis.inverse()
			reparent(VIEW_ANCHOR)
		else:
			
			ANCHOR.reparent(original_parent)
			ANCHOR.position = Vector3.ZERO
			ANCHOR.basis = Basis.IDENTITY
			reparent(original_parent)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ANCHOR = Node3D.new()
	assert(VIEW_ANCHOR != null, "NO view anchor set. Set this to the player's head.")
	original_parent = get_parent()
	
	
	await get_parent().ready
	get_parent().add_child(ANCHOR)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = position.lerp(ANCHOR.position, min(1.0, delta * 10))
	basis = Basis(Quaternion(basis).slerp(Quaternion(ANCHOR.basis), min(1.0, delta * 10)))

func _physics_process(delta: float) -> void:
	pass
