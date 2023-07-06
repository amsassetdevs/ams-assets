public with sharing class amsvl_CTR_LwcViewLogs {
    
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