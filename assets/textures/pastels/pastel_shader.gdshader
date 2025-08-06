shader_type spatial;


uniform float emission = 0.0;
uniform vec3 emission_color = vec3(0.3,0.2,0.1);

uniform float color_shade = 0.1;
uniform float life = 1.0;
//uniform float emission = 0.0;


vec3 hsv2rgb(vec3 hsv) {
	vec3 rgb;
	
	float h = hsv.x * 6.0f;
	float c = hsv.y * hsv.z;
	float x = c * (1.0f - abs(mod(h, 2.0f) - 1.0f));
	
	if(0.0f <= h && h < 1.0f){
		rgb = vec3(c, x, 0);
	}else if(1.0f <= h && h < 2.0f){
		rgb = vec3(x, c, 0);
	}else if(2.0f <= h && h < 3.0f){
		rgb = vec3(0, c, x);
	}else if(3.0f <= h && h < 4.0f){
		rgb = vec3(0, x, c);
	}else if(4.0f <= h && h < 5.0f){
		rgb = vec3(c, 0, x);
	}else if(5.0f <= h && h < 6.0f){
		rgb = vec3(x, 0, c);
	}else{rgb = vec3(0, 0, 0);}
	
	float m = hsv.z - c;
	rgb += m;
	
	return rgb;
}


void vertex() {
	// Called for every vertex the material is visible on.
}



void fragment() {
	float vibrancy = 0.15 + life * 0.5; // remaps life to 0.15 -. 0.65
    
    float highlight = sin((FRAGCOORD.x + -FRAGCOORD.y) * 1.0f + -TIME * 8.0f);
	highlight = tanh(8.0f*highlight - 4.0f);
	highlight = highlight * 0.5f + 0.5f;
	
	ALBEDO = hsv2rgb(vec3(color_shade, 0.3, vibrancy));
    
    EMISSION = emission_color * highlight * emission;
	
	// Called for every pixel the material is visible on.
}
