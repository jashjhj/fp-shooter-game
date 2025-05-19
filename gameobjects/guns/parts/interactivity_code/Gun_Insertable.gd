class_name Gun_Insertable extends Gun_Part_Interactive

const INSERTION_PLANE_LAYER:int = 524288

const INSERTION_LAYER = 262144 # 2^18 = layer 19

@export var MODEL:Node3D;
@export var PLANE_NORMAL:Vector3 = Vector3.FORWARD
@export var INSERTION_PLANE_DEPTH:float = 0;

@export var DEFAULT_DIRECTION:Vector3 = Vector3.UP;

##This is optional, helps with smoothing & interpolation
@export var NEARBY_SLOTS:Array[Gun_Part_Insertable_Slot]



@export_group("Flags")
@export_flags("1","2","4","8","16","32","64") var INSERTION_ACCEPTANCE:int = 0;


var projected_position:Node3D = Node3D.new();
var model_goal:Node3D = Node3D.new();
var lerp_rate_linear := 0.3;
var lerp_rate_angular := 0.1


var CURRENT_SLOT:Gun_Part_Insertable_Slot;
var ORIGINAL_PARENT:Node3D;
##Is it within a slot?
var is_housed:bool = false;

#var INSERTION_PLANE:Area3D



func _ready():
	ORIGINAL_PARENT = get_parent()
	add_child(projected_position);
	add_child(model_goal);
	#projected_position.global_position = INSERTABLE_OBJECT.global_position
	assert(MODEL != null, "No model set.")
	super._ready();
	
	
	
	call_deferred("setup_planes");
	
	
	
	#INSERTABLE_OBJECT.grabbed.connect(object_grabbed)
	#INSERTABLE_OBJECT.ungrabbed.connect(object_ungrabbed)


var insertion_plane_tools = preload("res://gameobjects/guns/parts/interactivity_code/Gun_Part_Tools.tscn").instantiate()
var plane_normal:Vector3;
func setup_planes():
	#Initialises the plane. Requires parent's position, so must be called deferred.
	plane_normal = PLANE_NORMAL.normalized()

	
	INTERACT_PLANE.global_position = global_position - INSERTION_PLANE_DEPTH*(global_basis*PLANE_NORMAL);
	set_interact_plane_normal(plane_normal)
	
	add_child(insertion_plane_tools)
	insertion_plane_tools.INTERACT_PLANE.process_mode = PROCESS_MODE_DISABLED
	assert(insertion_plane_tools != null, "Gun_Part_Tools does not exist @ `res://gameobjects/guns/parts/interactivity_code/Gun_Part_Tools.tscn`") # check
	insertion_plane_tools.INTERACT_PLANE.collision_layer = INSERTION_PLANE_LAYER;



#Process script

