import { LightningElement,api,wire } from 'lwc';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContentDocs from '@salesforce/apex/amsfd_CTR_LwcFileDisconnector.getContentDocs';
import deleteContentDocumentLink from '@salesforce/apex/amsfd_CTR_LwcFileDisconnector.deleteContentDocumentLink';
import { refreshApex } from '@salesforce/apex';
import OWNER_ID_FIELD from '@salesforce/schema/Contact.OwnerId';
import { NavigationMixin } from 'lightning/navigation';
import USERID from '@salesforce/user/Id';
import HELP_TEXT from '@salesforce/label/c.Disassociate_Help_Text';
import NO_FILE from '@salesforce/label/c.No_File_Found';

const actions = [
    { label: 'Disassociate', name: 'disassociate' }
 ];

const columns = [
    {type: 'button-icon',fixedWidth: 40,
        typeAttributes: {
            iconName: 'utility:preview',
            name: 'preview',
            title: 'Preview',
            variant: 'bare', 
        }
    },
    { label: 'File Name', fieldName: 'Title' },
    { label: 'File Type', fieldName: 'FileType', initialWidth: 100},
    { label: 'File Size', fieldName: 'FileSize', initialWidth: 100},
    { label: 'Created Date', fieldName: 'CreatedDate',
        initialWidth: 100,
        type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions
        }
    }
];

export default class LwcFileDisconnector extends NavigationMixin (LightningElement) {
    record=[];
    selectedRecords = [];
    selectedId=[];
    singleSelectedId=[];
    columns = columns;
    hasRecords = false;
    @api recordId;
    userId = USERID;
    isOwner;
    title;
    resultRecord;
    showLoadingSpinner = false;
    helpText = HELP_TEXT;
    noFile = NO_FILE;
    test = {"fieldApiName":"OwnerId","objectApiName":"Contact"};
    connectedCallback()
    {
        console.log('Test id' + JSON.stringify(OWNER_ID_FIELD));

    }

    tmdOwnerId;
    @wire(getRecord, { recordId: '$recordId', fields: test })
    tmdData({ error, data }) 
    {
        if(data){
                this.tmdOwnerId = getFieldValue(data,test);
                console.log('Id: ' + this.tmdOwnerId);
            }
        else if(error){
                console.log('Error: ' + JSON.parse(JSON.stringify(error)));
        }
    }
    
    //console.log('ownerId' + this.tmdOwnerId);

    @wire(getContentDocs,{recordId : '$recordId'})
    wiredRecord(result)
    {
        this.refreshTable = result;
        this.isOwner= this.tmdOwnerId == this.userId ? true: false;  
        if(result.data)
        {
            this.data = result.data;
            this.resultData =  this.data.map(conDocLink => {
                return {
                    id: conDocLink.Id,
                    FileId: conDocLink.ContentDocumentId,
                    Title:conDocLink.ContentDocument.Title,
                    FileType: conDocLink.ContentDocument.FileType,
                    FileOwnerId : conDocLink.ContentDocument.OwnerId,
                    FileSize: (conDocLink.ContentDocument.ContentSize /1024).toFixed() + 'KB',
                    CreatedDate:conDocLink.ContentDocument.CreatedDate,
                };
            });
            this.filteredData =  this.resultData.filter(owner => owner.FileOwnerId != this.tmdOwnerId);
            this.filteredData = JSON.parse(JSON.stringify(this.filteredData));
            this.record = [...this.record, ...this.filteredData];
            this.title = "Files I Do Not Own (" +  this.filteredData.length + ")";
            this.hasRecords = this.filteredData.length > 0 ? true: false;
        }
        else if (result.error) {
            this.resultRecord = result.error;
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
        }
    }

    handleRowActions(event) {
        const linkId ={};
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const recId =  event.detail.row.FileId;
        switch(actionName){
            case 'preview':
                this[NavigationMixin.Navigate]({ 
                    type:'standard__namedPage',
                    attributes:{ 
                        pageName:'filePreview'
                    },
                    state:{ 
                        selectedRecordId: recId
                    }
                })
                break;

            case 'disassociate':
                linkId.Id=row.id;
                this.singleSelectedId.push(linkId);
                this.deleteRecords(this.singleSelectedId);
                break;
        }
    }

    deleteRecords(contentLinkId) {
        if (this.selectedId.length > 0 || this.singleSelectedId.length > 0) {
            this.showLoadingSpinner = true;
            deleteContentDocumentLink({contDoc:contentLinkId}).then(result => {
                this.showLoadingSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'File/s disassociated.',
                        variant: 'success'
                    }),
                );
                this.record=[];
                this.template.querySelector('lightning-datatable').selectedRows = [];
                this.selectedId=[];
                this.singleSelectedId=[];
                refreshApex(this.refreshTable);
            }).catch(error => {        
                this.showLoadingSpinner = false;
                this.selectedId=[];
                this.singleSelectedId=[]; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ' Error',
                        message: 'We cannot process the disassociation at the time. Please contact the support team if issue persists.',
                        variant: 'error'
                    }),
                );
            });
        }
    } 

    handleButtonAction()
    {
        if(this.selectedId.length > 0){
            this.deleteRecords(this.selectedId);
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning!',
                    message: 'No file/s selected.',
                    variant: 'warning'
                }),
            );
        }
    }

    getSelectedRecords() {        
        this.selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        if(this.selectedRecords.length > 0)
        {
            this.selectedId =  this.selectedRecords.map(selected => {
                return {
                    Id: selected.id,
                };
            });
        }
        else{
            this.selectedId =[];
        }
    }

}