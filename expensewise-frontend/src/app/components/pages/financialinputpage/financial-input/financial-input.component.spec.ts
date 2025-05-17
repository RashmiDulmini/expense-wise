import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormsModule } from '@angular/forms';
import { FinancialInputComponent } from './financial-input.component';

describe('FinancialInputComponent', () => {
  let component: FinancialInputComponent;
  let fixture: ComponentFixture<FinancialInputComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [FinancialInputComponent],
      imports: [FormsModule]
    }).compileComponents();

    fixture = TestBed.createComponent(FinancialInputComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create the component', () => {
    expect(component).toBeTruthy();
  });

  it('should call submit() and log financial data', () => {
    spyOn(console, 'log');

    component.income = 2000;
    component.expenses = 1000;
    component.balance = 1000;

    component.submit();

    expect(console.log).toHaveBeenCalledWith('Financial Data Submitted');
    expect(console.log).toHaveBeenCalledWith('Income:', 2000);
    expect(console.log).toHaveBeenCalledWith('Expenses:', 1000);
    expect(console.log).toHaveBeenCalledWith('Balance:', 1000);
  });
});
