shader_type spatial;
render_mode cull_disabled;


uniform sampler2D depth;
uniform vec3 down = vec3(0.0,-1.0,0.0);
uniform int quality = 1;


const float plateau_radius = 0.05; // relative to UV

void vertex() {
	float depth_dist = texture(depth, UV).x;
	
	//Get highest point in neighbours
	
	if(quality > 0){
		depth_dist = min(depth_dist, texture(depth, vec2(min(1.0, UV.x + plateau_radius), UV.y)).x);
		depth_dist = min(depth_dist, texture(depth, vec2(max(0.0, UV.x - plateau_radius), UV.y)).x);
		depth_dist = min(depth_dist, texture(depth, vec2(UV.x, min(1.0, UV.y + plateau_radius))).x);
		depth_dist = min(depth_dist, texture(depth, vec2(UV.x, max(0.0, UV.y - plateau_radius))).x);
	}
	if(quality > 1){ // this doesnt matter as its already set to align to a grid
		//depth_dist = min(depth_dist, texture(depth, vec2(min(1.0, UV.x + plateau_radius*0.7), min(1.0, UV.y + plateau_radius*0.7))).x);
		//depth_dist = min(depth_dist, texture(depth, vec2(min(1.0, UV.x + plateau_radius*0.7), max(1.0, UV.y - plateau_radius*0.7))).x);
		//depth_dist = min(depth_dist, texture(depth, vec2(max(1.0, UV.x - plateau_radius*0.7), min(1.0, UV.y + plateau_radius*0.7))).x);
		//depth_dist = min(depth_dist, texture(depth, vec2(max(1.0, UV.x - plateau_radius*0.7), max(1.0, UV.y - plateau_radius*0.7))).x);
	}
	if(UV.x <= 0.01 || UV.x >= 0.99 || UV.y <= 0.01 || UV.y >= 0.99){
		depth_dist = 1.0; // tamp down corners of pocket
	}
	
	
	VERTEX += down * depth_dist;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(UV.x,UV.y, 0.0);
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
