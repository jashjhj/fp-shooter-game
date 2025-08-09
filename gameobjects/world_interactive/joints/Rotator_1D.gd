class_name Rotator_1D extends Body_Segment

@export_category("Rotation axis = around the local Y+")

enum ROTATOR_1D_MODE{
	TARGETING,
	MOTOR
	
}

@export var MODE:ROTATOR_1D_MODE = ROTATOR_1D_MODE.TARGETING


@export_group("Rotation Settings")
##Maximum degrees/Second
@export_range(0, 3600, 0.1, "radians_as_degrees") var ROTATION_MAX_SPEED:float = PI/3.0;
##In degrees/second/second
@export_range(0, 3600, 0.1, "radians_as_degrees") var ROTATION_ACCELERATION:float = 10.0*PI/9.0;
##In degrees/second/second. This is always applied, e.g. can stop motor after ACCELERATION IS DISABLED
@export_range(0, 3600, 0.1, "radians_as_degrees") var ROTATION_DECELERATION:float = PI/9.0;

@export var ANGLE_LIMITS_ENABLED:bool = false
@export_range(-180, 180, 1.0, "radians_as_degrees") var MIN_ANGLE = -PI/4; 
@export_range(-180, 180, 1.0, "radians_as_degrees") var MAX_ANGLE = PI/4;

@export var LIMIT_RESTITUTION_COEFFICIENT:float = 0.1;

##Amount of slop allowed. If Zero, does the ebst it can without jittering.
@export_range(0, 30, 0.1, "radians_as_degrees") var SLOP:float = 0.0;



@export var IS_ACTIVE:bool = true;

@export_group("Optional Settings")
@export var ATTACHED_RB:RigidBody3D;
##Also used for rotational impulses from super class.
@export var SIMULATED_MASS_ABOVE:float = 1.0;

@export var SFX:AudioStreamPlayer3D;
var default_sfx_volume:float;

@export var DEBUG_AXES:bool = false;



@onready var _initial_max_speed:float = ROTATION_MAX_SPEED
@onready var _initial_acceleration:float = ROTATION_ACCELERATION


var current_angle:float = 0.0;
var current_speed:float = 0.0;

##A vector representing which way this Rotator_1D should look towards (-z) || In GLOBAL Space
var target:Vector3:
	set(v):
		target = v;
		#Cannot set target-global as leads to inf. recursion. Also no need as thats onyl really extenral for convenience ofs etting
		#target_global = v + global_position

##Abject global position of the target.
var target_global:Vector3:
	set(v):
		target_global = v;
		target = v - global_position

func _ready() -> void:
	super()
	target = Vector3.INF
	if(IMPULSE_PROPOGATOR != null): IMPULSE_PROPOGATOR.on_hit.connect(take_torque_impulse)
	
	if(SFX != null):
		SFX.playing = true;
		SFX.autoplay = true
		default_sfx_volume = SFX.volume_linear


func _process(delta: float) -> void:
	if(SFX != null):
		SFX.volume_linear = default_sfx_volume * (abs(current_speed)/_initial_max_speed)**2



func _physics_process(delta: float) -> void:
	if(!IS_ACTIVE): return

	var delta_angle:float;
	var delta_angular_velocity:float;
	
	if(MODE == ROTATOR_1D_MODE.TARGETING):
		if(target == Vector3.INF): return
		#                                           target component that is perpendiculr to basis.y
		var target_angle = global_basis.z.signed_angle_to(target - global_basis.y* target.dot(global_basis.y), global_basis.y)
		
		
		
		if(DEBUG_AXES):
			DebugDraw3D.draw_position(global_transform)
			print(abs( target_angle ), " = angle, speed = ", ROTATION_MAX_SPEED * delta)
		
		#ROTATION CODE
		
		if(current_angle + target_angle > MAX_ANGLE): # Add limits
			target_angle = MAX_ANGLE - current_angle
		elif current_angle - target_angle < MIN_ANGLE:
			target_angle = MIN_ANGLE - current_angle
		
		
		var max_speed:float = sqrt(abs(2*target_angle * (ROTATION_ACCELERATION + ROTATION_DECELERATION))) * 0.8
		
		max_speed = min(max_speed, ROTATION_MAX_SPEED)
		delta_angular_velocity = ROTATION_ACCELERATION * delta * sign(target_angle);
		delta_angular_velocity += ROTATION_DECELERATION * delta * -sign(current_speed); # Apply deceleration
		
		if(abs(current_speed + delta_angular_velocity) > max_speed):
			
			var goal_dv = sign(target_angle)*max_speed - (current_speed)
			delta_angular_velocity = sign(goal_dv) * min(abs(goal_dv), ROTATION_ACCELERATION * delta) # accel to get it back to right speed
			
			#delta_angular_velocity = goal_dv
			#current_speed = sign(target_angle)*max_speed
			#delta_angular_velocity = 0
			#Limit it abck down to max accel
			#delta_angular_velocity = sign(delta_angular_velocity) * min(ROTATION_ACCELERATION * delta, abs(delta_angular_velocity))
		
		
	elif(MODE == ROTATOR_1D_MODE.MOTOR):
		delta_angular_velocity = ROTATION_ACCELERATION * delta
		if(abs(current_speed + delta_angular_velocity) > abs(ROTATION_MAX_SPEED)):
			delta_angular_velocity = ROTATION_MAX_SPEED - current_speed
	
	
	# Add speed and velocities
	current_speed += delta_angular_velocity/2
	delta_angle = current_speed * delta  # half either side for bad integration
	current_speed += delta_angular_velocity/2
	
	if(ANGLE_LIMITS_ENABLED):
		if(current_angle + delta_angle > MAX_ANGLE):
			delta_angle = MAX_ANGLE - current_angle
			current_angle = MAX_ANGLE
			current_speed = current_speed * -LIMIT_RESTITUTION_COEFFICIENT # boucne back
			
		elif(current_angle + delta_angle < MIN_ANGLE):
			delta_angle = MIN_ANGLE - current_angle
			current_angle = MIN_ANGLE
			current_speed = current_speed * -LIMIT_RESTITUTION_COEFFICIENT # bounce back
			
		else:
			current_angle += delta_angle
	else: # if no limits set:
		pass
		#IDK why this breaks if i set it
		#current_angle += delta_angle
	
	rotate(basis.y, delta_angle)
	
	if(ATTACHED_RB != null): # Equal and opposite type stuff
		ATTACHED_RB.apply_torque(-delta_angular_velocity * global_basis.y * SIMULATED_MASS_ABOVE)
	
	spin(delta_angle)

##Called every frame _process()
func spin(delta_angle:float):
	pass
	

func take_torque_impulse():
	var impulse_offset:Vector3 = IMPULSE_PROPOGATOR.last_impulse_pos - global_position
	var impulse_component:float = IMPULSE_PROPOGATOR.last_impulse.dot(global_basis.y.cross(impulse_offset).normalized())
	#perp-to-axis length component
	var impulse_perp_dist:float = (impulse_offset - global_basis.y * impulse_offset.dot(global_basis.y)).length()
	
	var dv_to_apply = impulse_perp_dist * impulse_component / SIMULATED_MASS_ABOVE
	var angular_velocity = dv_to_apply / impulse_perp_dist
	current_speed += angular_velocity
