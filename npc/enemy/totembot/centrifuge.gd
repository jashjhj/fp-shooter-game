class_name Stabilisation_Centrifuge extends Body_Segment

@export var GIMBAL:Rotator_1D;
@export var CORE:Rotator_1D;

@export var CORE_SPIN_SPEED:float = 60;
@export var GIMBAL_SPIN_SPEED:float = 40;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	pass
	#GIMBAL.rotate(basis.z, GIMBAL_SPIN_SPEED * delta)
	#CORE.rotate(GIMBAL.basis.y, CORE_SPIN_SPEED*delta)
