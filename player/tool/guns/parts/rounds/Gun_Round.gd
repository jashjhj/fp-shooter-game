class_name Gun_Round extends Node3D

@export var is_live:bool = true

@export var FIRE_TRIGGERS:Array[Triggerable];

@export var RIGIDBODY:RigidBody3D



##Numebr of times this bullet can be fired before it is no longer Live
#@export var SHOTS:int = 1;

signal fire

func _ready():
	fire.connect(triggered)
	if(RIGIDBODY != null):
		RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
		RIGIDBODY.collision_mask = 4096 + 1 + 8192;
		RIGIDBODY.collision_layer = 4096

##Access function
func trigger():
	triggered();

func triggered():
	if(is_live):
		for t in FIRE_TRIGGERS:
			t.trigger();
		
		#SHOTS -= 1;
		#if(SHOTS <= 0):
		is_live = false;
		

func enable_rigidbody():
	if(RIGIDBODY == null):
		push_error("Attempted to enable_rigidbody() on Gun_Round with no set RigidBody.")
		return
	
	
	RIGIDBODY.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child != RIGIDBODY:
			child.reparent(RIGIDBODY)
