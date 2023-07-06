 /**
 * @description 
 * @author Angelika Galang
 * @since July 5, 2023
 */
import { LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import VIEW_LOG from '@salesforce/schema/amsvl_ViewLog__c';
import NothingToSee from '@salesforce/label/c.amsvl_Error_NothingToSee';
import NothingToSeeMessage from '@salesforce/label/c.amsvl_Error_NothingToSeeMessage';
import Items from '@salesforce/label/c.amsvl_Label_Items';
import Updated from '@salesforce/label/c.amsvl_Label_Updated';
import getRecordFieldIdentifier from '@salesforce/apex/amsvl_CTR_LwcViewLogs.getRecordFieldIdentifier';

export default class Amsvl_lwcViewLogsTab extends NavigationMixin(LightningElement) {  
    //labels initialization
    labels = {
        NothingToSee,
        NothingToSeeMessage,
        Items,
        Updated
    };

    //datatable properties
    infiniteLoading = true;
    rowLimit = 100;

    //card details
    recordId;
    recordData;
    recordObject;
    cardBreadcrumbs = [];
    currentPageReference = null;

    dataLength = 0;
    lastUpdated;
    isLoading = true;
    
    get cardTitle(){
        return this.viewLogInfo?.data?.labelPlural;
    }

    get showIllustration(){
        return this.dataLength == 0;
    }

    @wire(getObjectInfo, { objectApiName: VIEW_LOG })
    viewLogInfo;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          this.recordId = currentPageReference.state.amsvl__recordId;
       }
    }

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.recordData = data;
            this.recordObject = this.recordData.apiName;
            // get values from fields based on object API name
            this.cardBreadcrumbs = [
                {
                    label: this.recordObject,
                    name: 'objectName',
                    id: this.recordObject
                }
            ];
        } else if (error) {
            
        }
    };

    
    @wire(getRecordFieldIdentifier, { objectName: '$recordObject' })
    wiredRecordField({ error, data }) {
        if (data) {
            this.cardBreadcrumbs = [
                ...this.cardBreadcrumbs,
                {
                    label: this.recordData.fields[data].value,
                    name: 'recordName',
                    id: this.recordId
                }
            ];
        } else if (error) {
        }
    }

    handleViewLogsLoad(event){
        this.dataLength = event.detail.dataLength;
        this.lastUpdated = event.detail.lastUpdated;
        this.isLoading = false;
    }

    handleNavigateTo(event) {
        event.preventDefault();
        //get the name of the breadcrumb that's clicked
        const crumbName = event.target.name;
        const crumbId = event.target.dataset.id;

        if(crumbName == 'objectName'){
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: crumbId,
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent'
                },
            });
        }else if(crumbName == 'recordName'){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: crumbId,
                    objectApiName: crumbName,
                    actionName: 'view'
                },
            });
        }
    }
}