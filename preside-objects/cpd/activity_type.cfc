/**
 * @dataManagerGroup      cpd
 * @dataManagerSortable   true
 * @dataManagerSortField  sort_order
 * @datamanagerGridFields label,sort_order,datecreated,datemodified
 */
component {
	property name="label";
	property name="sort_order" type="numeric" dbtype="int";
}
