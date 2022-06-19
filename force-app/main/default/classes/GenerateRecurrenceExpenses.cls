public class GenerateRecurrenceExpenses {
	private Date todayDate;
    private Datetime todayDateTime;
    private Id defaultRecordTypeId;
    private Id recurrenceRecordTypeId;
   
    public GenerateRecurrenceExpenses() {
        this.todayDate = System.today();
        this.todayDateTime = (DateTime) todayDate;
        this.defaultRecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        this.recurrenceRecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByDeveloperName().get('Recurrence').getRecordTypeId();
    }

    public void generateRecurrence(List<Expense__c> newExpenses) {
        List<Expense__c> defaultExpenses = new List<Expense__c>();

        for(Expense__c expense : newExpenses) {
            if(expense.RecordTypeId == this.defaultRecordTypeId) {
                defaultExpenses.add(expense);
            }
        }

        if(defaultExpenses.isEmpty()) {
            return;
        }

        List<Expense__c> createRecurrenceExpenses = new List<Expense__c>();
        for(Expense__c expense : defaultExpenses) {
            if(expense.MonthlyRecurrence__c != null || expense.WeeklyRecurrence__c != null) {
                Expense__c recurrenceExpense = new Expense__c();
                recurrenceExpense.RecordTypeId = this.recurrenceRecordTypeId;
                recurrenceExpense.Amount__c = expense.Amount__c;
                recurrenceExpense.Category__c = expense.Category__c;
                recurrenceExpense.Date__c = expense.Date__c;
                recurrenceExpense.Name = expense.Name;
                recurrenceExpense.WeeklyRecurrence__c = expense.WeeklyRecurrence__c;
                createRecurrenceExpenses.add(recurrenceExpense);
            }
        }      
        
        if(!createRecurrenceExpenses.isEmpty()) {
            Database.insert(createRecurrenceExpenses, true);
        }

    }

    public void generateExpense(List<Expense__c> newExpenses) {

    }
    
    public void generateWeekly(List<Expense__c> newExpenses) {
        List<Expense__c> expenses = new List<Expense__c>();

        List<Expense__c> weeklyExpenses = new List<Expense__c>();
        for(Expense__c expense : newExpenses) {
            if(expense.RecordTypeId == this.recurrenceRecordTypeId && expense.WeeklyRecurrence__c != null) {
                weeklyExpenses.add(expense);
            }
        }

        if(weeklyExpenses.isEmpty()) {
            return;
        }

        Map<String, List<Expense__c>> mapDayByExpenses = new Map<String, List<Expense__c>>();
        for(Expense__c expense : newExpenses) {
            String dayOfWeek = expense.WeeklyRecurrence__c;

            if(!mapDayByExpenses.containsKey(dayOfWeek)) {
                mapDayByExpenses.put(dayOfWeek, new List<Expense__c>());
            }

            mapDayByExpenses.get(dayOfWeek).add(expense);
        }
        

        Integer maxDaysinThisMonth = Date.daysInMonth(this.todayDate.year(), this.todayDate.month());
        Integer startDay = 0;
        if(Trigger.isExecuting) {
            maxDaysinThisMonth = maxDaysinThisMonth - this.todayDate.day();
            startDay = 1;
        }
        
        for(Integer moreDay = startDay; moreDay <= maxDaysinThisMonth; moreDay++) {
            Datetime actualyDate = todayDateTime.addDays(moreDay);
            String dayOfWeek = actualyDate.format('EEEE');

            if(!mapDayByExpenses.containsKey(dayOfWeek)) {
                continue;
            }

            for(Expense__c expense : mapDayByExpenses.get(dayOfWeek)) {
                Expense__c defaultExpense = new Expense__c();
                defaultExpense.RecordTypeId = this.defaultRecordTypeId;
                defaultExpense.Amount__c = expense.Amount__c;
                defaultExpense.Category__c = expense.Category__c;
                defaultExpense.Date__c = this.todayDate.addDays(moreDay-1);
                defaultExpense.Name = expense.Name;
                defaultExpense.WeeklyRecurrence__c = expense.WeeklyRecurrence__c;
                expenses.add(defaultExpense);
            }
        }

        if(!expenses.isEmpty()) {
            TriggerHandler.bypass('ExpenseTriggerHandler');
            Database.insert(expenses, true);
        }
    }

    public void generateMonthly(List<Expense__c> recurrenceExpenses) {
        List<Expense__c> expenses = new List<Expense__c>();

        List<Expense__c> monthlyExpenses = new List<Expense__c>();
        for(Expense__c expense : recurrenceExpenses) {
            if(expense.RecordTypeId == this.recurrenceRecordTypeId && expense.MonthlyRecurrence__c != null) {
                monthlyExpenses.add(expense);
            }
        }

        if(monthlyExpenses.isEmpty()) {
            return;
        }

        Map<String, List<Expense__c>> mapDayByExpenses = new Map<String, List<Expense__c>>();
        for(Expense__c expense : recurrenceExpenses) {
            String dayOfWeek = String.valueOf(expense.MonthlyRecurrence__c);

            if(!mapDayByExpenses.containsKey(dayOfWeek)) {
                mapDayByExpenses.put(dayOfWeek, new List<Expense__c>());
            }

            mapDayByExpenses.get(dayOfWeek).add(expense);
        }

        Integer maxDaysinThisMonth = Date.daysInMonth(this.todayDate.year(), this.todayDate.month());
        
        for(Integer moreDay = 0; moreDay <= maxDaysinThisMonth; moreDay++) {
            Datetime actualyDate = todayDateTime.addDays(moreDay);
            String dayOfWeek = String.valueOf(maxDaysinThisMonth);

            if(!mapDayByExpenses.containsKey(dayOfWeek)) {
                continue;
            }

            for(Expense__c expense : mapDayByExpenses.get(dayOfWeek)) {
                Expense__c defaultExpense = new Expense__c();
                defaultExpense.RecordTypeId = this.defaultRecordTypeId;
                defaultExpense.Amount__c = expense.Amount__c;
                defaultExpense.Category__c = expense.Category__c;
                defaultExpense.Date__c = Date.newInstance(this.todayDate.year(), this.todayDate.month(), Integer.valueOf(expense.MonthlyRecurrence__c));
                defaultExpense.Name = expense.Name;
                defaultExpense.MonthlyRecurrence__c = expense.MonthlyRecurrence__c;
                expenses.add(defaultExpense);
            }
        }

        if(!expenses.isEmpty()) {
            TriggerHandler.bypass('ExpenseTriggerHandler');
            Database.insert(expenses, true);
        }
    }
}