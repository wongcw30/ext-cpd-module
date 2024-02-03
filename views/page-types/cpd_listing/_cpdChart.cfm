<cfscript>
	args.pieChart= args.pieChart ?: [];

	heading        = "CPD logged";
	lastLoggedDate = args.lastLoggedDate ?: "";
	cpdChartWidth  = "200";
	cpdChartHeight = "200";
	cpdChartData   = args.cpdChartData   ?: "";
	cpdChartBg     = args.cpdChartBg     ?: "";
	cpdChartLabels = args.cpdChartLabels ?: "";
</cfscript>
<cfoutput>
	<canvas id="myCPD" width="#cpdChartWidth#" height="#cpdChartHeight#" data-list="#cpdChartData#" data-labels="#cpdChartLabels#" data-bg="#cpdChartBg#"></canvas>

	<div class="cpd-chart-label"><span class="cpd-chart-label-data">#args.totalCreditLogged#</span> CPD hour(s)</div>
</cfoutput>