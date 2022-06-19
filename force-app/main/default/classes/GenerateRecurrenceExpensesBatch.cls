global with sharing class GenerateRecurrenceExpensesBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = 
            'SELECT Id, Amount__c, Category__c, Date__c, Name, MonthlyRecurrence__c, WeeklyRecurrence__c, RecordTypeId FROM Expense__c ' +
            'WHERE ' +
                'RecordType.DeveloperName = \'Recurrence\' AND ' +
                'Date__c = LAST_MONTH AND ' +
                '(MonthlyRecurrence__c != NULL OR ' +
                'WeeklyRecurrence__c != NULL)';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<Expense__c> recurrenceExpenses) {
        try {
            GenerateRecurrenceExpenses generateRecurrenceExpenses = new GenerateRecurrenceExpenses();
            generateRecurrenceExpenses.generateMonthly(recurrenceExpenses);
            generateRecurrenceExpenses.generateWeekly(recurrenceExpenses);
        } catch(Exception e) {
            System.debug('Error on batch ' + e);
        }
    }   
    
    global void finish(Database.BatchableContext batchableContext) {
        System.debug('finish');
    }
}
