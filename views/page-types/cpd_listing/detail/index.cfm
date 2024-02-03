<cfscript>
	cpdDetails = args.cpdDetails ?: queryNew('');
	messages = renderView( view="/pixl8crm/util/_messages" );

	event.include( "/css/specific/cpd/" )
		 .include( "/css/specific/cpd-theme/" );
</cfscript>
<cfoutput>
	<cfif len( trim ( messages ) )>
		<div class="pixl8-crm-page-messages">#messages#</div>
	</cfif>

	<h1 class="page-title cpd-page-title" >#cpdDetails.label#</h1>

	<div class="widget widget-meta">
		<dl class="cpd-meta-list">
			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:activity_type.meta.title" )#</dt>
				<dd class="cpd-meta cpd-meta-definition"><span class="badge">#renderLabel( 'activity_type', cpdDetails.activity_type )#</span></dd>
			</div>

			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:activity_category.meta.title" )#</dt>
				<dd class="cpd-meta cpd-meta-definition"><span class="badge">#renderLabel( 'activity_category', cpdDetails.activity_category )#</span></dd>
			</div>

			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:date_completed.meta.title" )#</dt>
				<dd class="cpd-meta cpd-meta-definition">#dateFormat( cpdDetails.completed_date, 'dd mmm yyyy' )#</dd>
			</div>

			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:credit_logged.meta.title" )#</dt>
				<dd class="cpd-meta cpd-meta-definition">#cpdDetails.credit_logged# point(s)</dd>
			</div>
		</dl>
	</div>

	<p>#renderContent( renderer="richeditor", data=cpdDetails.description )#</p>

	<cfif !isEmpty( cpdDetails.supporting_documents?:'' )>
		<div class="widget widget-document">
			<h4 class="widget-title">Supporting documents</h4>

			<div class="document-list">
				<cfloop array="#listToArray( cpdDetails.supporting_documents )#" item="asset">
					<cfset assetDetail = getAssetDetail( asset )>
					<div class="document-item">
						<a href="#event.buildLink( assetId = asset )#" target="_blank" class="document-link">
							<span class="document-link-icon font-icon-general"></span>
							#assetDetail.title#
						</a>
					</div>
				</cfloop>

			</div>
		</div>
	</cfif>

	<cfif !isEmpty( cpdDetails.reflective_learning_note ?: "") >
		<h4>Reflective learning notes</h4>
		<p>#renderContent( renderer="richeditor", data=paragraphFormat(cpdDetails.reflective_learning_note) )#</p>
	</cfif>

	<div class="return-link-holder cpd-detail-return-link-holder">
		<a href="#event.buildLink( page='cpd_listing' )#" class="return-link">Return to My CPD area</a>
			<div class="right-cta">
				<a href="#event.buildLink( page="log_cpd_activity_page", queryString="cpdid=#cpdDetails.id#" )#" class="btn btn-bordered">Edit record</a>
				<a href="#event.buildLink( linkTo="page-types.cpd_listing.deleteCpdActivity", queryString="cpdId=#cpdDetails.id#" )#" onclick="return confirm('Are you sure you want to delete this CPD Activity record?')" class="btn btn-bordered js-delete-cpd">Delete</a>
			</div>
	</div>

</cfoutput>