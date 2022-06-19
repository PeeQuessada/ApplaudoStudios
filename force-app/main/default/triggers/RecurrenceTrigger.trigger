trigger RecurrenceTrigger on Recurrence__c (before insert, before update, before delete, after insert, after update, after undelete) {
    new RecurrenceTriggerHandler().run();
}