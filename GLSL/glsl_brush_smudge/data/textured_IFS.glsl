#ifdef GL_ES
precision highp float;
#endif

// Type of shader expected by Processing
#define PROCESSING_COLOR_SHADER

// Processing specific input
uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;

uniform sampler2D background;

// Layer between Processing and Shadertoy uniforms
vec3  iResolution = vec3(resolution,0.0);
float iGlobalTime = time;
vec4  iMouse = vec4(mouse,0.0,0.0); // zw would normally be the click status



//parameters
const int iterations=20;
const float scale=1.3;
const vec2 fold=vec2(.5);
const vec2 translate=vec2(1.5);
const float zoom=.25;
const float brightness=7.;
const float saturation=.65;
const float texturescale=.15;
const float rotspeed=.1;
const float colspeed=.05;
const float antialias=2.;

vec2 rotateOpt(vec2 p, vec2 rotv) {
	return vec2( p.x*rotv.x-p.y*rotv.y,
		         p.y*rotv.x+p.x*rotv.y  );
}

void main(void)
{
	vec3 aacolor=vec3(0.);
	vec2 pos=gl_FragCoord.xy / iResolution.xy-.5;
	float aspect=iResolution.y/iResolution.x;
	pos.y*=aspect;
	pos/=zoom; 
	vec2 pixsize=max(1./zoom,100.-iGlobalTime*50.)/iResolution.xy;
	pixsize.y*=aspect;
	float angle = iGlobalTime*rotspeed;
    vec2 rotv = vec2 ( cos(angle), sin(angle) );
	vec2 p=pos;
	p+=fold;
	float expsmooth=0.;
	vec2 average=vec2(0.);
	float l=length(p);
	for (int i=0; i<iterations; i++) {
		p=abs(p-fold)+fold;
		p=p*scale-translate;
		if (length(p)>20.) break;
		p=rotateOpt(p, rotv );
		average+=p;
	}
	//aacolor=vec3(1.0)*length(average);
	aacolor=vec3(average.x,0,average.y);
    float alpha = clamp(length(aacolor)/2,0.0,1.0);
	if(alpha<0.5) alpha = 0.0;
	
	//gl_FragColor = vec4(aacolor/(antialias*antialias),1.0);
	
	vec4 texColor  = texture2D(background, gl_FragCoord.xy/iResolution.xy ).rgba;
    gl_FragColor   = mix(texColor, vec4(1, 0, 0, 0), 1.0-alpha);
	//gl_FragColor   = mix(texColor, vec4(1, 0, 0, 0), 0.01);
}
