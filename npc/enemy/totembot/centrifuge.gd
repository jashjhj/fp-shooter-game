class_name Stabilisation_Centrifuge extends Body_Segment

@export var BODY:Grand_Body;

@export var GIMBAL:Rotator_1D;
@export var CORE:Rotator_1D;

@export var CORE_SPIN_SPEED:float = 60;
@export var GIMBAL_SPIN_SPEED:float = 40;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(len(IMPULSE_UPSTREAMS) != 0, "No impulse_Upstreams set on a Centrifuge")
	super()
	
	IMPULSE_PROPOGATOR.DISABLE_UPSTREAM = true # overrides its behaviour
	IMPULSE_PROPOGATOR.on_hit.connect(apply_random_impulse)
	BODY.IS_CONTROLLED_COM_ACTIVE = true
	BODY.CONTROLLED_COM = BODY.to_local(global_position)


func apply_random_impulse():
	var impulse = IMPULSE_PROPOGATOR.last_impulse;
	
	#Randomsie position of impulse grantedinto hemisphere out
	impulse = impulse.rotated(global_basis.y, (randf()-0.5) * 2*PI)
	impulse = impulse.rotated(global_basis.y.cross(impulse).normalized(), (randf()-0.5) * 2*PI)
	
	
	BODY.apply_impulse(impulse * 20, global_position - BODY.global_position)
	BODY.apply_torque(impulse * 2000)
	
	
	#for i in IMPULSE_UPSTREAMS:
		#i.trigger(IMPULSE_PROPOGATOR.last_damage, impulse, global_position)
	


func _physics_process(delta: float) -> void:
	pass
	#GIMBAL.rotate(basis.z, GIMBAL_SPIN_SPEED * delta)
	#CORE.rotate(GIMBAL.basis.y, CORE_SPIN_SPEED*delta)
