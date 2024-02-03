/**
 * @singleton      true
 * @presideService true
 */
component {
	/**
	* @cpdAssetService.inject CPDAssetService
	*/

	public any function init(
		required any cpdAssetService
	) {
		_setCpdAssetService( arguments.cpdAssetService );
		return this;
	}


	public query function getContactCpdActivity(
		  string  activityType     = ""
		, string  activityCategory = ""
		, string  activityDate     = ""
		, string  contactId        = getLoggedInContactId()
		, string  sortBy           = "recent"
		, boolean recordCountOnly  = false
	) {
		if ( isEmpty( arguments.contactId ) ) { return queryNew(""); };

		var sortOrder = "";
		var q         = new Query();

		q.setDatasource( "preside" );

		switch( arguments.sortBy ) {
			case "oldest":
				sortOrder = "allcpd.completed_date asc"
				break;

			default:
				sortOrder = "allcpd.completed_date desc"
				break;
		}

		var selectSQL =  "*";
		var limit     = "limit #(arguments.startRow-1)#, #arguments.maxRows#";
		var order     = "order by #sortOrder#";
		var where     = "where 1=1";

		if( arguments.recordCountOnly ){
			selectSQL = "count(*) as totalRecord";
			limit     = "";
			order     = "";
		}

		if( !isEmpty( arguments.activityCategory ?: "" ) ){
			where     &= " and activity_category in ( :activity_category )";
			q.addParam( name="activity_category", value=arguments.activityCategory, cfsqltype="cf_sql_varchar", list=true );
		}

		if( !isEmpty( arguments.activityType ?: "" ) ){
			where     &= " and activity_type in ( :activity_type )";
			q.addParam( name="activity_type", value=arguments.activityType, cfsqltype="cf_sql_varchar", list=true );
		}

		if( !isEmpty( arguments.activityDate ?: "" ) ){
			var dateFrom = listFirst( arguments.activityDate );
			var dateTo   = listLast( arguments.activityDate );

			if( listLen( arguments.activityDate ) == 1 ){
				where     &= " and completed_date = :completed_date";
				q.addParam( name="completed_date", value=dateFrom, cfsqltype="cf_sql_date" );
			} else if( listLen( arguments.activityDate ) == 2 ){
				where     &= " and completed_date >= :dateFrom and completed_date <= :dateTo ";
				q.addParam( name="dateFrom", value=dateFrom, cfsqltype="cf_sql_date" );
				q.addParam( name="dateTo", value=dateTo, cfsqltype="cf_sql_date" );
			}
		}

		if( !isEmpty( arguments.getFilter ?: "" ) ){
			selectSQL = "distinct activity_#arguments.getFilter# as id";
			limit     = "";
			order     = "";
			where     &= " and activity_#arguments.getFilter# !=''"
		}

		q.setSQL( "
			select #selectSQL# from (
				select
					  cpd_activity.id
					, cpd_activity.label
					, cpd_activity.activity_category
					, cpd_activity.activity_type
					, cpd_activity.credit_logged
					, cpd_activity.completed_date
					, cpd_activity.description
					, cpd_activity.reflective_learning_note
					, false as isEvent
					from pobj_cpd_activity cpd_activity
					where cpd_activity.contact = :contact and ( cpd_activity.inactive is null or cpd_activity.inactive=0 )

				union all

				select
					  ems_event.id as id
					, ems_event.name as label
					, 'Event'   as activity_category
					, ''   as activity_type
					, ems_event.cpd_points as credit_logged
					, ems_event.end_date as completed_date
					, ''   as description
					, ''   as reflective_learning_note
					, true as isEvent
				from `pobj_ems_attendee` `ems_attendee`
				inner join `pobj_ems_event` `ems_event` on (`ems_event`.`id` = `ems_attendee`.`ems_event`)
				where ems_attendee.website_user = :website_user
					and ems_attendee.attended IS TRUE
					and ems_event.cpd_points IS NOT NULL
					and ems_event.cpd_points > 0

				union all

				select
					  sessions.id as id
					, sessions.name as label
					, 'Event'   as activity_category
					, ''   as activity_type
					, sessions.cpd_points as credit_logged
					, sessions$schedule.date as completed_date
					, ''   as description
					, ''   as reflective_learning_note
					, true as isEvent
				from `pobj_ems_attendee` `ems_attendee`
				inner join `pobj_ems_attendee_session` `ems_attendee_session`
				on (`ems_attendee_session`.`ems_attendee` = `ems_attendee`.`id`)
				inner join `pobj_ems_session` `sessions` on (`sessions`.`id` = `ems_attendee_session`.`ems_session`)
				inner join `pobj_ems_schedule` `sessions$schedule` on (`sessions$schedule`.`id` = `sessions`.`schedule`)
				where ems_attendee.website_user = :website_user
					and ems_attendee.attended IS TRUE
					and sessions.cpd_points IS NOT NULL
					and sessions.cpd_points > 0
			) as allcpd
			#where#
			#!isEmpty( arguments.groupBy ?: "" ) ? "group by #arguments.groupBy#": ''#
			#order#
			#limit#
		");

		q.addParam( name="contact"     , value=arguments.contactId, cfsqltype="cf_sql_varchar" );
		q.addParam( name="website_user", value=$getWebsiteLoggedInUserId(), cfsqltype="cf_sql_varchar" );


		return  q.execute().getResult();
	}

	public query function getCpdActivityById( required string activityId, string contactId=getLoggedInContactId(), boolean includeInactive=false ) {
		if ( isEmpty( arguments.activityId ) ) { return queryNew(""); };

		var extraFilters = [];

		if( $helpers.isFalse( arguments.includeInactive ) ){
			extraFilters.append({
				  filter = "cpd_activity.inactive=0 or cpd_activity.inactive is null"
			});
		}

		var cpdActivity = $getPresideObject( "cpd_activity" ).selectData(
			selectFields = [
				  "cpd_activity.id"
				, "cpd_activity.label"
				, "cpd_activity.contact"
				, "cpd_activity.activity_category"
				, "cpd_activity.activity_type"
				, "cpd_activity.credit_logged"
				, "cpd_activity.completed_date"
				, "cpd_activity.description"
				, "cpd_activity.reflective_learning_note"
				, "'' as supporting_documents"
			]
			, filter = { "cpd_activity.id"=arguments.activityId,  "cpd_activity.contact"=arguments.contactId }
			, extraFilters = extraFilters
		);

		if( !cpdActivity.recordCount ){
			return queryNew('');
		}

		var supportingDocuments = $getPresideObject( "cpd_supporting_document" ).selectData(
			  selectFields = ["supporting_document"]
			, filter       = {
				cpd_activity = cpdActivity.id
			}
		);

		if( supportingDocuments.recordCount ){
			querySetCell( cpdActivity, "supporting_documents", valueList( supportingDocuments.supporting_document ) );
		}

		return cpdActivity;
	}

	public query function getAttendedCpdEvents() {
		return $getPresideObject( "ems_attendee" ).selectData(
			  selectFields = [
			  	  "ems_event.id           AS id"
			  	, "ems_event.name         AS label"
			  	, "ems_event.cpd_points   AS credit_logged"
			  	, "ems_event.end_date     AS completed_date"
			  	, "true                   AS isEvent"
			  ]
			, filter       = "ems_attendee.website_user = :website_user AND ems_attendee.attended IS TRUE AND ems_event.cpd_points IS NOT NULL AND ems_event.cpd_points > 0"
			, filterParams = { website_user = $getWebsiteLoggedInUserId() }
			, orderBy      = "ems_event.date DESC"
			, useCache     = false
		);
	}

	public query function getAttendedCpdSessions() {
		return $getPresideObject( "ems_attendee" ).selectManyToManyData(
			  propertyName = "sessions"
			, selectFields = [
			  	  "sessions.id                    AS id"
			  	, "sessions.name                  AS label"
			  	, "sessions.cpd_points            AS credit_logged"
			  	, "sessions$schedule.date         AS completed_date"
			  	, "true                           AS isEvent"
			  ]
			, filter       = "ems_attendee.website_user = :website_user AND ems_attendee.attended IS TRUE AND sessions.cpd_points IS NOT NULL AND sessions.cpd_points > 0"
			, filterParams = { website_user = $getWebsiteLoggedInUserId() }
			, orderBy      = "sessions$schedule.date DESC"
			, useCache     = false
		);
	}

	public boolean function deactivateCpdActivity( required string activityId ){
		var success = false;
		try{
			success = $getPresideObject( "cpd_activity" ).updateData( id=arguments.activityId, data={ inactive=1 } );
		} catch ( any e ) {
			$raiseError( e );
		}
		return success;
	}

	public string function addCpdActivity( required struct formData ) {
		if( !isEmpty( arguments.formData.supporting_documents ?: "" ) ){
			arguments.formData.supporting_documents = _moveDocumentToAssetManager( arguments.formData.supporting_documents );
		}

		return $getPresideObject( "cpd_activity" ).insertData( data=arguments.formData, insertManyToManyRecords=!isEmpty( arguments.formData.supporting_documents ?: "" ) );
	}

	public array function prepareFilterForUserCpdActivityCount(
		  required numeric count
		,          string  _numericOperator   = "gt"
		,          struct  _pastTime          = {}
	) {
		var paramSuffix = CreateUUId().lCase().replace( "-", "", "all" );
		var params      = {};
		var filter      = "";
		var datefilter  = "";

		if ( IsDate( arguments._pastTime.from ?: ""  ) ) {
			datefilter &= " and completed_date >= :dateFrom#paramSuffix#";
			params[ "dateFrom#paramSuffix#" ] = { type="cf_sql_timestamp", value=arguments._pastTime.from };
		}

		if ( IsDate( arguments._pastTime.to ?: ""  ) ) {
			datefilter &= " and completed_date <= :dateTo#paramSuffix#";
			params[ "dateTo#paramSuffix#" ] = { type="cf_sql_timestamp", value=arguments._pastTime.to };
		}

		var countHaveClause = "having sum(credit_logged) ${operator} #arguments.count#"
		switch ( _numericOperator ) {
			case "eq":
				countHaveClause = countHaveClause.replace( "${operator}", "=" );
			break;
			case "neq":
				countHaveClause = countHaveClause.replace( "${operator}", "!=" );
			break;
			case "gt":
				countHaveClause = countHaveClause.replace( "${operator}", ">" );
			break;
			case "gte":
				countHaveClause = countHaveClause.replace( "${operator}", ">=" );
			break;
			case "lt":
				countHaveClause = countHaveClause.replace( "${operator}", "<" );
			break;
			case "lte":
				countHaveClause = countHaveClause.replace( "${operator}", "<=" );
			break;
		}

		var querySql = "select id from (
				select
					  cpd_activity.credit_logged as credit_logged
					, cpd_activity.contact as id
					, cpd_activity.completed_date
					from pobj_cpd_activity cpd_activity
					where ( cpd_activity.inactive is null or cpd_activity.inactive=0 )

				union all

				select
					  ems_event.cpd_points as credit_logged
					, crm_contact.id as id
					, ems_event.end_date as completed_date
				from `pobj_ems_attendee` `ems_attendee`
				inner join `pobj_ems_event` `ems_event` on (`ems_event`.`id` = `ems_attendee`.`ems_event`)
				inner join `psys_website_user` `website_user` on (`website_user`.`id` = `ems_attendee`.`website_user` )				
				inner join `crm_contact` `crm_contact` on (`crm_contact`.`id` = `website_user`.`crm_contact`)
				where ems_attendee.attended IS TRUE
					and ems_event.cpd_points IS NOT NULL
					and ems_event.cpd_points > 0

				union all

				select
					  sessions.cpd_points as credit_logged
					, crm_contact.id as id
					, sessions$schedule.date as completed_date
				from `pobj_ems_attendee` `ems_attendee`
				inner join `pobj_ems_attendee_session` `ems_attendee_session`
				on (`ems_attendee_session`.`ems_attendee` = `ems_attendee`.`id`)
				inner join `pobj_ems_session` `sessions` on (`sessions`.`id` = `ems_attendee_session`.`ems_session`)
				inner join `pobj_ems_schedule` `sessions$schedule` on (`sessions$schedule`.`id` = `sessions`.`schedule`)
				inner join `psys_website_user` `website_user` on (`website_user`.`id` = `ems_attendee`.`website_user` )				
				inner join `crm_contact` `crm_contact` on (`crm_contact`.`id` = `website_user`.`crm_contact`)
				where ems_attendee.attended IS TRUE
					and sessions.cpd_points IS NOT NULL
					and sessions.cpd_points > 0

			) as allcpd
			where allcpd.id is not null
				#datefilter#
			group by allcpd.id
			#countHaveClause#
		";

		return [ { filter=filter, filterParams=params, extraJoins=[ {
			  type           = "inner"
			, subQuery       = querySql
			, subQueryAlias  = "cpdQuery"
			, subQueryColumn = "id"
			, joinToTable    = "crm_contact"
			, joinToColumn   = "id"
		} ] } ];
	}

	private string function _moveDocumentToAssetManager( required string assets ){

		var copiedFiles = "";

		for ( var item in listToArray( assets ) ){
			if( !isValid( 'UUID', item ) ){
				var uploadedFile = getFileInfo( GetTempDirectory() & "/" & item );

				var fileDetail = {
					  fileName     = uploadedFile.name
					, size         = uploadedFile.size
					, binary       = FileReadBinary( uploadedFile.path )
					, tempFileInfo = uploadedFile
				};

				var document = _getCpdAssetService().uploadAsset( uploadDetails=fileDetail, assetFolder="cpdFolder", assetType="file" );
				if( document.success ){
					copiedFiles = listAppend( copiedFiles, "{ supporting_document='#document.assetId#' }" );
				}
			} else {
				copiedFiles = listAppend( copiedFiles, "{ supporting_document='#item#' }" );
			}
		}

		return copiedFiles;

	}

	public string function updateCpdActivity( required struct formData, required string id ) {

		if( !isEmpty( arguments.formData.supporting_documents ?: "" ) ){
			arguments.formData.supporting_documents = _moveDocumentToAssetManager( arguments.formData.supporting_documents );
		}

		return $getPresideObject( "cpd_activity" ).updateData( data=arguments.formData, id=arguments.id, updateManyToManyRecords=true );
	}

	private string function getLoggedInContactId() {
		var loggedInUserDetails = $getWebsiteLoggedInUserDetails();

		return loggedInUserDetails.crm_contact ?: "";
	}


	private any function _getCpdAssetService() {
		return _cpdAssetService;
	}
	private void function _setCpdAssetService( required any cpdAssetService ) {
		_cpdAssetService = arguments.cpdAssetService;
	}

}