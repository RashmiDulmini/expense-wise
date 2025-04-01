/* dashboard.component.ts */
import { Component, AfterViewInit } from '@angular/core';
import Chart from 'chart.js/auto';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements AfterViewInit {
  ngAfterViewInit() {
    this.loadExpenseChart();
    this.loadIncomeExpenseChart();
  }

  loadExpenseChart() {
    new Chart("expenseChart", {
      type: 'doughnut',
      data: {
        labels: ['Travel', 'Education', 'Health Care', 'Garments', 'Grocery', 'Eating Outside'],
        datasets: [{
          data: [500, 300, 200, 1000, 809, 182],
          backgroundColor: ['#ffcc00', '#ff6666', '#ff9933', '#3399ff', '#33cc33', '#9933ff']
        }]
      }
    });
  }

  loadIncomeExpenseChart() {
    new Chart("incomeExpenseChart", {
      type: 'line',
      data: {
        labels: ['14-Jul', '15-Jul', '16-Jul', '17-Jul', '18-Jul', '19-Jul', '20-Jul'],
        datasets: [
          {
            label: 'Income',
            data: [6200, 3000, 2000, 1500, 1700, 2100, 2300],
            borderColor: '#33cc33',
            fill: false
          },
          {
            label: 'Expense',
            data: [5000, 2500, 1800, 1600, 1900, 2000, 2400],
            borderColor: '#ff6666',
            fill: false
          }
        ]
      }
    });
  }
}
