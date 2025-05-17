class_name Gun_Part_Insertable extends Gun_Part_Interactive
##Magazine/Bullet/clip etc.
@export var INSERTABLE_OBJECT: Gun_Insertable;

@export var INSERTION_DIRECTION:Vector3 = Vector3.UP;
@export var INSERTION_PLANE_NORMAL:Vector3 = Vector3.LEFT;
@export var INSERTION_LENGTH:float = 0.1;

@export var INSERTION_ENTRY_AREA:Area3D;
@export var OFFSET_NOT_IN_ENTRY:float = 0.02;

@export var HOUSED_TOLERANCE:float = 0.001

##Area in which it can be extracted from, when sunk.
var PULL_FROM_AREA:Area3D;


const INSERTION_LAYER = 262144 # 2^18 = layer 19

var insertable_goal:Node3D = Node3D.new();
var insertable_lerp_rate = 0.3;

##Actually correctly hosued within the place.
var housed:bool = false:
	set(value):
		housed = value;
		housed_set()

func housed_set():pass;

##Within the inserted area, not yet fully housed.
var populated:bool = false:
	set(value):
		populated = value;
		if(populated):
			pass
		else:
			set_begin_interact_insertable()

var insertion_in_progress:bool = false;
var is_locked:bool = false:
	set(value):
		is_locked = value;
		if(is_locked and housed):
			#make uninteractive
			INSERTABLE_OBJECT.GRABBABLE_AREA.collision_layer = 0;
		else:
			set_begin_interact_insertable()

var start_focus_offset:Vector3;





func set_begin_interact_insertable():
	BEGIN_INTERACT_COLLIDER = INSERTABLE_OBJECT.GRABBABLE_AREA;
	INSERTABLE_OBJECT.GRABBABLE_AREA.collision_layer = BEGIN_INTERACT_COLLISION_LAYER;
	PULL_FROM_AREA.collision_layer = 0;

#Basically never
func set_begin_interact_pull_area():
	BEGIN_INTERACT_COLLIDER = PULL_FROM_AREA;
	PULL_FROM_AREA.collision_layer = BEGIN_INTERACT_COLLISION_LAYER;
	INSERTABLE_OBJECT.GRABBABLE_AREA.collision_layer = 0;


##Ready
func _ready():
	#INSERTABLE_OBJECT.get_parent().
	add_child(insertable_goal);
	#insertable_goal.global_position = INSERTABLE_OBJECT.global_position
	
	PULL_FROM_AREA = BEGIN_INTERACT_COLLIDER;
	set_begin_interact_insertable()
	super._ready();
	
	
	call_deferred("setup_plane");
	
	assert(INSERTABLE_OBJECT != null, "Insertable part's object not set.")
	#INSERTABLE_OBJECT.grabbed.connect(object_grabbed)
	#INSERTABLE_OBJECT.ungrabbed.connect(object_ungrabbed)
	

var plane_normal:Vector3;
func setup_plane():
	#Initialises the plane. Requires parent's position, so must be called deferred.
	plane_normal = INSERTION_PLANE_NORMAL.normalized()
	
	set_interact_plane_normal(plane_normal)
	INTERACT_PLANE.position = Vector3.ZERO;

var insertion:float = -999;
func _process(delta:float) -> void:
	super._process(delta);
	
	#Debug.point(insertable_goal.global_position, 0.1);
	
	if(is_focused):
		
		# Update target
		insertable_goal.global_position = global_position + get_mouse_plane_position() - start_focus_offset
		insertable_goal.look_at(insertable_goal.global_position + global_basis*(INSERTION_DIRECTION), Vector3.UP);
		insertable_goal.rotate_object_local(Vector3.LEFT, PI/2)
		insertable_goal.transform = insertable_goal.transform.orthonormalized()
		
		
		
		var in_collider:bool = get_viewport().get_camera_3d().get_ray_from_camera_through(insertable_goal.global_position, 2, INSERTION_LAYER).get_collider() == INSERTION_ENTRY_AREA;
		
		if(!insertion_in_progress):
			insertion = -999;
			if(in_collider and !is_locked):
				insertion_in_progress = true;
				
				#insertable_goal.position = insertion * INSERTION_DIRECTION.normalized();
				
				#Interact plane to move
				INTERACT_PLANE.position = Vector3.ZERO;
			else:
				#pass
				INTERACT_PLANE.position = OFFSET_NOT_IN_ENTRY * (basis*plane_normal);
			
			populated = false;
			housed = false;
		else: # Inserting ...
			insertion = INSERTION_DIRECTION.normalized().dot(insertable_goal.position);
			if(insertion < 0 and !in_collider): # if out of collider and uninserted
				insertion_in_progress = false;
			else:
				insertion = min(insertion, INSERTION_LENGTH);
				insertable_goal.position = insertion * INSERTION_DIRECTION.normalized();
				
				
			populated = insertion >= 0 # Popuated if inserted at all
			housed = insertion >= INSERTION_LENGTH - HOUSED_TOLERANCE # Housed if fully housed, including tolerance
		
		
		
		#Update actual object to follow target.
		INSERTABLE_OBJECT.global_position = INSERTABLE_OBJECT.global_position.lerp(insertable_goal.global_position, insertable_lerp_rate);
		INSERTABLE_OBJECT.global_basis = Basis(Quaternion(INSERTABLE_OBJECT.global_basis).slerp(Quaternion(insertable_goal.global_basis),insertable_lerp_rate)); # Lerp rotation
		
	
	optional_extras()


func object_grabbed():
	pass
func object_ungrabbed():
	pass

var first_time:bool = true;
#Enable and disable being clicked on
func enable_focus():
	if(first_time):
		first_time = false;
		insertable_goal.global_position = global_position + get_mouse_plane_position()
	
	#INSERTABLE_OBJECT.reparent(self)
	insertable_goal.reparent(self)
	
	INSERTION_ENTRY_AREA.collision_layer = INSERTION_LAYER;
	start_focus_offset = get_mouse_plane_position() + global_position - insertable_goal.global_position


func disable_focus():
	INSERTION_ENTRY_AREA.collision_layer = 0;
	if(populated):
		INSERTABLE_OBJECT.reparent(self)
		insertable_goal.reparent(self)
	else:
		INSERTABLE_OBJECT.reparent(PARENT_GUN)
		insertable_goal.reparent(PARENT_GUN)


## OPTIONAL EXTRAS

@export_group("Optional Extras")
@export var IMPOSED_LIMITS_ROTATEABLES:Array[Gun_Action_Rotateable_Impose_Limit];
@export var WHEN_WITHIN_LIMITS: Array[Vector2];

func optional_extras():
	var i = 0;
	for limits_set in WHEN_WITHIN_LIMITS:
		if(len(IMPOSED_LIMITS_ROTATEABLES) <= i):
			push_warning("Limits set, but no correlating limits object")
			return
		elif(IMPOSED_LIMITS_ROTATEABLES[i] == null):
			push_warning("Limits set, but no correlating limits object")
			return
		else:
			if insertion >= limits_set.x and insertion <= limits_set.y:
				IMPOSED_LIMITS_ROTATEABLES[i].ACTIVE = true;
			else:
				IMPOSED_LIMITS_ROTATEABLES[i].ACTIVE = false;
		i += 1;
