class_name Bullet extends Node3D

@export var data:BulletData
@export var direction:Vector3;

@export var velocity:Vector3;
@export var origin_global_pos:Vector3;

@onready var FORWARDS_RAY:RayCast3D = $RayCast3D;

#var speed:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(data == null):
		push_error("Bullet instanced without data!")
		
		free()
		return
	
	#initialise velocity.
	
	global_position = origin_global_pos;
	direction = direction.normalized()
	velocity = direction*data.speed;
	
	FORWARDS_RAY.target_position = Vector3(0,0,data.speed*1.5);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	var speed = velocity.length()
	
	
	FORWARDS_RAY.look_at(global_position - velocity)
	FORWARDS_RAY.force_raycast_update()
	if((FORWARDS_RAY.get_collision_point() - global_position).length() < speed*delta and FORWARDS_RAY.get_collider() != null): # Going to hit an object.
		hit_object()
	else: # free room to travel forwards
		position += velocity*delta;
		
		#calculate next frames data
		velocity.y -= data.gravity*delta; # grav
		velocity *= (1-data.drag*delta)   # drag
		
	
	$RayCast3D/RayVisualiser.position.z = -speed*delta/2 # This shows it better as it is mvoed previously.
	$RayCast3D/RayVisualiser.mesh.height = speed*delta;
	


func draw_trail(): # not working yet
	pass
	#var trail = preload("res://gameobjects/bullets/trail/bullet_trail.tscn").instantiate()
	#trail.lifetime = 2000;
	#trail.direction = velocity.normalized();
	
	#get_tree().get_current_scene().add_child(trail);
	#trail.global_position = global_position;


func hit_object():
	#print("Bullet hit " + str(FORWARDS_RAY.get_collision_point()))
	
	#add bullet hole
	var bullet_hole_inst = preload("res://gameobjects/bullets/hole/bullet_hole.tscn").instantiate()
	get_tree().get_current_scene().add_child(bullet_hole_inst);
	Globals.RUBBISH_COLLECTOR.add_rubbish(bullet_hole_inst);
	bullet_hole_inst.global_position = FORWARDS_RAY.get_collision_point() + FORWARDS_RAY.get_collision_normal() * 0.01;
	if(FORWARDS_RAY.get_collision_normal().dot(Vector3.RIGHT) != 0):
		bullet_hole_inst.look_at(bullet_hole_inst.global_position + Vector3.UP.cross(FORWARDS_RAY.get_collision_normal()), FORWARDS_RAY.get_collision_normal());
	else: # normal is vertical, therefore use RIGHT to generate perpendicularity
		bullet_hole_inst.look_at(bullet_hole_inst.global_position + Vector3.RIGHT.cross(FORWARDS_RAY.get_collision_normal()), FORWARDS_RAY.get_collision_normal());

	
	queue_free()
