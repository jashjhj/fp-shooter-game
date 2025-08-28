class_name Shrinkwrap extends MeshInstance3D
##Always shrinks down, as it forces a planemesh


@export var PROBE_LENGTH:float = 5.0;

@export_flags_3d_physics var RAY_MASK:int = 1 + 65536 + 1048576 # Floor + Gun parts
@onready var ray:RayCast3D = RayCast3D.new()


var depth:Image;
var depth_texture:ImageTexture;
var shrinkwrap_mat:ShaderMaterial;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	assert(mesh is PlaneMesh, "Mesh must be a PLANEMESH")
	mesh = mesh as PlaneMesh
	
	shrinkwrap_mat = load("res://assets/objects/Shrinkwrap_Material.tres")
	
	
	
	if(get_surface_override_material(0) == null): # Sets material in render
		set_surface_override_material(0, shrinkwrap_mat)
	else:
		get_surface_override_material(0).next_pass = shrinkwrap_mat
	
	depth = Image.create(mesh.subdivide_width + 1, mesh.subdivide_depth + 1, false, Image.FORMAT_L8)
	
	add_child(ray)
	ray.target_position = PROBE_LENGTH * Vector3.DOWN
	ray.collision_mask = RAY_MASK
	
	refresh()
	
	##Axis-aligned bounding box for frustum culling, as vertices offset
	mesh.custom_aabb = AABB(Vector3(-mesh.size.x/2, 0, -mesh.size.y/2), Vector3(mesh.size.x, -PROBE_LENGTH, mesh.size.y))


var ticks_til_refresh:int = 0;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(ticks_til_refresh == 0):
		refresh()
		ticks_til_refresh = 10
	ticks_til_refresh -= 1;
	
	
	shrinkwrap_mat.set_shader_parameter("down", -global_basis.y * PROBE_LENGTH)


var is_first:bool = true
##Refreshes the map
func refresh():
	mesh = mesh as PlaneMesh
	
	for x in range(0, mesh.subdivide_width + 1):
		for y in range(0, mesh.subdivide_depth + 1):
			var d:float = 1.0; # depth to paint
			
			ray.position.x = -mesh.size.x/2 + mesh.size.x * x / (mesh.subdivide_width+1)
			ray.position.z = -mesh.size.y/2 + mesh.size.y * y / (mesh.subdivide_depth+1)
			ray.force_raycast_update()
			if(ray.get_collider() == null):
				d = 1.0;
			else:
				d = (ray.get_collision_point() - ray.global_position).length() / PROBE_LENGTH
				#print(d)
			
			depth.set_pixel(x, y, Color(d,d,d))
	
	if(is_first):
		depth_texture = ImageTexture.create_from_image(depth)
		is_first = false
		shrinkwrap_mat.set_shader_parameter("depth", depth_texture)
	else:
		depth_texture.update(depth)
	
	
