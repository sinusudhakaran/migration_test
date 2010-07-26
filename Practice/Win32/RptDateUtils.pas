unit RptDateUtils;

{
   Routines to calculate the previous & next reporting period start dates
}

{..$DEFINE RPT_DATE_UTILS_TEST} // Uncomment this to run the test code.

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

//Function Get_Previous_Reporting_Period_Start_Date( Const aReporting_Period_Start_Date: Integer; Const aReporting_Period: byte ) : Integer;
//Function Get_Next_Reporting_Period_Start_Date( Const aReporting_Period_Start_Date: Integer; Const aReporting_Period: byte ) : Integer;
//Function Get_Reporting_Period_End_Date( Const aReporting_Period_Start_Date: Integer; Const aReporting_Period: byte ) : Integer;

Function Get_Reporting_Period_Start_Date( Const aReporting_Period_End_Date: Integer; Const aReporting_Period: byte ) : Integer;
Function Is_In_Reporting_Period( Const aSystem_Reporting_Period_End_Date : Integer;
                                 Const aClient_Reporting_Start_Date : Integer;
                                 Const aClient_Reporting_Period : byte ): Boolean;

//------------------------------------------------------------------------------
implementation uses BkConst, StDate, bkDateUtils;
//------------------------------------------------------------------------------

Function Get_Previous_Reporting_Period_Start_Date( Const aReporting_Period_Start_Date: Integer; Const aReporting_Period: byte ) : Integer;
//used by
//   Get_Reporting_Period_Start_Date
Const
  NoMonths : Array[ roSendEveryMonth..roSendEveryMonthTwoMonths ] of Integer = ( 1, 2, 3, 4, 6, 12, 1, 1 );
Var
  D, M, Y : Integer;
Begin
  // Note EveryTwoMonthsMonth will never be set when we come in here...
  // SchedRepUtils.GetReportingPeriodToUse will have reset it to either EveryTwoMonths or EveryMonth
  Assert( aReporting_Period_Start_Date > 0 );
  Assert( aReporting_Period in [ roSendEveryMonth..roSendEveryMonthTwoMonths ] );
  StDatetoDMY( aReporting_Period_Start_Date, D, M, Y );
  Assert( D=1 );
  DecMY( M, Y, NoMonths[ aReporting_Period ] );
  Result := DMYtoStDate(1, M, Y, bkDateUtils.Epoch);
end;

//------------------------------------------------------------------------------

{Function Get_Next_Reporting_Period_Start_Date( Const aReporting_Period_Start_Date: Integer; Const aReporting_Period: byte ) : Integer;
Const
  NoMonths : Array[ roSendEveryMonth..roSendEveryMonthTwoMonths ] of Integer = ( 1, 2, 3, 4, 6, 12, 1, 1 );
Var
  D, M, Y : Integer;
Begin
  Assert(aReporting_Period_Start_Date > 0);
  Assert(aReporting_Period in [ roSendEveryMonth..roSendEveryTwoMonthsMonth ]);
  StDatetoDMY( aReporting_Period_Start_Date, D, M, Y);
  Assert( D=1 );
  IncMY( M, Y, NoMonths[ aReporting_Period ] );
  Result := DMYtoStDate(1, M, Y, bkDateUtils.Epoch );
end;}

//------------------------------------------------------------------------------

{Function Get_Reporting_Period_End_Date( Const aReporting_Period_Start_Date: Integer; Const aReporting_Period: byte ) : Integer;
Begin
  Result := Pred( Get_Next_Reporting_Period_Start_Date( aReporting_Period_Start_Date, aReporting_Period ) );
end;}

//------------------------------------------------------------------------------

Function Get_Reporting_Period_Start_Date( Const aReporting_Period_End_Date: Integer; Const aReporting_Period: byte ) : Integer;
// used by
//    RptAdmin.WhatsDueDetail
//    Scheduled.ScheduledReportsDue
//    Scheduled.DoScheduledReportsForClient
//    Scheduled.DoExportScheduledECodingFile
Var
  NextPdStarts : Integer;
Begin
  Assert( aReporting_Period_End_Date > 0 );
  Assert( IsTheLastDayOfTheMonth( aReporting_Period_End_Date ) );
  Assert( aReporting_Period in [ roSendEveryMonth..roSendEveryTwoMonthsMonth ] );

  NextPdStarts := Succ( aReporting_Period_End_Date );
  Result := ( Get_Previous_Reporting_Period_Start_Date( NextPdStarts, aReporting_Period ) );
end;

//------------------------------------------------------------------------------

Function Is_In_Reporting_Period( Const aSystem_Reporting_Period_End_Date : Integer;
                                 Const aClient_Reporting_Start_Date : Integer;
                                 Const aClient_Reporting_Period : byte ): Boolean;
// used by:
//    Scheduled.ScheduledReportsDue
Const
  NoMonths : Array[ roSendEveryMonth..roSendEveryMonthTwoMonths ] of Integer = ( 1, 2, 3, 4, 6, 12, 1, 1 );
Var
  D, CM, CS, SM, Y : Integer;
Begin
  Assert( aClient_Reporting_Period in [ roSendEveryMonth..roSendEveryTwoMonthsMonth ] );

  StDateToDMY( aClient_Reporting_Start_Date, D, CM, Y );
  CS := CM; // for 2 month 1 month, CS is the client start month
  Dec( CM ); If CM=0 then CM := 12;
  // CM is one of the client's period end dates.

  StDateToDMY( aSystem_Reporting_Period_End_Date, D, SM, Y );
  // SM is the system period end month

  if aClient_Reporting_Period = roSendEveryTwoMonthsMonth then // special case - no overlapping
  begin
    // Is the system report end month an end period?
    if (CS - SM) mod 3 = 0 then
      Result := False
    else
      Result := True;
  end
  else
    Result :=  ( ( SM - CM ) mod NoMonths[ aClient_Reporting_Period ] = 0 );
end;

//------------------------------------------------------------------------------

{$IFDEF RPT_DATE_UTILS_TEST}
Initialization
  Assert( Is_In_Reporting_Period( bkStr2Date( '31/12/00' ), bkStr2Date( '01/12/00' ), roSendEveryMonth ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '31/12/00' ), bkStr2Date( '01/12/00' ), roSendEveryTwoMonths )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '31/01/00' ), bkStr2Date( '01/12/00' ), roSendEveryTwoMonths ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/01/00' ), roSendEveryThreeMonths ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/02/00' ), roSendEveryThreeMonths )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/03/00' ), roSendEveryThreeMonths )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/04/00' ), roSendEveryThreeMonths ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/04/00' ), roSendEverySixMonths ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/09/00' ), bkStr2Date( '01/04/00' ), roSendEverySixMonths ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/05/00' ), roSendEverySixMonths )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/04/00' ), roSendAnnually ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/03/00' ), roSendAnnually )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/05/00' ), roSendAnnually )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/10/00' ), roSendEveryThreeMonths ) );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/11/00' ), roSendEveryThreeMonths )=False );
  Assert( Is_In_Reporting_Period( bkStr2Date( '30/03/00' ), bkStr2Date( '01/12/00' ), roSendEveryThreeMonths )=False );
{$ENDIF RPT_DATE_UTILS_TEST}

end.
