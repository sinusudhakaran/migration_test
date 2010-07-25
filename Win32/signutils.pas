Unit SignUtils;

Interface

Uses
   MoneyDef;

Type
   tSign = (Debit, Credit, NNone );

Function SignOf(m: money) : tSign;

Function SetSign( m : money; sign : TSign) : money;
Function SetSign_Curr( m : currency; sign : TSign) : currency;

Function ExpectedSign(Account_Type: byte) : tSign;

Function ReverseSign( Expected : tSign ) : tSign;

//******************************************************************************
Implementation

Uses
   bkconst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function SignOf(m: money) : tSign;
Begin { SignOf }
   If m < 0 Then
   Begin
      SignOf := Credit
   End
   Else
   Begin
      SignOf := Debit
   End;
End; { SignOf }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ExpectedSign(Account_Type: byte) : tSign;
Const
   ExpectedSignFor : Array [atMin..atMax] Of tSign = {replaces a function of the same name}
   (
      { atNone          }
      Credit,
      { atIncome        }
      Credit,
      { atDirectExpense }
      Debit,
      { atExpense  }
      Debit,
      { atOtherExpense  }
      Debit,
      { atOtherIncome   }
      Credit,
      { atEquity}
      Credit,
      { atDebtors       }
      Debit,
      { atCreditors     }
      Credit,
      { atOpeningStock  }
      Debit,
      { atPurchases     }
      Debit,
      { atClosingStock  }
      Credit,
      { atFixedAssets   }
      Debit,
      { atStockOnHand   }
      Debit,
      { atBankAccount   }
      Debit,
      { atRetainedPorL  }
      Debit,
      { atGSTPayable    }
      Credit,
      { atUnknownDR     }
      Debit,
      { atUnknownCR     }
      Credit,
      { atCurrentAsset }
      Debit,
      { atCurrentLiability }
      Credit,
      { atLongTermLiabilit }
      Credit,
      { atUnknown Cr}
      Credit,
      { atUnknown Dr}
      Debit,
      { atCurrentYearsEarnings}
      Credit,
      { atGSTReceivable}
      Debit
      );
Begin
   Result := ExpectedSignFor[Account_Type];
End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ReverseSign( Expected : tSign ) : tSign;
begin
   Result := NNone;
   if Expected = Debit then
      Result := Credit;
   if Expected = Credit then
      Result := Debit;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function SetSign( m : money; sign : TSign) : money;
begin
   result := m;
   case sign of
      Debit  : if m < 0 then result := -1 * m;   //result must be +ve
      Credit : if m > 0 then result := -1 * m;   //result must be -ve
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function SetSign_Curr( m : currency; sign : TSign) : currency;
begin
   result := m;
   case sign of
      Debit  : if m < 0 then result := -1 * m;   //result must be +ve
      Credit : if m > 0 then result := -1 * m;   //result must be -ve
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
End.
