/**
 * @description 
 * @author Angelika Galang
 * @since July 5, 2023
 */
import { LightningElement, api } from 'lwc';
import getViewLogRecords from '@salesforce/apex/amsvl_CTR_LwcViewLogs.getViewLogRecords';
import getViewLogsCount from '@salesforce/apex/amsvl_CTR_LwcViewLogs.getViewLogsCount';

const VIEW_LOG_COLUMNS = [
    { 
        label: 'User',
        fieldName: 'userUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'userName' }, 
            target: '_self'
        } 
    },
    { label: 'View Count', fieldName: 'amsvl_ViewCount__c', type: 'number' },
    { 
        label: 'Last Visited', 
        fieldName: 'amsvl_LastVisited__c', 
        type: 'date',
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        } 
    }
];
export default class Amsvl_lwcViewLogsTable extends LightningElement {
    //params passed from parent lwc
    @api recordId;
    @api infiniteLoading;
    @api rowLimit;
    
    //datatable properties
    viewLogColumns = VIEW_LOG_COLUMNS;
    viewLogs = [];

    //value used to query succeeding loaded records
    rowOffset = 0;

    //to be returned to parent flag
    valuesLoaded = false;
    dataLength = 0;

    get showTable(){
        return this.dataLength > 0;
    }

    connectedCallback(){
        this.getViewLogs();
    }

    getViewLogs(){
        getViewLogRecords({
            recordId: this.recordId,
            limitSize: this.rowLimit,
            offsetSize: this.rowOffset
        })
        .then(result => {
            let resultFormatted = result.map(viewLog => {
                return {
                    ...viewLog,
                    userUrl: '/' + viewLog.amsvl_User__c,
                    userName: viewLog.amsvl_User__r.Name
                }
            });
            this.viewLogs = [...this.viewLogs,...resultFormatted];

            if(!this.valuesLoaded){
                this.passValuesToParent();
            }
        })
        .catch(error => {
            this.error = error;
            console.log('ERROR: ',JSON.stringify(error));
            // this.generateToast(
            //     ErrorTitle,
            //     ErrorMessage,
            //     ErrorVariant
            // );
        })
        .finally(() => {
            //this.isLoading = false;
        });
    }

    passValuesToParent(){
        getViewLogsCount({
            recordId: this.recordId
        })
        .then(result => {
            this.dataLength = result;
            const selectedEvent = new CustomEvent("viewlogsload", {
                detail: {
                    dataLength: result,
                    lastUpdated: this.viewLogs.length > 0 ?
                        new Date(this.viewLogs[0].amsvl_LastVisited__c).toLocaleString() : //get most recent record
                        new Date().toLocaleString() //set to now's date if no records
                }
            });
            this.dispatchEvent(selectedEvent);
        })
        .catch(error => {
            this.error = error;
            
            console.log('ERROR getViewLogsCount: ',JSON.stringify(error));
            // this.generateToast(
            //     ErrorTitle,
            //     ErrorMessage,
            //     ErrorVariant
            // );
        })
        .finally(() => {
            this.valuesLoaded = true;
        });
    }

    handleLoadMore(event){
        if(this.infiniteLoading & this.dataLength != this.viewLogs.length){ //load only when there are remaining records
            const { target } = event;
            target.isLoading = true;

            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.getViewLogs()
            .then(()=> {
                target.isLoading = false;
            });   
        }
    }
}