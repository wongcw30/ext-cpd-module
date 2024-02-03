<cfscript>
	availableSorts    = args.availableSorts ?: [];
	reportQueryString = [];
	queryFields       = ['category','type','cpd_date','cpd_date_from','cpd_date_to'];
	for( var queryField in queryFields ){
		if( !isEmpty( rc[queryField] ?: "" ) ){
			reportQueryString.append( queryField & '=' & rc[queryField] );
		}
	}

	reportQueryString = arrayToList( reportQueryString, '&');
</cfscript>
<cfoutput>
	<div class="results-count">

		<div class="container">

			<div class="row">

				<div class="col-xs-12 col-sm-7 col-md-8">
					<div class="document-list document-list-inline">
							<div class="document-item">
								<a id="download-report-link" href='#event.buildLink( linkTo="page-types.cpd_listing.getReport", queryString=reportQueryString)#' target="_blank" class="document-link">
									<span class="document-link-icon font-icon-download"></span>
									Download report
								</a>
							</div>
					</div>
				</div>

				<div class="col-xs-12 col-sm-5 col-md-4">
					<!--- <div class="results-count-right">
						<form action="##" method="get" class="form-sort mod-inline" >
							<div class="form-group" >
								<label for="sel-sort" class="form-label" >Sort by:</label>
								<select name="sort" id="sel-sort" class="form-control js-filter-input" >
									<option value="">Most recent</option>
									<option value="">Most relevant</option>
								</select>
							</div>
						</form>
					</div> --->


					<div class="results-count-right">
						<div class="form-sort mod-inline" >
							<div class="form-group" >
								<label for="sortBy" class="form-label" >Sort by:</label>

								<select class="form-control related-filter-field" name="sortBy" id="sortBy">

									<cfloop array="#availableSorts#" item="sort">
										<option
											value="#sort.value#"
											<cfif (rc.sortBy?:"") EQ sort.value>
												selected="selected"
											</cfif>
										>
											#sort.label#
										</option>
									</cfloop>

								</select>
							</div>
						</div>
					</div>
				</div>

			</div>

		</div>

	</div>

</cfoutput>