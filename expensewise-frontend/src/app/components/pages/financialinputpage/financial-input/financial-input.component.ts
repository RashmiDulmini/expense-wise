import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms'; // ✅ Required for ngModel
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-financial-input',
  standalone: true,
  imports: [CommonModule, FormsModule], // ✅ Add FormsModule here
  templateUrl: './financial-input.component.html',
  styleUrls: ['./financial-input.component.css']
})
export class FinancialInputComponent {
  month: string = '';
  year: number = new Date().getFullYear();
  income: number | null = null;
  expenses: number | null = null;
  balance: number | null = null;

  months: string[] = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  years: number[] = Array.from({ length: 10 }, (_, i) => this.year - i);

  submit(): void {
    const data = {
      month: this.month,
      year: this.year,
      income: this.income,
      expenses: this.expenses,
      balance: this.balance
    };
    console.log('Submitted Financial Data:', data);

    // Here you can add a service call to send this data to the backend.
  }
}
