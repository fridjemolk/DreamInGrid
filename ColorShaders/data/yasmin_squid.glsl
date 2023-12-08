#define MAX_STEPS 128
#define MAX_DIST 120.
#define SURF_DIST .01

/*SHADER BY delirious_blanc https://www.shadertoy.com/view/7dS3DR*/

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
float iTime = time/6;
vec4 iMouse = vec4(mouse,0.0,0.0); // zw would normally be the click status
//Processing Conversion//

//from IQ
float dot2( in vec2 v ) { return dot(v,v); }
float dot2( in vec3 v ) { return dot(v,v); }
float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }

mat2 Rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float sdCapsule (vec3 p, vec3 a, vec3 b, float r) {
    vec3 ab = b-a;
    vec3 ap = p-a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0., 1.);
    
    vec3 c = a + t*ab;
    return length(p - c)-r;
}

float sdTorus (vec3 p, vec2 r) {
    float x = length(p.xz) - r.x;
    return length(vec2(x, p.y))-r.y;
}

float dBox(vec3 p, vec3 s) {
    return length(max(abs(p)-s, 0.));
}

float sdSphere(vec3 p, float s) {
    return length(p)-s;
}

float sdBoundingBox( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;

  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float sMin( float a, float b, float k) {
    float h = clamp(.5 + .5 *(b-a)/k, 0., 1.);
    return mix(b, a, h) - k*h*(1. - h);
}

float sineCrazy(vec3 p){
    return 1. - abs((sin(p.x)+sin(p.y)+sin(p.z)))/4.;
}

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

// 2D Random
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float GetDist(vec3 p){
    float scale = 5. + 10. * sin(time *0.5);
    
    float planeDist = p.y; //0
    
    //Cylinders
    vec3 cdp = p + vec3(0.5, 0., 0.);
    cdp.x = abs(cdp.x) - 2.;
    
    cdp.xz *= Rot(cdp.x*.5 + iTime*.5);
    
    float cd = sdCapsule(cdp, vec3(0, 0.,-1.75), vec3(.5, 2.5, 3), .2);
    float cd2 = sdCapsule(cdp, vec3(2, 0., -1.75), vec3(-.75, 3, 3), .2);
    
    //cdp.yz *= Rot(cdp.x*1. + iTime*.5); //rotating cylinders around origin
    
    float cd3 = sdCapsule(cdp, vec3(-.2, 2.2, -1.), vec3(-3, 0.2, 3) , .2);
    float cd4 = sdCapsule(cdp, vec3(-1.5, .7, 0.), vec3(0., 2.2, 2.), .2); 
    
    
   cdp.y = abs(cdp.y) - .5;
    
    float cdtogether = sMin(cd, cd2, 0.1); //+ sin(iTime*.2);
    cdtogether = sMin(cdtogether, cd3, .1);
    cdtogether = sMin(cdtogether, cd4, .1);
    
    
    vec3 sp = p - vec3(-1., 1., 0.);
    sp.x = abs(sp.x) - 2.5;
    //sp.xz *= Rot(sp.z * sin(0.2*iTime));
    
    float sphere = sdSphere(sp, 1.);
    //float box = dBox(sp, 1.2)
    
    float d = min(cdtogether, sphere);
    //float d = min(cdtogether, planeDist); //planeDist
    return d;
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<MAX_STEPS; i++) {
    	vec3 p = ro + rd*dO;
        float dS = GetDist(p);
        dO += dS;
        if(dO>MAX_DIST || dS<SURF_DIST) break;
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
    vec3 lightPos = vec3(0, 5, 6);
    lightPos.xz += vec2(sin(iTime), cos(iTime))*2.;
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);
    
    float dif = clamp(dot(n, l), 0., 1.);
    float d = RayMarch(p+n*SURF_DIST*2., l);
    
    //if(d<length(lightPos-p)) dif *= .1; //shadow
    
    return dif;
}

vec3 Bg(vec3 rd) {
	float k = rd.z*.8+.8;
    //light blue: .2, .5, 1
    vec3 col = mix(vec3(0.105, 0.815, 0.615), vec3(0.035, 0.525, 0.356), k);
    return col;
}

void main()
{
    vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy)/iResolution.y;
    //vec2 m = iMouse.xy / iResolution.xy;
    
    vec3 col = vec3(0);
    
    vec3 ro = vec3(0, 3.5, -7);
    ro.z -= sin(iTime);
    //ro.xz *= Rot(0.2*iTime * sin(.5));
    
    //ro.yz *= Rot(-m.y*3.14+1.); //mouse interaction
    //ro.xz *= Rot(-m.x*6.2831); //mouse interaction
    
    vec3 rd = normalize(vec3(uv.x-.1, uv.y-.4, 1));

    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd * d;
    
    //col += Bg(rd);
    
        if(d<MAX_DIST) {
    	vec3 p = ro + rd * d;
        vec3 n = GetNormal(p);
        vec3 r = reflect(rd, n);
        
        float spec = pow(max(0., r.y), 20.);

    	float dif = dot(n, normalize(vec3(1,2,3)))*.2+1.; //GetLight(p);
        col = mix(Bg(r), vec3(dif), .25) + spec;
        col += pal(rd.x, vec3(0., 0.13, 0.89), vec3(0.5,0.4,0.2),vec3(2.0,1.0,1.0),vec3(0.301, 0.309, 0.901));
        //0.901, 0.627, 0.301
    	//col = vec3(dif);
    }
    
    //float dif = GetLight(p);
    //col = vec3(dif);
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    gl_FragColor = vec4(col,1.0);
}