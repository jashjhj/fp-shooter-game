class_name Hittable_Intersect_Collider extends Hittable_Collider

@export_category("Collision shape must be convex!")

@export var DAMAGE_ON_COLLIDE:float = 20.0;
##Spawn immunity time in msec
@export var SPAWN_IMMUNITY:float = 2.5;

var start_tick:int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	body_entered.connect(begin_collision)
	
	start_tick = Time.get_ticks_msec()

func begin_collision(body:Node3D):
	if(Time.get_ticks_msec() - start_tick < int(SPAWN_IMMUNITY * 1000.0)):return # check enough tiem ahs passed
	for h in HIT_COMPONENTS:
		h.trigger(DAMAGE_ON_COLLIDE, Vector3.ZERO, global_position)
