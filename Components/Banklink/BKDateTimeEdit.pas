unit BKDateTimeEdit;

interface

uses
  SysUtils,
  Messages,
  Classes,
  RzDBEdit, RzEdit;

type
  TBKDateTimeEdit = class(TRzDateTimeEdit)
  private
    FGoingCalendar: Boolean;

    procedure WMKillFocus( var Msg: TMessage ); message wm_KillFocus;
  protected
    procedure DoDateEvaluation; virtual;
    procedure DisplayCalendar; override;
    procedure Change; override;
  public
    constructor Create(aOwner: TComponent); override;
  end;

procedure Register;

function ReformatDate(InDate: String; NewFormat: String): String;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKDateTimeEdit]);
end;

function ReformatDate(InDate: String; NewFormat: String): String;
var
  I: Integer;
  Ch: Char;
  Curval: String;
  Values: Array[0..2] of string;
  CmpValues: Array[0..1] of Integer;
  Part: Integer;
  Months: Integer;
  VMonth, VDay, VYear: Integer;
  VLargest, Largest: Integer;
  Value: Integer;
  CurYear, CurMonth, CurDay: Word;
  NewDate: TDateTime;
  MaxDays: Integer;
  DiffSizes, FirstFound: Boolean;
  DoDefault: Boolean;
