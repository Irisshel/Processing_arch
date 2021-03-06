// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


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
float iGlobalTime = time;
vec4 iMouse = vec4(mouse,0.0,0.0); // zw would normally be the click status





void main(void)
{
	vec2 p = gl_FragCoord.xy / iResolution.xy;

    vec2 cc = 1.1*vec2( 0.5*cos(0.1*iGlobalTime) - 0.25*cos(0.2*iGlobalTime), 
	                    0.5*sin(0.1*iGlobalTime) - 0.25*sin(0.2*iGlobalTime) );

	vec4 dmin = vec4(1000.0);
    vec2 z = (-1.0 + 2.0*p)*vec2(1.7,1.0);
    for( int i=0; i<32; i++ )
    {
        z = cc + vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
		z += 0.15*sin(float(i));
		dmin=min(dmin, vec4(abs(0.0+z.y + 0.5*sin(z.x)), 
							abs(1.0+z.x + 0.5*sin(z.y)), 
							dot(z,z),
						    length( fract(z)-0.5) ) );
    }
    
    vec3 color = vec3( dmin.w );
	color = mix( color, vec3(1.00,0.80,0.60),     min(1.0,pow(dmin.x*0.25,0.20)) );
    color = mix( color, vec3(0.72,0.70,0.60),     min(1.0,pow(dmin.y*0.50,0.50)) );
	color = mix( color, vec3(1.00,1.00,1.00), 1.0-min(1.0,pow(dmin.z*1.00,0.15) ));

	color = 1.25*color*color;
	
	color *= 0.5 + 0.5*pow(16.0*p.x*(1.0-p.x)*p.y*(1.0-p.y),0.15);

	gl_FragColor = vec4(color,1.0);
}
