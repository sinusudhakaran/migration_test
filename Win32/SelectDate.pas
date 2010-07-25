unit SelectDate;

interface
uses
  OvcPF, ovcDate, Windows, sysutils, controls,stdCtrls;

function  DateIsValid( s:string) : boolean;
procedure ShowDateError(Sender : TObject);
procedure MovePeriod(Add : boolean; eDateFrom , eDateTo :TOvcPictureField; FDataFrom, FDataTo:integer);

implementation
uses
  InfoMoreFrm, bkDateUtils, quikdate, globals;

procedure MovePeriod(Add : boolean; eDateFrom , eDateTo :TOvcPictureField; FDataFrom, FDataTo:integer);
var
  Diff : integer;
  D1,D2 : integer;
  d1d,d1m,d1y : integer;
  d2d,d2m,d2y : integer;
  DaysIn : integer;
  DDiff, MDiff, YDiff : integer;
  d1New, d2New : integer;
//  DataBOM, DataEOM : integer;
begin
  d1 := eDateFrom.AsStDate;
  d2 := eDateTo.AsStDate;

  Diff := d2-d1;
  if diff <=0 then exit;

  StDatetoDMY(d1,d1d,d1m,d1y);
  StDatetoDmy(d2,d2d,d2m,d2y);
  DaysIn := OvcDate.DaysInMonth(d2m,d2y,BKDATEEPOCH);

  if (d1d <> 1) or (d2d <> DaysIn) then
  begin
     {not looking a date for the first and last of the month}
     eDateFrom.AsStDate := DMYtoStDate(1,d1m,d1y,BKDATEEPOCH);
     eDateTo.AsStDate   := DMYtoStDate(DaysIn,d2m,d2y,BKDATEEPOCH);
     exit;
  end;

  {have dates that are first and last of month, so now find mth and year diff}
  DateDiff(d1,d2+1,dDiff,mDiff,yDiff);

  if not Add then
  begin
     {go back}
     d1New := IncDate(d1,0,-mDiff,-yDiff);
     d2New := d1-1;
  end
  else
  begin
     {go forward}
     d1New := d2+1;
     d2New := IncDate(d2+1,0,mDiff,yDiff)-1;
  end;

  {have new dates, now need to see if provide dates that have data}
  {first convert the datafrom and dataTo to beginning and end of month dates}
  StDatetoDMY(FDataFrom,d1d,d1m,d1y);
  StDatetoDmy(FDataTo,d2d,d2m,d2y);

(*
  DaysIn := DaysInMonth(d2m,d2y,BKDATEEPOCH);

  if (d1d <> 1) or (d2d <> DaysIn) then
  begin
     {not looking a date for the first and last of the month}
     DataBOM := DMYtoStDate(1,d1m,d1y,BKDATEEPOCH);
     DataEOM := DMYtoStDate(DaysIn,d2m,d2y,BKDATEEPOCH);
  end
  else
  begin
     DataBOM := FDataFrom;
     DataEOM := FDataTo;
  end;

  //checks to see if the new dates are inside the range of current transactions
  //code disabled
  if ((d1New < DataBOM) and (d2New < DataBOM)) or
     ((d1New > DataEOM) and (d2New > DataEOM)) then exit; {new range not valid}

  if d1New < DataBOM then d1New := dataBOM;
  if d2New > DataEOM then d2New := dataEOM;
  *)

  eDateFrom.asStDate := d1New;
  eDateTo.asStDate := d2New;
end;

function DateIsValid( s:string) : boolean;
Var
   ADate : TStDate;
begin
   ADate := bkDateUtils.bkStr2Date( S );
   Result := ( ADate<>0 ) and ( ADate<>BadDate );
end;

procedure ShowDateError(Sender : TObject);
begin
  HelpfulInfoMsg('Invalid Date Entered',0);
  TOvcPictureField(Sender).AsString := '';
end;

end.
