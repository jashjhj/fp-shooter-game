class_name BulletTrail extends MeshInstance3D

var camera:Camera3D;
var width:= 0.1;

var segment_origin:Vector3;
var segment_end:Vector3;

var lifetime_start:int;
@export var lifetime:int = 2000;
@export var material:Material;

var up := Vector3.UP;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	lifetime_start = Time.get_ticks_msec()
	
	camera = get_viewport().get_camera_3d()
	
	var surface_array = [];
	surface_array.resize(Mesh.ARRAY_MAX);
	var verts = PackedVector3Array();
	var uvs = PackedVector2Array();
	
	#var up:Vector3 = camera.position.cross(segment_end-segment_origin).normalized();
	
	up = up.normalized()
	
	var vector:Vector3 = segment_end-segment_origin
	
	var pos0 := up*width; # Creates mesh rect
	var pos1 := -up*width;
	var pos2 := vector + up*width;
	var pos3 := vector - up*width
	
	verts.append(pos0);
	verts.append(pos1);
	verts.append(pos2);
	verts.append(pos1);
	verts.append(pos2);
	verts.append(pos3);
	
	var texture_loop_rate = 1.0;
	
	uvs.append(Vector2(0, 0))
	uvs.append(Vector2(1, 0))
	uvs.append(Vector2(0, vector.length()*texture_loop_rate))
	uvs.append(Vector2(1, 0))
	uvs.append(Vector2(0, vector.length()*texture_loop_rate))
	uvs.append(Vector2(1, vector.length()*texture_loop_rate))
	
	surface_array[Mesh.ARRAY_VERTEX] = verts;
	surface_array[Mesh.ARRAY_TEX_UV] = uvs;
	
	surface_array.resize(Mesh.ARRAY_MAX);
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array);
	mesh.surface_set_material(0, material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time_passed = float(Time.get_ticks_msec() - lifetime_start) / float(lifetime)
	
	if(time_passed > 1.0):
		queue_free();
	pass