var insertion:float = -999;
func _process(delta:float) -> void:
	super._process(delta);
	
	#Debug.point(projected_position.global_position, 0.1); # DEBUG LINE
	
	if(is_focused):
		
		# Update target
		projected_position.global_position = global_position + get_mouse_plane_position() - start_focus_offset
		#projected_position.look_at(projected_position.global_position + global_basis*(INSERTION_DIRECTION), Vector3.UP);
		#projected_position.rotate_object_local(Vector3.LEFT, PI/2)
		projected_position.transform = projected_position.transform.orthonormalized()
		model_goal.transform = model_goal.transform.orthonormalized()
		
		model_goal.global_position = projected_position.global_position;
		
		var effective_lerp_rate_linear := lerp_rate_linear
		var effective_lerp_rate_angular := lerp_rate_angular;
		
		
		
		var nearest_slot:Gun_Part_Insertable_Slot = null; # Might be useful? for smoothing thigns out ?
		for slot in NEARBY_SLOTS:
			if nearest_slot == null: nearest_slot = slot;
			elif (slot.global_position - global_position).length() < (nearest_slot.global_position - global_position).length():
				nearest_slot = slot;
		
		var current_insertion_vector_global:Vector3;
		if(CURRENT_SLOT != null):
			current_insertion_vector_global = (CURRENT_SLOT.INSERTION_PATH.global_position - CURRENT_SLOT.global_position).normalized()
			
			
			if(insertion > 0): # Just entered a slot
				is_housed = true;
				CURRENT_SLOT.is_housed = true;
				CURRENT_SLOT.housed_insertable = self;
				
		
		
		
		#print(insertion)
		
		
		
		
		#var in_slot_collider:Area3D = get_viewport().get_camera_3d().get_ray_from_camera_through(MODEL.global_position, 2, INSERTION_LAYER).get_collider();
		var in_slot_collider:Area3D = get_viewport().get_camera_3d().get_ray_from_camera_through(MODEL.global_position, 2, INSERTION_LAYER).get_collider();
		if(!is_housed):
			if(in_slot_collider != null):
				if(not in_slot_collider.get_parent() is Gun_Part_Insertable_Slot):
					push_error("Gun_part_Insertable_Slot's Area3D not direct child @ " + str(in_slot_collider.get_parent()))
					return
				
				var new_slot:Gun_Part_Insertable_Slot = in_slot_collider.get_parent()
				if(new_slot.INSERTION_ACCEPTANCE & INSERTION_ACCEPTANCE != 0 and new_slot.is_housed == false): # If there is overlap, meaning can be inserted, and slot is free
					CURRENT_SLOT = new_slot
					
					
					#INTERACT_PLANE.reparent(CURRENT_SLOT);
					insertion_plane_tools.INTERACT_PLANE.global_position = CURRENT_SLOT.global_position;
					insertion_plane_tools.INTERACT_PLANE.look_at(CURRENT_SLOT.global_position + CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_PLANE_NORMAL, Vector3.FORWARD)
					
					
					#Cosmetics - Near slot
					if(current_insertion_vector_global != Vector3.ZERO): # Updates on the second frame, so wait.
						
						#projected_position.global_position = CURRENT_SLOT.global_position + insertion * current_insertion_vector_global; # make it closer to the slot
						
						
						projected_position.look_at(projected_position.global_position + global_basis*current_insertion_vector_global, Vector3.UP);
						projected_position.rotate(projected_position.basis.x, -PI/2)
						model_goal.global_position = get_viewport().get_camera_3d().get_ray_from_camera_through(projected_position.global_position, 2, INSERTION_PLANE_LAYER).get_collision_point();
						model_goal.global_basis = projected_position.basis
					
					
					insertion = current_insertion_vector_global.dot(model_goal.global_position - CURRENT_SLOT.global_position);
			else:
				CURRENT_SLOT = null;
				
				
				#Cosmetics - Nowehere near
				#projected_position.basis = basis
				projected_position.look_at(projected_position.global_position + global_basis*DEFAULT_DIRECTION, Vector3.RIGHT);#projected_position.global_basis.z);
				projected_position.rotate(projected_position.basis.x, -PI/2)
				#projected_position.rotate_z(0.1)
				#projected_position.rotate(projected_position.basis.x, -PI/2)
				#projected_position.global_rotate(global_basis*DEFAULT_DIRECTION, PI/2)
				model_goal.transform = projected_position.transform
				
			
		
		else: # If currently housed within a slot
			effective_lerp_rate_angular = 0.8
			
			var aimed_at_position:Vector3 = get_viewport().get_camera_3d().get_ray_from_camera_through(projected_position.global_position, 2, INSERTION_PLANE_LAYER).get_collision_point();
			
			#projected_position.global_position = global_position + get_mouse_plane_position(INSERTION_PLANE_LAYER) - start_focus_offset;
			insertion = current_insertion_vector_global.dot(aimed_at_position - CURRENT_SLOT.global_position);
			insertion = min(insertion, CURRENT_SLOT.INSERTION_LENGTH)
			CURRENT_SLOT.insertion = insertion
			
			if(insertion < 0):
				is_housed = false;
				CURRENT_SLOT.is_housed = false;
				CURRENT_SLOT.insertion = 0;
				CURRENT_SLOT.housed_insertable = null;
			
			
			#Cosmetics - In slot
			projected_position.global_position = CURRENT_SLOT.global_position + insertion * current_insertion_vector_global;
			projected_position.look_at(projected_position.global_position + current_insertion_vector_global, current_insertion_vector_global.cross(CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_PLANE_NORMAL));
			projected_position.rotate(projected_position.basis.x, -PI/2)
			
			
			model_goal.global_position = projected_position.global_position
			model_goal.global_basis = projected_position.global_basis
			#projected_position.global_rotate(CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_PLANE_NORMAL, PI/2)
			#projected_position.look_at(projected_position.global_position + CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_DIRECTION, Vector3.UP);
			#projected_position.global_rotate(CURRENT_SLOT.global_basis*CURRENT_SLOT.INSERTION_PLANE_NORMAL, PI/2)
		
		
		MODEL.global_position = MODEL.global_position.lerp(model_goal.global_position, effective_lerp_rate_linear);
		MODEL.global_basis = Basis(Quaternion(MODEL.global_basis).slerp(Quaternion(model_goal.global_basis), effective_lerp_rate_angular)); # Lerp rotation
	
	



var start_focus_offset:Vector3;
var first_time:bool = true;
#Enable and disable being clicked on
func enable_focus():
	if(first_time):
		first_time = false;
	
	call_deferred("reparent_model_to_original") # Deferred as to not interfere with raycasts further on in the frame
	projected_position.reparent(ORIGINAL_PARENT)
	model_goal.reparent(ORIGINAL_PARENT)
	
	#This clamps it back to the right plane and sets the right offset
	projected_position.global_position = (get_viewport().get_camera_3d().get_ray_from_camera_through(projected_position.global_position, 2, PLANE_COLLISION_LAYER).get_collision_point())
	start_focus_offset = global_position + get_mouse_plane_position() - projected_position.global_position

	insertion_plane_tools.INTERACT_PLANE.process_mode = Node.PROCESS_MODE_INHERIT

func reparent_model_to_original():
	MODEL.reparent(ORIGINAL_PARENT)

func disable_focus():
	insertion_plane_tools.INTERACT_PLANE.process_mode = Node.PROCESS_MODE_DISABLED
	if(is_housed):
		MODEL.reparent(CURRENT_SLOT)
		projected_position.reparent(CURRENT_SLOT)
		model_goal.reparent(CURRENT_SLOT)
	else:
		MODEL.reparent(ORIGINAL_PARENT)
		projected_position.reparent(ORIGINAL_PARENT)
		model_goal.reparent(ORIGINAL_PARENT)
