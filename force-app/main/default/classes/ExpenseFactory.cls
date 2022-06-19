public class ExpenseFactory {

    private Expense__c expense;
    
    public ExpenseFactory() {
        this.expense = new Expense__c(
            RecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId()
        );
    }
    
    public ExpenseFactory name(String name) {
        this.expense.Name = Name;
        return this;
    }
    
    public ExpenseFactory category(String category) {
        this.expense.Category__c = category;
        return this;
    }

    public ExpenseFactory amount(Double amount) {
        this.expense.Amount__c = amount;
        return this;
    }
    
    public ExpenseFactory day(Date day) {
        this.expense.Date__c = day;
        return this;
    }

    public ExpenseFactory monthlyRecurrence(Integer monthlyRecurrence) {
        this.expense.MonthlyRecurrence__c = Double.valueOf(monthlyRecurrence);
        return this;
    }
    
    public ExpenseFactory weeklyRecurrence(String weeklyRecurrence) {
        this.expense.WeeklyRecurrence__c = weeklyRecurrence;
        return this;
    }
    
    public Expense__c get() {
        return this.expense;
    }
      
}
