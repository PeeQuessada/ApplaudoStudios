import { LightningElement, track, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CATEGORY_FIELD from '@salesforce/schema/Expense__c.Category__c';
import EXPENSE_OBJECT from '@salesforce/schema/Expense__c';

export default class CreateExpense extends LightningElement {

    @track recurenceOption = 'no';
    @track labelValue;
    @track categoryValue;
    @track dateValue;
    @track amountValue;
    @track weeklyValue;
    @track monthlyValue;

    @wire(getObjectInfo, { objectApiName: EXPENSE_OBJECT })
    objectInfo;

    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Default');
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: CATEGORY_FIELD })
    wiredCategory;

    get categoryOptions() {
        if(this.wiredCategory?.data?.values) {
            return this.wiredCategory.data.values;
        }

        return [];
    }

    changeFieldValue(event) {

        let field = event.currentTarget.dataset.id;
        let value = event.detail.value;
        this[field] = value;

        if(field == 'recurenceOption') {
            this.weeklyValue = '';
            this.monthlyValue = '';
        }
    }

    get isRecurenceOptions() {
        return [
            { label: 'No', value: 'no' },
            { label: 'Weekly', value: 'weekly' },
            { label: 'Monthly', value: 'monthly' },
        ];
    }

    get isWeekly() {
        if(this.recurenceOption == 'weekly') {
            return true;
        }

        return false;
    }

    get isMonthly() {
        if(this.recurenceOption == 'monthly') {
            return true;
        }

        return false;
    }

    changeWeeklyOption(event) {
        this.weeklyValue = event.detail.value
    }

    get weeklyOptions() {
        return [
            { label: 'Monday', value: 'Monday' },
            { label: 'Tuesday', value: 'Tuesday' },
            { label: 'Wednesday', value: 'Wednesday' },
            { label: 'Thursday', value: 'Thursday' },
            { label: 'Friday', value: 'Friday' },
            { label: 'Saturday', value: 'Saturday' },
            { label: 'Sunday', value: 'Sunday' },
        ];
    }

    save() {
        if(this.validateFields()) {
            this.createRecord();
        }
    }


    saveAndNew() {
        try {
            this.save();

            // clean fields
            this.recurenceOption = '';
            this.labelValue = '';
            this.categoryValue = '';
            this.dateValue = '';
            this.amountValue = '';
            this.weeklyValue = '';
            this.monthlyValue = '';

        } catch (error) {
            console.log('error ', error);
        }
    }

    validateFields() {
        if(!this.recurenceOption) {
            return false;
        }
        if(!this.labelValue) {
            return false;
        }
        if(!this.categoryValue) {
            return false;
        }
        if(!this.dateValue) {
            return false;
        }
        if(!this.amountValue) {
            return false;
        }
        if(!this.weeklyValue && this.recurenceOption == 'weekly') {
            return false;
        }
        if(!this.monthlyValue && this.recurenceOption == 'monthly') {
            return false;
        }

        return true;
    }

    createRecord() {
        let fields = {
            'Name' : this.labelValue, 
            'Amount__c' : this.amountValue, 
            'Category__c' : this.categoryValue,
            'Date__c' : this.dateValue
        };

        if(this.recurenceOption == 'weekly') {
            fields.WeeklyRecurrence__c = this.weeklyValue;
        }
        else if(this.recurenceOption == 'monthly') {
            console.log('monthly ', this.monthlyValue.split('-')[2])
            fields.MonthlyRecurrence__c = this.monthlyValue.split('-')[2];
        }
        
        // LDS method to create record.
        createRecord({'apiName' : 'Expense__c', fields})
            .then(response => {
                this.dispatchToast('Success', 'Expense created ');
            }).catch(error => {
                this.dispatchToast('Error', error, 'error');
                console.log(error);
            });
    }

    dispatchToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant, variant
        });
        this.dispatchEvent(event);
    }
}