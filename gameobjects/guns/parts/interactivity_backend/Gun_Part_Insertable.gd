class_name Gun_Part_Insertable extends Gun_Part_Interactive
##Magazine/Bullet/clip etc.
@export var INSERTABLE_OBJECT: Gun_Insertable;

@export var INSERTION_DIRECTION:Vector3 = Vector3.UP;
@export var INSERTION_PLANE_NORMAL:Vector3 = Vector3.LEFT;
@export var INSERTION_LENGTH:float = 0.1;

@export var INSERTION_ENTRY_AREA:Area3D;

@export var OFFSET_NOT_IN_ENTRY:float = 0.05;

##Area in which it can be extracted from, when sunk.
var PULL_FROM_AREA:Area3D;


const INSERTION_LAYER = 262144 # 2^18 = layer 19

var insertable_goal:Node3D = Node3D.new();
var insertable_lerp_rate = 0.5;



var populated:bool = false:
	set(value):
		populated = value;
		if(populated):
			set_begin_interact_pull_area()
		else:
			set_begin_interact_insertable()

var insertion_in_progress:bool = false;

func set_begin_interact_insertable():
	BEGIN_INTERACT_COLLIDER = INSERTABLE_OBJECT.GRABBABLE_AREA;
	INSERTABLE_OBJECT.GRABBABLE_AREA.collision_layer = BEGIN_INTERACT_COLLISION_LAYER;
	PULL_FROM_AREA.collision_layer = 0;
func set_begin_interact_pull_area():
	BEGIN_INTERACT_COLLIDER = PULL_FROM_AREA;
	PULL_FROM_AREA.collision_layer = BEGIN_INTERACT_COLLISION_LAYER;
	INSERTABLE_OBJECT.GRABBABLE_AREA.collision_layer = 0;


##Ready
func _ready():
	add_child(insertable_goal);
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

func _process(delta:float) -> void:
	super._process(delta);
	
	
	if(is_focused):
		
		# Update target
		insertable_goal.global_position = global_position + get_mouse_plane_position()
		insertable_goal.look_at(insertable_goal.global_position + global_basis*(INSERTION_DIRECTION), Vector3.UP);
		insertable_goal.rotate_object_local(Vector3.LEFT, PI/2)
		insertable_goal.transform = insertable_goal.transform.orthonormalized()
		
		
		var insertion:float = INSERTION_DIRECTION.normalized().dot(insertable_goal.position);
		var in_collider:bool = get_viewport().get_camera_3d().get_mouse_ray(2, INSERTION_LAYER).get_collider() == INSERTION_ENTRY_AREA;
		
		if(!insertion_in_progress):
			if(in_collider):
				insertion_in_progress = true;
				
				insertable_goal.position = insertion * INSERTION_DIRECTION.normalized();
				
			else:
				insertable_goal.position += OFFSET_NOT_IN_ENTRY * (basis*plane_normal);
			
		else: # Inserting ...
			if(insertion < 0 and !in_collider): # if out of collider and uninserted
				insertion_in_progress = false;
			else:
				insertion = min(insertion, INSERTION_LENGTH);
				insertable_goal.position = insertion * INSERTION_DIRECTION.normalized();
				
				if(insertion == INSERTION_LENGTH):
					populated = true;
				else:
					populated = false;
		
		
		
		
		#Update actual object to follow target.
		INSERTABLE_OBJECT.global_position = INSERTABLE_OBJECT.global_position.lerp(insertable_goal.global_position, insertable_lerp_rate);
		INSERTABLE_OBJECT.global_basis = Basis(Quaternion(INSERTABLE_OBJECT.global_basis).slerp(Quaternion(insertable_goal.global_basis),insertable_lerp_rate)); # Lerp rotation
		
	
	


func object_grabbed():
	pass
func object_ungrabbed():
	pass


#Enable and disable being clicked on
func enable_focus():
	INSERTION_ENTRY_AREA.collision_layer = INSERTION_LAYER;
	INSERTABLE_OBJECT.reparent(PARENT_GUN)

func disable_focus():
	INSERTION_ENTRY_AREA.collision_layer = 0;
	if(populated):
		INSERTABLE_OBJECT.reparent(self)
	else:
		INSERTABLE_OBJECT.reparent(PARENT_GUN)
