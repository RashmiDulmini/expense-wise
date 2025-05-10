import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-summary',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './summary.component.html',
  styleUrls: ['./summary.component.css']
})
export class SummaryComponent {
  monthlyData = [
    { name: 'January', income: 3000, expense: 1500 },
    { name: 'February', income: 2500, expense: 1200 },
    { name: 'March', income: 2000, expense: 1800 },
  ];

  onMonthClick(month: any) {
    console.log('Month clicked:', month);
    
  }
}