shader_type spatial;
render_mode cull_disabled;


uniform sampler2D depth;
uniform vec3 down = vec3(0.0,-1.0,0.0);

const float plateau_radius = 0.05;

void vertex() {
	float depth_dist = texture(depth, UV).x;
	
	//Get highest point in neighbours
	
	depth_dist = min(depth_dist, texture(depth, vec2(UV.x + plateau_radius, UV.y)).x);
	depth_dist = min(depth_dist, texture(depth, vec2(UV.x - plateau_radius, UV.y)).x);
	depth_dist = min(depth_dist, texture(depth, vec2(UV.x, UV.y + plateau_radius)).x);
	depth_dist = min(depth_dist, texture(depth, vec2(UV.x, UV.y - plateau_radius)).x);
	
	
	
	VERTEX += down * depth_dist;
}

void fragment() {
	// Called for every pixel the material is visible on.
	//ALBEDO = texture(depth, UV).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
