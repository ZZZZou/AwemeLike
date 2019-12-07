attribute vec3 attPosition;
attribute vec2 attUV;
uniform mat4 u_MVP;
varying vec2 g_vary_Texcoord;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.w = 1.0;
  tmpvar_1.xyz = attPosition;
  g_vary_Texcoord = attUV;
  gl_Position = (u_MVP * tmpvar_1);
}

