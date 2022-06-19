@isTest
private class ExpenseTriggerHandlerTest {
    

    @isTest
    static void createDefaultExpense(){
        Expense__c defaultExpense = new ExpenseFactory()
          .name('Expense Test')
          .category('Food')
          .amount(500)
          .day(System.today())
          .get();
      
        Test.startTest();
        insert defaultExpense;
        Test.stopTest();

        List<Expense__c> expenses = [SELECT Id, Date__c FROM Expense__c];
        System.assert(expenses.size() == 1);
    }

    @isTest
    static void createWeeklyExpense(){

        Date day = Date.newInstance(System.today().year(), System.today().month(), 1);
        Expense__c weeklyExpense = new ExpenseFactory()
          .name('weeklyExpense Test')
          .category('Food')
          .amount(500)
          .day(day)
          .weeklyRecurrence('Tuesday')
          .get();
      
        Test.startTest();
        insert weeklyExpense;
        Test.stopTest();

        List<Expense__c> expenses = [SELECT Id, Date__c FROM Expense__c WHERE RecordType.DeveloperName = 'Recurrence'];
        System.assert(expenses.size() == 1);
    }

    @isTest
    static void createMonthlyExpense(){
        Date day = Date.newInstance(System.today().year(), System.today().addMonths(-1).month(), 1);
        Expense__c monthlyExpense = new ExpenseFactory()
          .name('monthlyExpense Test')
          .category('Food')
          .amount(500)
          .day(day)
          .monthlyRecurrence(1)
          .get();

        insert monthlyExpense;

        List<Expense__c> expenses = [SELECT Id, format(Date__c), RecordType.DeveloperName FROM Expense__c ];
        System.debug('expenses.size() ' + expenses);
      
        Test.startTest();
        GenerateRecurrenceExpensesBatch batch = new GenerateRecurrenceExpensesBatch();
        database.executeBatch(batch);
        Test.stopTest();

         expenses = [SELECT Id, format(Date__c), RecordType.DeveloperName FROM Expense__c WHERE Date__c = THIS_MONTH ];
        System.debug('expenses.size() ' + expenses);
        System.assert(expenses.size() == 1);
    }
}
