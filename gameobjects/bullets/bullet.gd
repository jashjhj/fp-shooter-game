class_name Bullet extends Node3D

@export var data:BulletData
@export var direction:Vector3;

@export var velocity:Vector3;
@export var origin_global_pos:Vector3;

@export var ticks_per_process:int = 3;

@onready var FORWARDS_RAY:RayCast3D = $RayCast3D;

 #                     FLOOR + NPC + NPC_PHYSICS + NPC_HITTABLES + Debris
const BULLET_HIT_MASK = 1+ + 32 + 0 + 128 + 8192 + 16384 

var lifetime_start:int;

var prev_bullet_trail_pos:Vector3;


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
	FORWARDS_RAY.collide_with_areas = true
	
	prev_bullet_trail_pos = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



var tick_number = -0;
func _physics_process(delta: float) -> void:
	
	var time_passed = float(Time.get_ticks_msec() - lifetime_start) / 1000 / float(data.lifetime)
	
	if(time_passed > 1.0): # time_passed is proportional
		queue_free();
	
	tick_number += 1;
	if(tick_number % ticks_per_process != 0): # Only operate per nth tick
		delta *= ticks_per_process;
		process_bullet_step(delta, true)
	else:
		process_bullet_step(delta, false)
	





func process_bullet_step(delta:float, draw_trail:bool = false) -> void:
	
	
	FORWARDS_RAY.look_at(global_position - velocity*delta) # because forwards is -Z
	FORWARDS_RAY.force_raycast_update()
	if(FORWARDS_RAY.get_collider() != null): # Going to hit an object.
		var hit_result = hit_object()
		
		if(hit_result == 1):#Ricochet
			
			
			global_position = FORWARDS_RAY.get_collision_point()
			
			draw_trail(prev_bullet_trail_pos, FORWARDS_RAY.get_collision_point())
			prev_bullet_trail_pos = global_position
			
			var elapsed_time:float = (FORWARDS_RAY.get_collision_point() - global_position).length()/velocity.length()
			process_bullet_step(delta - elapsed_time, false) # Recurse
			
			
		elif hit_result == 2:#Terminate
			draw_trail(prev_bullet_trail_pos, FORWARDS_RAY.get_collision_point()) # draws it only to the object
			queue_free() # Final escape
		
	else: #Normal procession
		
		position += velocity*delta;
		
		if(draw_trail):
			draw_trail(prev_bullet_trail_pos, global_position)
		
		
		#calculate next frames data
		velocity.y -= data.gravity*delta; # grav
		velocity *= (1-data.drag*delta)   # drag
		
	
	#DEBUG COSMETICS
	#$RayCast3D/RayVisualiser.position.z = -speed*delta/2 # This shows it better as it is moved previously. - but purely cosmetic
	#$RayCast3D/RayVisualiser.mesh.height = speed*delta;


var current_ricochet:int = 0;
var max_ricochets:int = 20;

##Returns 1 for ricochet, 2 for termination

func hit_object() -> int:
	#print("Bullet hit " + str(FORWARDS_RAY.get_collision_point()))
	var collision_normal:Vector3 = FORWARDS_RAY.get_collision_normal()
	
	var angle:float = asin(-velocity.normalized().dot(collision_normal))
	var delta_v:Vector3;
	
	var result:int = 2;
	
	if(angle < data.ricochet_angle):#Ricochet
		#print(collision_normal)
		delta_v = velocity.dot(collision_normal)*collision_normal * -(1.0+data.NEL_coefficient)
		#print(delta_v)
		velocity += delta_v # bounces it
		
		current_ricochet += 1
		if(current_ricochet < max_ricochets):  # check to prevent infintie ricochets
			result = 1;
		else:
			result = 2;
	else:
		delta_v = -velocity
		result = 2;
	
	var collider = FORWARDS_RAY.get_collider();
	var damage = data.damage * (delta_v.length()/data.speed)
	
	
	
	var impulse = -delta_v*data.mass
	var impulse_pos = FORWARDS_RAY.get_collision_point()
	
	
	if(collider is Hittable_StaticBody):
		for hittable in collider.HIT_COMPONENTS:
			if(hittable != null):
				hittable.trigger(damage, impulse, impulse_pos);
	
	elif(collider is Hittable_Collider):
		for hittable in collider.HIT_COMPONENTS:
			if(hittable != null):
				hittable.trigger(damage, impulse, impulse_pos);
	
	elif(collider is RigidBody3D):
		if(collider is Hittable_RB):
			for hittable in collider.HIT_COMPONENTS:
				if(hittable != null):
					hittable.trigger(damage, impulse, impulse_pos);
		
		else: # Just a plain RB3D no Hittable
			
			collider.apply_impulse(impulse, impulse_pos - collider.global_position)
	
	
	#add bullet hole
	var bullet_hole_inst = preload("res://gameobjects/bullets/hole/bullet_hole.tscn").instantiate()
	collider.add_child(bullet_hole_inst);
	Globals.RUBBISH_COLLECTOR.add_rubbish(bullet_hole_inst);
	bullet_hole_inst.global_position = FORWARDS_RAY.get_collision_point() + collision_normal * 0.01;
	if(collision_normal.dot(Vector3.RIGHT) != 0):
		bullet_hole_inst.look_at(bullet_hole_inst.global_position + Vector3.UP.cross(collision_normal), collision_normal);
	else: # normal is vertical, therefore use RIGHT to generate perpendicularity
		bullet_hole_inst.look_at(bullet_hole_inst.global_position + Vector3.RIGHT.cross(collision_normal), collision_normal);
	
	bullet_hole_inst.rotate_object_local(Vector3.UP, randf()*2*PI) # make it random rotation
	
	return result






##vector is from current pos
func draw_trail(origin:Vector3, end:Vector3):
	var quality = 2;
	
	var dist_2_to_player = (origin - Globals.PLAYER.global_position).length_squared()
	if dist_2_to_player > 2500: #>50m away, dont render mesh
		return;
	
	if(dist_2_to_player < 16): # < 4m
		quality = 8
	elif(dist_2_to_player < 64): # < 8m 
		quality = 4
	else:
		quality = 2;
	
	print(quality)
	
	for i in range(0, quality):
		var trail = preload("res://gameobjects/bullets/trail/bullet_trail.tscn").instantiate()
		
		trail.lifetime = 0.1;
		trail.segment_origin = origin;
		trail.segment_end = end;
		
		trail.material = data.trail_material;
		
		trail.up = Vector3.UP.rotated((end - origin).normalized(), ((PI) / float(quality)) * (i));
		get_tree().get_current_scene().add_child(trail);
		trail.global_position = origin
	#
	#var trail2 = preload("res://gameobjects/bullets/trail/bullet_trail.tscn").instantiate()
	#trail2.lifetime = 0.1;
	#trail2.segment_origin = origin;
	#trail2.segment_end = end;
	#
	#trail2.material = data.trail_material;
	#
	#trail2.up = Vector3.UP.cross(end - origin)
	#get_tree().get_current_scene().add_child(trail2);
	#trail2.global_position = origin;
