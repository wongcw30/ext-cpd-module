<cfscript>
	public query function getAssetDetail( required string id, array selectFields ){
		return getModel('assetManagerService').getAsset( argumentCollection=arguments );
	}
</cfscript>