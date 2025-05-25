class_name Bullet extends Node3D

@export var data:BulletData
@export var direction:Vector3;

@export var velocity:Vector3;
@export var origin_global_pos:Vector3;

@onready var FORWARDS_RAY:RayCast3D = $RayCast3D;

 #                     FLOOR + NPC + NPC_PHYSICS + Debris
const BULLET_HIT_MASK = 1+ 32 + 64 + 4096

var lifetime_start:int;
#var speed:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(data == null):
		push_error("Bullet instanced without data!")
		
		free()
		return
	
	lifetime_start = Time.get_ticks_msec()
	#initialise velocity.
	
	global_position = origin_global_pos;
	direction = direction.normalized()
	velocity = direction*data.speed;
	
	FORWARDS_RAY.target_position = Vector3(0,0,data.speed*1.5);
	FORWARDS_RAY.collision_mask = BULLET_HIT_MASK


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var time_passed = float(Time.get_ticks_msec() - lifetime_start) / float(data.lifetime)
	
	if(time_passed > 1.0): # time_passed is proportional
		queue_free();
	
	
	var speed = velocity.length()
	
	
	
	FORWARDS_RAY.look_at(global_position - velocity)
	FORWARDS_RAY.force_raycast_update()
	if((FORWARDS_RAY.get_collision_point() - global_position).length() < speed*delta and FORWARDS_RAY.get_collider() != null): # Going to hit an object.
		var hit_result = hit_object()
		if(hit_result == 1):#Ricochet
			
			var elapsed_time:float = (FORWARDS_RAY.get_collision_point() - global_position).length()/velocity.length()
			draw_trail(FORWARDS_RAY.get_collision_point() - global_position)
			global_position = FORWARDS_RAY.get_collision_point()
			_physics_process(delta - elapsed_time)

			
		elif hit_result == 2:#Terminate
			draw_trail(FORWARDS_RAY.get_collision_point() - global_position) # draws it only to the object
			queue_free() # Final escape
		
	else: #Normal procession
		draw_trail(velocity*delta)
		
		position += velocity*delta;
		
		#calculate next frames data
		velocity.y -= data.gravity*delta; # grav
		velocity *= (1-data.drag*delta)   # drag
		
	
	#DEBUG COSMETICS
	#$RayCast3D/RayVisualiser.position.z = -speed*delta/2 # This shows it better as it is moved previously. - but purely cosmetic
	#$RayCast3D/RayVisualiser.mesh.height = speed*delta;




func draw_trail(vector):
	var trail = preload("res://gameobjects/bullets/trail/bullet_trail.tscn").instantiate()
	trail.lifetime = 0.1;
	trail.segment_origin = global_position;
	trail.segment_end = global_position + vector;
	
	trail.material = data.trail_material;
	
	trail.up = Vector3.UP;
	get_tree().get_current_scene().add_child(trail);
	trail.global_position = global_position

	
	var trail2 = preload("res://gameobjects/bullets/trail/bullet_trail.tscn").instantiate()
	trail2.lifetime = 0.1;
	trail2.segment_origin = global_position;
	trail2.segment_end = global_position + vector;
	
	trail2.material = data.trail_material;
	
	trail2.up = Vector3.UP.cross(vector)
	get_tree().get_current_scene().add_child(trail2);
	trail2.global_position = global_position;


##Returns 1 for ricochet, 2 for termination
func hit_object() -> int:
	#print("Bullet hit " + str(FORWARDS_RAY.get_collision_point()))
	
	var angle:float = asin(-velocity.normalized().dot(FORWARDS_RAY.get_collision_normal()))
	var delta_v:Vector3;
	
	var result:int;
	
	if(angle < data.ricochet_angle):#Ricochet
		delta_v = -velocity.dot(FORWARDS_RAY.get_collision_normal())*FORWARDS_RAY.get_collision_normal() * (1.0+data.NEL_coefficient)
		velocity = delta_v # bounces it
		result = 1;
	else:
		delta_v = -velocity
		result = 2;
	
	var collider = FORWARDS_RAY.get_collider();
	var damage = data.damage * (delta_v.length()/data.speed)
	
	if(collider is Hittable):
		#print("hit with force: ", damage) # use this for figuring out how much damage needs doing
		collider.hit(damage) # 1/2mv^2
	
	
	if(collider is RigidBody3D):
		collider.apply_impulse(delta_v*data.mass, FORWARDS_RAY.get_collision_point())

	
	
	
	#add bullet hole
	var bullet_hole_inst = preload("res://gameobjects/bullets/hole/bullet_hole.tscn").instantiate()
	collider.add_child(bullet_hole_inst);
	Globals.RUBBISH_COLLECTOR.add_rubbish(bullet_hole_inst);
	bullet_hole_inst.global_position = FORWARDS_RAY.get_collision_point() + FORWARDS_RAY.get_collision_normal() * 0.01;
	if(FORWARDS_RAY.get_collision_normal().dot(Vector3.RIGHT) != 0):
		bullet_hole_inst.look_at(bullet_hole_inst.global_position + Vector3.UP.cross(FORWARDS_RAY.get_collision_normal()), FORWARDS_RAY.get_collision_normal());
	else: # normal is vertical, therefore use RIGHT to generate perpendicularity
		bullet_hole_inst.look_at(bullet_hole_inst.global_position + Vector3.RIGHT.cross(FORWARDS_RAY.get_collision_normal()), FORWARDS_RAY.get_collision_normal());
	
	bullet_hole_inst.rotate_object_local(Vector3.UP, randf()*2*PI) # make it random rotation
	
	return result
