/**
 * @isSystemPageType       true
 * @pageLayouts            twocol
 * @allowedParentPageTypes cpd_listing
 */

component {
	property name="success_message"          type="string" dbtype="varchar" maxlength="1000" control="textarea";
	property name="failed_message"           type="string" dbtype="varchar" maxlength="1000" control="textarea";
	property name="not_found_message"        type="string" dbtype="varchar" maxlength="1000" control="textarea";

	property name="maximum_upload"                type="numeric" dbtype="int" default=5;
	property name="maximum_size"                  type="numeric" dbtype="int" default=20;


}