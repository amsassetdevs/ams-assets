 /**
 * @description Data service for View Log object
 * @author Angelika Galang
 * @since July 4, 2023
 */

 public inherited sharing class amsvl_DAL_ViewLog {

    //constants
        //public
    public static final String OBJECT_NAME = amsvl_ViewLog__c.SObjectType.getDescribe().getLocalName();
        //private
    private static final String OP_AND = 'AND';

    /**
     * @description
     *
     * @return  `List<String>`
     */
    private static List<String> getDefaultFields(){
        return new List<String>{
            amsvl_ViewLog__c.Id.getDescribe().getLocalName(),
            amsvl_ViewLog__c.amsvl_LastVisited__c.getDescribe().getLocalName(),
            amsvl_ViewLog__c.amsvl_ObjectName__c.getDescribe().getLocalName(),
            amsvl_ViewLog__c.amsvl_RecordId__c.getDescribe().getLocalName(),
            amsvl_ViewLog__c.amsvl_User__c.getDescribe().getLocalName(),
            'amsvl_User__r.Name',
            amsvl_ViewLog__c.amsvl_ViewCount__c.getDescribe().getLocalName()
        };
    }

    public static Integer getViewLogsCountByRecordId(String recordId){
        return Database.countQuery(
            ams_UTL_SearchStringBuilder.soqlSearch(
                new List<String>{
                    'count()'
                },
                OBJECT_NAME,
                'amsvl_RecordId__c =: recordId'
            )
        );
    }

    /**
     * @description 
     *
     * @param recordId 
     *
     * @return  `List<amsvl_ViewLog__c>`
     */
    public static List<amsvl_ViewLog__c> getViewLogsByRecordId(String recordId){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getDefaultFields(),
                OBJECT_NAME,
                'amsvl_RecordId__c =: recordId'
            )
        );
    }

    /**
     * @description 
     *
     * @param recordId 
     *
     * @return  `List<amsvl_ViewLog__c>`
     */
    public static List<amsvl_ViewLog__c> getViewLogsByRecordId(
        String recordId,
        Integer limitSize,
        Integer offsetSize
    ){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getDefaultFields(),
                OBJECT_NAME,
                'amsvl_RecordId__c =: recordId ORDER BY amsvl_LastVisited__c DESC LIMIT :limitSize OFFSET :offsetSize'
            )
        );
    }

    public static List<amsvl_ViewLog__c> getViewLogsByUserAndRecordId(
        String recordId,
        String userId
    ){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getDefaultFields(),
                OBJECT_NAME,
                new List<String>{
                    'amsvl_RecordId__c =: recordId',
                    'amsvl_User__c =: userId'
                },
                OP_AND
            )
        );
    }

    /**
     * 
     * @param recordId 
     * @return  `AggregateResult`
     */
    public static AggregateResult getViewCountByRecordId(String recordId){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                new List<String>{
                    'SUM(amsvl_ViewCount__c) totalViewCount',
                    'COUNT(amsvl_User__c) totalViewerCount'
                },
                OBJECT_NAME,
                'amsvl_RecordId__c =: recordId GROUP BY amsvl_RecordId__c'
            )
        );
    }
}