#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001

/*SHADER BY delirious_blanc https://www.shadertoy.com/view/tlsBz2*/

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

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

mat2 Rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0., 1. );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
	vec3 ab = b-a;
    vec3 ap = p-a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0., 1.);
    
    vec3 c = a + t*ab;
    
    return length(p-c)-r;
}

float sdCylinder(vec3 p, vec3 a, vec3 b, float r) {
	vec3 ab = b-a;
    vec3 ap = p-a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0., 1.);
    
    vec3 c = a + t*ab;
    
    float x = length(p-c)-r;
    float y = (abs(t-.5)-.5)*length(ab);
    float e = length(max(vec2(x, y), 0.));
    float i = min(max(x, y), 0.);
    
    return e+i;
}

float sdTorus(vec3 p, vec2 r) {
	float x = length(p.xz)-r.x;
    return length(vec2(x, p.y))-r.y;
}

float sdBox(vec3 p, vec3 s) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
}

//this is good augmentation with poseNet

float GetDist(vec3 p) {

    vec3 bp = p-vec3(2,3,0);
    //bp.z += sin(bp.z*3.5+iTime*2.)*.3; // flag wave
    
    bp.z = abs(bp.z) - .5; //mirroring
    bp.z -= .7; //extend mirrored shape
    
    vec3 n = normalize(vec3(0,1,0));
    bp -= 2. * n*min(0., dot(p, n));
    
    float scale = mix(1.,4., smoothstep(-1., 1.,bp.y));
    bp.xz *= scale;
    
    bp.xz *= Rot(smoothstep(0., 1., bp.y)); 
    bp.y -= sin(bp.y *.6 + iTime *.8);
    bp.z += sin(bp.z * 2.); //* .2;
    
    float box = sdBox(bp, vec3(1,1.5,1))/scale; 
    
    box-= sin(p.x*2.+iTime*2.)*.1; //displacement mapping
   	box = abs(box)-.2; //makes shell
    
    float d = box * .5; //min(plane, box*.6); //max get intersection, min is normal shape
    
    return d;
}
    //Rot(bp.y*2.); //+iTime*2.
    //box = abs(box);
   // box -= 1.;
      // bp.x *= Rot( 2. + iTime*2.);
   // bp.y *= bp.y*2. + iTime*2.;
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

float GetLight(vec3 p) {
    vec3 lightPos = vec3(3, 5, 4);
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);
    
    float dif = clamp(dot(n, l)*.5+.5, 0., 1.);
    float d = RayMarch(p+n*SURF_DIST*2., l);
   // if(p.y<.01 && d<length(lightPos-p)) dif *= .5;
    
    return dif;
}

vec3 R(vec2 uv, vec3 p, vec3 l, float z) {
    vec3 f = normalize(l-p),
        r = normalize(cross(vec3(0,1,0), f)),
        u = cross(f,r),
        c = p+f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i-p);
    return d;
}

vec3 Bg(vec3 rd) {
	float k = rd.y*.8+.8;
    //light blue: .2, .5, 1
    vec3 col = mix(vec3(0.105, 0.815, 0.615), vec3(0.972, 0.050, 0.2), k);
    return col;
}

void main()
{
    vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy)/iResolution.y;
	vec2 m = iMouse.xy/iResolution.xy;
    
    vec3 col = vec3(0);
    
    vec3 ro = vec3(2., -9., -8);
   // vec2 m = (2., 1.);
  ro.xy *= Rot(-5.);
  //ro.y += 2.;
    ro.xz *= Rot(0.09 * iTime * abs(sin(-5.))); //-m.y*3.14+1.
    ro.yz *= Rot(10. * -m.y*3.14+1.);
    ro.xz *= Rot(-m.x*6.2831);
    ro.yz *= Rot(0.2 * iTime * sin(3.)); //-m.x*6.2831
    
    vec3 rd = R(uv, ro, vec3(0,1,0), 1.);

    col += Bg(rd);

    float d = RayMarch(ro, rd);
    
    if(d<MAX_DIST) {
    	vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        
        float spec = pow(max(0., r.y), 20.);

    	float dif = dot(n, normalize(vec3(1,2,3)))*.2+1.; //GetLight(p);
        col = mix(Bg(r), vec3(dif), .2) + spec;
        col += pal(rd.x, vec3(0.368, 0.219, 0.458),vec3(0.00,0.33, 0.67),vec3(0.2,0.4,0.2),vec3(0.0,0.33,0.27) );
    	//col = vec3(dif);
    }
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    gl_FragColor = vec4(col,1.0);
}