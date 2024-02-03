component {
	property name="cpdService"                     inject="CPDService";
	property name="siteTreeService"                inject="SiteTreeService";
	property name="presideObjectService"           inject="presideObjectService";
	property name="memberService"                  inject="MemberService";
	property name="pixl8CrmMembershipPortalService" inject="pixl8CrmMembershipPortalService";

	public function preHandler( event ){
		event.cachePage(false);

		if ( !isLoggedIn() ) {
			event.accessDenied( reason="LOGIN_REQUIRED" );
		}
	}

	private function index( event, rc, prc, args={} ) {
		args.maxRows        = event.getPageProperty( propertyName="result_per_page", defaultValue=10 );
		args.availableSorts = _getAvailableSorts();
		prc.filters         = getAllFilters( argumentCollection = arguments );
		args.cpdChartBg     = _getChartColour();
		var chartData       = _getCPDCategoryActivity();
		args.cpdChartData   = "";
		args.cpdChartLabels = "";

		for( var item in chartData.cpdCategory ){
			args.cpdChartData   = listAppend( args.cpdChartData , chartData.cpdCategory[item] );
			args.cpdChartLabels = listAppend( args.cpdChartLabels , item );
		}

		if( listLen( args.cpdChartData ) < 2 ){
			args.cpdChartData = listAppend( args.cpdChartData, 0 );
		}

		args.totalCreditLogged = isNumeric( chartData.totalCreditLogged?:'' ) && ( chartData.totalCreditLogged > 0 ) ? chartData.totalCreditLogged : 0;
		args.lastLoggedDate    = chartData.endDate ?: now();

		event.includeData( {
			  resultsContainer       = "##result-section"
			, resultEndpoint         = event.buildLink( linkTo="page-types.cpd_listing.resultSection" )
			, maxRows                = args.maxRows
			, urlSelectedDate        = listToArray( rc.date ?: "" )
			, downloadReportEndpoint = event.buildLink( linkTo="page-types.cpd_listing.getReport" )
			, chartEndpoint          = event.buildLink( linkto="page-types.cpd_listing.getChart" )
			, chartContainer         = ".cpd-chart"
		} ).include( 'resource-loader' );

		return renderView(
			  view          = 'page-types/cpd_listing/index'
			, presideObject = 'cpd_listing'
			, id            = event.getCurrentPageId()
			, args          = args
		);
	}

	public struct function getAllFilters( event, rc, prc, args={} ) {
		return {
			  type     = _getActivityTypeFilter( argumentCollection = arguments )
			, category = _getActivityCategoryFilter( argumentCollection = arguments )
		};
	}

	public string function ajaxLoadMoreResult( event, rc, prc, args={} ) {
		args.cpdActivities = _getCpdActivities( argumentCollection = arguments );

		return renderView(
			  view     = "/page-types/cpd_listing/_resultItem"
			, noLayout = true
			, args     = args
		);
	}

	public string function resultSection( event, rc, prc, args={} ) {
		args.cpdActivities = _getCpdActivities( argumentCollection = arguments );

		if( !args.cpdActivities.recordCount() ){
			args.noResultMessage = presideObjectService.selectData(
				  objectName   = "cpd_listing"
				, selectFields = ['no_activity_message']
			).no_activity_message;
		}

		args.totalResults = _getCpdActivities( argumentCollection = arguments, recordCountOnly=true ).totalRecord;

		return renderView(
			  view     = "/page-types/cpd_listing/_resultSection"
			, args     = args
			, noLayout = true
		);
	}

	public function getReport( event, rc, prc, args={} ) {
		args.cpdCategoryActivity = _getCPDCategoryActivity( argumentCollection = arguments  );
		var selectFields         = [ "report_detail_title", "report_detail_description", "report_footer" ];

		args.reportContent = presideObjectService.selectData(
			  objectName   = "cpd_listing"
			, selectFields = selectFields
		);

		args.loggedInContactDetails = pixl8CrmMembershipPortalService.getLoggedInContact();
		args.subscription           = memberService.getSubscription( contactId=args.loggedInContactDetails.id?:"" );

		if( !isEmptyString( rc.cpd_date ?: "" ) ){
			var fixedCPDDate = rc.cpd_date;
			if( listFind( fixedCPDDate, 'past_week') ){
				args.dateFrom = dateAdd( 'ww', -1, now() )
			}
			if( listFind( fixedCPDDate, 'past_month') ){
				args.dateFrom = dateAdd( 'm', -1, now() )
			}
			if( listFind( fixedCPDDate, 'past_year') ){
				args.dateFrom = dateAdd( 'yyyy', -1, now() )
			}

			args.dateFrom = dateFormat( args.dateFrom ?: "", "yyyy-mm-dd" );
		} else {
			args.dateFrom = !isEmptyString( rc.cpd_date_from ?: "" ) ? dateFormat( rc.cpd_date_from, "yyyy-mm-dd" ) : "";
			args.dateTo   = !isEmptyString( rc.cpd_date_to   ?: "" ) ? dateFormat( rc.cpd_date_to, "yyyy-mm-dd"   ) : dateFormat( now(), "yyyy-mm-dd" );
		}

		args.hasFilters  = !isEmptyString( args.dateFrom ?: "" ) || !isEmptyString( args.dateTo ?: "" ) || !isEmptyString( rc.category ?: "" ) || !isEmptyString( rc.type ?: "" );

		return renderView( view='/page-types/cpd_listing/pdf/report', args=args );
	}

	public function getChart( event, rc, prc, args={} ){
		args.cpdChartBg     = _getChartColour();
		var chartData       = _getCPDCategoryActivity( argumentCollection = arguments );
		args.cpdChartData   = "";
		args.cpdChartLabels = "";

		for( var item in chartData.cpdCategory ){
			args.cpdChartData   = listAppend( args.cpdChartData , chartData.cpdCategory[item] );
			args.cpdChartLabels = listAppend( args.cpdChartLabels , item );
		}

		if( listLen( args.cpdChartData ) < 2 ){
			args.cpdChartData = listAppend( args.cpdChartData, 0 );
		}

		args.totalCreditLogged = isNumeric( chartData.totalCreditLogged?:'' ) && ( chartData.totalCreditLogged > 0 ) ? chartData.totalCreditLogged : 0;
		args.lastLoggedDate    = chartData.endDate ?: now();

		return renderView( view="/page-types/cpd_listing/_cpdChart", args=args );
	}

//Detail page
	public function detail( event, rc, prc, args={} ){
		var cpdid = prc.cpdid ?: "";

		args.cpdDetails = cpdService.getCpdActivityById( activityId=cpdid );

		if ( !args.cpdDetails.recordCount ) {
			setNextEvent( url=event.buildLink( page="cpd_listing" ) );
		}

		var parentPage = siteTreeService.getPage( systemPage="cpd_listing" );

		event.initializeDummyPresideSiteTreePage(
			  parentPage = parentPage
			, id         = args.cpdDetails.id
			, page_type  = "cpd_detail"
			, title      = args.cpdDetails.label
		);

		event.setEditPageLink( event.buildAdminLink( linkTo="datamanager.editRecord", queryString="object=cpd_activity&id=#args.cpdDetails.id#" ) );

		prc.pageLayoutBody = renderView( view="page-types/cpd_listing/detail/index", args=args );
		prc.pageLayout     = "twocol";

		event.setView( view="/general/_pageLayout" );
	}

	public function deleteCpdActivity( event, rc, prc, args={} ){
		var loggedInContact = pixl8CrmMembershipPortalService.getLoggedInContactId();
		var cpdId           = rc.cpdId ?: "";
		var success         = false;

		var selectedCpd = cpdService.getCpdActivityById( activityId=cpdId, includeInactive=true );

		if( selectedCpd.recordCount ){
			success = cpdService.deactivateCpdActivity( activityId=cpdId );
		}

		if( success ){
			setNextEvent( url=event.buildLink( page="cpd_listing" ), persistStruct={ successMessage="The CPD Activity record has been removed successfully." } );
		} else {
			setNextEvent( url=event.buildLink( cpdid=cpdId ), persistStruct={ errorMessage="There was an error when performing the action, please try again later." } );
		}
	}

//Private helpers
	private array function _getAvailableSorts(){
		return [
			  { label="Most recent" , value="recent"   }
			, { label="Oldest"      , value="oldest"   }
		];
	}

	private query function _getActivityTypeFilter( event, rc, prc, args={} ) {
		return _getCpdActivities( argumentCollection = arguments, getFilter="type"  );
	}

	private query function _getActivityCategoryFilter( event, rc, prc, args={} ) {
		return _getCpdActivities( argumentCollection = arguments, getFilter="category" );
	}

	private query function _getCpdActivities( event, rc, prc, args={} ) {
		var maxRows = args.maxRows ?: ( isNumeric( rc.maxRows ?: "" ) && rc.maxRows <= 999999 ? rc.maxRows : 10 ) ;
		if( isBoolean( arguments.getAll ?: "" ) && arguments.getAll ){
			maxRows = 9999999;
		}


		var dateFilter   = "";
		var fixedCPDDate = rc.cpd_date ?: "";
		if( isDate( rc.cpd_date_from ?: "" ) ){
			dateFilter = rc.cpd_date_from;
			if( isDate( rc.cpd_date_to ?: "" ) ){
				dateFilter = listAppend( dateFilter, rc.cpd_date_to );
			} else {
				dateFilter = listAppend( dateFilter, now() );
			}
		} else if( isDate( rc.cpd_date_to ?: "" ) ){
			dateFilter = "01 Jan 1970";
			dateFilter = listAppend( dateFilter, rc.cpd_date_to );
		} else if( !isEmpty( fixedCPDDate ) ){
			if( listFind( fixedCPDDate, 'past_week') ){
				dateFilter = dateAdd( 'ww', -1, now() )
			}
			if( listFind( fixedCPDDate, 'past_month') ){
				dateFilter = dateAdd( 'm', -1, now() )
			}
			if( listFind( fixedCPDDate, 'past_year') ){
				dateFilter = dateAdd( 'yyyy', -1, now() )
			}
			dateFilter = listAppend( dateFilter, now() );
		} else {
			var todayYear  = year( now() );
			var startDate = createDate( todayYear , 3 , 1 );
			var endDate  = createDate( todayYear+1 , 2 , 28 );


			dateFilter = dateFormat( startDate, "dd-mm-yyyy" );
			dateFilter &= ",#dateFormat( endDate, "dd-mm-yyyy" )#";
		}

		return cpdService.getContactCpdActivity(
			  startRow          = isNumeric( rc.startRow ?: "" ) && rc.startRow <= 9999 ? rc.startRow : 1
			, maxRows           = maxRows
			, activityType      = !isEmpty( arguments.getFilter ?: "" ) ? "" : ( rc.type     ?: "" )
			, activityCategory  = !isEmpty( arguments.getFilter ?: "" ) ? "" : ( rc.category ?: "" )
			, activityDate      = !isEmpty( arguments.getFilter ?: "" ) ? "" : dateFilter
			, sortBy            = rc.sortBy   ?: "recent"
			, recordCountOnly   = isBoolean( arguments.recordCountOnly ?: "" ) && arguments.recordCountOnly
			, getFilter         = arguments.getFilter       ?: ""
			, groupBy           = arguments.groupBy         ?: ""
		);
	}

	private struct function _getCPDCategoryActivity( event, rc, prc, args={} ) {
		var cpdActivities = _getCpdActivities( argumentCollection = arguments, getAll=true );

		var cpdCategoryActivity = {
			  cpdActivities     = cpdActivities
			, cpdCategory       = {}
			, totalCreditLogged = 0
			, cpdCategoryOrder  = []
			, endDate           = ''
			, startDate         = ''
		};

		for( var item in cpdActivities ){
			if( !len( trim( item.activity_category ) ) ){
				item.activity_category ="Event";
			} else {
				item.activity_category = renderLabel( 'activity_category', item.activity_category );
			}
			if( !structKeyExists( cpdCategoryActivity.cpdCategory, item.activity_category ) ){
				cpdCategoryActivity.cpdCategory[item.activity_category]=item.credit_logged;
				cpdCategoryActivity.cpdCategoryOrder.append( item.activity_category );
			} else {
				cpdCategoryActivity.cpdCategory[item.activity_category]+=item.credit_logged;
			}
			cpdCategoryActivity.totalCreditLogged += item.credit_logged;

			if( isEmpty( cpdCategoryActivity.endDate ) ){
				cpdCategoryActivity.endDate = item.completed_date;
			} else {
				if( item.completed_date >= cpdCategoryActivity.endDate ){
					cpdCategoryActivity.endDate = item.completed_date;
				}
			}

			if( isEmpty( cpdCategoryActivity.startDate ) ){
				cpdCategoryActivity.startDate = item.completed_date;
			} else {
				if( item.completed_date <= cpdCategoryActivity.startDate ){
					cpdCategoryActivity.startDate = item.completed_date;
				}
			}
		}

		cpdCategoryActivity.cpdCategoryOrder = cpdCategoryActivity.cpdCategoryOrder.sort('text','asc' );

		return cpdCategoryActivity;
	}

	private string function _getChartColour() {
		return "##E30613,##F17300,##CAA8F5,##9984D4,##592E83,##230C33,##03064C";
	}
}