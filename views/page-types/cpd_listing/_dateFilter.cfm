<cfscript>
	selectedValue     = ListToArray( rc['cpd_date'] ?: "" );
	selectedDateRange = isDate( rc.cpd_date_to ?: "" ) || isDate( rc.cpd_date_from ?: "" );
	isOpen            = !isEmpty( selectedValue ) || selectedDateRange;
</cfscript>
<cfoutput>
		<div class="collapsible-item">
			<h4 class="collapsible-item-header"><a data-toggle="collapse" <cfif isOpen>class="collapsed" aria-expanded=true<cfelse>class aria-expanded=false</cfif> role="button" >#translateResource( "page-types.cpd_listing:filter.date.title", "Date" )#</a></h4>
			<div class="collapsible-item-content collapse <cfif isOpen >in</cfif>">
				<div class="form-group">
					<div class="form-field">
						<div class="checkbox">
							<input
								type       = "checkbox"
								class      = "filter-checkbox"
								name       = "cpd_date"
								id         = "cb-past_week"
								value      = "past_week"
							<cfif selectedValue.findNoCase( 'past_week' )> checked="checked"</cfif>
							>
							<label for="cb-past_week">Past week</label>
						</div>
						<div class="checkbox">
							<input
								type       = "checkbox"
								class      = "filter-checkbox"
								name       = "cpd_date"
								id         = "cb-past_month"
								value      = "past_month"
							<cfif selectedValue.findNoCase( 'past_month' )> checked="checked"</cfif>
							>
							<label for="cb-past_month">Past month</label>
						</div>
						<div class="checkbox">
							<input
								type       = "checkbox"
								class      = "filter-checkbox"
								name       = "cpd_date"
								id         = "cb-past_year"
								value      = "past_year"
							<cfif selectedValue.findNoCase( 'past_year' )> checked="checked"</cfif>
							>
							<label for="cb-past_year">Past year</label>
						</div>
						<div class="checkbox">
							<input type="checkbox" id="cpd_date_range" name="cpd_date_range" value="1" class="js-filter-input js-submit-on-change " data-toggle="cpd_date_range" <cfif selectedDateRange >checked</cfif>>
							<label for="cpd_date_range">
								Select a custom date
							</label>
						</div>
						<div class="date-range-fields" data-field-toggle="cpd_date_range" <cfif selectedDateRange >style="display: block;"</cfif>>
							#renderFormControl(
								  name           = "cpd_date_from"
								, type           = "datepicker"
								, label          = "From"
								, context        = "website"
								, layout         = "formcontrols.layouts.field.vertical"
								, dateFormat     = "DD MMM YYYY"
								, dateFormatCfml = "DD MMM YYYY"
								, placeholder    = "DD MMM YYYY"
								, maxDate        = dateAdd( 'd', 1, now() )
								, value          = rc.cpd_date_from ?: ""
								, class          = "date-filter"
							)#
							#renderFormControl(
								  name           = "cpd_date_to"
								, type           = "datepicker"
								, label          = "To"
								, context        = "website"
								, layout         = "formcontrols.layouts.field.vertical"
								, dateFormat     = "DD MMM YYYY"
								, dateFormatCfml = "DD MMM YYYY"
								, placeholder    = "DD MMM YYYY"
								, maxDate        = dateAdd( 'd', 1, now() )
								, value          = rc.cpd_date_to ?: ""
								, class          = "date-filter"
							)#
						</div>
					</div>
				</div>
			</div>
		</div>
</cfoutput>