 /**
 * @description 
 * @author Angelika Galang
 * @since July 5, 2023
 */
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import VIEW_LOG from '@salesforce/schema/amsvl_ViewLog__c';
import ViewAll from '@salesforce/label/c.amsvl_Label_ViewAll';
export default class Amsvl_lwcViewLogsRelatedList extends NavigationMixin(LightningElement) {
    //globally exposed record id
    @api recordId;
    
    //labels initialization
    labels = {
        ViewAll
    };
    
    //datatable properties
    infiniteLoading = false;
    rowLimit = 5;

    dataLength = 0;
    isLoading = true;

    get cardTitle(){
        return this.viewLogInfo ? 
            this.viewLogInfo.data?.labelPlural + ' (' + (this.dataLength <= 5 ? this.dataLength : '5+') + ')' :
            '';
    }

    get showFooter(){
        return this.dataLength > 0;
    }

    @wire(getObjectInfo, { objectApiName: VIEW_LOG })
    viewLogInfo;

    handleViewLogsLoad(event){
        this.dataLength = event.detail.dataLength;
        this.isLoading = false;
    }

    handleViewAll(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'amsvl_RelatedViewLogs'
            },
            state: {
                amsvl__recordId: this.recordId
            }
        });
    }
}