begin
  VMonth := 0;
  VDay := 0;
  VYear := 0;

  NewDate := Date; {Worst case scenario as todays date, but this will never happen}

  DoDefault := True;

  InDate := Trim(InDate);

  try
    {Check for special identifiers}
    if CompareText(InDate, 'Today') = 0 then
    begin
      NewDate := Date;

      DoDefault := False;
    end
    else
    if CompareText(InDate, 'Tomorrow') = 0 then
    begin
      NewDate := Date + 1;

      DoDefault := False;
    end
    else
    if CompareText(InDate, 'Yesterday') = 0 then
    begin
      NewDate := Date - 1;

      DoDefault := False;
    end
    else
    begin
      {Check for day names, all week days that happen before today roll over to next week,
       all others fall on this week}
      for I := 1 to 7 do
      begin
        if (CompareText(ShortDayNames[I], InDate) = 0) or (CompareText(LongDayNames[I], InDate) = 0) then
        begin
          NewDate := Date + (I - DayOfWeek(Date));

          if DayOfWeek(Date) >= I then NewDate := NewDate + 7;

          DoDefault := False;

          Break;
        end;
      end;
    end;

    {If we didn't have any special days then perform the normal date conversion}
    if DoDefault then
    begin
      DecodeDate(Date, CurYear, CurMonth, CurDay);

      {Split the parts out into three}
      Part := 0;

      for I := 1 to Length(InDate) do
      begin
        Ch := InDate[I];

        if Ch in [#32, '-', ',', '.', ':', DateSeparator] then
        begin
          if Curval <> '' then
          begin
            Values[part] := Curval;

            Curval := '';

            Inc(Part);

            if Part > 2 then break;
          end;
        end
        else
        begin
          Curval := Curval + Ch;
        end;
      end;

      {Trap the last part}
      if Curval <> '' then Values[part] := Curval;

      {Check for one whole date - special case}
      if (Values[0] <> '') and (Values[1] = '') and (Values[2] = '') then
      begin
        if Length(Values[0]) = 6 then
        begin
          {Whole date as 010107}
          Values[2] := Copy(Values[0], 5, 2);
          Values[1] := Copy(Values[0], 3, 2);
          Values[0] := Copy(Values[0], 1, 2);
        end
        else
        if Length(Values[0]) = 8 then
        begin
          {Whole date as 01012007}
          Values[2] := Copy(Values[0], 5, 4);
          Values[1] := Copy(Values[0], 3, 2);
          Values[0] := Copy(Values[0], 1, 2);
        end;
      end;

      {Check for month names in each of the parts, also find the largest value}
      VLargest := 0;
      Largest := -1;
      DiffSizes := False;
      FirstFound := False;

      for I := 0 to 2 do
      begin
        for Months := 1 to 12 do
        begin
          if (CompareText(Values[I], ShortMonthNames[Months]) = 0) or (CompareText(Values[I], LongMonthNames[Months]) = 0) then
          begin
            VMonth := Months;

            Values[I] := '';

            Break;
          end;
        end;

        {Find the largest string, if there is one}
        if Values[I] <> '' then
        begin
          Value := Length(Values[I]);

          if Value <> VLargest then
          begin
            if FirstFound = True then DiffSizes := True;

            if Value > VLargest then
            begin
              VLargest := Value;
              Largest := I;

              FirstFound := True;
            end;
          end;
        end;
      end;

      {If the largest was not any bigger than the rest then there wasn't really a largest}
      if DiffSizes = False then Largest := -1;

      {If we have a largest then this is the year, otherwise the last one defined is the year}
      if Largest > -1 then
      begin
        VYear := StrToIntDef(Values[Largest], CurYear);

        Values[Largest] := '';
      end
      else
      begin
        for I := 2 downto 0 do
        begin
          if Values[I] <> '' then
          begin
            VYear := StrToIntDef(Values[I], CurYear);

            Values[I] := '';

            Break;
          end;
        end;
      end;

      {Now we have our year and maybe our month}
      Part := 0;

      CmpValues[0] := 0;
      CmpValues[1] := 0;

      {Collect up to two remaining parts}
      for I := 0 to 2 do
      begin
        if Values[I] <> '' then
        begin
          Value := StrToIntDef(Values[I], 0);

          CmpValues[Part] := Value;

          Inc(Part);

          if Part > 1 then Break;
        end;
      end;

      {No month so decide which of the two is the month}
      if VMonth = 0 then
      begin
        {Check if either are > 12, if so then it myst be days, if we already have days then month
         is current month as invalid month specified}
        if CmpValues[0] > 12 then
        begin
          VDay := CmpValues[0];
          VMonth := CmpValues[1];
        end
        else
        if CmpValues[1] > 12 then
        begin
          VDay := CmpValues[1];
          VMonth := CmpValues[0];
        end;

        {If neither were days then the first is ... determined if d appears before m in the base format or not}
        if VDay = 0 then
        begin
          if Pos('d', NewFormat) < Pos('m', NewFormat) then
          begin
            VDay := CmpValues[0];
            VMonth := CmpValues[1];
          end
          else
          begin
            VDay := CmpValues[1];
            VMonth := CmpValues[0];
          end;
        end;
      end
      else
      begin
        {We have our month so the first value is days}
        VDay := CmpValues[0];
      end;

      {Single digit year, less than 60 translates to 2000, over 60 translates to 1900}
      if (VYear > 0) and (VYear < 100) then
      begin
        if VYear < 60 then
          VYear := 2000 + VYear
        else
          VYear := 1900 + VYear;
      end;

      if VYear < 1900 then VYear := 1900;

      {Double check the boundries, if any are over, reset to current}
      if (VYear = 0) then VYear := CurYear;
      if (VMonth < 1) or (VMonth > 12) then VMonth := CurMonth;

      MaxDays := MonthDays[IsLeapYear(VYear), VMonth];

      if (VDay < 1) or (VDay > MaxDays) then VDay := CurDay;

      if (VYear < 0) or (VYear > 9999) then VYear := CurYear;

      NewDate := EncodeDate(VYear, VMonth, VDay);
    end;

    Result := FormatDateTime(NewFormat, NewDate);
  except
    Result := InDate;
  end;
end;

{ TBKDateTimeEdit }

constructor TBKDateTimeEdit.Create(aOwner: TComponent);
begin
  inherited;

  FGoingCalendar := False;
end;

procedure TBKDateTimeEdit.Change;
begin
  inherited;
end;

procedure TBKDateTimeEdit.DoDateEvaluation;
var
  SFormat: String;
  InText: String;
begin
  if (Text <> '') then
  begin
    SFormat := Format;
    if SFormat = '' then SFormat := ShortDateFormat;

    InText := Text;

    Text := ReformatDate(Text, SFormat);

    {If we did reformat the time then set the modified so the inherited focus change sets the internal value}
    if InText <> Text then Modified := True;
  end;
end;

procedure TBKDateTimeEdit.DisplayCalendar;
begin
  FGoingCalendar := True;
  try
    DoDateEvaluation;

    SetDateTime;

    inherited;
  finally
    FGoingCalendar := False;
  end;
end;

procedure TBKDateTimeEdit.WMKillFocus(var Msg: TMessage);
begin
  {Here we check the date format and reformat it back to the format that the default method expects}
  if EditType = etDate then
  begin
    if (FGoingCalendar = False) and (not (csDestroying in ComponentState)) then
    begin
      DoDateEvaluation;
    end;
  end;

  inherited;
end;

end.
