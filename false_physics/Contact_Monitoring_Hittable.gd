class_name Contact_Monitoring_Hittable extends Hittable_Collider

@export var DAMAGE_ON_COLLISION:float = 10.0;
##Time until this can activate, in seconds after initialisation
@export var COOLDOWN:float = 1.0;

var start_tick:int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	body_entered.connect(collision)
	start_tick = Time.get_ticks_msec()


#func _physics_process(delta: float) -> void:
	#pass
		

func collision(body:Node3D):
	if(Time.get_ticks_msec() - start_tick > int(COOLDOWN * 1000.0)):
		for h in HIT_COMPONENTS:
			h.trigger(DAMAGE_ON_COLLISION, Vector3.ZERO, global_position)
