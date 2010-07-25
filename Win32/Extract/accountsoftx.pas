unit accountsoftx;

{ AccountSoft Contact Details:

  Mr Rob Cook
  accsoft@c033.aone.net
  "The Client Accountant" software
  Ph 00613 5156 2443
  Fx 00613 5156 2355

  Uses the standard BankLink 5.0 CSV format.
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses CSVX;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
Begin
   CSVX.ExtractData( FromDate, ToDate, SaveTo );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
