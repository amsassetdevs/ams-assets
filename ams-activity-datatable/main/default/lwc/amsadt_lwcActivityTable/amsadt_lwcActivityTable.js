 /**
 * @description 
 * @author Aldrin Vallespin
 * @since October 24, 2023
 */

import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivityDetails from '@salesforce/apex/amsadt_CTR_LwcActivityTable.getActivityDetails';
import getActivityCustomFilters from '@salesforce/apex/amsadt_CTR_LwcActivityTable.getActivityCustomFilters';

const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';
const ERROR_MSG = 'Sorry, we cannot process your request at the time. Please contact the support team if issue persists.';

export default class Amsadt_lwcActivityTable extends LightningElement {
    @api activityTypeAPIName;
    @api recordId;

    data = [];
    finalSObjectDataList = [];
    sObjectRelatedFieldListValues = [];
    activityFilterFields = [];
    tableTitle;
    tableTitleWithCount;
    tableIcon;
    allOrMyLabel;
    allOrMyPlaceholder;
    dateRangeLabel;
    dateRangePlaceholder;
    dateSortLabel;
    dateSortPlaceholder;

    showDateRange;
    showDateSort;
    showAllMyCustomers;

    error;
    totalNumberOfRows = 0;
    offSetCount = 0;
    loadMoreStatus;
    targetDatatable;
    hasData;
    numCustomFields = 0;

    dateRange;
    dateSort;
    allMyCustomers;

    /**
     * @description This is to get the Activity Custom Filters based on actTypeAPIName specified from Custom Metadata
     * @param {String} actTypeAPIName The Activity Type API Name from Activity_Table_Setting__mdt Custom Metadata
     * @param {String} currentRecordId The Id of record of the object like on Campaign, Customer Group etc.
     * 
     * @returns List of Activity Custom Filters with filter options from lwcActivityTableController Apex Class
     */
    @wire(getActivityCustomFilters,{actTypeAPIName: '$activityTypeAPIName', currentRecordId: '$recordId'})
    actFilters(result)
    {
        if(result.data){
            this.activityFilterFields = result.data.map(field => {
                let _field = {...field};
                _field.options = JSON.parse(_field.options);
    
                return _field;
            });

            this.numCustomFields = result.data.length;
        }
    }

    /**
     * @returns List of option values for Date Range field
     */
    get dateRangePicklistValues() {
        return [
            { label: 'All Time', value: 'ALL' },
            { label: 'Last 7 Days', value: 'LAST_N_DAYS:7' },
            { label: 'Last 30 Days', value: 'LAST_N_DAYS:30' },
            { label: 'Last 3 Months', value: 'LAST_N_MONTHS:3' },
            { label: 'Last 6 Months', value: 'LAST_N_MONTHS:6' },
            { label: 'Upcoming 7 Days', value: 'NEXT_N_DAYS:7' },
            { label: 'Upcoming 30 Days', value: 'NEXT_N_DAYS:30' }
        ]
    }

    /**
     * @returns List of option values for Date Sort field
     */
    get dateSortPicklistValues() {
        return [
            { label: 'Ascending', value: 'ASC' },
            { label: 'Descending', value: 'DESC' }
        ]
    }

    /**
     * @returns List of option values for All or My {Activity Type} field
     */
    get customersPicklistValues() {
        return [
            { label: 'All '+this.tableTitle, value: 'ALL' },
            { label: 'My '+this.tableTitle, value: 'MY' }
        ]
    }

    connectedCallback() {
        this.getRecords();
    }

