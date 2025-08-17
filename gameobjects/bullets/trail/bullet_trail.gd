class_name BulletTrail extends MeshInstance3D

var camera:Camera3D;
var width:= 0.015;

var segment_origin:Vector3;
var segment_end:Vector3;

var lifetime_start:float;
@export var lifetime:float = 1.0;
@export var material:Material;

var up := Vector3.UP;
var vector:Vector3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if(material == null):
		push_error("No material set in bullet_data")
	
	lifetime_start = Time.get_ticks_msec()
	
	camera = get_viewport().get_camera_3d()
	
	var surface_array = [];
	surface_array.resize(Mesh.ARRAY_MAX);
	var verts = PackedVector3Array();
	var uvs = PackedVector2Array();
	
	#var up:Vector3 = camera.position.cross(segment_end-segment_origin).normalized();
	
	up = up.normalized()
	
	vector = segment_end-segment_origin
	
	var pos0 := up*width; # Creates mesh rect
	var pos1 := -up*width;
	var pos2 := vector + up*width;
	var pos3 := vector - up*width
	
	verts.append(pos0);
	verts.append(pos1);
	verts.append(pos2);
	verts.append(pos3);
	verts.append(pos2);
	verts.append(pos1);
	
	var texture_loop_rate = 3.0;
	
	uvs.append(Vector2(0, 0))
	uvs.append(Vector2(1, 0))
	uvs.append(Vector2(0, vector.length()*texture_loop_rate))
	uvs.append(Vector2(1, vector.length()*texture_loop_rate))
	uvs.append(Vector2(0, vector.length()*texture_loop_rate))
	uvs.append(Vector2(1, 0))
	
	surface_array[Mesh.ARRAY_VERTEX] = verts;
	surface_array[Mesh.ARRAY_TEX_UV] = uvs;
	
	surface_array.resize(Mesh.ARRAY_MAX);
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array);
	mesh.surface_set_material(0, material)
	
	#var surface_tool = SurfaceTool.new() # Generate normals
	#surface_tool.create_from(mesh, 0)
	#surface_tool.generate_normals()
	#mesh = surface_tool.commit()
	
	
	var timer:Timer = Timer.new() # Deletion timer
	add_child(timer)
	timer.wait_time = lifetime * 1
	timer.timeout.connect(self.queue_free)
	timer.timeout.connect(timer.queue_free)
	timer.start()
	
	#mesh.surface_get_material(0).set_shader_parameter("alpha_mult", 0.8)


#func _process(delta: float) -> void:
	#var lifetime_portion_elapsed = (float(Time.get_ticks_msec()) - lifetime_start)/1000 / lifetime
	#scale = Vector3(1,1,1) * (1+0.1*lifetime_portion_elapsed)
