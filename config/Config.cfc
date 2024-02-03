component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_setupAssetFolder( settings );
	}

	private void function _setupAssetFolder( required struct settings  ) {
		settings.assetmanager.folders.cpdFolder = {
			  label             = "CPD"
			, hidden            = false
			, inEditor          = false
		};
	}
}

