/**
 * @description Interface for Trigger related methods
 * @author Angelika Galang
 * @since July 3, 2023
 */

 public interface ams_UTL_TriggerHandler {

    void beforeInsert(List<SObject> newRecords);

    void beforeUpdate(Map<Id,SObject> oldRecordsMap, List<SObject> newRecords);

    void beforeDelete(Map<Id,SObject> oldRecordsMap);

    void afterInsert(List<SObject> newRecords);

    void afterUpdate(Map<Id,SObject> oldRecordsMap, List<SObject> newRecords);

    void afterDelete(Map<Id,SObject> oldRecordsMap);

    void afterUndelete(List<SObject> newRecords);

}