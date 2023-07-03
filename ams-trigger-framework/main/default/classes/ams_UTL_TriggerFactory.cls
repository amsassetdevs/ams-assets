/**
 * @description Class responsible for executing object's trigger handler
 * @author Angelika Galang
 * @since July 3, 2023
 */

 public inherited sharing class ams_UTL_TriggerFactory {
    /**
     * @description lazy loading of Trigger Configuration Object-Handler map
     */
    public static Map<String,ams_UTL_TriggerHandler> handlers {
        get {
            if(handlers == null){
                handlers = new Map<String,ams_UTL_TriggerHandler>();

                for(ams_Trigger_Configuration__mdt config : [
                    SELECT ams_Object_Name__c, ams_Handler_Class_Name__c
                    FROM ams_Trigger_Configuration__mdt
                    WHERE ams_Is_Active__c = true
                ]){
                    Type handlerType = Type.forName(config.ams_Handler_Class_Name__c);
                    if(handlerType != null){
                        handlers.put(
                            config.ams_Object_Name__c,
                            (ams_UTL_TriggerHandler) handlerType.newInstance()
                        );
                    }
                }
            }
            return handlers;
        }
        set;
    }

    /**
     * @description method that calls appropriate trigger handler method
     *
     * @param objectName object triggered
     * @param newRecords list of new records from trigger event
     * @param oldRecordsMap map of old records from trigger event
     */
    public static void execute(
        String objectName,
        List<SObject> newRecords,
        Map<Id,SObject> oldRecordsMap
    ){
        ams_UTL_TriggerHandler handler = handlers.get(objectName);

        if(handler != null){
            //before events
            if(Trigger.isBefore){
                if(Trigger.isInsert){
                    handler.beforeInsert(newRecords);
                }else if(Trigger.isUpdate){
                    handler.beforeUpdate(oldRecordsMap, newRecords);
                }else if(Trigger.isDelete){
                    handler.beforeDelete(oldRecordsMap);
                }
            }
            //after events
            else{
                if(Trigger.isInsert){
                    handler.afterInsert(newRecords);
                }else if(Trigger.isUpdate){
                    handler.afterUpdate(oldRecordsMap, newRecords);
                }else if(Trigger.isDelete){
                    handler.afterDelete(oldRecordsMap);
                }else if(Trigger.isUndelete){
                    handler.afterUndelete(newRecords);
                }
            }
        }
    }
}