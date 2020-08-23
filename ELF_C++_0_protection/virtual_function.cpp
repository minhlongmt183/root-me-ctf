#include <iostream>
using namespace std;

class Account{
public:
    Account(double d){_balance = d;}
    virtual ~Account(){}
    virtual double GetBalance(){return _balance;}
    virtual void PrintBalance(){cerr << "Error. Balance not available for base type." << endl;}
private:
    double _balance;
};

class CheckingAccount : public Account {
public:
    CheckingAccount(double d) : Account(d){}
    void PrintBalance(){ cout << "Checking account balance: " << GetBalance() << endl;}
};

class SavingsAccount : public Account {
    public:
        SavingsAccount(double d) : Account(d){}
        void PrintBalance(){cout << "Savings account balance: " << GetBalance();}
};

int main(){
    CheckingAccount checking(100.00);
    SavingsAccount savings(1000.000);

    Account *pAccount = &checking;
    pAccount->PrintBalance();

    pAccount = &savings;
    pAccount->PrintBalance();
    return 0;
}
