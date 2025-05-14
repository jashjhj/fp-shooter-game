class_name Gun extends Node3D

signal trigger;

@export var trigger_functions:Array[Gun_Part_Listener];


##Set to the default bullet scene
var bullet:PackedScene = load("res://gameobjects/bullets/bullet.tscn");
@export var bullet_data:BulletData


func _ready() -> void:
	trigger.connect(_trigger);
	assert(bullet_data != null, "No Bullet data set.")
	


func _trigger():
	for listener in trigger_functions:
		listener.triggered.emit();
