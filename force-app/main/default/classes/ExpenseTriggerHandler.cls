public with sharing class ExpenseTriggerHandler extends TriggerHandler {

    private List<Expense__c> newExpenses;
    private Map<Id, Expense__c> oldExpensesMap;

    public ExpenseTriggerHandler() {
        this.newExpenses = (List<Expense__c>) Trigger.new;
        this.oldExpensesMap = (Map<Id, Expense__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        GenerateRecurrenceExpenses generateRecurrenceExpensesHandler = new GenerateRecurrenceExpenses();
        generateRecurrenceExpensesHandler.generateRecurrence(this.newExpenses);
        generateRecurrenceExpensesHandler.generateExpense(this.newExpenses);
    }
}