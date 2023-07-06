public with sharing class amsvl_CTR_LwcViewLogs {

    private static final String STR_ID = 'Id';
    private static final String STR_NAME = 'name';
    private static final String STR_AUTONUMBER = 'autonumber';
    private static final String STR_UNIQUE = 'unique';
    private static final String STR_TOTALVIEW = 'totalViewCount';
    private static final String STR_TOTALVIEWER = 'totalViewerCount';

    private static void updateViewLogs(String recordId,String sObjName){
        Id userId = UserInfo.getUserId();
        Datetime lastVisited = Datetime.now();
        List<amsvl_ViewLog__c> viewLogs = amsvl_DAL_ViewLog.getViewLogsByUserAndRecordId(recordId,userId);
        List<amsvl_ViewLog__c> viewLogsToUpsert = new List<amsvl_ViewLog__c>();

        //insert new view log if new user
        if(viewLogs.isEmpty()){
            viewLogsToUpsert.add(new amsvl_ViewLog__c(
                amsvl_LastVisited__c = lastVisited,
                amsvl_ObjectName__c = sObjName,
                amsvl_RecordId__c = recordId,
                amsvl_User__c = userId,
                amsvl_ViewCount__c = 1
            ));
        }
        //update existing view log for user
        else{
            for(amsvl_ViewLog__c viewLog : viewLogs){
                viewLog.amsvl_LastVisited__c = lastVisited;
            	viewLog.amsvl_ViewCount__c += 1;
                viewLogsToUpsert.add(viewLog);
            }
        }

        Database.upsert(viewLogsToUpsert);
    }

    @AuraEnabled
    public static Map<String,Integer> getViewLogsInfo(String recordId){
        Map<String,Integer> result = new Map<String,Integer>();

        String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        
        //insert or update view logs
        updateViewLogs(recordId,sObjName);
        
        //query to get the Total Views Count and Total Viewers Count
        AggregateResult agxViewLogsInfo = amsvl_DAL_ViewLog.getViewCountByRecordId(recordId);
        result.put(
            STR_TOTALVIEW,
            Integer.valueOf(agxViewLogsInfo.get(STR_TOTALVIEW))
        );
        result.put(
            STR_TOTALVIEWER,
            Integer.valueOf(agxViewLogsInfo.get(STR_TOTALVIEWER))
        );
        
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordFieldIdentifier(
        String objectName
    ){
        Map<String,String> fields = new Map<String,String>(); //priority: name -> autonumber -> unique
        
        SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> mapFields = sObjType.getDescribe().fields.getMap();
        for(Schema.SObjectField objField : mapFields.values()){
            String fieldName = objField.getDescribe().getName();

            if(!fields.containsKey(STR_NAME) && objField.getDescribe().isNameField()){
                fields.put(STR_NAME,fieldName); //first prio, no need to iterate when found
                break;
            }else if(!fields.containsKey(STR_AUTONUMBER) && objField.getDescribe().isAutoNumber()){
                fields.put(STR_AUTONUMBER,fieldName); 
            }else if(!fields.containsKey(STR_UNIQUE) && objField.getDescribe().isUnique()){
                fields.put(STR_UNIQUE,fieldName);
            }
        }

        return 
            fields.containsKey(STR_NAME) ? fields.get(STR_NAME) :
            fields.containsKey(STR_AUTONUMBER) ? fields.get(STR_AUTONUMBER) :
            fields.containsKey(STR_UNIQUE) ? fields.get(STR_UNIQUE) :
            STR_ID; //set Id as default when no other available fields
    }

    @AuraEnabled(cacheable=true)
    public static List<amsvl_ViewLog__c> getViewLogRecords(
        String recordId,
        Integer limitSize,
        Integer offsetSize
    ){
        return amsvl_DAL_ViewLog.getViewLogsByRecordId(recordId,limitSize,offsetSize);
    }

    @AuraEnabled(cacheable=true)
    public static Integer getViewLogsCount(
        String recordId
    ){
        return amsvl_DAL_ViewLog.getViewLogsCountByRecordId(recordId);
    }
}