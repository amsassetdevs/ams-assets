public with sharing class amsvl_CTR_LwcViewLogs {
    @AuraEnabled
    public static Map<String,Integer> getViewLogsInfo(String recordId){
        Map<String,Integer> result = new Map<String,Integer>();

        String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        
        //insert or update view logs
        updateViewLogs(recordId,sObjName);
        
        //query to get the Total Views Count and Total Viewers Count
        AggregateResult agxViewLogsInfo = amsvl_DAL_ViewLog.getViewCountByRecordId(recordId);
        result.put(
            'totalViewCount',
            Integer.valueOf(agxViewLogsInfo.get('totalViewCount'))
        );
        result.put(
            'totalViewerCount',
            Integer.valueOf(agxViewLogsInfo.get('totalViewerCount'))
        );
        
        return result;
    }

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
}