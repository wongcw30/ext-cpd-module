component {
	property name="cpdService" inject="CPDService";
	property name="siteTreeService"         inject="SiteTreeService";

	public function preHandler( event ){
		if ( !isLoggedIn() ) {
			event.accessDenied( reason="LOGIN_REQUIRED" );
		}

		if ( action.endsWith( "action" ) && !event.validateCsrfToken( rc.csrftoken ?: "" ) ) {
			var persist        = StructCopy( event.getCollectionWithoutSystemVars() );
			    persist.message = "CSRF_VALIDATION_FAILED";
			setNextEvent( url=cgi.http_referer, persistStruct=persist );
		}
	}

	private function index( event, rc, prc, args={} ) {
		if ( structKeyExists( rc, "cpdid" ) && !isStruct( rc.formData ?: "" ) ) {
			args.cpdDetails = cpdService.getCpdActivityById( rc.cpdid );
			if ( !args.cpdDetails.recordCount ) {
				setNextEvent( url=event.buildLink( page="cpd_listing" ) );
			} else {
				if( structIsEmpty( rc.formData?:{} ) ){
					rc.formData = {};
					structAppend( rc.formData, queryRowToStruct( args.cpdDetails ) );
				}
			}
		}

		var maximumUploadFiles = event.getPageProperty( propertyName="maximum_upload", defaultValue="5" );
		var maximumSize        = event.getPageProperty( propertyName="maximum_size", defaultValue="10" );

		args.additionalArgs = {
			  fields = {
				  completed_date       = { maxDate=now() }
				, supporting_documents = { numFiles=maximumUploadFiles, maximumFileSize=maximumSize }
			}
		};

		return renderView(
			  view          = 'page-types/log_cpd_activity_page/index'
			, presideObject = 'log_cpd_activity_page'
			, id            = event.getCurrentPageId()
			, args          = args
		);
	}

	public function submitCpdActivityAction( event, rc, prc, args={} ) {
		var postUrl          = event.buildLink( page="log_cpd_activity_page" );
		var forms            = event.getSubmittedPresideForms();
		var formData         = event.getCollectionForForm();
		var validationResult = NullValue();
		var persistStruct    = {};
		var cpdActivity      = queryNew('');
		var pageDetails      = siteTreeService.getPage( systemPage="log_cpd_activity_page" );
		var pageExtendedProps = siteTreeService.getExtendedPageProperties( id=pageDetails.id?:"",pageType="log_cpd_activity_page" );

		for( var formName in forms ) {
			validationResult = validateForm(
				  formName         = formName
				, formData         = formData
				, validationResult = local.validationResult ?: NullValue()
				, preProcessData   = false
			);
		}

		persistStruct.validationResult = validationResult;

		if ( !isEmpty( rc.cpdId ?: "" ) ) {
			cpdActivity  = cpdService.getCpdActivityById( rc.cpdId );
			if( !cpdActivity.recordCount ){
				persistStruct.errorMessage = pageExtendedProps.not_found_message?:"";
			}
			postUrl = event.buildLink( page="log_cpd_activity_page", queryString="cpdid=#rc.cpdid#" );
		}

		var futureDate = isDate( formData.completed_date ?: "" ) && dateDiff( "d", dateFormat( now(), "yyyy-mm-dd" ), formData.completed_date ) > 0;
		if ( futureDate ) {
			persistStruct.validationResult.addError( "completed_date", translateResource( "preside-objects.cpd_activity:validation.future_date" ) );
		}

		if( len( formData.reflective_learning_note ?: '' ) < 50 ){
			persistStruct.validationResult.addError( "reflective_learning_note", translateResource( "preside-objects.cpd_activity:validation.reflective_learning_note" ) );
		}

		if ( !validationResult.validated() ) {
			structAppend( persistStruct , formData );
			persistStruct.errorMessage = pageExtendedProps.failed_message?:"";
		} else {
			formData.contact = getLoggedInUserDetails().crm_contact ?: "";
			persistStruct.successMessage = pageExtendedProps.success_message ?: "";

			if ( !cpdActivity.recordCount ) {
				cpdService.addCpdActivity( formData=formData );
				postUrl = event.buildLink( page="cpd_listing" );
			} else{
				cpdService.updateCpdActivity( formData=formData, id=cpdActivity.id );
				postUrl = event.buildLink( cpdid=cpdActivity.id );
			}
		}

		setNextEvent( url=postUrl, persistStruct=persistStruct );
	}
}
