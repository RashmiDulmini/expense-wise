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

  it('should update data on input change', () => {
    component.month = 'January';
    component.year = 2025;
    component.income = 3000;
    component.expenses = 1500;
    component.balance = 1500;

    expect(component.month).toBe('January');
    expect(component.year).toBe(2025);
    expect(component.income).toBe(3000);
    expect(component.expenses).toBe(1500);
    expect(component.balance).toBe(1500);
  });

  it('should log data on submit', () => {
    spyOn(console, 'log');
    component.submit();
    expect(console.log).toHaveBeenCalled();
  });
});
