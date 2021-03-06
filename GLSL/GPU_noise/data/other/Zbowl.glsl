// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


#ifdef GL_ES
precision highp float;
#endif
#define PROCESSING_COLOR_SHADER
uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;


vec2 map( vec2 z ){ return vec2( z.x*z.x-z.y*z.y,   2*z.x*z.y   )*(1.8-dot(z,z)); }

vec2 mapSum(vec2 p){
	vec2 sum=vec2(0,0);
	for (int i=0; i<10; i++){
		p  = map(p);
		sum+=p;
	}
	return sum;
}


void main(void){
	vec2 q  = (gl_FragCoord.xy / resolution.xy); 
	vec2 f = mapSum( q*4 -vec2(2.0,2.0) );
    gl_FragColor = vec4( 0.5+f.xy, 0.5, 1.0 );
}
