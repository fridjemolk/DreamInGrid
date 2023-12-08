// "RayMarching starting point" 
// by Martijn Steinrucken aka BigWings/CountFrolic - 2020
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// 
// You can use this shader as a template for ray marching shaders

/*SHADER ADPAPTED BY delirious_blanc https://www.shadertoy.com/view/3tfBDB*/

//Processing Conversion//
#ifdef GL_ES
precision highp float;
#endif

// Type of shader expected by Processing
#define PROCESSING_COLOR_SHADER

// Processing specific input
uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;

// Layer between Processing and Shadertoy uniforms
vec3 iResolution = vec3(resolution,0.0);
float iTime = time*0.2;
vec4 iMouse = vec4(mouse,0.0,0.0); // zw would normally be the click status
//Processing Conversion//

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001

#define S smoothstep

mat2 Rot(float a) {
    float s=sin(a), c=cos(a);
    return mat2(c, -s, s, c);
}

float Hash21(vec2 p) {
    p = fract(p*vec2(123.34,233.53));
    p += dot(p, p+23.234);
    return fract(p.x*p.y);
}

float sdBox(vec3 p, vec3 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

float sdBox2d(vec2 p, vec2 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, p.y), 0.);
}

float GetDist(vec3 p) {
    float r1 = 1.7, r2=.2; //r1 = big radius, r2 = small radius
    vec2 cp = vec2(length(p.xz)-r1, p.y);
    
    float a = atan(p.x, p.z); //polar angle between -pi and pi
    cp *= Rot(a*.5+iTime*1.5);
    cp.y =abs(cp.y)-.7; //flip y-coords
    
    float d = length(cp)-r2;
   	d = sdBox2d(cp, vec2(.1, .4*(sin(4.*a)*.5+.5)))-.1;
    return d*.7;
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    
    return dO;
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.001, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));
    
    return normalize(n);
}

vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
    vec3 f = normalize(l-p),
        r = normalize(cross(vec3(0,1,0), f)),
        u = cross(f,r),
        c = f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i);
    return d;
}


vec3 Bg(vec3 rd) {
    float k = rd.y*.5+.5; //map rd to 0-1 range
    
    vec3 col = mix(vec3(.4, .1, .2), vec3(.1, .7, 1), k);
        
    return col;
    
}
void main()
{
    vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy)/iResolution.y;
	vec2 m = iMouse.xy/iResolution.xy;
    
    vec3 col = vec3(0);
    
    vec3 ro = vec3(0, 3, -5); //cam pos
    ro.z += 2.*sin(iTime*.5);
    ro.y -= 5.;
    ro.yz *= Rot(-m.y*3.14+1.);
    ro.xz *= Rot(-m.x*6.2831);
    
    vec3 rd = GetRayDir(uv, ro, vec3(0), 1.);

    col += Bg(rd);
    
    float d = RayMarch(ro, rd);
    
    if(d<MAX_DIST) {
    	vec3 p = ro + rd * d;
    	vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        
        float spec = pow(max(0., r.y), 40.);
    	float dif = dot(n, normalize(vec3(.5,5,7)))*.5+.5;
    	col = mix(Bg(r)*2., vec3(dif), .2)+spec;  
        //col = vec3(spec);
    }
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    gl_FragColor = vec4(col,1.0);
}