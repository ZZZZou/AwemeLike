precision lowp float;
varying highp vec2 uv0;
uniform sampler2D u_Scene_InputTexture0;
void main()
{
    gl_FragColor = texture2D(u_Scene_InputTexture0, uv0);
}
