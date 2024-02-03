/**
 * @dataManagerGroup       cpd
 * @labelRenderer          supportingDocument
 * @datamanagerGridFields  cpd_activity,supporting_document
 * @oneToManyConfigurator  true
 */
component {
	property name="label"               formula="${prefix}supporting_document.title" type="string" adminrenderer="none";
	property name="cpd_activity"        relationship="many-to-one" required="true";
	property name="supporting_document" relatedTo="asset" relationship="many-to-one" required="true" ondelete="cascade";
}
