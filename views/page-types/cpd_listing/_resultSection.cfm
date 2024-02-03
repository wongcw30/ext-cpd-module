<cfscript>
	cpdActivities = args.cpdActivities ?: queryNew('');
	totalResults  = args.totalResults ?: 0;

	args.type           = args.type          ?: rc.type           ?: "";
	args.category       = args.category      ?: rc.category       ?: "";
	args.cpd_date       = args.cpd_date      ?: rc.cpd_date       ?: "";
	args.cpd_date_from  = args.cpd_date_from ?: rc.cpd_date_from  ?: "";
	args.cpd_date_to    = args.cpd_date_to   ?: rc.cpd_date_to    ?: "";

	args.sortBy         = args.sortBy   ?: rc.sortBy    ?: "";
	args.maxRows        = args.maxRows  ?: rc.maxRows  ?: "";
	no_activity_message = args.no_activity_message ?: "";
</cfscript>
<cfoutput>
	<cfif totalResults>
		<ul class="cpd-list" id="results-listing">

			#renderView( view="page-types/cpd_listing/_resultItem", args=args )#
		</ul>
		<cfif totalResults GT args.maxRows>
			<div class="cpd-list-more load-more">
				<a href="##" class="btn load-more-link"
					data-href          = "#event.buildLink( linkto='page-types.cpd_listing.ajaxLoadMoreResult' )#"
					data-target        = "##results-listing"
					data-itemclass     = ".cpd-item"
					data-maxrows       = "#args.maxRows#"
					data-type          = "#args.type#"
					data-category      = "#args.category#"
					data-cpd_date      = "#args.cpd_date#"
					data-cpd_date_from = "#args.cpd_date_from#"
					data-cpd_date_to   = "#args.cpd_date_to#"
					data-sortBy        = "#args.sortBy#"
				>See more</a>
			</div>
		</cfif>
	<cfelse>
		#no_activity_message#
	</cfif>
</cfoutput>