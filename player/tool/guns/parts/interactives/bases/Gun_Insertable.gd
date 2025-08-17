class_name Gun_Insertable extends Gun_Part_Interactive

##Everything that should move with the model, should be a child of MODEL.
@export var MODEL:Node3D;

@export var PLANE_NORMAL:Vector3 = Vector3(0, 0, 1)

@export var LERP_RATE_LINEAR:float = 0.5;
@export var LERP_RATE_ANGULAR:float = 0.1;

@export var HIDES_MOUSE:bool = true;

@export var MODEL_OFFSET:Vector3 = Vector3(0.0, 0.0, 0)
@export var DEFAULT_DIRECTION:Vector3 = Vector3.UP;

@export_group("Flags")
@export_flags("1","2","4","8","16","32","64") var INSERTION_ACCEPTANCE:int = 1;

#Consts & helper objects
const INSERTION_AREA_LAYER = 262144 # 2^18 = layer 19
const INSERTION_PLANE_LAYER:int = 524288

var INSERTION_PLANE:Area3D

var insertable_position:Node3D = Node3D.new() # The insertable's insertion point
var model_goal:Node3D = Node3D.new() # The goal of the model, usually a relative offset to the insertable_position


#Variables
#In local space from model_goal;
var start_focus_mouse_difference:Vector3;
var is_housed:bool = false;

var CURRENT_SLOT:Gun_Part_Insertable_Slot;



func _ready():
	PLANE_NORMAL = PLANE_NORMAL.normalized()
	super._ready();
	
	add_child(insertable_position)
	add_child(model_goal);
	
	var insertion_tools = load("res://player/tool/guns/parts/interactives/Gun_Part_Tools.tscn").instantiate()
	add_child(insertion_tools)
	INSERTION_PLANE = insertion_tools.INTERACT_PLANE;
	INSERTION_PLANE.collision_layer = INSERTION_PLANE_LAYER;
	INSERTION_PLANE.process_mode = Node.PROCESS_MODE_DISABLED;
	
	set_interact_plane_normal(PLANE_NORMAL);
	
	
	
	insertable_position.global_position = MODEL.global_position
	model_goal.transform = MODEL.transform;
	assert(MODEL != null, "No model set.")



func enable_focus():
	INSERTION_PLANE.process_mode = Node.PROCESS_MODE_INHERIT;
	if(HIDES_MOUSE): Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	
	insertable_position.global_position = model_goal.global_position
	var mouse_click_position := get_mouse_plane_position() - global_position;
	var insertable_visual_position := screen_raycast(model_goal.global_position, PLANE_COLLISION_LAYER).get_collision_point()
	#var insertable_position_distance_from_plane := (insertable_position.global_position - insertable_visual_position).dot(global_basis*PLANE_NORMAL) # this hsits borked
	
	insertable_position.global_position = insertable_visual_position# + insertable_position_distance_from_plane * (global_basis*PLANE_NORMAL);
	start_focus_mouse_difference = insertable_visual_position - (global_position + mouse_click_position)
	
	#Debug.point(insertable_visual_position, 1, Color(1, 0, 0, 0))
	#Debug.point(insertable_position.global_position, 1, Color(0, 1, 0, 0))

func disable_focus():
	INSERTION_PLANE.process_mode = Node.PROCESS_MODE_DISABLED;
	if(HIDES_MOUSE): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if(is_housed):
		MODEL.reparent(CURRENT_SLOT)
	else:
		MODEL.reparent(self)


