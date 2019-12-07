attribute   vec3 attPosition;
uniform     mat4 u_MVP;

void main()
{
    gl_Position = u_MVP * vec4(attPosition, 1.0);
}
