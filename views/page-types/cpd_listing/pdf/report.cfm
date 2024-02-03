<cfscript>
	cpdCategoryActivity = args.cpdCategoryActivity ?: queryNew('');
	subscription        = args.subscription        ?: queryNew("");
	hasFilters          = args.hasFilters          ?: false;
</cfscript>

<cfdocument fontembed="true"
format="PDF"
orientation="portrait"
marginleft="0"
marginright="0"
marginbottom="0"
margintop="0"
pagewidth="8.3"
pageheight="16.5"
pagetype="custom"
	>

	<cfdocumentsection 
		marginleft="0"
		marginright="0"
		marginbottom="0"
		margintop="0"> 

		<cfoutput>
			<!DOCTYPE html>
			<html lang="en">
				<head>
					<meta charset="UTF-8">
					<title>CPD Report</title>

					<style type="text/css">
						
						body {
							width                   : 100% !important; 
							webkit-text-size-adjust : 100%; 
							-ms-text-size-adjust    : 100%; 
							margin                  : 0; 
							padding                 : 0;
							font-family             : Arial, sans-serif;
							font-size               : 14px;
							line-height             : normal;
							color                   : ##000000;
						}

						h1 {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif;
							font-size     : 24px; 
							font-weight   : bold; 
							line-height   : normal; 
							color         : ##000000;
						}

						h2 {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif; 
							font-size     : 22px; 
							font-weight   : bold; 
							line-height   : normal; 
							color         : ##000000;
						}

						h3 {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif; 
							font-size     : 20px; 
							font-weight   : bold; 
							line-height   : normal; 
							color         : ##000000;
						}

						h4 {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif; 
							font-size     : 18px; 
							font-weight   : bold; 
							line-height   : normal; 
							color         : ##000000;
						}

						h5 {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif; 
							font-size     : 16px; 
							font-weight   : bold; 
							line-height   : normal; 
							color         : ##000000;
						}

						h6 {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif; 
							font-size     : 14px; 
							font-weight   : bold; 
							line-height   : normal; 
							color         : ##000000;
						}

						p {
							margin-bottom : 20px;
							font-family   : Arial, sans-serif; 
							font-size     : 14px; 
							font-weight   : normal; 
							line-height   : 1.5; 
							color         : ##000000;
						}

						small,
						.small {
							font-family   : Arial, sans-serif;
							font-size     : 14px; 
							font-weight   : normal; 
							line-height   : normal; 
							color         : ##000000;
						}

						p.small {
							margin-bottom: 10px;
						}

						.underlined {
							padding-bottom : 6px;
							border-bottom  : dotted 2px ##EBD8F3;
							margin-bottom  : 10px;
						}

						.caption {
							margin-bottom : 10px;
							font-family   : Arial, sans-serif; 
							font-size     : 12px;
							font-style    : italic;
							color         : ##787878;
						}

						table,
						.table {
							margin-bottom : 30px;
							font-size     : 14px;
						}

						th,
						td {
							padding-right  : 20px;
							vertical-align : top;
							line-height    : 1.5;
						}

						th:last-child,
						td:last-child {
							padding-right: 0;
						}

						th {
							font-weight: bold;
						}

						.table thead {
							background-color: ##65758C;
						}

						.table thead th,
						.table thead td {
							color: ##FFFFFF;
						}

						.table th,
						.table td {
							padding: 10px 20px;
						}

						.table tbody tr:nth-child(odd) {
							background-color: ##F6F7F5;
						}

						dl {
							margin     : 0 0 20px;
							text-align : left;
						}

						dt,
						dd {
							margin      : 0;
							padding     : 0;
							font-family : Arial, sans-serif; 
							font-size   : 14px; 
							font-weight : normal; 
							line-height : 1.5; 
							text-align  : left;
							color       : ##000000;
						}

						dt {
							font-weight: bold;
						}

						hr {
							width: 100%;
							height: 1px;
							padding: 0;
							border: 0;
							margin-bottom: 10px;
							background-color: ##D9D9D9;
						}
						
					</style>
				</head>

				<body>
					
					<table border="0" cellpadding="0" cellspacing="0" align="center" id="main-table" width="100%">
						<tr>
							<td style="padding: 30px 40px; vertical-align: top;">
								<table border="0" cellpadding="0" cellspacing="0" width="100%" align="left">
									<tr>
										<td>
											
											<h1>#( !isEmpty( args.reportContent.report_detail_title ?: "" ) ? args.reportContent.report_detail_title : "My CPD Summary" )#</h1>
											<!--- <p><strong>14 - 19 October 2021</strong></p> --->

										</td>
										<td align="right" style="padding-top: 15px;">
											
											<img style="height: 60px;" src="data:image/svg;base64,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" alt="">

										</td>
									</tr>

									<cfif !isEmpty( args.reportContent.report_detail_description ?: "" )>
										<tr>
											<td colspan="2">
												<p>#renderContent( 'richeditor', args.reportContent.report_detail_description )#</p>
											</td>
										</tr>
									</cfif>

									

									<tr>
										<td colspan="2">
											
											<table border="0" cellpadding="0" cellspacing="0" width="100%" align="left">
												<thead>
													<tr>
														<cfif subscription.recordCount>
															<th>Membership number</th>
														</cfif>
														<th>Full name</th>
														<th>Occupation</th>
														<th>Organisation</th>
													</tr>
												</thead>
												<tbody>
													<tr>
														<cfif subscription.recordCount>
															<td>#subscription.membership_number ?: ""#</td>
														</cfif>
														<td>#args.loggedInContactDetails.title# #args.loggedInContactDetails.first_name# #args.loggedInContactDetails.last_name#</td>
														<td>#args.loggedInContactDetails.job_title#</td>
														<td>#renderLabel( "crm_organisation", args.loggedInContactDetails.organisation )#</td>
													</tr>
												</tbody>
											</table>

										</td>
									</tr>

									<cfif hasFilters>
										<tr>
											<td colspan="2">
												<table border="0" cellpadding="0" cellspacing="0" align="left">
													<thead>
														<tr>
															<th>#translateResource( "page-types.cpd_listing:report.filter.applied.title" )#</th>
														</tr>
													</thead>
													<tbody>
														<cfif !isEmptyString( args.dateFrom ?: "" ) || !isEmptyString( args.dateTo ?: "" ) >
															<cfset dateApplied = [ args.dateFrom ?: "", args.dateTo ?: "#dateFormat( now(), "yyyy-mm-dd" )#" ] />
															<tr>
																<th>#translateResource( "page-types.cpd_listing:report.filter.date.title" )#</th>
																<td>#arrayToList( dateApplied, " until " )#</td>
															</tr>
														</cfif>
														<cfif !isEmptyString( rc.category ?: "" )>
															<cfscript>
																categories = listToArray( rc.category )
																catLabels = [];
																for( var cat in categories ){
																	arrayAppend( catLabels, renderLabel( "activity_category", cat ) );
																}
															</cfscript>
															<cfset categories = listToArray( rc.category ) />
															<tr>
																<th>#translateResource( "page-types.cpd_listing:report.filter.category.title" )#</th>
																<td>#arrayToList( catLabels, ", " )#</td>
															</tr>
														</cfif>
														<cfif !isEmptyString( rc.type ?: "" )>
															<cfscript>
																types = listToArray( rc.type )
																typeLabels = [];
																for( var type in types ){
																	arrayAppend( typeLabels, renderLabel( "activity_type", type ) );
																}
															</cfscript>
															<cfset types = listToArray( rc.type ) />
															<tr>
																<th>#translateResource( "page-types.cpd_listing:report.filter.type.title" )#</th>
																<td>#arrayToList( typeLabels, ", " )#</td>
															</tr>
														</cfif>
													</tbody>
												</table>
											</td>
										</tr>
									</cfif>

									<tr>
										<td colspan="2">
											
											<table class="table" border="0" cellpadding="0" cellspacing="0" width="100%" align="left">
												<thead>
													<tr>
														<th>Professional areas</th>
														<th>Number of Hours</th>
													</tr>
												</thead>
												<tbody>
													<cfloop array="#cpdCategoryActivity.cpdCategoryOrder#" item="cpd">
														<tr>
															<td>#cpd#</td>
															<td>#cpdCategoryActivity.cpdCategory[cpd]# hour(s)</td>
														</tr>
													</cfloop>

													<tr>
														<td><strong>Total:</strong></td>
														<td><strong>#cpdCategoryActivity.totalCreditLogged# hour(s)</strong></td>
													</tr>
												</tbody>
											</table>

										</td>
									</tr>

									<cfloop query="#cpdCategoryActivity.cpdActivities#">
										<tr>
											<td colspan="2">
												
												<h3>#cpdCategoryActivity.cpdActivities.label#</h3>

												<hr>

												<table border="0" cellpadding="0" cellspacing="0" width="100%" align="left">
													<tbody>
														<tr>
															<td width="50%" valign="top" align="left">
																
																<table border="0" cellpadding="0" cellspacing="0" width="100%" align="left">
																	<tbody>
																		<tr>
																			<td width="60%" valign="top" align="left">

																				<dl>
																					<dt>Date activity completed</dt>
																					<dd>#dateFormat( cpdCategoryActivity.cpdActivities.completed_date, 'dd mmmm yyyy' )#</dd>
																				</dl>

																			</td>
																			<td width="40%" valign="top" align="left">

																				<dl>
																					<dt>Activity type</dt>
																					<dd>#renderLabel( 'activity_type', cpdCategoryActivity.cpdActivities.activity_type )#</dd>
																				</dl>

																			</td>
																		</tr>
																	</tbody>
																</table>

															</td>
															<td width="50%" valign="top" align="left">

																<table border="0" cellpadding="0" cellspacing="0" width="100%" align="left">
																	<tbody>
																		<tr>
																			<td width="50%" valign="top" align="left">

																				<dl>
																					<dt>Activity category</dt>
																					<dd>#renderLabel( 'activity_category', cpdCategoryActivity.cpdActivities.activity_category )#</dd>
																				</dl>

																			</td>
																			<td width="50%" valign="top" align="left">

																				<dl>
																					<dt>Number of hour(s)</dt>
																					<dd>#cpdCategoryActivity.cpdActivities.credit_logged# hour(s)</dd>
																				</dl>

																			</td>
																		</tr>
																	</tbody>
																</table>

															</td>
														</tr>
														<tr>
															<td width="50%" valign="top" align="left">

																<dl>
																	<dt>Description</dt>
																	<dd>#renderContent( 'simpleFreeText', cpdCategoryActivity.cpdActivities.description )#</dd>
																</dl>

															</td>
															<td width="50%" valign="top" align="left">

																<dl>
																	<dt>Reflective learning</dt>
																	<dd>#renderContent( 'simpleFreeText', cpdCategoryActivity.cpdActivities.reflective_learning_note )#</dd>
																</dl>

															</td>
														</tr>
													</tbody>
												</table>

											</td>
										</tr>
									</cfloop>
								</table>
							</td>
						</tr>
					</table>

				</body>
			</html>

		</cfoutput>

	</cfdocumentsection>

</cfdocument>