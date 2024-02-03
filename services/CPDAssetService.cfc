/**
 * @singleton true
 * @presideService
 */
component {
	/**
	 * @AssetManagerService.inject assetManagerService
	 */
	public any function init(
		required any assetManagerService
	) {
		_setAssetManagerService( arguments.assetManagerService );
		return this;
	}

	public struct function uploadAsset( struct uploadDetails, string folder = "", string assetId = "" ) {
		var newlyUploadedAssetId = "";
		var currentTime          = timeformat(now(),'hhmmssl');

		if( Len( Trim( arguments.uploadDetails.fileName ) ) ) {
			var originalFilename = Trim( arguments.uploadDetails.fileName );

			try {

				var folderDetails  = _getAssetManagerService().getFolder( id=arguments.folder, includeHidden=true );
				var assetSize      = Len( arguments.uploadDetails.binary );
				var maxSizeAllowed = isNumeric( folderDetails.max_filesize_in_mb ?: '' ) ? folderDetails.max_filesize_in_mb * 1000000 : "";

				if( isNumeric( maxSizeAllowed ) && assetSize > maxSizeAllowed ){
					return { success=0, errorMsg="Could not add asset, attachment size exceeds the allowable limit ( #folderDetails.max_filesize_in_mb# MB )." }
				}

				if( Len( Trim( arguments.assetId ) ) ){

					_getAssetManagerService().addAssetVersion(
						  assetId    = arguments.assetId
						, fileBinary = arguments.uploadDetails.binary
						, fileName   = originalFilename
					);

					return { success=1, assetId=arguments.assetId }
				} else {
					newlyUploadedAssetId = _getAssetManagerService().addAsset(
						  fileBinary = arguments.uploadDetails.binary
						, fileName   = originalFilename
						, folder     = arguments.folder
						, assetData  = {
							  title          = listFirst( originalFilename, "." ) & "_" & currentTime & "." & listLast( originalFilename, "." )
							, original_title = listFirst( originalFilename, "." )
							, size           = arguments.uploadDetails.size
						}
					);
					return { success=1, assetId=newlyUploadedAssetId }
				}

			} catch( any e ) {
				return { success=0, errorMsg="Could not add Asset, Details were #e.detail# : #e.message#" }
			}
		}
	}


	public array function searchAssets( array ids=[] ) {
		var assetDao    = $getPresideObject( "asset" );
		var filter      = "( asset.is_trashed = :is_trashed )";
		var params      = { is_trashed = false };
		var records     = "";
		var result      = [];

		if ( arguments.ids.len() ) {
			filter &= " and ( asset.id in (:id) )";
			params.id = { value=ArrayToList( arguments.ids ), list=true };
		}

		records = assetDao.selectData(
			  selectFields = [ "asset.id", "asset.title as label", "asset.size", "asset.width", "asset.height", "'' as path", "asset.asset_type" ]
			, filter       = filter
			, filterParams = params
		);

		for( var record in records ){
			record.folder = record.folder ?: "";
			result.append( record );
		}

		return result;
	}

// GETTERS AND SETTERS
	private any function _getAssetManagerService() {
		return _assetManagerService;
	}
	private void function _setAssetManagerService( required any AssetManagerService ) {
		_assetManagerService = arguments.AssetManagerService;
	}

}