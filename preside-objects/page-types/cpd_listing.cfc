/**
 * @isSystemPageType true
 * @pageLayouts      fullwidth
 */
component {
	property name="no_activity_message" type="string"  dbtype="text";
	property name="result_per_page"     type="numeric" dbtype="numeric";

	property name="report_detail_title"         type="string" dbtype="varchar";
	property name="report_detail_description"   type="string" dbtype="text";
}