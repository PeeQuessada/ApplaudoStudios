public class GenerateRecurrenceExpenses {
	private Date todayDate;
    private Datetime todayDateTime;
    private Id defaultRecordTypeId;
    private Id recurrenceRecordTypeId;
   
    public GenerateRecurrenceExpenses() {
        this.todayDate = System.today();
        this.todayDateTime = (DateTime) System.today();
        this.defaultRecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        this.recurrenceRecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByDeveloperName().get('Recurrence').getRecordTypeId();
    }

    public void generateRecurrence(List<Expense__c> newExpenses) {
        List<Expense__c> defaultExpenses = new List<Expense__c>();

        // Validar recordType do registro == default

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
                recurrenceExpense.Name = expense.Name + ' - Recurrence ';
                recurrenceExpense.Recurrence__c = expense.Recurrence__c;
                recurrenceExpense.WeeklyRecurrence__c = expense.WeeklyRecurrence__c;
                createRecurrenceExpenses.add(recurrenceExpense);
            }
        }      
        
        if(!createRecurrenceExpenses.isEmpty()) {
            Database.insert(createRecurrenceExpenses, true);
        }

    }

    public void generateExpense(List<Expense__c> newExpenses) {
        List<Expense__c> expenses = new List<Expense__c>();

        // Validar recordType do registro == Recurrence
        List<Expense__c> recurrenceExpenses = new List<Expense__c>();

        for(Expense__c expense : newExpenses) {
            if(expense.RecordTypeId == this.recurrenceRecordTypeId) {
                recurrenceExpenses.add(expense);
            }
        }

        if(recurrenceExpenses.isEmpty()) {
            return;
        }

        List<Expense__c> monthlyExpenses = new List<Expense__c>();
        // Validar se eh despesa mensal
            // se sim colocar em um map, onde a chave eh o dia do mes e o valor eh uma lista de despesas
        for(Expense__c expense : recurrenceExpenses) {
            if(expense.MonthlyRecurrence__c != null) {
                monthlyExpenses.add(expense);
            }
        }

        
        List<Expense__c> weeklyExpenses = new List<Expense__c>();
        // Validar se eh despesa semanal
            // se sim colocar em um map, onde a chave eh o dia do mes e o valor eh uma lista de despesas
        for(Expense__c expense : recurrenceExpenses) {
            if(expense.WeeklyRecurrence__c != null) {
                weeklyExpenses.add(expense);
            }
        }

        //expenses.addAll(this.generateMonthly(monthlyExpenses));
        expenses.addAll(this.generateWeekly(weeklyExpenses));

        if(!expenses.isEmpty()) {
            TriggerHandler.bypass('ExpenseTriggerHandler');
            Database.insert(expenses, true);
        }
        
    }
    
    private List<Expense__c> generateWeekly(List<Expense__c> newExpenses) {
        List<Expense__c> expenses = new List<Expense__c>();

        if(newExpenses.isEmpty()) {
            return expenses;
        }

        Map<String, List<Expense__c>> mapDayByExpenses = new Map<String, List<Expense__c>>();
        for(Expense__c expense : newExpenses) {
            String dayOfWeek = expense.WeeklyRecurrence__c;

            if(!mapDayByExpenses.containsKey(dayOfWeek)) {
                mapDayByExpenses.put(dayOfWeek, new List<Expense__c>());
            }

            mapDayByExpenses.get(dayOfWeek).add(expense);
        }
        

        // criar registros para o restante do mes
        Integer maxDaysinThisMonth = Date.daysInMonth(this.todayDate.year(), this.todayDate.month());
        maxDaysinThisMonth = maxDaysinThisMonth - this.todayDate.day();
        for(Integer moreDay = 1; moreDay <= maxDaysinThisMonth; moreDay++) {
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
                defaultExpense.Recurrence__c = expense.Recurrence__c;
                defaultExpense.WeeklyRecurrence__c = expense.WeeklyRecurrence__c;
                expenses.add(defaultExpense);
            }
        }

        return expenses;
    }

    private List<Expense__c> generateMonthly(List<Expense__c> newExpenses) {
        List<Expense__c> expenses = new List<Expense__c>();

        if(newExpenses.isEmpty()) {
            return expenses;
        }

        // criar registros para o restante do mes

            // for nos dias restantes do mes

                // pega o dia do mes (1, 2, 3...)
                // pego todas as despesas para esse dia da semana (pegar do map)
                // duplicar todos os campos execeto o dia

        return expenses;
    }
}