    /**
     * @description This is to get the Activity Details based from params specified from Custom Metadata
     * @param {Map<String, String>} params Consist of parameters needed to display Activity datatable details:
     * actTypeAPIName : The Activity Type API Name from Activity_Table_Setting__mdt Custom Metadata
     * currentRecordId : The Id of record of the object like on Campaign, Customer Group etc.
     * offSetCount : The number of offset from handleLoadMore of datatable.
     * dateRange : The static filter field of selected date range from dateRangePicklistValues().
     * dateSort: The static filter field of selected date sort from dateSortPicklistValues().
     * allMyCustomers : The static filter field of selected All or My {Activity Type} from customersPicklistValues().
     * 
     * @returns List of Activity Details to Activity datatable from lwcActivityTableController Apex Class
     */
    getRecords() {
        // Build the object that needed to send to the apex classes
        let params = {
            actTypeAPIName: this.activityTypeAPIName,
            currentRecordId: this.recordId,
            offSetCount : this.offSetCount,
            dateRange: this.dateRange,
            dateSort: this.dateSort,
            allMyCustomers: this.allMyCustomers,
        }

        this.activityFilterFields.forEach(field => {
            params[field.fieldApiName] = this[field.fieldApiName];
        });

        // get the activity details based from parameters passed
        getActivityDetails({inputParams : params})
        .then(result => {
            this.data = result;
            if(this.data){
                this.tableTitle = this.data.TableTitle;
                this.tableIcon = this.data.TableIcon;
                this.tableTitleWithCount = this.data.TableTitle +" ("+this.data.TotalViewCount+")";

                this.showDateRange = this.data.showDateRange;
                this.showDateSort = this.data.showDateSort;
                this.showAllMyCustomers = this.data.showAllMyCustomers;

                this.allOrMyLabel = "All "+this.data.TableTitle+" or My "+this.data.TableTitle;
                this.allOrMyPlaceholder = "Select All "+this.data.TableTitle+" or My "+this.data.TableTitle;
                this.dateRangeLabel = "Date Range ("+this.data.dateRangeLabel+")";
                this.dateRangePlaceholder = "Select Date Range ("+this.data.dateRangeLabel+")";
                this.dateSortLabel = "Sorting By "+this.data.dateRangeLabel;
                this.dateSortPlaceholder = "Select Sorting By "+this.data.dateRangeLabel;
                
                this.columns = JSON.parse(this.data.lstDataTableColumns);
                let urlIds = JSON.parse(this.data.URLFields);
                
                for (let row of this.data.lstDataTableData) {
                    const finalSobjectRow = {}
                    let rowIndexes = Object.keys(row); 

                    rowIndexes.forEach((rowIndex) => {
                        const relatedFieldValue = row[rowIndex];

                        if(relatedFieldValue.constructor === Object){
                            this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                        }
                        else{
                            finalSobjectRow[rowIndex] = urlIds.includes(rowIndex) ? '/'+relatedFieldValue : relatedFieldValue;
                        }
                    });

                    this.sObjectRelatedFieldListValues.push(finalSobjectRow);
                }

                this.finalSObjectDataList = this.sObjectRelatedFieldListValues;
                this.totalNumberOfRows = this.data.TotalViewCount;

                this.hasData = (this.finalSObjectDataList.length > 0)? true : false;
                this.loadMoreStatus = '';

                if (this.targetDatatable && this.finalSObjectDataList.length >= this.totalNumberOfRows) {
                    //stop Infinite Loading when threshold is reached
                    this.targetDatatable.enableInfiniteLoading = false;
                    //Display "No more data to load" when threshold is reached
                    if(this.finalSObjectDataList.length > 0){
                        this.loadMoreStatus = 'No more data to load';
                    }
                }
                
                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
            } 
        })
        .catch(error => {
            this.error = error;
            console.log('error : ' + JSON.stringify(this.error));

            this.generateToast(ERROR_TITLE, ERROR_MSG, ERROR_VARIANT);
        });
    }
    
    /**
     * @description This is to flatten Object Type from Activity records to one dimentional array
     * @param {Object} fieldValue The field value from getRecords 
     * @param {Array} finalSobjectRow The row from getRecords
     * @param {String} fieldName The field name from getRecords
     * 
     * @returns Flattened Activity records field values as an array
     */
    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {        
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.'+ key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }

    /**
     * @description Event to handle onchange on lightning-combobox of Activity Filter fields
     * @returns List of Filtered Activity records based from the selected filter fields
     */
    handleValueChange(e) {
        // on change of the field it will automatically assign the value to the var
        this[e.target.name] = e.detail.value;
        
        // reset this.finalSObjectDataList and offset
        this.finalSObjectDataList = [];
        this.sObjectRelatedFieldListValues = [];
        this.offSetCount = 0;
        this.totalNumberOfRows = 0;

        if (this.targetDatatable) {
            this.targetDatatable.enableInfiniteLoading = true;
        }

        // call the function
        this.getRecords();
    }

    /**
     * @description Event to handle onloadmore on lightning datatable markup
     * @returns List of additional Activity records based from the offset specified
     */
    handleLoadMore(event) {
        event.preventDefault();

        if(this.totalNumberOfRows > 10){
            // increase the offset count by 20 on every loadmore event
            this.offSetCount = this.offSetCount + 20;

            //Display a spinner to signal that data is being loaded
            event.target.isLoading = true;

            //Set the onloadmore event taraget to make it visible to imperative call response to apex.
            this.targetDatatable = event.target;

            //Display "Loading" when more data is being loaded
            this.loadMoreStatus = 'Loading';

            // Get new set of records and append to this.finalSObjectDataList
            this.getRecords();
        }
    }

    /**
     * @returns return String as CSS for setting up datatable height
     */
    get datatableHeight() {
        if (this.finalSObjectDataList.length > 10) {
            return 'height: 350px;margin-bottom: 10px;';
        }
        else{
            return 'height: auto;margin-bottom: 10px;';
        }
    }

    /**
     * @returns return String as CSS for setting up width of each Activity Filter field to automatic fit on the page
     */
    get activityFilterWidth() {
        let numFields = this.numCustomFields + 3;
        let width = 100/numFields;
        
        return 'width: '+width+'%';
    }

    /**
     * @description This is for generation of Toast event
     * @param {String} _title The Title of Toast Event Message
     * @param {String} _message The Message of Toast Event
     * @param {String} _variant The variant or type of Toast Event
     */
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}