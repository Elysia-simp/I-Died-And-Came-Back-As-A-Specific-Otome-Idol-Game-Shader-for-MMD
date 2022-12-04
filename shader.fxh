//includes
#include <sub/header.fxh>
#include <HgShadow_ObjHeader.fxh>
//

//base structure
struct vs_in
{
    float4 pos          : POSITION;
    float3 normal       : NORMAL;
    float2 uv            : TEXCOORD0;
    float4 vertexcolor   : TEXCOORD2; 

};


struct vs_out
{
    float4 pos          : POSITION;
    float2 uv           : TEXCOORD0;
    float4 vertex       : TEXCOORD1;
    float3 normal       : TEXCOORD2;
    float3 view         : TEXCOORD3;
    float4 ppos         : TEXCOORD4; //hgshadow stuff idk if anything else uses ppos
};

struct edge_out
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float4 texlod : TEXCOORD1;
    float3 normal : NORMAL;
    float4 vertex : TEXCOORD2;
};

vs_out vs_model (vs_in i)
{
    vs_out o; //seriously stop writing OUT/IN in full
    //also could of used just vs_out o; but i use this to fix an error in unity and idfk if it affects mmd
    //but my other shaders work with this so deal with it lol
    o.pos = mul(i.pos, wvpMatrix());
    o.uv = i.uv;
	o.normal = normalize(mul((float3x3) mmd_world, i.normal));
    o.view = mmd_cameraPosition - mul(i.pos.xyz, (float3x3)mmd_world);
    o.vertex = i.vertexcolor;
    o.ppos = o.pos;
    return o;
}

edge_out vs_edge (vs_in i)
{
    edge_out o = (edge_out)0;
    o.uv = i.uv;
     o.texlod = tex2Dlod(EdgeMaskSampler, float4(i.uv.xy, 0, 0));
    if(use_edgemask == 1)
    {
    o.vertex = i.vertexcolor;
    o.vertex = (o.vertex < 1.0) ? 1 : 0;
    o.texlod = tex2Dlod(EdgeMaskSampler, float4(i.uv.xy, 0, 0));
    i.pos.xyz = i.pos.xyz + i.normal * o.vertex * 0.015 ;
    }
    else{
    i.pos.xyz = i.pos.xyz + i.normal  * 0.015 ;
    }
    o.pos = mul(i.pos, mmd_wvp);
    return o;
}

float4 ps_edge(edge_out i) : COLOR0
{
    float4 color = float4(0,0,0,1);
    return color;
}

float4 ps_model(vs_out i, float vface : VFACE) : COLOR0
{
    //hgshadow
    float comp = 1.0;
    if(HgShadow_Valid)
    {
        comp = HgShadow_GetSelfShadowRate(i.ppos);
    }
    //cause i know my ass isnt writing i.[func] all day
    float2 uv = i.uv;
    float3 view = normalize(i.view);
    float3 normal = i.normal;
    float4 color = 1; //intialize color
    //Textures
    float4 diffuse = tex2D(diffuseSampler, uv); //self explanatory
    float4 ShadowTex = tex2D(ShadowSampler, uv); //shadow color
    float4 Lightmap = tex2D(LightSampler, uv); //r = AO, g = unused(?), b = Specular, a = not used
    
    

    color = diffuse;
    //dots
    float ndotv = saturate(1 - (dot(normal, view)));//rimlight
    ndotv *= normalize(normal.y + (normal.x * 0.6)); //theirs is a lot more complicated than this but i'd have to write a completely different processing for this
    //if/when i look back on this i'll make it a dedicated post effect instead

    float ndotl =(min(dot(normal - Lightmap.r, -light_d), comp)); //lighting
    
    float ndoth = pow(dot(normal, normalize(view + -light_d)), 2.5) * Spec_bright; //specular
    ndoth = clamp(0, 1, ndoth);// as far as im aware there's no texture ramp for this..
    //so clamp we go

    //toon
    float4 ToonTex = tex2D(ToonSampler, ndotl); //sample ndotl
    //rimlight
    float4 rim = tex2D(RimSampler, ndotv); //sample ndotv

    //also note for when you deal with ramp textures always CLAMP them
    //wrap will give you several errors

    //lerps
    if (use_subtexture){
        color.rgb = lerp(ShadowTex.rgb, color.rgb, ToonTex);
        color.rgb = lerp(color.rgb, color.rgb + Lightmap.b, ndoth);
        color.rgb = lerp(color.rgb, color.rgb + rim, rim);
    } else if(!use_subtexture){
        color.rgb = lerp(color.rgb, Lightmap.rgb, Lightmap.a);
        color.rgb = lerp(color.rgb, ShadowTex.rgb, ShadowTex.a);
    }

    color.rgb *= egColor;
    #ifdef is_stencil
    color.a *= stencil_effectiveness;
    #endif

    return color;
}
//end of pixel shader
technique model_SS_tech <string MMDPASS = "object_ss"; >
{
    pass main
    {
        cullmode = NONE;
        VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
    }
    #ifdef is_stencil
    pass mayu_stencil
    {
        cullmode = ccw;
        ZEnable = FALSE;
        VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
    }
    #endif
    pass outline
    {
        cullmode = cw;
        VertexShader = compile vs_3_0 vs_edge();
        PixelShader = compile ps_3_0 ps_edge();
    }
}

technique model_tech <string MMDPASS = "object"; >
{
    pass main
    {
        cullmode = NONE;
        VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
    }
    #ifdef is_stencil
    pass mayu_stencil
    {
        cullmode = ccw;
        ZEnable = FALSE;
        VertexShader = compile vs_3_0 vs_model();
        PixelShader = compile ps_3_0 ps_model();
    }
    #endif
    pass outline
    {
        cullmode = cw;
        VertexShader = compile vs_3_0 vs_edge();
        PixelShader = compile ps_3_0 ps_edge();
    }
}
