import { LightningElement, wire, api, track} from 'lwc';
import getAvailableConfigs from '@salesforce/apex/CK_ConfigsController.getAvailableConfigs';
import createCaseConfigs from '@salesforce/apex/CK_ConfigsController.createCaseConfigs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import CASE_CONFIG_CREATED_CHANNEL from '@salesforce/messageChannel/CaseConfigCreated__c';

const columns = [
    { label: 'Label', fieldName: 'Label__c', sortable: true },
    { label: 'Type', fieldName: 'Type__c', sortable: true },
    { label: 'Amount', fieldName: 'Amount__c', sortable: true },
];

export default class Ck_AvailableConfigs extends LightningElement {
    
    @api recordId;
    wiredConfigRecords;
    data;
    error;
    columns = columns;
    selectedRows = [];

    @track
    sampleSelection = [];

    isLoading = false;
    pageNo;
    totalPages;
    startRecord;
    endRecord;
    end = false;
    pagelinks = [];
    recordsperpage = 5;
    @track recordsToDisplay;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @wire(MessageContext)
    messageContext;

    @wire(getAvailableConfigs, {})
    retrieveConfigs(wireResult){
        const { data, error } = wireResult;
        this.wiredConfigRecords = wireResult;
        if(data){
            this.data = data.lstConfigs;

            this.totalRecords = data.count;
            this.pageNo = 1;
            this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
            this.preparePaginationList();

            for (let i = 1; i <= this.totalPages; i++) {
                this.pagelinks.push(i);
            }
            this.isLoading = false;
        }
        if(error) {
            console.error(error)
        }
    }

    preparePaginationList() {
        this.isLoading = true;
        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.data.slice(begin, end);
        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;
        setTimeout(() => {
            this.disableEnableActions();
        }, 200);
        this.isLoading = false;
    }

    disableEnableActions() {
        
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach(bun => {
            if (bun.label === this.pageNo) {
                bun.disabled = true;
            } else {
                bun.disabled = false;
            }

            if (bun.label === "First") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            }
        });
    }

    handlePage(button) {
        this.pageNo = button.target.label;
        this.preparePaginationList();
    }

    handleNext() {
        this.pageNo += 1;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    handleFirst() {
        this.pageNo = 1;
        this.preparePaginationList();
    }

    handleLast() {
        this.pageNo = this.totalPages;
        this.preparePaginationList();
    }

    async createCaseConfigRecords(){
        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();  
        this.selectedRows = selectedRecords;
        let result = await createCaseConfigs({
            caseId: this.recordId,
            lstSelectedConfigs: this.selectedRows
        });
        if(result){
            if(result.isSuccess === true){
                this.showToast('Success!','Case Configuration Added Successfully!','success');
                const payload = { 
                    updated: 'true'
                };
                publish(this.messageContext, CASE_CONFIG_CREATED_CHANNEL, payload);
            }
            else {
                this.showToast('Error!',result.validationErrors[0],'error');
            }
        }
        else {
            this.showToast('Error!','Something went wrong','error');
        }
    }

    getSelectedName(event){
        let my_ids = [];
        let selectedRows = event.detail.selectedRows;
        for(let i = 0; i< selectedRows.length; i++){
            my_ids.push(selectedRows[i].Id);
        }
        this.sampleSelection.concat(my_ids);
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.recordsToDisplay];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplay = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    
    sortBy( field, reverse, primer ) {
        const key = primer
        ? function( x ) {
            return primer(x[field]);
        }
        : function( x ) {
            return x[field];
        };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };
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