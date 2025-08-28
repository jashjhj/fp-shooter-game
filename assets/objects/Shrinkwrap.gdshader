shader_type spatial;
render_mode cull_disabled;


uniform sampler2D depth: filter_nearest;
uniform vec3 down = vec3(0.0,-1.0,0.0);
uniform int quality = 1;
uniform int hem = 15;

uniform float convexity = 0.1;

const float plateau_radius = 0.05; // relative to UV


float sample_depth(vec2 pos){
	return texture(depth, pos * 0.98 + 0.01).x;
}

void vertex() {
	float depth_dist = sample_depth(UV);
	
	//Get highest point in neighbours
	
	if(quality > 0){
		depth_dist = min(depth_dist, sample_depth(vec2(min(1.0, UV.x + plateau_radius), UV.y)));
		depth_dist = min(depth_dist, sample_depth(vec2(max(0.0, UV.x - plateau_radius), UV.y)));
		depth_dist = min(depth_dist, sample_depth(vec2(UV.x, min(1.0, UV.y + plateau_radius))));
		depth_dist = min(depth_dist, sample_depth(vec2(UV.x, max(0.0, UV.y - plateau_radius))));
	}
	if(quality > 1){ // this doesnt matter as its already set to align to a grid
		//depth_dist = min(depth_dist, sample_depth(vec2(min(1.0, UV.x + plateau_radius*0.7), min(1.0, UV.y + plateau_radius*0.7))).x);
		//depth_dist = min(depth_dist, sample_depth(vec2(min(1.0, UV.x + plateau_radius*0.7), max(1.0, UV.y - plateau_radius*0.7))).x);
		//depth_dist = min(depth_dist, sample_depth(vec2(max(1.0, UV.x - plateau_radius*0.7), min(1.0, UV.y + plateau_radius*0.7))).x);
		//depth_dist = min(depth_dist, sample_depth(vec2(max(1.0, UV.x - plateau_radius*0.7), max(1.0, UV.y - plateau_radius*0.7))).x);
	}
	
	depth_dist = min(depth_dist, 1.0- convexity*0.5*(sin(PI*UV.x) + sin(PI*UV.y)));
	
	if((UV.x <= 0.01 && (hem&1)==1 )|| (UV.x >= 0.99 && (hem&2)==2 ) || (UV.y <= 0.01 && (hem&4)==4 ) || (UV.y >= 0.99 && (hem&8)==8 )){
		depth_dist = 1.0; // tamp down corners of pocket
	}
	
	depth_dist = min(depth_dist, 1.0-(sin(PI*UV.x) + sin(PI*UV.y)));
	
	
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
