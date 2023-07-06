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
import NameMapping from '@salesforce/label/c.amsvl_JSON_NameMapping';
import NothingToSee from '@salesforce/label/c.amsvl_Error_NothingToSee';
import NothingToSeeMessage from '@salesforce/label/c.amsvl_Error_NothingToSeeMessage';
import Items from '@salesforce/label/c.amsvl_Label_Items';
import Updated from '@salesforce/label/c.amsvl_Label_Updated';

const RECORD_FIELDS = JSON.parse(NameMapping);
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
            // get values from fields based on object API name
            console.log(JSON.stringify(data.fields));
            let recordFieldValues = [];
            let objectName = data.apiName;
            if(objectName in RECORD_FIELDS){
                RECORD_FIELDS[objectName].forEach(fieldName =>{
                    if(data.fields[fieldName].value){
                        recordFieldValues.push(data.fields[fieldName].value);
                    }
                });
            }

            this.cardBreadcrumbs = [
                {
                    label: objectName,
                    name: 'objectName',
                    id: objectName
                },
                {
                    label: 
                        recordFieldValues.length > 0 ? 
                        recordFieldValues.join(' ') : //get custom label fields defined
                        data.fields.Name ? 
                        data.fields.Name.value : //get name field if no custom label
                        data.id, //default to id if name is also unavailable
                    name: 'recordName',
                    id: this.recordId
                }
            ];
        } else if (error) {
            
        }
    };

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