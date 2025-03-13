import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';  // Import CommonModule here

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css'],
  standalone: true,  // Mark SidebarComponent as standalone if using standalone components
  imports: [CommonModule]  // Import CommonModule for directives like ngClass, ngFor
})
export class SidebarComponent {
  tabs = [
    { name: 'Summary', icon: 'home' },
    { name: 'Transactions', icon: 'account_balance_wallet' },
    { name: 'Insights', icon: 'bar_chart' },
    { name: 'Savings', icon: 'savings' }
  ];

  activeTab = 'Summary';
}
