import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderComponent } from "./components/header/header.component";
import { SidebarComponent } from "./components/sidebar/sidebar.component";
import { SummaryComponent } from "./components/pages/summarypage/summary/summary.component";
import { TransactionsComponent } from "./components/pages/transactionspage/transactions/transactions.component";
import { InsightsComponent } from "./components/pages/insightspage/insights/insights.component";
import { SavingsComponent } from "./components/pages/savingspage/savings/savings.component";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, HeaderComponent, SidebarComponent, SummaryComponent, TransactionsComponent, InsightsComponent, SavingsComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})

export class AppComponent {
  title(title: any) {
    throw new Error('Method not implemented.');
  }
  activeTab = 'Summary';
}
