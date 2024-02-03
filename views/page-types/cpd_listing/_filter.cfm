<cfscript>
	fieldName     = args.fieldName     ?: "";
	filters       = prc.filters        ?: {};
	filterItems   = filters[fieldName] ?: queryNew('');
	selectedValue = ListToArray( rc[fieldName] ?: "" );
	isOpen = !isEmpty( selectedValue );
</cfscript>
<cfoutput>
	<cfif filterItems.recordCount>
		<div class="collapsible-item">
			<h4 class="collapsible-item-header"><a data-toggle="collapse" <cfif isOpen>class="collapsed" aria-expanded=true<cfelse>class aria-expanded=false</cfif> role="button" >#translateResource( "page-types.cpd_listing:filter.#fieldName#.title", fieldName )#</a></h4>
			<div class="collapsible-item-content collapse <cfif isOpen >in</cfif>">

				<div class="form-group">
					<div class="form-field">
<!--- 						<cfloop array="#items#" item="item" index="itemIndex" >

							<cfset item.filterName = filterName />
							<cfset item.checkboxExtraClass = "js-submit-on-change" />

							#renderView(
								  template = "/modules/cpd/filters/_filterCheckbox"
								, args     = item
							)#

						</cfloop> --->

						<cfloop query="#filterItems#">
							<div class="checkbox">
								<input
									type       = "checkbox"
									class      = "filter-checkbox"
									name       = "#fieldName#"
									id         = "cb-#filterItems.id#"
									value      = "#filterItems.id#"
								<cfif selectedValue.findNoCase( filterItems.id )> checked="checked"</cfif>
								>
								<label for="cb-#filterItems.id#">#renderLabel( 'activity_#fieldName#', filterItems.id )#</label>
							</div>
						</cfloop>
					</div>
				</div>
			</div>
		</div>
	</cfif>
</cfoutput>