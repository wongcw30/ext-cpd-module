<cf_presideparam name="args.title"               field="page.title"                      editable="true" />
<cf_presideparam name="args.main_content"        field="page.main_content"               editable="true" />
<cf_presideparam name="args.teaser"              field="page.teaser"                     editable="true" />
<cf_presideparam name="args.no_activity_message" field="cpd_listing.no_activity_message" editable="false" />
<cf_presideparam name="args.banner_image"        field="page.banner_image"               editable="false" />
<cf_presideparam name="args.show_banner"         field="page.show_banner"                editable="false" />

<cfscript>
	messages = renderView( view="/pixl8crm/util/_messages" );

	event.include( "/js/specific/components/cpd-chart/" )
		 .include( "/css/specific/components/calendar-range/" )
		// .include( "/js/specific/components/dhxCalendar/" )
		 .include( "/js/specific/components/collapsible/" )
		// .include('ext-js-cpd')
		 .include( "/css/specific/cpd/" )
	     .include( "/css/specific/cpd-theme/" );

	heading        = "CPD logged";
	lastLoggedDate = args.lastLoggedDate ?: "";
	cpdChartWidth  = "200";
	cpdChartHeight = "200";
</cfscript>

<cfoutput>
	<div class="main-content">
		<div class="container">
			<div class="row">

				<section class="main-section col-xs-12 col-md-8" role="main"> <!--- Left column as main content --->
					<!--- Example contents, widgets --->

					<cfif len( trim ( messages ) )>
						<div class="pixl8-crm-page-messages">#messages#</div>
					</cfif>

					<cfif isFalse( args.banner_image?:'' ) && isFalse( args.show_banner?: '' ) >
						<h1 class="page-title cpd-page-title" >#args.title#</h1>

						<cfif !isEmptyString( args.teaser )>
							<p class="cpd-page-intro" >#args.teaser#</p>
						</cfif>
					</cfif>

					#args.main_content#

					<div class="cpd-chart-widget">
						<div class="cpd-chart-header">
							<h4 class="cpd-chart-heading">#heading#</h4>
							<p class="cpd-chart-log-text">Last logged on #dateFormat(lastLoggedDate, "d mmmm yyyy")#</p>
						</div>
						<div class="cpd-chart-holder">
							<div class="cpd-chart">
								#renderViewlet( event="page-types.cpd_listing.getChart", args=args )#
							</div>
							<p class="cpd-chart-btn-holder"><a href="#event.buildLink( page="log_cpd_activity_page" )#" class="btn cpd-chart-btn">Log your CPD</a></p>
						</div>
					</div>
				</section>

				<aside class="sidebar col-xs-12 col-md-4"> <!--- Right column as sidebar --->
					#renderViewlet( event="cmsLayout._subNavigation", args={ depth=3 } )#
				</aside>
			</div>
		</div>
	</div>

	<div class="bottom-content">
		#renderView( view='page-types/cpd_listing/_sortForm', args=args )#

		<section class="page-section">
			<div class="container">
				<div id="result-body" class="page-section-body">
					<div class="row">
						<div class="col-xs-12 col-md-4 pull-right">
							<aside class="sidebar">
								#renderView( view="page-types/cpd_listing/_filterPanel", args=args )#
							</aside>
						</div>
						
						<div class="col-xs-12 col-md-8 pull-left">
							<div id="result-section" class="result-section">
								#renderViewlet( event="page-types.cpd_listing.resultSection", args=args )#
							</div>
						</div>
					</div>
				</div>
			</div>
		</section>
	</div>
</cfoutput>