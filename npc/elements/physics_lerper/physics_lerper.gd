class_name Physics_Lerper extends Node

@export var RIGIDBODY:RigidBody3D;
@export var AUTO_TRIGGER:bool = false;
@export var AUTO_TRIGGER_NODE:Node3D;

##Stable up to ~ 1000ms-2 acceleration
@export var FORCE:float = 7.0;
@export var RESERVE_FORCE:float = 20;
##Value for how much the object should bounce
@export var BOUNCINESS:float = 1.0;
@export var SLOP:float = 0.01;

##Should be called once per physics process, to apply the forces.
@onready var max_deceleration = FORCE/RIGIDBODY.mass


#TODO Known issues:
#Orbiting when given right scenarios
#  - maybe act goal_force agaisnt it, rather than towards goal?
#

var corrective_force:Vector3;

var last_force:Vector3;
var last_velocity:Vector3;
func apply_forces(delta:float) -> void:
	if(RIGIDBODY == null): return
	
	#Identifiers
	var mass:float = RIGIDBODY.mass;
	#Velocity is local to the point on the rigidbody.
	var velocity:Vector3 = RIGIDBODY.linear_velocity
	var pos:Vector3 = RIGIDBODY.global_position
	
	
	
	var delta_pos = AUTO_TRIGGER_NODE.global_position - pos
	if(delta_pos.length() < SLOP):
		delta_pos = Vector3.ZERO # This works as delta_pos.normalised = (0,0,0)
		
	
	
	## Maximum velocity function to wind up @ target. Scalar.
	# Using v^2 = u^2 + 2as  =>  u = sqrt(2as) (+v=0)
	var maximum_velocity:float = sqrt(abs(2 * delta_pos.length() * max_deceleration)) 
	maximum_velocity *= BOUNCINESS
	var velocity_along_delta = velocity.dot(delta_pos.normalized()) * delta_pos.normalized()
	
	var force_to_apply:Vector3 = delta_pos.normalized() * FORCE
	
	var prospective_dv:Vector3 = (force_to_apply / mass) * delta
	var prospective_speed:Vector3 = velocity + prospective_dv
	
	if(prospective_speed.length() > maximum_velocity): # If going too fast / wrong direction?
		var goal_v:Vector3 = maximum_velocity*delta_pos.normalized()
		var goal_dv:Vector3 = goal_v - prospective_speed
		#Attempt to apply goal_dv
		var goal_force:Vector3 = (goal_dv*mass) / delta
		if(goal_force.length() > FORCE):
			goal_force = goal_force.normalized() * FORCE
		
		force_to_apply = goal_force
	
	
	
	
	#Lost force caluclations to counter gravity - TODO REDO to consider unexpected DVs correctly
	var lost_impulse = last_force*delta - mass*(velocity - last_velocity)
	var lost_force_mag = lost_impulse.length() / delta
	lost_force_mag = min(RESERVE_FORCE, lost_force_mag)
	var appliable_lost_force = lost_impulse.normalized() * lost_force_mag
	
	last_velocity = velocity;
	last_force = force_to_apply + appliable_lost_force;
	
	
	
	
	
	RIGIDBODY.apply_central_force(force_to_apply + appliable_lost_force)
	


func _physics_process(delta: float) -> void:
	if(AUTO_TRIGGER):
		apply_forces(delta)
