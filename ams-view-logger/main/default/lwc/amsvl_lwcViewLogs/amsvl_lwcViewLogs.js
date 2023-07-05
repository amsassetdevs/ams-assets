/**
 * 
 */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ErrorMessage from '@salesforce/label/c.amsvl_Error_Message';
import ErrorTitle from '@salesforce/label/c.amsvl_Error_Title';
import ErrorVariant from '@salesforce/label/c.amsvl_Error_Variant';
import TotalNumberofViewers from '@salesforce/label/c.amsvl_Label_TotalNumberofViewers';
import TotalNumberofViews from '@salesforce/label/c.amsvl_Label_TotalNumberofViews';
import ViewLogsSummary from '@salesforce/label/c.amsvl_Label_ViewLogsSummary';
import getViewLogsInfo from '@salesforce/apex/amsvl_CTR_LwcViewLogs.getViewLogsInfo';


export default class Amsvl_lwcViewLogs extends LightningElement {
    //globally exposed record id
    @api recordId;
    
    //labels initialization
    labels = {
        ViewLogsSummary,
        TotalNumberofViewers,
        TotalNumberofViews
    };

    //view counts
    totalViewCount = 0;
    totalViewerCount = 0;

    /**
     * 
     */
    connectedCallback() {
        this.getViewLogs();
    }

    /**
     * 
     */
    getViewLogs() {
        getViewLogsInfo({recordId: this.recordId})
        .then(result => {

            if(result){
                this.totalViewCount = result.totalViewCount;
                this.totalViewerCount = result.totalViewerCount;
            }
        })
        .catch(error => {
            this.error = error;
            this.generateToast(
                ErrorTitle,
                ErrorMessage,
                ErrorVariant
            );
        })
    }

    /**
     * 
     * @param {*} _title 
     * @param {*} _message 
     * @param {*} _variant 
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