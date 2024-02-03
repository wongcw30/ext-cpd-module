<cfscript>
	filterView = "/page-types/cpd_listing/_filter";
</cfscript>
<cfoutput>
	<div class="widget widget-filter" id="cpd-filter" >
		<div class="widget-content">
			<div class="collapsible">
				#renderView( view = "/page-types/cpd_listing/_dateFilter", args={ fieldName="date" } )#
				#renderView( view = filterView, args={ fieldName="category" } )#
				#renderView( view = filterView, args={ fieldName="type" } )#
			</div>
		</div>
	</div>
</cfoutput>