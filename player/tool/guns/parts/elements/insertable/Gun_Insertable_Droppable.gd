class_name Gun_Insertable_Droppable extends Gun_Insertable

#Upon being dropped, reparents whole object to the assigned rigidbody adn adds it as rubbish globally to scene.


@export var RIGIDBODY:RigidBody3D;


##Ready
func _ready():
	super._ready();
	RIGIDBODY.process_mode = Node.PROCESS_MODE_DISABLED
	RIGIDBODY.collision_mask = 1 + 8192;
	RIGIDBODY.collision_layer = 4096


var prev_pos:Vector3;
var prev_angles:Vector3;
var pre_prev_pos:Vector3;
var pre_prev_angles:Vector3;
var prev_delta:float;
func _physics_process(delta: float) -> void:
	pre_prev_pos = prev_pos;
	pre_prev_angles = prev_angles
	prev_pos = MODEL.global_position;
	prev_angles = MODEL.global_rotation;
	prev_delta = delta

func disable_focus():
	super.disable_focus();
	if(!is_housed):
		is_focusable = false;
		RIGIDBODY.reparent(get_tree().get_current_scene())
		RIGIDBODY.global_transform = MODEL.global_transform
		
		for child in get_children():
			if child != RIGIDBODY:
				child.reparent(RIGIDBODY)
		
		RIGIDBODY.linear_velocity = (prev_pos - pre_prev_pos)/prev_delta
		RIGIDBODY.angular_velocity = (prev_angles - pre_prev_angles)/prev_delta * 3 # Dramatises angles. fun!
		
		Globals.RUBBISH_COLLECTOR.add_rubbish(RIGIDBODY);
		
		RIGIDBODY.process_mode = Node.PROCESS_MODE_INHERIT;
		queue_free()
