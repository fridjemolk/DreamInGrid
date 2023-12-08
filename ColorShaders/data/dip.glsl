#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;
uniform float extraTime;
uniform float width;

//based on https://www.shadertoy.com/view/sd2Gzh

#define pi 3.141592653

void main( void ){

    float t = time*extraTime;
    vec2 R = resolution.xy;
    vec2 uv = (gl_FragCoord.xy-.5*R.xy)/R.y;
    uv.y=-uv.y;
    float y0 = uv.y;
    float y1 = uv.y;
    
    float wc = 160.0;
    float aa = 0.003*(450.0/max(resolution.y,450.0)); 
    float w = width; //width
    w-=aa; 
    
    for(int i = 0; i<int(wc); i++){
        float fi = float(i);
        
        y1=uv.y+2.1-2.5*(pow(fi/9.0,2.0)/300.0);

        float x = uv.x*4.4+1.8*sin(fi/11.0+t)*((fi*3.3)/300.0);
        
        float h;
        h =3.*sin((fi/11.0)+t);
        
        //Try these too
        //h = 3.5*sin((fi/11.0)+t)*sin((fi/11.0)+t);
        //h = 3.5*abs(sin((fi/11.0)+t));
        
        y1+=h*(cos(x*pi)+1.0)*0.05*step(-1.0,x)*step(x,1.0);
        
        y0 = y0*smoothstep((y1+w)+aa,(y1+w)+aa*3.0,0.4)  
        +(y1-w)*smoothstep(0.4,0.4+aa,(y1-w)+aa);    
    }
    
    //This is bad but I'm too stupid to fix it.
    y0=1.0-y0;
    y0=smoothstep(y0-0.4,y0,0.6);
    y0=1.0-y0;

    gl_FragColor = vec4(vec3(y0),1.0);
}