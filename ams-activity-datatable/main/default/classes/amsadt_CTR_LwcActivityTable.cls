public with sharing class amsadt_CTR_LwcActivityTable {

    /**
     * @description Will get Activity Details based from inputParams from LWC of lwcActivityTable and Custom Metadata: amsadt_ActivityTableSetting__mdt
     * 
     * @param inputParams The inputs from LWC of lwcActivityTable with recordId, activityAPIName from metadata, offSetCount, 
     * dateRange, dateSort, allMyCustomers and the dynamic filter fields from custom metadata: amsadt_ActivityTableCustomFilter__mdt
     * 
     * @return List of Activity Details like Datatable columns, activity list results, and other Metadata details in wrapper of DataTableResponse
     */

	@AuraEnabled(cacheable=true)
    public static DataTableResponse getActivityDetails(Map<String,String> inputParams)
    {
        List<SObject> lstDataTableData = new List<SObject>();
        DataTableResponse finalWrapper = new DataTableResponse();
        
        // Input parameters from LWC
        String currentRecordId = inputParams.get('currentRecordId');
        String actTypeAPIName = inputParams.get('actTypeAPIName');
        Integer offSetCount = Integer.valueOf(inputParams.get('offSetCount'));
        String dateRange = inputParams.get('dateRange');
        String dateSort = inputParams.get('dateSort');
        String allMyCustomers = inputParams.get('allMyCustomers');
        String loggedInUser = UserInfo.getUserId();
        
        try {
            // Get Activity Custom Filters for Dynamic Filtering
            Map<String,String> actCustomFilters = new Map<String,String>();

            // Get Activity Table Settings & Filters Metadata
            amsadt_ActivityTableSetting__mdt ActivityTableMetadata = amsadt_DAL_ActivityTable.getActivitySettingsByAPIName(actTypeAPIName);
            List<amsadt_ActivityTableCustomFilter__mdt> activityFiltersList = amsadt_DAL_ActivityTable.getActivityFilterList(actTypeAPIName);

            for(amsadt_ActivityTableCustomFilter__mdt atcf : activityFiltersList){
                String filterField = (atcf.amsadt_ObjectFieldId__c != null) ? atcf.amsadt_ObjectFieldId__c : atcf.amsadt_ObjectField__c;
                actCustomFilters.put(atcf.amsadt_FilterFieldName__c,filterField);
            }
            
            String sortOrder = (dateSort == null || dateSort.equals('') || dateSort.equalsIgnoreCase('DESC')) ? 'DESC' : 'ASC';
            String queryCon = ' WHERE WhatId != null AND WhatId =: currentRecordId';
            
            // Query Condition String for Filtering
            queryCon += (dateRange != null && !dateRange.equals('') && !dateRange.equalsIgnoreCase('ALL')) ? ' AND '+ActivityTableMetadata.amsadt_DefaultFilterDateRangeField__c+' = '+dateRange : '';
            queryCon += (allMyCustomers != null && !allMyCustomers.equals('') && !allMyCustomers.equalsIgnoreCase('ALL')) ? ' AND OwnerId =: loggedInUser' : '';
            
            // Query Dynamic Condition from Custom Filter
            for(String acf : actCustomFilters.keySet()){
                queryCon += (inputParams.get(acf) != null && !inputParams.get(acf).equals('') && !inputParams.get(acf).equalsIgnoreCase('ALL') && !inputParams.get(acf).equalsIgnoreCase('BLANK')) ? ' AND '+actCustomFilters.get(acf)+' = \'' +String.escapeSingleQuotes(inputParams.get(acf)) + '\'' : ((inputParams.get(acf) != null && !inputParams.get(acf).equals('') && inputParams.get(acf).equalsIgnoreCase('BLANK')) ? ' AND '+actCustomFilters.get(acf)+' = null' : '');
            }
            
            // Get Activity Details from Query
            String query = 'SELECT '+ActivityTableMetadata.amsadt_QueryFields__c+' FROM '+ActivityTableMetadata.amsadt_ObjectName__c +queryCon;
            query += ' ORDER BY '+ActivityTableMetadata.amsadt_DefaultFilterSortByField__c+' '+sortOrder;
            query += ' LIMIT 20 OFFSET :offSetCount';
            
            for(SObject SObjectItem : Database.query(query)){
                lstDataTableData.add(SObjectItem);
            }

            // Get Activity Details Count from Query
            String queryCount = 'SELECT COUNT(Id)totalCountRow FROM '+ActivityTableMetadata.amsadt_ObjectName__c +queryCon;
            
            // Get Activity Details Count from Query
            AggregateResult agxActivityCount = Database.query(queryCount);
            Integer totalRowCount = (Integer) agxActivityCount.get('totalCountRow');
            
            finalWrapper.lstDataTableColumns = ActivityTableMetadata.amsadt_TableColumns__c;
            finalWrapper.lstDataTableData = lstDataTableData;
            finalWrapper.TotalViewCount = totalRowCount;
            finalWrapper.TableTitle = ActivityTableMetadata.Label;
            finalWrapper.TableIcon = ActivityTableMetadata.amsadt_TableIcon__c;
            finalWrapper.URLFields = ActivityTableMetadata.amsadt_URLFields__c;
            finalWrapper.showDateRange = ActivityTableMetadata.amsadt_DefaultFilterDateRange__c;
            finalWrapper.showDateSort = ActivityTableMetadata.amsadt_DefaultFilterSortBy__c;
            finalWrapper.showAllMyCustomers = ActivityTableMetadata.amsadt_DefaultFilterAllorMy__c;
            finalWrapper.dateRangeLabel = ActivityTableMetadata.amsadt_DefaultFilterDateRangeLabel__c;
            finalWrapper.dateSortLabel = ActivityTableMetadata.amsadt_DefaultFilterSortByLabel__c;
        } 
        catch (Exception e) {
            System.debug(e);
        }
        
        return finalWrapper;
    }
    
    /**
     * @description Will get Activity Custom Filters based from Custom Metadata: Activity_Table_Custom_Filter__mdt to be return in LWC of lwcActivityTable
     * 
     * @param actTypeAPIName The API Name of ActivityType in Custom Metadata: Activity_Table_Setting__mdt to determine what metadata to be used in page.
     * @param currentRecordId The Id of record of the object like on Campaign, Customer Group etc.
     * 
     * @return List of Activity Custom Filters in wrapper of SObjectActivityFilter
     */
    @AuraEnabled(cacheable=true)
    public static List<SObjectActivityFilter> getActivityCustomFilters(String actTypeAPIName, String currentRecordId){
        
        List<SObjectActivityFilter> activityCustomFilters = new List<SObjectActivityFilter>();
        
        try {
            // Get Dynamic Activity Custom Filters from Metadata
            List<amsadt_ActivityTableCustomFilter__mdt> ActivityCustomFilterMetadata = amsadt_DAL_ActivityTable.getActivityFilterList(actTypeAPIName);
            
            // Set Activity Dynamic Filter Options if Filter_Options__c is null, get the options from object picklist
            for(amsadt_ActivityTableCustomFilter__mdt atcf : ActivityCustomFilterMetadata){
    			String filterOptions = getCustomFilterOptions(atcf.DeveloperName, currentRecordId);
                activityCustomFilters.add(new SObjectActivityFilter(atcf.amsadt_FilterFieldName__c, atcf.Label, atcf.amsadt_FilterPlaceholder__c, filterOptions));
            }
        } 
        catch (Exception e) {
            System.debug(e);
        }
        
        return activityCustomFilters;
    }
    
    /**
     * @description Will get Activity Custom Filter Options in Activity Details based from Custom Metadata: Activity_Table_Custom_Filter__mdt to be return in LWC of lwcActivityTable
     * 
     * @param actFilterAPIName The API Name of Custom Filter from getActivityCustomFilters in Custom Metadata: Activity_Table_Custom_Filter__mdt.
     * @param currentRecordId The Id of record of the object like on Campaign, Customer Group etc.
     * 
     * @return String that contains of serialized List of Activity Custom Filters Options in wrapper of SObjectFilterOption
     */
    @AuraEnabled(cacheable=true)
    public static String getCustomFilterOptions(String actFilterAPIName, String currentRecordId){

        String picklistValueString;
        List<SObjectFilterOption> picklistValue = new List<SObjectFilterOption>();
        
        try {
            amsadt_ActivityTableCustomFilter__mdt ActivityCustomFilterMetadata = amsadt_DAL_ActivityTable.getActivityFilterByAPIName(actFilterAPIName);
            
            String objectFieldId = (ActivityCustomFilterMetadata.amsadt_ObjectFieldId__c != null) ? ActivityCustomFilterMetadata.amsadt_ObjectFieldId__c+' ,' : '';
            String objectFieldAlias = (ActivityCustomFilterMetadata.amsadt_ObjectFieldAlias__c != null) ? ' '+ActivityCustomFilterMetadata.amsadt_ObjectFieldAlias__c : '';
            
            String queryOption = 'SELECT '+objectFieldId+ActivityCustomFilterMetadata.amsadt_ObjectField__c+objectFieldAlias+' FROM '+ActivityCustomFilterMetadata.amsadt_ActivityTableSetting__r.amsadt_ObjectName__c;
            queryOption += ' WHERE WhatId != null AND WhatId =: currentRecordId';
            queryOption += ' GROUP BY '+objectFieldId+ActivityCustomFilterMetadata.amsadt_ObjectField__c+' ORDER BY '+ActivityCustomFilterMetadata.amsadt_ObjectField__c+' ASC';
            
            picklistValue.add(new SObjectFilterOption('All '+ActivityCustomFilterMetadata.Label, 'ALL'));

            List<AggregateResult> activityFilterList = Database.query(queryOption);

            for(AggregateResult agx : activityFilterList) {

                String picklistLabel = (ActivityCustomFilterMetadata.amsadt_ObjectFieldAlias__c == null) ? (String)agx.get(ActivityCustomFilterMetadata.amsadt_ObjectField__c) : (String)agx.get(ActivityCustomFilterMetadata.amsadt_ObjectFieldAlias__c);
                String picklistVal = (ActivityCustomFilterMetadata.amsadt_ObjectFieldId__c != null) ? (String)agx.get(ActivityCustomFilterMetadata.amsadt_ObjectFieldId__c) : ((ActivityCustomFilterMetadata.amsadt_ObjectFieldAlias__c == null) ? (String)agx.get(ActivityCustomFilterMetadata.amsadt_ObjectField__c) : (String)agx.get(ActivityCustomFilterMetadata.amsadt_ObjectFieldAlias__c));
                
                picklistLabel = (picklistLabel == '' || picklistLabel == null) ? 'Blank' : picklistLabel;
                picklistVal = (picklistVal == '' || picklistVal == null) ? 'BLANK' : picklistVal;

                picklistValue.add(new SObjectFilterOption(picklistLabel, picklistVal));
            }
            
            picklistValueString = JSON.serialize(picklistValue);
        } 
        catch (Exception e) {
            System.debug(e);
        }

        return picklistValueString;
    }
    
    public class DataTableResponse {
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}
        @AuraEnabled
        public String lstDataTableColumns {get;set;}
        @AuraEnabled
        public Integer TotalViewCount {get;set;}
        @AuraEnabled
        public String TableTitle {get;set;}   
        @AuraEnabled
        public String TableIcon {get;set;}   
        @AuraEnabled
        public String URLFields {get;set;}  
        @AuraEnabled
        public Boolean showDateRange {get;set;}
        @AuraEnabled
        public Boolean showDateSort {get;set;}
        @AuraEnabled
        public Boolean showAllMyCustomers {get;set;}
        @AuraEnabled
        public String dateRangeLabel {get;set;}
        @AuraEnabled
        public String dateSortLabel {get;set;}
    }

    public class SObjectActivityFilter {
        @AuraEnabled
        public String fieldApiName;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String placeholder;
        @AuraEnabled
        public String options;

        public SObjectActivityFilter(String afieldName, String aLabel, String aPlaceholder, String aOptions) {
			fieldApiName = afieldName;
            label = aLabel;
            placeholder = aPlaceholder;
            options = aOptions;
        }
    }
    
    public class SObjectFilterOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public SObjectFilterOption(String foLabel, String foValue) {
            label = foLabel;
            value = foValue;
        }
    }
}