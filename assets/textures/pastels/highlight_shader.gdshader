shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never, depth_test_disabled;

uniform float emission = 0.0;
uniform vec3 emission_color = vec3(0.3,0.2,0.4);



void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float highlight = sin((FRAGCOORD.x + -FRAGCOORD.y) * 0.6f + -TIME * 8.0f);
	highlight = tanh(8.0f*highlight - 4.0f);
	highlight = highlight * 0.5f + 0.5f;

	//ALBEDO = vec3(0.0,0.0,0.0);
	ALBEDO = emission_color * highlight * emission;
	//EMISSION = color * highlight * emission;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
