component {

	public any function init(){
		return this;
	}

	public boolean function match( required string path, required any event ){
		return reFind( "^\/?cpd\/.*\.html$", arguments.path );
	}

	public void function translate( required string path, required any event ){
		var rc  = event.getCollection();
		var prc = event.getCollection( private=true );

		var cpdId = reReplace( arguments.path, "^\/?cpd\/(.*)\.html$", "\1", "ALL" );

		prc.cpdId = cpdId;

		rc.event = "page-types.cpd_listing.detail";
	}

	public boolean function reverseMatch( required struct buildArgs, required any event ){
		return structKeyExists( arguments.buildArgs, "cpdid" );
	}

	public string function build( required struct buildArgs, required any event ){
		return event.getSiteUrl() & "/cpd/#arguments.buildArgs.cpdid#.html";
	}
}