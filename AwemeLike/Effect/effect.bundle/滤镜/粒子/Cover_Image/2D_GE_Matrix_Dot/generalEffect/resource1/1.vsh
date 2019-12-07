
attribute vec4 attPosition;
attribute vec4 Normal;
attribute vec2 attUV;
uniform mat4 Projection;
uniform mat4 Model;
uniform float Time;
uniform float PointSize;
uniform float zMultiplier;
uniform float invertColors;
uniform float zView;
uniform float rotate;
uniform sampler2D Texture;
varying vec2 DestinationTexCoord;
varying vec3 EyeNormal;

vec4 Quat(float angle, vec3 axes)
{
    float fHalfAngle = 0.5 * angle;
    float fSin = sin(fHalfAngle);
    float w = cos(fHalfAngle);
    float x = fSin * axes.x;
    float y = fSin * axes.y;
    float z = fSin * axes.z;
    return vec4(x, y, z, w);
}

mat4 makeTransform(vec3 position, vec3 scale, vec4 orientation)
{
    // Ordering:
    //    1. Scale
    //    2. Rotate
    //    3. Translate
    
    float fTx = orientation.x + orientation.x;
    float fTy = orientation.y + orientation.y;
    float fTz = orientation.z + orientation.z;
    float fTwx = fTx * orientation.w;
    float fTwy = fTy * orientation.w;
    float fTwz = fTz * orientation.w;
    float fTxx = fTx * orientation.x;
    float fTxy = fTy * orientation.x;
    float fTxz = fTz * orientation.x;
    float fTyy = fTy * orientation.y;
    float fTyz = fTz * orientation.y;
    float fTzz = fTz * orientation.z;
    
    mat4 m = mat4(0.0);
    // Set up final matrix with scale, rotation and translation
    m[0][0] = scale.x * (1.0 - (fTyy + fTzz));
    m[1][0] = scale.y * (fTxy - fTwz);
    m[2][0] = scale.z * (fTxz + fTwy);
    m[3][0] = position.x;
    m[0][1] = scale.x * (fTxy + fTwz);
    m[1][1] = scale.y * (1.0 - (fTxx + fTzz));
    m[2][1] = scale.z * (fTyz - fTwx);
    m[3][1] = position.y;
    m[0][2] = scale.x * (fTxz - fTwy);
    m[1][2] = scale.y * (fTyz + fTwx);
    m[2][2] = scale.z * (1.0 - (fTxx + fTyy));
    m[3][2] = position.z;
    
    // No projection term
    m[0][3] = 0.0;
    m[1][3] = 0.0;
    m[2][3] = 0.0;
    m[3][3] = 1.0;
    return m;
}

void main(void) {
    DestinationTexCoord = attUV;
    vec4 wavedPosition = attPosition;
    wavedPosition = attPosition;
    vec2 texturePosition = (attPosition.xy + vec2(1.0)) / 2.0;
    //texturePosition.y = 1.0 - texturePosition.y;
    lowp vec4 color = texture2D(Texture, texturePosition);
    lowp float wpz1 = dot(color.rgb, vec3(1)) / 5.0;
    lowp float wpz2 = dot(vec3(1.0) - color.rgb, vec3(1)) / 5.0;
    wavedPosition.z = mix(wpz1, wpz2, invertColors);
    wavedPosition.z += 0.3;
    wavedPosition.z *= zMultiplier;
    wavedPosition.z -= 0.3;
    vec2 texturePosition_r = vec2(texturePosition.x + 1.0 / 128.0, texturePosition.y);
    float color_r = texture2D(Texture, texturePosition_r).r;
    vec2 texturePosition_b = vec2(texturePosition.x, texturePosition.y + 1.0 / 128.0);
    float color_b = texture2D(Texture, texturePosition_b).r;
    vec2 nShift = vec2(color_r - color.r, color_b - color.r);
    vec4 wavedNormal = wavedPosition;
    wavedNormal.xy += nShift;
    wavedNormal = mix(wavedPosition / 1.1, wavedNormal, zMultiplier);
    EyeNormal = vec3(Model * wavedNormal);
    vec4 positionResult = wavedPosition;
    gl_PointSize = PointSize;
    
    vec3 position = vec3(0.0, 0.0, zView);
    vec3 scale = vec3(1.0, 1.0, 1.0);
    vec3 s = vec3(0.0, 1.0, 0.0);
    vec4 orientation = Quat(rotate, s);
    mat4 viewMat = makeTransform(position, scale, orientation);
    gl_Position = positionResult * viewMat;//viewMatrix(zView, rotate);
}
