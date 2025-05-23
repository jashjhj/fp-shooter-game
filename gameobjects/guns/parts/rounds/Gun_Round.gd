class_name Gun_Round extends Node3D

@export var is_live:bool = true

@export var BULLET_SOURCE:Gun_Part_BulletSource;
@export var RIGIDBODY:RigidBody3D;

@export var LIVE_ROUND_MODEL:Node3D;
@export var SPENT_ROUND_MODEL:Node3D;

##Should parts be freed after final use
@export var IS_SINGLE_USE:bool = true;

signal fire

func _ready():
	fire.connect(triggered)
	
	if(RIGIDBODY != null):
		RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
		RIGIDBODY.collision_mask = 4096 + 1;
		RIGIDBODY.collision_layer = 4096
	
	if(SPENT_ROUND_MODEL != null):
		SPENT_ROUND_MODEL.visible = false;

##Access function
func trigger():
	triggered();

func triggered():
	if(is_live):
		is_live = false;
		BULLET_SOURCE.shoot.emit();
		if(IS_SINGLE_USE):
			BULLET_SOURCE.queue_free()

		
		if(LIVE_ROUND_MODEL != null and SPENT_ROUND_MODEL != null):
			LIVE_ROUND_MODEL.visible = false;
			SPENT_ROUND_MODEL.visible = true;
			
			if(IS_SINGLE_USE):
				LIVE_ROUND_MODEL.queue_free()

func enable_rigidbody():
	if(RIGIDBODY == null):
		push_error("Attempted to enable_rigidbody() on Gun_Round with no set RigidBody.")
		return
	
	RIGIDBODY.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child != RIGIDBODY:
			child.reparent(RIGIDBODY)
