class_name Physics_Lerper extends Node

@export var RIGIDBODY:RigidBody3D;
##Optional: This must be a child of RIGIDBODY. It acts as the source of the force & relevant calculations.      
##|      I recommend that if using this as the only source of forces on an object, and no PEG is set, enable angular damping on RIGIDBODY.
##|      Contains issues with predicting and cancelling angular momentum.
@export var RIGIDBODY_PEG:Node3D;
@export var enabled:bool = true;
@export var TARGET:Node3D;

##Stable up to ~ 1000ms-2 acceleration
@export var FORCE:float = 7.0;
##Backup force to un-counter forces (e.g. Gravity)
@export var RESERVE_FORCE:float = 20;
##Value for how much the object should bounce, like a spring, damped to the end. Bigger is more bouncy
@export var BOUNCINESS:float = 1.0;
##If (this) close, consider it there.
@export var SLOP:float = 0.01;





var corrective_force:Vector3;

var last_force:Vector3;
var last_velocity:Vector3;
func apply_forces(delta:float) -> Vector3:
	var force = calculate_forces(delta);
	
	if(RIGIDBODY_PEG != null):
		RIGIDBODY.apply_force(force, RIGIDBODY_PEG.global_position - RIGIDBODY.global_position)
	else:
		RIGIDBODY.apply_central_force(force)
	
	return force

##Pos is global
func apply_forces_from_pos(delta:float, pos:Vector3) -> Vector3:
	var force = calculate_forces_from_pos(delta, pos);
	
	if(RIGIDBODY_PEG != null):
		RIGIDBODY.apply_force(force, RIGIDBODY_PEG.global_position - RIGIDBODY.global_position)
	else:
		RIGIDBODY.apply_central_force(force)
	
	return force

##Pos is global
func calculate_forces_from_pos(delta:float, pos:Vector3) -> Vector3:
	#Creates new target temporarily at position in order to calculate from there.
	
	var old_targ = TARGET.duplicate()
	TARGET = Node3D.new()
	TARGET.global_position = pos
	
	var result = calculate_forces(delta)
	
	TARGET = old_targ
	return result

##Should be called once per physics process, to calculate the forces. TODO: Add option to shortcut through function when ZERO to reset, maybe if delta == 0?
func calculate_forces(delta:float) -> Vector3:
	if(RIGIDBODY == null): return Vector3.ZERO
	if(TARGET == null): 
		push_warning("Attempted to calculate forces with no target set.")
		return Vector3.ZERO
	
	#Identifiers
	var mass:float = RIGIDBODY.mass;
	var velocity:Vector3;
	var pos:Vector3;
	
	if(RIGIDBODY_PEG != null): # Calculates Velocities/Positions
		#Velocity is local to the point on the rigidbody.  ----------- This is magic that calculates local linear vlocity of a spinning object ----------
		#However, there is no suitable PID calculation to actually compnsate for this. So, best elft undone :(.
		velocity = RIGIDBODY.linear_velocity# + RIGIDBODY.angular_velocity.cross(RIGIDBODY_PEG.global_position - RIGIDBODY.global_position)
		pos = RIGIDBODY_PEG.global_position
	else:
		velocity = RIGIDBODY.linear_velocity;
		pos = RIGIDBODY.global_position
	
	
	
	var delta_pos = TARGET.global_position - pos
	
	
	if(delta_pos.length() < SLOP):
		delta_pos = Vector3.ZERO#This works as delta_pos.normalised = (0,0,0)

	
	## Maximum velocity function to wind up @ target. Scalar.
	var max_deceleration = FORCE/RIGIDBODY.mass
	# Using v^2 = u^2 + 2as  =>  u = sqrt(2as) (+v=0)
	var maximum_velocity:float = sqrt(abs(2 * delta_pos.length() * max_deceleration)) 
	maximum_velocity *= BOUNCINESS
	var velocity_along_delta = velocity.dot(delta_pos.normalized()) * delta_pos.normalized()
	
	var force_to_apply:Vector3 = delta_pos.normalized() * FORCE # Initial setting for calculations. Checked in IF statement
	
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
	
	
	##And again for perpendicular
	#Maxmim velocity is constant as its proportional to distance
	var p_velocity:Vector3 = velocity - velocity_along_delta;
	var p_force_to_apply:Vector3 = (-p_velocity).normalized() * FORCE * min(1.0, velocity_along_delta.length()) # uses length as a limit so it doesnt overpower
	
	var p_prospective_dv:Vector3 = (p_force_to_apply / mass) * delta
	var p_prospective_speed:Vector3 = p_velocity + p_prospective_dv
	

	
	if(not p_prospective_speed.length() > maximum_velocity):
		force_to_apply += p_force_to_apply
	else:
		var goal_v:Vector3 = Vector3.ZERO
		var goal_dv:Vector3 = goal_v - p_prospective_speed
		
		#Attempt to apply goal_dv
		var goal_force:Vector3 = (goal_dv*mass) / delta
		if(goal_force.length() > FORCE):
			goal_force = goal_force.normalized() * FORCE
		
		
		force_to_apply += goal_force
	
	
	#Lost force caluclations to counter gravity - TODO REDO to consider unexpected DVs correctly
	var lost_impulse = last_force*delta - mass*(velocity - last_velocity)
	var lost_force_mag = lost_impulse.length() / delta
	lost_force_mag = min(RESERVE_FORCE, lost_force_mag)
	var appliable_lost_force:Vector3 = lost_impulse.normalized() * lost_force_mag
	if(appliable_lost_force.length() > RESERVE_FORCE):
		appliable_lost_force = appliable_lost_force.normalized() * RESERVE_FORCE # Caps it where necessary
	
	last_velocity = velocity;
	last_force = force_to_apply + appliable_lost_force;
	
	
	return force_to_apply + appliable_lost_force


func _physics_process(delta: float) -> void:
	if(enabled):
		if(TARGET != null):
			apply_forces(delta)


 
