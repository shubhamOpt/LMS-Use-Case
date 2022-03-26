import { LightningElement ,wire , api } from 'lwc';
import getCaseConfigs from '@salesforce/apex/CK_ConfigsController.getCaseConfigs';
import sendRequest from '@salesforce/apex/CK_ConfigsController.sendRequest';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { subscribe, MessageContext } from 'lightning/messageService';
import CASE_CONFIG_CREATED_CHANNEL from '@salesforce/messageChannel/CaseConfigCreated__c';

const columns = [
    { label: 'Label', fieldName: 'Label__c', sortable: true },
    { label: 'Type', fieldName: 'Type__c', sortable: true },
    { label: 'Amount', fieldName: 'Amount__c', sortable: true },
];

export default class Ck_CaseConfigs extends LightningElement {

    @api recordId;
    subscription = null;
    renderTable = false;
    wiredConfigRecords;
    data;
    error;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    buttonDisabled = true;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    @wire(MessageContext)
    messageContext;

    @wire(getCaseConfigs, {caseId: '$recordId'})
    retrieveConfigs(wireResult){
        const { data, error } = wireResult;
        this.wiredConfigRecords = wireResult;
        if(data && data.length > 0){
            this.renderTable = true;
            this.buttonDisabled = false;
            this.data = data
        }
        if(error) {
            console.error(error)
        }
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          CASE_CONFIG_CREATED_CHANNEL,
          (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        if(message.updated == 'true') {
            refreshApex(this.wiredConfigRecords);
        }
    }

    async handleSend(event) {
        let payload = {};
        payload = this.createPayload();
        let request = await sendRequest({
            caseId: this.recordId,
            payload: JSON.stringify(payload)
        });
        if(request){
            if(request.isSuccess){
                eval("$A.get('e.force:refreshView').fire();");
                this.buttonDisabled = true;
                this.showToast('Success!','Information Posted Successfully','success');
            }
            else{
                this.showToast('Error!',request.validationErrors[0],'error');
            }
        }
        else {
            this.showToast('Error!','Something went wrong. Please contact your System Admin!','error');
        }
    }
    
    createPayload() {
        let caseConfigArray = [];
        for(let i = 0; i < this.data.length; i++){
            let eachCaseConfig = {
                label: this.data[i].Label__c,
                type: this.data[i].Type__c,
                amount: this.data[i].Amount__c
            };
            caseConfigArray.push(eachCaseConfig);
        }
        return {
            caseId: this.recordId,
            status: 'Closed',
            caseConfigs: caseConfigArray
        };
    }

    onHandleSort(event) {       
        this.sortedBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortBy(this.sortedBy, this.sortDirection);
    }


    sortBy(fieldname, direction) {
        
        let parseData = JSON.parse(JSON.stringify(this.data));
       
        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            
            return isReverse * ((x > y) - (y > x));
        });
        
        this.data = parseData;

    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }
}