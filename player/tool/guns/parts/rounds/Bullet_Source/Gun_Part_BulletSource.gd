class_name Gun_Part_BulletSource extends Gun_Part


@export var bullet_data:BulletData;


#var bullet:PackedScene = preload("res://gameobjects/bullets/bullet.tscn");

signal shoot

@onready var bullet_source:Bullet_Source = Bullet_Source.new();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bullet_source.bullet_data = bullet_data
	add_child(bullet_source)
	
	shoot.connect(bullet_source.shoot.emit)
	
	
	$Display.free() # Add clause to check?
