#version 330 compatibility 
uniform float   uTimeScale;
//uniform float uG;
//uniform float uH;
uniform float   uAm0;
uniform float   uKm0;
uniform float   uGamma0;
uniform float   uAm1;
uniform float   uKm1;
uniform float   uPhiM1;
uniform float   uGamma1;
uniform float   Timer;
uniform float   uLightX, uLightY, uLightZ; 


vec3 eyeLightPosition = vec3(  uLightX,  uLightY,  uLightZ ); 

out vec2        vST;
out vec3        vMC;
out vec3        vEs;
out vec3        vLs;
out vec3        vNs;
const float PI = 3.14159265; 
const float G  = 1.; 

void main()
{
    vST = gl_MultiTexCoord0.st;
    
    float newx = gl_Vertex.x; 
    float newy = 0.; 
    float newz = gl_Vertex.z; 
    float dxda = 1.; 
    float dyda = 0.; 
    float dzda = 0.; 
    float dxdb = 0.; 
    float dydb = 0.; 
    float dzdb = 1.;
    // m = 0
    {
        float phiM0 = 0.; // m=0 is the phase baseline 
        float wm0 = sqrt( G*uKm0 ); 
        float thetam = gl_Vertex.x*uKm0*cos(uGamma0) + gl_Vertex.z*uKm0*sin(uGamma0) - wm0*Timer*uTimeScale- phiM0; 
        newx -= uAm0*cos(uGamma0)*sin(thetam); 
        newy += uAm0 * cos(thetam); 
        newz -= uAm0*sin(uGamma0)*sin(thetam); 
        float dthetamda = uKm0*cos(uGamma0); 
        float dthetamdb = uKm0*sin(uGamma0); 
        dxda -= uAm0*cos(uGamma0)*cos(thetam)*dthetamda; 
        dyda -= uAm0*sin(thetam)*dthetamda; 
        dzda -= uAm0*sin(uGamma0)*cos(thetam)*dthetamda; 
        dxdb -= uAm0*cos(uGamma0)*cos(thetam)*dthetamdb; 
        dydb -= uAm0*sin(thetam)*dthetamdb; 
        dzdb -= uAm0*sin(uGamma0)*cos(thetam)*dthetamdb; 
    }
    // m = 1 
    { 
        float wm1 = sqrt( G*uKm1 ); 
        float thetam = gl_Vertex.x*uKm1*cos(uGamma1) + gl_Vertex.z*uKm1*sin(uGamma1) - wm1*Timer*uTimeScale- uPhiM1; 
        newx -= uAm1*cos(uGamma1)*sin(thetam); 
        newy += uAm1 * cos(thetam); 
        newz -= uAm1*sin(uGamma1)*sin(thetam); 
        float dthetamda = uKm1*cos(uGamma1); 
        float dthetamdb = uKm1*sin(uGamma1); 
        dxda -= uAm1*cos(uGamma1)*cos(thetam)*dthetamda; 
        dyda -= uAm1*sin(thetam)*dthetamda; 
        dzda -= uAm1*sin(uGamma1)*cos(thetam)*dthetamda; 
        dxdb -= uAm1*cos(uGamma1)*cos(thetam)*dthetamdb; 
        dydb -= uAm1*sin(thetam)*dthetamdb; 
        dzdb -= uAm1*sin(uGamma1)*cos(thetam)*dthetamdb;
    }
    
    vec3 newVertex = vec3( newx, newy, newz); 
    vMC = newVertex; 
    vec3 ta = vec3( dxda, dyda, dzda); 
    vec3 tb = vec3( dxdb, dydb, dzdb); 
    vNs = normalize( gl_NormalMatrix*cross( tb, ta ) );         // surface normal vector 
    vec4 ECposition = gl_ModelViewMatrix* vec4( newVertex, 1. ); 
    vLs = normalize( eyeLightPosition-ECposition.xyz);          // vector from the point 
                                                                // to the light position 
    vEs = normalize( vec3( 0., 0., 0. ) - ECposition.xyz);      // vector from the point 
                                                                // to the eye position 
    gl_Position = gl_ModelViewProjectionMatrix * vec4( newVertex, 1.); 
}