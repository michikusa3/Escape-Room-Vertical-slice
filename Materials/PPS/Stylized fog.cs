using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[System.Serializable]
[PostProcess( typeof( StylizedFogRenderer ), PostProcessEvent.AfterStack, "Custom/Stylized Fog" )]
public sealed class PostProcess_StylizedFog : PostProcessEffectSettings
{
	#region Shader Parameters

	public ColorParameter FogColor = new ColorParameter { value = new Color( 1, 1, 1, 1 ) };

	[Range( 0, 1 )]
	public IntParameter UseStylizedFogTexture = new IntParameter { value = 0 };

	public TextureParameter StylizedFogTexture = new TextureParameter { };

	public FloatParameter FogMinDistance = new FloatParameter { value = 0 };

	public FloatParameter FogMaxDistance = new FloatParameter { value = 100 };

	[Range( 0, 1 )]
	public IntParameter IsExponential = new IntParameter { value = 1 };

	[Range( 0f, 10f )]
	public FloatParameter ExponentialDensity = new FloatParameter { value = 1f };

	[Range( 0f, 1f )]
	public FloatParameter FogIntensity = new FloatParameter { value = 1 };

	[Range( 0f, 1f )]
	public FloatParameter FogOpacityMax = new FloatParameter { value = 1 };

	#endregion

	public override bool IsEnabledAndSupported( PostProcessRenderContext context )
	{
		return enabled.value;
	}
}

public sealed class StylizedFogRenderer : PostProcessEffectRenderer<PostProcess_StylizedFog>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "Hidden/Stylized Fog" ) );

		sheet.properties.SetColor( "FogColor", settings.FogColor );
		sheet.properties.SetInt( "UseStylizedFogTexture", settings.UseStylizedFogTexture );

		if ( settings.StylizedFogTexture != null )
			sheet.properties.SetTexture( "StylizedFogTexture", settings.StylizedFogTexture );

		sheet.properties.SetFloat( "FogMinDistance", settings.FogMinDistance );
		sheet.properties.SetFloat( "FogMaxDistance", settings.FogMaxDistance );
		sheet.properties.SetInt( "IsExponential", settings.IsExponential );
		sheet.properties.SetFloat( "ExponentialDensity", settings.ExponentialDensity );
		sheet.properties.SetFloat( "FogIntensity", settings.FogIntensity );
		sheet.properties.SetFloat( "FogOpacityMax", settings.FogOpacityMax );

		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}