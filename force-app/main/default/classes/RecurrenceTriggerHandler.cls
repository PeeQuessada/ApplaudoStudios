public with sharing class RecurrenceTriggerHandler extends TriggerHandler {

    private List<Recurrence__c> newRecurrences;
    private Map<Id, Recurrence__c> oldRecurrencesMap;

    public RecurrenceTriggerHandler() {
        this.newRecurrences = (List<Recurrence__c>) Trigger.new;
        this.oldRecurrencesMap = (Map<Id, Recurrence__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        GenerateRecurrenceExpenses generateRecurrenceExpensesHandler = new GenerateRecurrenceExpenses();
    }
}
