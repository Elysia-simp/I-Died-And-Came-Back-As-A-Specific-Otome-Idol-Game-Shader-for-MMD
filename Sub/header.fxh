#include <sub/textures.fxh>
float4x4 mmd_world : WORLD;
float4x4 mmd_view  : VIEW;
float4x4 mmd_wvp   : WORLDVIEWPROJECTION;
float4x4 mmd_p : PROJECTION;
float4x4 mmd_vp : VIEWPROJECTION;
float4x4 model_world : CONTROLOBJECT < string name = "(self)"; >;
float3 mmd_cameraPosition : POSITION < string Object = "Camera"; >;
float3 light_d : DIRECTION < string Object = "Light"; >;
float4 egColor;