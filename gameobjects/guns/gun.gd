class_name Gun extends Node3D

signal trigger;

@export var prerequisites:Array[GunPrerequisite];

@export var bullet_source:Gun_BulletSource;

##Set to the default bullet scene
var bullet:PackedScene = load("res://gameobjects/bullets/bullet.tscn");
@export var bullet_data:BulletData


func _ready() -> void:
	trigger.connect(_trigger);
	assert(bullet_data != null, "No Bullet data set.")
	assert(bullet_source != null, "No Bullet source set.")
	


func _trigger():
	var is_success = true;
	for prerequisite in prerequisites:
		if(is_success): # If still going
			var does_pass = prerequisite._trigger(self);
			if(!does_pass): # if prerequisite check failed
				is_success = false;
	
	if(is_success):
		print("Succeeded")
	
	fire_bullet() # add this to is_success after debug
	

func fire_bullet():
	var bullet_inst = bullet.instantiate()
	bullet_inst.data = bullet_data;
	bullet_inst.direction = bullet_source.get_global_transform().basis.z;
	bullet_inst.origin_global_pos = bullet_source.global_position;
	
	get_tree().get_current_scene().add_child(bullet_inst);
	if(bullet_inst == null):
		push_error("Bullet failed to initialise")
		return
	
