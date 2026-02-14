shader_type canvas_item;

uniform vec2[2000] points;
uniform vec2 pos;
uniform int num_points;
uniform float strong_dist = 10.0;
uniform float weak_dist = 40.0;
//uniform float strong_val = 0.8;
//uniform float roundness = 2;
uniform vec4 strong_color = vec4(0.694, 0.753, 0.827,1);
uniform vec4 weak_color = vec4(0.769, 0.816, 0.859,1);
varying vec2 global_pos;
void vertex() {
	
	// Called for every vertex the material is visible on.
	global_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	global_pos -= vec2(1900,3150);
	//global_pos = vec2(0,0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	
    float min_dist = 10000.0; // Initialize with a large value
    for (int i = 0; i < num_points; i++) {
        float d = distance(global_pos,pos + points[i]);
		
	    min_dist = abs(min(min_dist, d));
    }
	//if (min_dist < strong_dist)
	//{
    	//COLOR = strong_color;
	//}
	if (min_dist < weak_dist)
	{
		//float workspace =  weak_dist- strong_dist;
		//float val = (min_dist-strong_dist)/workspace * (1.0-strong_val) + strong_val;
		//val = round(val * pow(10.0, roundness)) / pow(10.0, roundness);
		COLOR = weak_color;
	}
	else
	{
		COLOR =vec4(0,0,0,0);
  	//COLOR =vec4(UV.x, UV.y,0,1);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
