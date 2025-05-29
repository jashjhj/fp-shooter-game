@tool
class_name Cover extends Node3D

@export var DISTANCE:int = 20;
@export var DISTANCE_BETWEEN_PROBES:float = 1.0;

@export var PROBES_NUMBER:int = 8;
@export var PROBES_LENGTH:float = 10;

@export_tool_button("Load Cover") var button = load_cover

var cover_data:PackedFloat32Array;
var pos_index_map:PackedInt32Array;

var probes_size_x:int;
var probes_size_z:int;

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		persistent_load_cover()

func load_cover():
	cover_data = []
	pos_index_map = []
	
	var checked = 0;
	var total_to_check = int(DISTANCE*DISTANCE*4 / (DISTANCE_BETWEEN_PROBES*DISTANCE_BETWEEN_PROBES))
	var checked_interval = total_to_check / 10;
	
	probes_size_x = int(2*float(DISTANCE)/DISTANCE_BETWEEN_PROBES+2)
	probes_size_z = int(2*float(DISTANCE)/DISTANCE_BETWEEN_PROBES+2)
	for x_i in range(0, probes_size_x):
		var x:float = (x_i) * DISTANCE_BETWEEN_PROBES - DISTANCE
		for y_i in range(0, probes_size_z):
			var y:float = (y_i) * DISTANCE_BETWEEN_PROBES - DISTANCE
			
			var distances := get_distances_at(global_position + Vector3(x, 0, y))
			if(len(distances)) == 0:
				pos_index_map.append(-1)
			else:
				pos_index_map.append(len(cover_data))
				cover_data.append_array(distances)
			
			checked += 1;
			if(checked % checked_interval == 0): print("Checked ", checked, " out of ", total_to_check, ".")
	
	persistent_save_cover()



func get_cover(pos:Vector3, from_pos:Vector3) -> float:
	
	var angle = atan2(from_pos.x - pos.x, from_pos.z - pos.z) - PI
	var nearest_angle_index = round(angle/(2*PI) * PROBES_NUMBER)
	#from_pos.y = pos.y
	
	DebugDraw3D.draw_line(pos, from_pos, Color(0, 0, 1))
	
	
	
	var index = get_index_near(pos)
	if(index == -1): return 1
	else:
		var data = cover_data[index*PROBES_NUMBER + nearest_angle_index]
		
		
		#var distance = pos.distance_to(from_pos)
		#var angle_vector = Vector3.FORWARD.rotated(Vector3.UP, float(nearest_angle_index)/float(PROBES_NUMBER)*(2*PI))*data
		#DebugDraw3D.draw_line(pos, pos+ angle_vector, Color(1, 0, 0))
		
		#print(data)
		return data

func get_index_near(pos:Vector3) -> int:
	var local_pos = pos - global_position;
	local_pos = Vector2(local_pos.x, local_pos.z)
	local_pos = round(local_pos/DISTANCE_BETWEEN_PROBES) # Nearest probe index
	local_pos += Vector2.ONE * (DISTANCE+1); # Just adding
	local_pos = local_pos.minf(2*DISTANCE/DISTANCE_BETWEEN_PROBES)
	local_pos = local_pos.maxf(0)
	
	var map_index = int(local_pos.y* (2*DISTANCE/DISTANCE_BETWEEN_PROBES + 2) + local_pos.x);
	#print(map_index)
	return map_index



func get_distances_at(pos:Vector3) -> PackedFloat32Array:
	var out:PackedFloat32Array = [];
	for i in range(0, PROBES_NUMBER):
		var ray = ray(pos, pos+Vector3.FORWARD.rotated(Vector3.UP, float(i)/float(PROBES_NUMBER)*(2*PI))*PROBES_LENGTH)
		
		if(len(ray) == 0):
			#No collision
			out.append(PROBES_LENGTH)
		else:
			#pos_index_map.append(len(cover_data))
			var distance = ray["position"].length();
			if distance < 0.001:
				return []
			elif distance > PROBES_LENGTH:
				out.append(PROBES_LENGTH)
			else:out.append(distance)
	
	return out

func ray(from:Vector3, to:Vector3) -> Dictionary:
	var ray_params := PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	ray_params.hit_from_inside = true;
	ray_params.collide_with_areas = true
	ray_params.collision_mask = -1
	return get_world_3d().direct_space_state.intersect_ray(ray_params);






func persistent_save_cover():
	var file = FileAccess.open("res://maps/map_resources/pathfinding/cover/cover_data.dat", FileAccess.WRITE);
	file.store_var(DISTANCE)
	file.store_var(DISTANCE_BETWEEN_PROBES)
	file.store_var(PROBES_NUMBER)
	
	file.store_var(cover_data);
	file.store_var(pos_index_map);
	
	#cover_data = [];
	#valid_slots = [];
	#pos_index_map = [];

func persistent_load_cover():
	var file = FileAccess.open("res://maps/map_resources/pathfinding/cover/cover_data.dat", FileAccess.READ);
	FileAccess.get_open_error()
	DISTANCE = file.get_var()
	DISTANCE_BETWEEN_PROBES = file.get_var()
	PROBES_NUMBER = file.get_var()
	
	cover_data = file.get_var();
	pos_index_map = file.get_var();
	
