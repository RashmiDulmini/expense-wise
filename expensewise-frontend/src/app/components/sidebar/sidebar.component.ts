import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Input, Output, EventEmitter } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { AppComponent } from '../../app.component';
import { BrowserModule } from '@angular/platform-browser';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css'],
  standalone: true, // mark sidevar as standalone component
  imports: [CommonModule]  // Import CommonModule for directives like ngClass, ngFor
})


export class SidebarComponent {
  @Input() activeTab: string = 'Summary';  // Receive the activeTab from the parent component
  @Output() activeTabChange: EventEmitter<string> = new EventEmitter<string>();  // emit changes to the parent component

  tabs = [
    { name: 'Summary', icon: 'home' },
    { name: 'Transactions', icon: 'account_balance_wallet' },
    { name: 'Insights', icon: 'bar_chart' },
    { name: 'Savings', icon: 'savings' }
  ];

  // method - change the active tab
  changeTab(tab: string) {
    this.activeTab = tab;
    this.activeTabChange.emit(this.activeTab);  // add the updated activeTab value to the parent
  }
}
