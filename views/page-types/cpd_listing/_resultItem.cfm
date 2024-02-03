<cfscript>
	cpdActivities = args.cpdActivities ?: queryNew('');
</cfscript>

<cfoutput query="cpdActivities">
	<li class="cpd-item">
		<h4 class="cpd-title">
			<cfif !cpdActivities.isEvent>
				<a href="#event.buildLink( cpdid='#cpdActivities.id#' )#">#cpdActivities.label#</a>
			<cfelse>
				#cpdActivities.label#
			</cfif>
		</h4>

		<dl class="cpd-meta-list">
			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:date_completed.meta.title" )#</dt>
				<dd class="cpd-meta cpd-meta-definition">#dateFormat( cpdActivities.completed_date, 'dd mmmm yyyy')#</dd>
			</div>

			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:credit_logged.meta.title" )#</dt>
				<dd class="cpd-meta cpd-meta-definition">#cpdActivities.credit_logged# point(s)</dd>
			</div>

			<div class="cpd-meta-group">
				<dt class="cpd-meta cpd-meta-term">#translateResource( "page-types.cpd_listing:activity_category.meta.title" )#</dt>
				<cfif cpdActivities.isEvent>
					<dd class="cpd-meta cpd-meta-definition"><span class="badge">#translateResource( "page-types.cpd_listing:is_event.tag.title" )#</span></dd>
				<cfelse>
					<dd class="cpd-meta cpd-meta-definition"><span class="badge">#renderLabel( "activity_category", cpdActivities.activity_category )#</span></dd>
				</cfif>
			</div>
		</dl>
	</li>
</cfoutput>