func _process(delta:float) -> void:
	super._process(delta);
	
	if(is_focused):
		var effective_lerp_rate_linear := LERP_RATE_LINEAR
		var effective_lerp_rate_angular := LERP_RATE_ANGULAR;
		
		
		insertable_position.global_position = get_mouse_plane_position() + start_focus_mouse_difference;
		if(CURRENT_SLOT == null): # ---------------------- NO CURRENT SLOT
			
			
			var insertable_searcher:RayCast3D = get_viewport().get_camera_3d().get_ray_from_camera_through(insertable_position.global_position, 4, INSERTION_AREA_LAYER);
			if(insertable_searcher.get_collider() != null):
				var collider_parent = insertable_searcher.get_collider().get_parent()
				if(not collider_parent is Gun_Part_Insertable_Slot):
					push_error("Collider with layer 18 - INSERTION AREA LAYER - Not a child of an Insertable Slot", insertable_searcher.get_collider())
				collider_parent = collider_parent as Gun_Part_Insertable_Slot; #type casting
				
				#Condition for allowing a slot
				if(collider_parent.INSERTION_ACCEPTANCE & INSERTION_ACCEPTANCE != 0 and not collider_parent.is_locked and not collider_parent.is_housed): # if overlap, ie can be accepted
					CURRENT_SLOT = collider_parent;
					CURRENT_SLOT.housed_insertable = self;
			
			#Cosmetics
			model_goal.global_position = insertable_position.global_position;
			var new_basis:Basis = Basis.IDENTITY; # Look in direction of CurrentSlot
			new_basis.y = (global_basis*DEFAULT_DIRECTION).normalized()
			new_basis.z = (global_basis*PLANE_NORMAL).normalized()
			new_basis.x = new_basis.y.cross(new_basis.z);
			model_goal.global_basis = new_basis
			
		else: # ----------------------------------- CURRENT SLOT NOT NULL
			INSERTION_PLANE.global_position = CURRENT_SLOT.global_position;
			INSERTION_PLANE.look_at(INSERTION_PLANE.global_position + CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_PLANE_NORMAL)
			var insertion_plane_position:Vector3 = get_viewport().get_camera_3d().get_ray_from_camera_through(insertable_position.global_position, 4, INSERTION_PLANE_LAYER).get_collision_point();
			var insertion:float = (insertion_plane_position - CURRENT_SLOT.global_position).dot(CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_VECTOR);
			
			
			if(insertion >= 0): # If being inserted
				
				#SOme weird test i dont need regarding insertion angle checking
				#if(cos(CURRENT_SLOT.SLOT_ANGLE_TOLERANCE) > abs(MODEL.global_basis.y.dot(CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_VECTOR))):#If within tolerances for slot
					#insertion = min(0.0, insertion)
				#else:
				insertion = min(insertion, CURRENT_SLOT.INSERTION_LENGTH)
				effective_lerp_rate_angular = 0.9
				is_housed = true;
				CURRENT_SLOT.insertion = insertion
				#Move it in line with abrrel
				model_goal.global_position = CURRENT_SLOT.global_position + CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_VECTOR*insertion;
			else:
				is_housed = false;
				CURRENT_SLOT.insertion = 0;
				# Move closer to barrel                                     PARRALLEL                                                           PERPENDICULAR
				var perpendicular_vector:Vector3 = CURRENT_SLOT.global_basis*(CURRENT_SLOT.INSERTION_VECTOR.cross(CURRENT_SLOT.INSERTION_PLANE_NORMAL).normalized())
				var perpendicular_distance:float = (insertion_plane_position - CURRENT_SLOT.global_position).dot(perpendicular_vector)
				model_goal.global_position = CURRENT_SLOT.global_position + CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_VECTOR*insertion + CURRENT_SLOT.PULL_OBJECT_IN_FACTOR*500*(insertion*insertion)*perpendicular_vector*perpendicular_distance;
			
			CURRENT_SLOT.is_housed = is_housed
			
			var new_basis:Basis = Basis.IDENTITY; # Look in direction of CurrentSlot
			new_basis.y = (CURRENT_SLOT.global_basis*CURRENT_SLOT.basis.y).normalized()
			if(CURRENT_SLOT.FLIP_INSERTION):
				new_basis.y = -new_basis.y
			new_basis.z = (CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_PLANE_NORMAL).normalized()
			new_basis.x = new_basis.y.cross(new_basis.z);
			model_goal.global_basis = new_basis
			
			if(!is_housed): # if just come unhoused
				var insertable_searcher:RayCast3D = get_viewport().get_camera_3d().get_ray_from_camera_through(insertable_position.global_position, 4, INSERTION_AREA_LAYER);
				if(insertable_searcher.get_collider() == null):
					CURRENT_SLOT.insertion = 0; # Update current slot
					CURRENT_SLOT.is_housed = false;
					CURRENT_SLOT.housed_insertable = null;
					CURRENT_SLOT = null
		
		
		#End
		
		#Debug.point(insertable_position.global_position, 0.1, Color(0,0,1,0))
		#Debug.point(model_goal.global_position, 0.1, Color(1,0,1,0))
		
		MODEL.global_position = MODEL.global_position.lerp(model_goal.global_position, effective_lerp_rate_linear);
		MODEL.global_basis = Basis(Quaternion(MODEL.global_basis).slerp(Quaternion(model_goal.global_basis), effective_lerp_rate_angular)); # Lerp rotation



##Helper function.
func screen_raycast(pos:Vector3, mask:int) -> RayCast3D:
	var ray = get_viewport().get_camera_3d().get_ray_from_camera_through(pos, 4, mask);
	return ray;
