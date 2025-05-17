import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms'; 
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-financial-input',
  standalone: true,
  imports: [CommonModule, FormsModule], 
  templateUrl: './financial-input.component.html',
  styleUrls: ['./financial-input.component.css']
})
export class FinancialInputComponent {
  selectedMonth: string = '';
  selectedYear: string = '';
  income: number | null = null;
  expenses: number | null = null;
  balance: number | null = null;

  submit() {
    console.log('Financial Data Submitted');
    console.log('Income:', this.income);
    console.log('Expenses:', this.expenses);
    console.log('Balance:', this.balance);

    // Add logic here to send data to backend or service
  }
}
