class_name Gun_Part_BulletSource extends Gun_Part


@export var LISTENER:Gun_Part_Listener;
@export var ATTACHED_RIGIDBODY:RigidBody3D;

@export var bullet_data:BulletData;


var bullet:PackedScene = load("res://gameobjects/bullets/bullet.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(bullet_data != null, "No Bullet data set.")
	LISTENER.triggered.connect(trigger)
	
	$Display.free()

func trigger():
	fire_bullet()
	return true;



func fire_bullet():
	var bullet_inst = bullet.instantiate()
	bullet_inst.data = bullet_data;
	bullet_inst.direction = get_global_transform().basis.z;
	bullet_inst.origin_global_pos = global_position;
	
	get_tree().get_current_scene().add_child(bullet_inst);
	
	
	if(bullet_inst == null):
		push_error("Bullet failed to initialise")
		return
	
	if(ATTACHED_RIGIDBODY != null): # add velocity to bullet on shoot
		bullet_inst.velocity += ATTACHED_RIGIDBODY.linear_velocity;
	
