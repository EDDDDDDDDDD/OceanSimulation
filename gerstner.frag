#version 330 compatibility 

in vec3    vMC;
in vec3    vNs;
in vec3    vLs;
in vec3    vEs;
in vec2	   vST;

uniform float uKa,uKd, uKs;
uniform float uShininess;
uniform float uNoiseAmp;
uniform float uNoiseFreq;
uniform float uBlend;
uniform vec4  uColor;
uniform sampler3D Noise3;


const vec4 WHITE = { 1., 1., 1., 1. };            

uniform sampler2D TexUnit;

vec3 
RotateNormal( float angx, float angy, vec3 n ) 
{
    float cx = cos( angx ); 
    float sx = sin( angx ); 
    float cy = cos( angy ); 
    float sy = sin( angy ); 
    // rotate about x: 
    float yp =  n.y*cx - n.z*sx; 
    n.z =  n.y*sx + n.z*cx; 
    n.y  =  n.x;
    // n.x =  yp;
    
    // rotate about y: 
    float xp =  n.x*cy + n.z*sy;
    n.z = -n.x*sy + n.z*cy;
    n.x  =  n.y;
    // n.y =  xp;
    
    return normalize( n );
} 

void main()
{
    vec3 waveText = texture( TexUnit, vec2(mod(vST.s * 5, 4), mod(vST.t * 5, 4)) ).rgb;
    vec4 nvx = texture3D( Noise3, uNoiseFreq*vMC ); 
    vec4 nvy = texture3D( Noise3, uNoiseFreq*vec3(vMC.xy,vMC.z+0.5) ); 
    float angx = nvx.r + nvx.g + nvx.b + nvx.a;     //  1. -> 3.
    angx = angx- 2.; 
    // -1. -> 1. 
    angx *= uNoiseAmp; 
    
    float angy = nvy.r + nvy.g + nvy.b + nvy.a;     //  1. -> 3.
    angy = angy- 2.; 
    // -1. -> 1. 
    angy *= uNoiseAmp; 
    
    vec3 normal = normalize( vNs ); 
    vec3 light  = normalize( vLs ); 
    vec3 eye    = normalize( vEs ); 
    
    normal = RotateNormal( angx, angy, normal ); 
    vec4 ambient = uKa * uColor; 
    float d = max( dot(normal,light), 0. ); 
    d = abs( dot(normal,light)); 
    vec4 diffuse = uKd * d * uColor; 
    float s = 0.; 
    if( dot(normal,light) > 0. )    // only do specular if the light can see the point
    { 
       vec3 ref = normalize( 2. * normal * dot(normal,light) - light ); 
       s = pow( max( dot(eye,ref),0. ), uShininess ); 
    } 
    vec4 specular = uKs * s * WHITE; 
    vec3 newcolor = ambient.rgb + diffuse.rgb + specular.rgb;
    newcolor = (1-uBlend) * newcolor + uBlend*waveText;
    
    gl_FragColor = vec4( newcolor, 1. );
}