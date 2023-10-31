 /**
 * @description Data service for Activity Table
 * @author Aldrin Vallespin
 * @since October 24, 2023
 */

 public inherited sharing class amsadt_DAL_ActivityTable {

    //constants
    //public
    public static final String OBJECT_ACTIVITY_SETTING_NAME = amsadt_ActivityTableSetting__mdt.SObjectType.getDescribe().getLocalName();
    public static final String OBJECT_ACTIVITY_FILTER_NAME = amsadt_ActivityTableCustomFilter__mdt.SObjectType.getDescribe().getLocalName();

    /**
     * @description
     *
     * @return  `List<String>`
     */
    private static List<String> getActivitySettingDefaultFields(){
        return new List<String>{
            amsadt_ActivityTableSetting__mdt.Id.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.DeveloperName.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.Label.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_ObjectName__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_QueryFields__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_URLFields__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_TableIcon__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_TableColumns__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_ParentObjectName__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterAllorMy__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterDateRange__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterSortBy__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterDateRangeField__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterSortByField__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterDateRangeLabel__c.getDescribe().getLocalName(),
            amsadt_ActivityTableSetting__mdt.amsadt_DefaultFilterSortByLabel__c.getDescribe().getLocalName()
        };
    }

    /**
     * @description
     *
     * @return  `List<String>`
     */
    private static List<String> getActivityFilterDefaultFields(){
        return new List<String>{
            amsadt_ActivityTableCustomFilter__mdt.Id.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.DeveloperName.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.Label.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_ActivityTableSetting__c.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_ObjectField__c.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_ObjectFieldId__c.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_FilterFieldName__c.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_FilterPlaceholder__c.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_ObjectFieldAlias__c.getDescribe().getLocalName(),
            amsadt_ActivityTableCustomFilter__mdt.amsadt_FilterSortOrder__c.getDescribe().getLocalName(),
            'amsadt_ActivityTableSetting__r.amsadt_ObjectName__c',
            'amsadt_ActivityTableSetting__r.amsadt_ParentObjectName__c',
            'amsadt_ActivityTableSetting__r.DeveloperName'
        };
    }

    /**
     * @description 
     *
     * @param activityAPIName 
     *
     * @return  `amsadt_ActivityTableSetting__mdt`
     */
    public static amsadt_ActivityTableSetting__mdt getActivitySettingsByAPIName(String activityAPIName){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getActivitySettingDefaultFields(),
                OBJECT_ACTIVITY_SETTING_NAME,
                'DeveloperName =: activityAPIName'
            )
        );
    }

    /**
     * @description 
     *
     * @param activityAPIName 
     *
     * @return  `List<amsadt_ActivityTableCustomFilter__mdt>`
     */
    public static List<amsadt_ActivityTableCustomFilter__mdt> getActivityFilterList(String activityAPIName){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getActivityFilterDefaultFields(),
                OBJECT_ACTIVITY_FILTER_NAME,
                'amsadt_ActivityTableSetting__r.DeveloperName =: activityAPIName'
            )
        );
    }

    /**
     * @description 
     *
     * @param activityAPIName 
     *
     * @return  `amsadt_ActivityTableCustomFilter__mdt`
     */
    public static amsadt_ActivityTableCustomFilter__mdt getActivityFilterByAPIName(String activityAPIName){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getActivityFilterDefaultFields(),
                OBJECT_ACTIVITY_FILTER_NAME,
                'DeveloperName =: activityAPIName'
            )
        );
    }
}