<cf_presideparam name="args.title"         field="page.title"        editable="true" />
<cf_presideparam name="args.main_content"  field="page.main_content" editable="true" />

<cfscript>
	cpdDetails    = args.cpdDetails ?: QueryNew("");
	cpdActivityId = Len( Trim( cpdDetails.id ?: "" ) ) ? cpdDetails.id : ( rc.cpdId ?: "" );

	event.include( "/css/specific/cpd/" )
		 .include( "/css/specific/cpd-theme/" );
</cfscript>

<cfoutput>
	#args.main_content#

	<form action="#event.buildLink( linkTo="page-types.log_cpd_activity_page.submitCpdActivityAction" )#" method="POST">
		<input type="hidden" name="csrfToken" value="#event.getCsrfToken()#">
		<cfif Len( Trim( cpdActivityId ) )>
			<input type="hidden" name="cpdId" value="#cpdActivityId#">
		</cfif>

		#renderForm(
			  formName         = "cpd.cpd-activity"
			, context          = "website"
			, fieldLayout      = "pixl8crm.forms.formFieldLayoutColumns"
			, fieldsetLayout   = "pixl8crm.forms.formFieldsetLayout"
			, tabLayout        = "pixl8crm.forms.formTabLayout"
			, formLayout       = "pixl8crm.forms.formLayout"
			, additionalArgs   = args.additionalArgs ?: {}
			, savedData        = rc.formData         ?: {}
			, validationResult = rc.validationResult ?: ""
		)#

		<div class="return-link-holder cpd-detail-return-link-holder">
			<a href="#event.buildLink( page="cpd_listing" )#" class="return-link">#translateResource( "page-types.log_cpd_activity_page:return_to_listing.label" )#</a>

			<div class="right-cta">
				<button type="submit" class="btn">#translateResource( "page-types.log_cpd_activity_page:#cpdDetails.recordCount ? 'update' : 'submit'#.cpdactivity.label")#</button>
			</div>
		</div>
	</form>
</cfoutput>