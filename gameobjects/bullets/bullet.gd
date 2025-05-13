class_name Bullet extends Node3D

@export var data:BulletData
@export var direction:Vector3;

@export var velocity:Vector3;
@export var origin_global_pos:Vector3;

@onready var FORWARDS_RAY:RayCast3D = $RayCast3D;

var speed:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(data == null):
		push_error("Bullet instanced without data!")
		
		free()
		return
	
	#initialise velocity.
	speed = data.speed;
	
	global_position = origin_global_pos;
	direction = direction.normalized()
	velocity = direction*speed;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	draw_trail()
	
	FORWARDS_RAY.look_at(global_position - velocity)
	if((FORWARDS_RAY.get_collision_point() - global_position).length() < speed*delta * 2): # Going to hit an object.
		hit_object()
	else: # free room to travel forwards
		position += velocity*delta;
		velocity.y -= data.gravity*delta; # grav
		velocity *= (1-data.drag*delta)   # drag
		
	


func draw_trail(): # not working yet
	pass
	#var trail = preload("res://gameobjects/bullets/trail/bullet_trail.tscn").instantiate()
	#trail.lifetime = 2000;
	#trail.direction = velocity.normalized();
	
	#get_tree().get_current_scene().add_child(trail);
	#trail.global_position = global_position;


func hit_object():
	print("Bullet hit " + str(FORWARDS_RAY.get_collision_point()))
	
	#add bullet hole
	var bullet_hole_inst = preload("res://gameobjects/bullets/hole/bullet_hole.tscn").instantiate()
	get_tree().get_current_scene().add_child(bullet_hole_inst);
	Globals.RUBBISH_COLLECTOR.add_rubbish(bullet_hole_inst);
	bullet_hole_inst.global_position = FORWARDS_RAY.get_collision_point();
	bullet_hole_inst.look_at(Vector3.FORWARD, FORWARDS_RAY.get_collision_normal());

	
	queue_free()
