class_name Gun_Part_BulletSource extends Gun_Part


@export var bullet_data:BulletData;


var bullet:PackedScene = preload("res://gameobjects/bullets/bullet.tscn");

signal shoot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(bullet_data != null, "No Bullet data set.")
	
	shoot.connect(trigger)
	
	$Display.free()



func trigger(): # Triggers on next frame.
	for i in range(0, bullet_data.amount):
		fire_bullet(velocity)


var prev_position:= Vector3.ZERO
var velocity:=Vector3.ZERO
func _physics_process(delta: float) -> void:
	velocity = (global_position - prev_position) / delta
	prev_position = global_position





func fire_bullet(supplementary_velocity := Vector3.ZERO):
	var bullet_inst = bullet.instantiate() as Bullet
	bullet_inst.data = bullet_data;
	bullet_inst.direction = get_global_transform().basis.z;
	
	var inaccuracy = randf() * bullet_data.base_inaccuracy;
	var inaccuracy_vector = get_global_transform().basis.y.rotated(get_global_transform().basis.z, randf()*2*PI); # random vector to rotate around
	bullet_inst.direction = bullet_inst.direction.rotated(inaccuracy_vector, inaccuracy)
	
	bullet_inst.origin_global_pos = global_position;
	
	get_tree().get_current_scene().add_child(bullet_inst);
	
	if(bullet_inst == null):
		push_error("Bullet failed to initialise")
		return
	
	bullet_inst.velocity += supplementary_velocity;
	
