/**
 * @dataManagerGroup                cpd
 * @dataManagerDisallowedOperations clone
 * @datamanagerGridFields           label,contact,activity_category,activity_type,credit_logged,completed_date,inactive,datecreated,datemodified
 * @useCache                        false
 */
component {
	property name="contact"                  relatedTo="crm_contact"       relationship="many-to-one" required="true";
	property name="activity_category"        relatedTo="activity_category" relationship="many-to-one" required="true" quickadd=true quickedit=true superquickadd=true;
	property name="activity_type"            relatedTo="activity_type"     relationship="many-to-one" required="true" quickadd=true quickedit=true superquickadd=true;
	property name="credit_logged"            type="numeric" dbtype="int"   default="0"                required="true";
	property name="completed_date"           type="date"    dbtype="date"  required="true";
	property name="description"              type="string"  dbtype="text";
	property name="reflective_learning_note" type="string"  dbtype="text";
	property name="supporting_documents"     relationship="one-to-many" relatedTo="cpd_supporting_document" relationshipKey="cpd_activity";
	property name="inactive"                 type="boolean" dbtype="boolean";
}
