public class GenerateRecurrenceExpenses {
	private Date todayDate;
    private Datetime todayDateTime;
   
    public GenerateRecurrenceExpenses() {
        this.todayDate = System.today();
        this.todayDateTime = (DateTime) System.today();
    }

    public void generate(List<Expense__c> newExpenses) {
        List<Expense__c> expenses = new List<Expense__c>();

        List<Expense__c> monthlyExpenses = new List<Expense__c>();
        // Validar se eh despesa mensal
            // se sim colocar em um map, onde a chave eh o dia do mes e o valor eh uma lista de despesas

        
        List<Expense__c> weeklyExpenses = new List<Expense__c>();
        // Validar se eh despesa semanal
            // se sim colocar em um map, onde a chave eh o dia do mes e o valor eh uma lista de despesas

        expenses.addAll(this.generateMonthly(monthlyExpenses));
        expenses.addAll(this.generateWeekly(weeklyExpenses));

        Database.insert(expenses, false);
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
                expense.Date__c = this.todayDate.addDays(moreDay);
                expenses.add(expense);
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