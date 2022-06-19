trigger ExpenseTrigger on Expense__c (before insert, before update, before delete, after insert, after update, after undelete) {
    new AccountTriggerHandler().run();
}