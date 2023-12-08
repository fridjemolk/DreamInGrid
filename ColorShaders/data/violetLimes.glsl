#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;

void main( void ){
	
	vec2 uv = gl_FragCoord.xy/resolution.xy;

	vec3 line = vec3(9.1);
   
    uv*= 3.9;
    
    float len;
    
 	for (int i = 0; i < 3; i++) {
        len = length(vec2(uv.x, uv.y));
        
        uv.x +=  sin(uv.y + time * 0.4)*3.;
        uv.y +=  cos(uv.x + time * 0.4 + cos(len * 3.0))*1.4;
    }
    

  	vec3 color = vec3(tan(len - 0.3), tan(len + 0.1), tan(len - 0.1));
    
    gl_FragColor = vec4(color, 1.0);

}


