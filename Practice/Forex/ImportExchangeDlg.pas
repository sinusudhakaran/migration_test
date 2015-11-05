unit ImportExchangeDlg;
//------------------------------------------------------------------------------
{
   Title:        BankLink Import Exchange Rates Dialog unit

   Description:  CSV import of Exchange Rates.


   Remarks:      The Date mask scope should be updated. It should be per reload, not per column.

                 Some of the UK files seem to be ';' Delimited, the Delimiter selection is hidden at the moment
                 Mainly because they seem to have ',' in the fields which may present a problem



   Author:       Andre' Joosten, AUG 2010

}
//------------------------------------------------------------------------------

interface

uses
  ExchangeRateList,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,Contnrs,
  BKDateUtils,
  Dialogs, ExtCtrls, VirtualTrees, StdCtrls, baObj32,
  ComCtrls, moneyDef, Mask, RzEdit, RzSpnEdt,OsFont,ImportHistClass;

type
  ControlList =  array of TControl;
  AmountType  =  (NotAmount, Amount, AmountWithSign);
  PMoney = ^Money;

type
  TImportExchange = class(TForm)
    pFileinput: TPanel;
    pBtn: TPanel;
    pFile: TPanel;
    BTNBrowse: TButton;
    EPath: TEdit;
    OpenDlg: TOpenDialog;
    Label1: TLabel;
    chFirstline: TCheckBox;
    PFormat: TPanel;
    PCFormat: TPageControl;
    TSDate: TTabSheet;
    EDate: TEdit;
    Label2: TLabel;
    cbDate: TComboBox;
    Label4: TLabel;
    BtnCancel: TButton;
    btnOK: TButton;
    SkipLine: TRzSpinEdit;
    Label9: TLabel;
    pOut: TPanel;
    ReloadTimer: TTimer;
    lbFile: TLabel;
    cbDelimiter: TComboBox;
    Label12: TLabel;
    vsOut: TVirtualStringTree;
    vsFile: TVirtualStringTree;
    Label3: TLabel;
    cbOverwriteExchangeRates: TCheckBox;
    procedure BTNBrowseClick(Sender: TObject);
    procedure chFirstlineClick(Sender: TObject);
    procedure PCFormatChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbDateChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbRateChange(Sender: TObject);
    procedure SkipLineChange(Sender: TObject);
    procedure FormResize(Sender: TObject);


    procedure ReloadTimerTimer(Sender: TObject);
    procedure cbDelimiterChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vsFileGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vsOutGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vsFileChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vsOutChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vsFilePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vsFileBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure vsOutPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vsOutBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure vsFileHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure vsOutHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    FColumnControls: ControlList;
    FLockCount: Integer;
    FKeepCursor: Integer;
    FFormatsettings: TFormatSettings;
    FReloading: Boolean;
    FOutLvChanged: Boolean;
    FFileLvChanged: Boolean;
    fFileList: TobjectList;
    fOutList: TobjectList;
    FCurrentDate: Integer;
    FDateMask: string;
    FExchangeSource: PExchangeSource;
    FISOColumns: TVirtualTreeColumns;
    CurColumns: array of TCombobox;
    procedure BeginUpdate;
    procedure Endupdate;

    procedure ReloadFile;

    procedure SetColumnControls(const value: ControlList);
    function GetSelectedCol(index: Integer): Boolean;
    procedure SetSelectedCol(index: Integer; const Value: Boolean);
    procedure SetFileLvChanged(const Value: Boolean);
    procedure SetOutLvChanged(const Value: Boolean);
    procedure SetDateMask(const Value: string);
    procedure SetExchangeSource(const Value: PExchangeSource);
    property SelectedCol [index : Integer]: Boolean read GetSelectedCol write SetSelectedCol;
    function GetFileText(const Row,Col: Integer; MaxLen: Integer = 0):string;
    property ColumnControls:ControlList read FColumnControls write SetColumnControls;

    // Some basic test/validation funtions;
    function IsNumericOnly(const Value: string): Boolean;overload;
    function IsNumericOnly(const Value: Integer): Boolean;overload;
    function IsAlphaOnly(const Value: string): Boolean;overload;
    function IsAlphaOnly(const Value: Integer): Boolean;overload;
    function IsDebitCredit(const Value: string): Boolean;overload;//IsSign
    function IsDebitCredit(const Value: Integer): Boolean;overload;
    function IsAmount(const Value: string): AmountType;overload;
    function IsAmount(const Value: Integer): AmountType;overload;
    function IsDate(const Value, Mask: string):Boolean; overload;
    function IsDate(const Value: Integer):string; overload;

    // Other Helpers
    function SwapMonth(const Value: string):string;
    function IsValidColumn(const Value: Integer): Boolean;
    function ColumnColor(const Value: Integer):tColor;
    function ReadNum(Var NumText: string):Integer;
    function ReadMonth(Var NumText: string):Integer;

    function StrtoCurr(Value: string): Currency;
    function StrtoDate(Value,Mask: string): Integer;
    procedure SetDefault(Value: string; ComboBox: TComboBox; Default: integer = 0);
    procedure OutColResize(Value: Integer);
    property FileLvChanged: Boolean read FFileLvChanged write SetFileLvChanged;
    property OutLvChanged: Boolean read FOutLvChanged write SetOutLvChanged;
    property DateMask: string read FDateMask write SetDateMask;
    function CurrentDate: Integer;
    procedure SetUpHelp;
    { Private declarations }
  public
    { Public declarations }
    property ExchangeSource: PExchangeSource read FExchangeSource write SetExchangeSource;
  end;

 function ImportExchangeRates(const aExchangeSource: PExchangeSource; ISOColumns: TVirtualTreeColumns ): boolean;

implementation

{$R *.dfm}

uses
  Math,
  BKHelp,
  bkXPThemes,
  commCtrl,
  winutils,
  bkConst,
  TransactionUtils,
  bktxio,
  StrUtils,
  GenUtils,
  YesNoDlg,
  bkDefs,
  ErrorMoreFrm,
  Globals,
  stDate,
  ComBoUtils,
  UsageUtils,
  stDatest,
  WarningMoreFrm, bkBranding;

const
  tNone = ' ';
  // Tag for Column Types
  TagAlpha  = 1; // Has no Numbers, Cannot be Date or Amount..
  TagDebitCredit = 2; // Has No Numbers All Rows start with D C or M
  TagAmount = 3; // Has valid amounts  no Negatives
  TagAmountSign = 4; // Valid amounts with some Negatives (No Debit Or Credit Column)
  TagDate = 5; // Has Valid dates...

  // Index into OutItem,
  SubDate   = 0;

  // Bottom PageIndex, but used as Bottom Column Tag as well
  // The Bottom Combo boxes use this tag as
  piDate = 0;
  piRate = 1;


type
  TFileitem = class (TStringList)
  public
     ListNode: PVirtualNode;
  end;

  TOutitem = class (TFileitem)
  public
     OutDate: TstDate;
     Matched: TExchangeRecord;
  end;


function ImportExchangeRates(const aExchangeSource: PExchangeSource;
  ISOColumns: TVirtualTreeColumns): boolean;
var
   Ldlg: TImportExchange;
begin
   Ldlg := TImportExchange.Create(Application.MainForm);
   try
      ldlg.FISOColumns := ISOColumns;  //This must be done before setting the exchange source
      ldlg.ExchangeSource := aExchangeSource;

      Result := ldlg.ShowModal = mrOK;
   finally
      Ldlg.Free;
   end;
end;


procedure TImportExchange.BeginUpdate;
begin
   if FLockCount = 0 then begin
      FKeepCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
   end;
   inc(FlockCount);
end;

procedure TImportExchange.BTNBrowseClick(Sender: TObject);
begin
   OpenDLG.FileName := EPath.Text;
   if OpenDLG.Execute() then begin
       EPath.Text := OpenDLG.FileName;

       ReloadFile;
   end;
end;


procedure TImportExchange.btnOKClick(Sender: TObject);

   procedure ShowError(Text: string; TS: TTabsheet; Value: TWinControl);
   begin
      HelpfulErrorMsg(Text,0);
      PCFormat.ActivePage := TS;
      Value.SetFocus;
      PCFormatChange(nil);
   end;

   function AskSelection(Text1,Text2: string; TS: TTabsheet; Value: TWinControl): Boolean;
   begin
      if AskYesNo(Text1,Text2, DLG_NO,0) = DLG_YES then begin
         // Its OK to continue...
         Result := False;
      end else begin
         // Go Back and select one..
         PCFormat.ActivePage := TS;
         PCFormatChange(nil);
         Value.SetFocus;
         Result := True;
      end;
   end;

var R: Integer;
    C: Integer;
    W: Integer;
    FailCount,
    GoodCount, FutureCount: Integer;
    lRec: TExchangeRecord;
    RateIndex: integer;

begin
   if fOutlist.Count = 0 then begin
      HelpfulErrorMsg('No valid entries found, try a different file.',0);
      Exit;
   end;

   // Validate ..
   if CBDate.Items.Count = 0 then begin
      ShowError('No valid Date columns found, try a different file.',TSdate,CBDate);
      Exit;
   end;
   if CBDate.ItemIndex < 0 then begin
      ShowError('No Date column selected',TSdate,CBDate);
      Exit;
   end;
   //Amount

   

  FailCount := 0; //Used as temp Counts..
  GoodCount := 0;
  FutureCount := 0;
  for R := 0 to fOutlist.Count - 1 do begin
     if (not Assigned(TOutItem(fOutlist[R]).Matched))
     or (not TOutItem(fOutlist[R]).Matched.Locked) then

        Inc(GoodCount) // Will import
     else
        Inc(FailCount); // Wont Import
     if (TOutItem(fOutlist[R]).OutDate > stDate.CurrentDate) then
       Inc(FutureCount);
  end;

  if GoodCount = 0 then begin
     HelpfulErrorMsg('You cannot import these exchange rates as the dates all ' +
                     'belong to a period which is locked. If you need to update ' +
                     'the rates in the locked period please unlock the dates first.', 0);
     Exit;
  end else if FailCount > 0 then begin
     HelpfulWarningMsg('Locked exchange rates are unable to be imported. ' +
                       'Any exchange rates imported for a locked rate will be ignored.',0);
  end;

  if (FutureCount > 0) then
    if AskSelection('Future dates in import',
      'Future dates exist in the import. These will be ignored, do you want to continue?', TsDate,cbDate) then
        Exit;

   if FailCount > 0 then
      if AskSelection('Transactions will be skipped',
         Format ('%D Transaction(s) will be skipped, do you want to continue?',[FailCount]) , TsDate,cbDate) then
            Exit;

   // We Shoul be good to go...

    W := FExchangeSource.Width;

    for R := 0 to fOutlist.Count - 1 do begin
       lRec := TOutItem(fOutlist[R]).Matched;
       if Assigned(LRec) then begin
          if LRec.Locked then
            Continue;
       end else if (TOutItem(fOutlist[R]).OutDate < stDate.CurrentDate) then begin
          //Only add if exchange rate date < current date
          LRec := TExchangeRecord.Create(TOutItem(fOutlist[R]).OutDate, W);
          try
             FExchangeSource.ExchangeTree.Insert(LRec);
          except
             ShowError(Format ('Duplicate Date  %s found.',[TOutItem(fOutlist[R]).Strings[0]]) ,TSdate,CBDate);
             LRec.Free;
             Continue;
          end;
       end else
          Continue;

       for C := 0 to pred(vsout.Header.Columns.Count) do begin
          if (vsout.Header.Columns[C].Tag >= piRate) // is a rate column
          and (TOutItem(fOutlist[R])[C] > '') then begin // Has a rate...
             RateIndex := vsout.Header.Columns[C].Tag - piRate;
             //Don't overwrite unless overwrite = true or existing exchange rate = 0
             if cbOverwriteExchangeRates.Checked or
                (Assigned(TOutItem(fOutlist[R]).Matched) and (LRec.Rates[RateIndex] = 0)) or
                (not Assigned(TOutItem(fOutlist[R]).Matched)) then
                   LRec.Rates[RateIndex] := StrToFloat(TOutItem(fOutlist[R])[C]);
          end;
       end;
    end;

    ModalResult := mrOK;
end;

procedure TImportExchange.cbRateChange(Sender: TObject);
var
  CIn,
  COut,
  Row  : Integer;

begin
   if not assigned(Sender) then
      Exit;

   BeginUpdate;
   vsOut.BeginUpdate;
   try
      // One of the Rate columns changed..

      CIn := GetComboCurrentIntObject(TComboBox(sender));
      COut := TComboBox(sender).Tag;

      if CIn >= 0 then begin
         for Row := 0 to fOutList.Count - 1 do
           TOutItem(foutList[Row]).Strings[COut] := GetFiletext(Row,CIn,12);
      end else begin
         for Row := 0 to fOutList.Count - 1 do
           TOutItem(foutList[Row]).Strings[COut] := '';
      end;
      OutColResize(COut+1);

   finally
      FileLVChanged := True;
      OutLVChanged := True;
      vsOut.EndUpdate;
      EndUpdate;
   end;
end;

procedure TImportExchange.cbDateChange(Sender: TObject);
var R, C : integer;
    Format: string;

    function GetDateText: string;
    var D: tstDate;
    begin
        TOutItem(foutList[R]).Matched := nil;
       try
          D := StrtoDate(GetFileText(R,C),Format);
          TOutItem(foutList[R]).OutDate := D;
          if D = 0 then
             Result := '**/**/**' //so You can see it..
          else begin
             Result := bkDate2Str(D);
             TOutItem(foutList[R]).Matched := FExchangeSource.GetDateRates(D);
          end;
       except
          Result := '**/**/**' ;
       end;
    end;

begin
   BeginUpdate;
   try
      // Update date column
      C := GetComboCurrentIntObject(cbDate);
      if C >= 0 then begin
          Format := EDate.Text;
          for R := 0 to fOutList.Count - 1 do begin
             TOutItem(foutList[R]).Strings[SubDate] := GetDateText;
          end;
      end else
         for R := 0 to fOutList.Count - 1 do begin
             TOutItem(foutList[R]).Matched := nil;
             TOutItem(foutList[R]).OutDate := 0;
             TOutItem(foutList[R]).Strings[SubDate] := '-';
         end;
      // Resize..
      OutColResize(0);
      FileLVChanged := True;
      OutLVChanged := True;
   finally
      EndUpdate;
   end;
end;

procedure TImportExchange.cbDelimiterChange(Sender: TObject);
begin
  if EPath.Text > '' then
     ReloadFile;
end;

procedure TImportExchange.chFirstlineClick(Sender: TObject);
begin
   if BkFileexists(ePath.Text) then
      ReLoadFile;
end;


function TImportExchange.ColumnColor(const Value: Integer): tColor;
begin
   if SelectedCol[Value] then
      Result := clHighLight
   else
      Result := clWhite;
end;



function TImportExchange.CurrentDate: Integer;
begin
   if fCurrentDate = 0 then  // so wo only do this once
     fCurrentDate := stdate.CurrentDate;
   Result := fCurrentDate;
end;

procedure TImportExchange.Endupdate;
begin
   if FLockCount > 0 then begin
      Dec(FlockCount);
      if FLockCount = 0 then begin
         Screen.Cursor := FKeepCursor;
         if fFileLvChanged then begin
            fFileLvChanged := False;
            vsFile.Invalidate;
         end;
         if fOutLvChanged then begin
            fOutLvChanged := False;
            vsOut.Invalidate;
         end;
      end;
   end;
end;

procedure TImportExchange.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
const
  CANCEL_PROMPT = 'Are you sure you want to exit the Import Exchange Rates window?';
begin
  if not (ModalResult = mrOK) and (fFilelist.Count > 0) then
    CanClose := (AskYesNo('Cancel Import Exchange Rates', CANCEL_PROMPT, Dlg_No, 0) = DLG_YES);
end;

procedure TImportExchange.FormCreate(Sender: TObject);

begin
   bkXPThemes.ThemeForm( Self);
   vsOut.Header.Font := Self.Font;
   vsFile.Header.Font := Self.Font;
   Tmaskedit(SkipLine).MaxLength := 2;
   fFileList := TobjectList.Create(True);
   fOutList := TobjectList.Create(True);
   FReloading := False;

   bkbranding.StyleSelectionColor(vsOut);
   bkbranding.StyleSelectionColor(vsFile);

   pcFormat.ActivePageIndex := 0;//Not the design time one..
   lbFile.Height := 0;
   vsFile.SyncView := vsOut;
   vsOut.SyncView := vsFile;
   PCFormatChange(nil);
end;


procedure TImportExchange.FormDestroy(Sender: TObject);
begin
   fFileList.Free;
   fOutList.Free;
end;

procedure TImportExchange.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    Char(VK_ESCAPE):
      begin
        Key := #0;
        ModalResult := mrCancel;
      end;
  end;
end;

procedure TImportExchange.FormResize(Sender: TObject);
var H: integer;
begin
   H := ClientHeight - (pFileinput.Height + PFormat.Height + pBtn.Height);
   pFile.Height := H div 2;
   
   // pFile is align client, so it will take up the rest
end;



function TImportExchange.GetFileText(const Row,Col: Integer; MaxLen: Integer = 0): string;
begin
   Result := '';
   if Row >= fFilelist.Count then
      Exit;
   with TFileItem(fFilelist[Row]) do begin
     if Col >= Count then
         Exit;
      Result := trim(Strings[Col]);
      if MaxLen > 0 then
         if Length(Result) > MaxLen then
           SetLength(Result,MaxLen)
   end;
end;

function TImportExchange.GetSelectedcol(index: Integer): Boolean;
var C, Idx, ObjIdx: Integer;
begin
   Result := True;
   for C := Low(FColumnControls) to High(FColumnControls) do
     if FColumnControls[C] is TComboBox then begin
         Idx := TComboBox(FColumnControls[C]).ItemIndex;
         if Idx >=0 then begin
            ObjIdx := Integer(TComboBox(FColumnControls[C]).Items.Objects[Idx]);
            if ObjIdx = index then
               Exit;
         end;
     end;
   // Still here...
   Result := False;
end;


function TImportExchange.IsAlphaOnly(const Value: string): boolean;
var I: integer;
begin
   Result := False;
   for I := 1 to Length(Value) do
      if Value[I] in ['0'..'9'] then
         Exit;
   Result := True;
end;

function TImportExchange.IsNumericOnly(const Value: string): Boolean;
var I: integer;
begin
   Result := False;
   for I := 1 to Length(Value) do
      if Upcase(Value[I]) in ['A', 'B', {C,D} 'E' .. 'Q', {R} 'S'..'Z'] then  {DR, CR}
         Exit;
   Result := True;
end;

function TImportExchange.IsAlphaOnly(const Value: Integer): boolean;
var I: Integer;
begin
   Result := False;
   for I := 0 to fFileList.Count-1 do
      if not IsAlphaOnly(GetFileText(I,Value)) then
         Exit;
   Result := true;
end;


function TImportExchange.IsAmount(const Value: Integer): AmountType;
var I: Integer;
begin
   Result := Amount;
   for I := 0 to fFileList.Count-1 do
      case IsAmount(GetFileText(I,Value)) of
      NotAmount : begin
         Result :=  NotAmount;
         Exit;
      end;
      AmountWithSign : Result := AmountWithSign;
      Amount:;
      end;
end;

function TImportExchange.IsAmount(const Value: string): AmountType;
begin
   try
      if StrToCurr(Value) < 0 then
         Result := AmountWithSign
      else
         Result := Amount
   except
       Result := NotAmount;
   end;
end;

function TImportExchange.IsDebitCredit(const Value: string): Boolean;
var l: integer;
    V: PChar;
begin
   l := Length(Value);
   if l > 0 then begin

      Result := True;
      V := pchar(Value);

      if StrliComp(V,'debit',l) = 0 then
         Exit;
      if StrliComp(V,'credit',l) = 0 then
         Exit;
      if StrliComp(V,'m',l) = 0 then
         Exit;
   end;

   Result := False;
end;



function TImportExchange.IsDate(const Value, Mask: string): Boolean;
var D: Integer;
begin
   D := StrtoDate(Value,Mask);
   Result := (D < CurrentDate)
          and (D > Date1980);

end;

function TImportExchange.IsDate(const Value: Integer): string;
var I: Integer;
    ResMask,
    S: string;
    monthNotSwapped: Boolean;

   procedure BuildMask;
   var D: Integer;
       S: string;

       Mdone,Ddone,Ydone: Boolean;

       function FailNumber: Boolean;
       begin
          Result := true;

          if D = 0 then begin
             if ReadMonth(S) in [1..12] then begin
                if Mdone then begin
                   DDone := True;
                   ResMask := SwapMonth(ResMask);
                end;
                MDone := True;
                ResMask := ResMask + 'MMM'
             end else
                Exit;
          end else
          if D > 2100 then
             Exit // ??
          else if D > 1000 then begin
             if YDone then
                Exit;
             ResMask := ResMask + 'YYYY';
             YDone := true;
          end else if D > 31 then begin
             if MDone
             and DDone then begin
                ResMask := ResMask + 'YY';
                YDone := True;
             end;
          end else if D > 12 then begin
             if DDone then begin
                if Mdone  then begin
                   ResMask := ResMask + 'YY';
                   YDone := True;
                end else begin
                   ResMask := SwapMonth(ResMask);
                   ResMask := ResMask + 'DD';
                   MDone := True;
                end;
             end else begin
                ResMask := ResMask + 'DD';
                DDone := True;
             end;
          end else begin
             if MDone then begin
                if DDone  then begin
                   ResMask := ResMask + 'YY';
                   YDone := True;
                end else begin
                   ResMask := SwapMonth(ResMask);
                   ResMask := ResMask + 'MM';
                   DDone := True;
                end;
             end else begin
                if DDone then begin
                   ResMask := ResMask + 'MM';
                   MDone := true;
                end else begin
                   ResMask := ResMask + 'DD';
                   DDone := True;
                end;
             end;
          end;
          Result := False;
       end;
   begin
      Mdone := False;
      Ddone := False;
      Ydone := False;
      S := GetFileText(0,Value);
      ResMask := '';
      // read the first number..
      D := ReadNum(S);
      if FailNumber then begin
         ResMask := 'Fail';
         Exit;
      end;

      ResMask := ResMask + Copy(S,1,1);
      // read the second number
      S := Copy(S,2,255);
      D := ReadNum(S);
      if FailNumber then begin
         ResMask := 'Fail';
         Exit;
      end;

      ResMask := ResMask + Copy(S,1,1);
      S := Copy(S,2,255);

      D := ReadNum(S);
      if FailNumber then begin
         ResMask := 'Fail';
         Exit;
      end;

      if not( Mdone and Ddone and Ydone) then
         ResMask := 'Fail';
      
      if Pos('@',ResMask) > 0 then
         ResMask := 'Fail';

      if Pos(':',ResMask) > 0 then
         ResMask := 'Fail';
   end;


begin
  result := '';
  if fFileList.Count < 0 then
     Exit;


  BuildMask;
  monthNotSwapped := True;
  for I := 0 to fFileList.Count -1 do begin
      S :=  GetFileText(I,Value);
      if Length(S) > 0 then begin
         if Length(ResMask) = 0  then
            BuildMask;

         if IsDate(S,ResMask) then
         else begin
            // Have to Check a couple things
            if monthNotSwapped then begin
               if IsDate(S,SwapMonth( ResMask)) then begin
                  ResMask := SwapMonth( ResMask);
                  MonthNotSwapped := false;
               end;
            end else
               Exit;
         end;
      end;
  end;
  Result := ResMask;
end;

function TImportExchange.IsDebitCredit(const Value: Integer): Boolean;
var I: Integer;
begin
   Result := False;
   for I := 0 to fFileList.Count -1 do
      if not IsDebitCredit(GetFileText(I,Value)) then
           Exit;

   Result := true;
end;

function TImportExchange.IsNumericOnly(const Value: Integer): Boolean;
var I: Integer;
begin
   Result := False;
    for I := 0 to fFileList.Count -1 do
      if not IsNumericOnly(GetFileText(I,Value)) then
         Exit;
   Result := true;
end;

function TImportExchange.IsValidColumn(const Value: Integer): Boolean;
begin

   Result := True;

   case PcFormat.ActivePageIndex of
   piDate: if vsFile.header.Columns[Value].Tag <> TagDate then
         Result := false;
   piRate: ;

   end;
end;





procedure TImportExchange.OutColResize(Value: Integer);
begin
  vsOut.Header.AutoFitColumns(False);
end;

procedure TImportExchange.PCFormatChange(Sender: TObject);
var ll: ControlList;
begin
  BeginUpdate;
  try

     SetLength(ll,1);
     case PCFormat.ActivePageIndex of
       piDate : ll[0] := cbDate;
       piRate ..
       piRate + 99 : ll[0] := CurColumns[PCFormat.ActivePageIndex - piRate];
     else
       SetLength(ll,0);
     end;
     ColumnControls := ll;
     OutLvChanged := True;
     FileLvChanged := True;
  finally
     EndUpdate;
  end;
end;

function TImportExchange.ReadMonth(var NumText: string): Integer;
var I: Integer;
    Month: string;
begin
   Result := 0;
   try
      for I := 1 to Length(NumText) do
         if NumText[I] in ['a' .. 'z', 'A' .. 'Z'] then
            // Find all the Text
            Month := Month + NumText[I]
         else begin
            // Remove any Text we found
            NumText := Copy(NumText,I,255);
            Break;
         end;

      if Length(Month) >= 3 then
         // Find the Month text
         for I := 1 to 12 do
            if SameText(Copy(Month,1,3), ShortMonthNames[I]) then begin
               Result := I;
               Break;
            end;

   except
      Result := 0; //
   end;
end;

function TImportExchange.ReadNum(var NumText: string): Integer;
var I: Integer;
begin
   Result := 0;
   try
      // May need to update to handle leading <space>
      for I := 1 to Length(NumText) do
         if NumText[I] in ['0' .. '9'] then
            // Find the starting Number
            Result := (Result * 10) + (Byte(NumText[I]) - Byte('0'))
         else begin
            // remove the starting number
            NumText := Copy(NumText,I,255);
            Break;
         end;
   except
      Result := 0; // overflow...
   end;
end;

procedure TImportExchange.ReloadFile;
var lFile: TStringList;
    lLine: TStringList;
    InItem: TFileItem;
    OutItem: TOutitem;
    Row,Col: Integer;
    TestBool: Boolean;
    AmountColumnCount: Integer;

    procedure TryDate(Column: Integer);
    var DateMask: string;
    begin
       DateMask := ISdate(Column);
       if Pos('M',DateMask) > 0  then begin
          vsFile.header.Columns[Column].Tag := TagDate;
          cbDate.Items.AddObject( vsFile.header.Columns[Column].Text, TObject(Column));
          EDate.Text := DateMask;
       end;
    end;

    function NextLine(Keep: Boolean = False): Boolean;
    begin
       Result := False;
       while Row < Pred(LFile.Count) do begin
          Inc(Row);
          lLine.DelimitedText := LFile[Row];
          if Keep then begin
             // Show the skipped lines
             if lbFile.Caption > '' then
                lbFile.Caption := LbFile.Caption + #13 + LFile[Row]
             else
                lbFile.Caption := LFile[Row];
          end;

          if lLine.Count > 1 then begin
             Result := True;
             Break;
          end;
       end;
    end;

    function AddColumn(Name: string; aTag: Integer):TVirtualTreeColumn;
    begin
       Result := vsfile.Header.Columns.Add;
       with Result do begin
          Text := Name;
          Width := 100;
          Minwidth := 50;
          Tag := aTag;
       end;
    end;

    procedure ClearCurCols;
    var C: Integer;
    begin
       for C := low(CurColumns) to high(CurColumns) do
          if Assigned(CurColumns[C]) then // Savety net
             CurColumns[C].Clear;
    end;

    procedure AddCurCols(Text: string; Index: Integer);
    var C: Integer;
    begin
       for C := low(CurColumns) to high(CurColumns) do
          if Assigned(CurColumns[C]) then
             CurColumns[C].Items.AddObject(Text, TObject(Index));
    end;

    procedure SetCurColDefaults;
    var C: Integer;
    begin
       for C := low(CurColumns) to high(CurColumns) do
          if Assigned(CurColumns[C]) then
              SetDefault(LowerCase(TTabsheet(CurColumns[C].Parent).Caption) ,CurColumns[C]);
    end;

begin
   if FReloading then
      Exit;

   Freloading := True;
   BeginUpdate;
   vsFile.BeginUpdate;
   vsOut.BeginUpdate;
   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
       // reset the dialog
       GetLocaleFormatSettings(0,FFormatsettings);
       vsFile.Clear;
       vsFile.Header.Columns.Clear;
       lbFile.Caption := '';
       lbFile.Height := 0;

       vsOut.Clear;

       cbDate.Clear;

       ClearCurCols;

       fFileList.Clear;
       fOutlist.Clear;


       // Read the File into the grid.
       case cbDelimiter.ItemIndex of
       1 :   lline.Delimiter := ';';
       2 :   lline.Delimiter := #9;
       else  lline.Delimiter := ',';
       end;
       lLine.StrictDelimiter := True;

       try
          lFile.LoadFromFile(EPath.Text);
       except
          on e: exception do begin
             HelpfulErrorMsg('File open failed.',0, True, Format( 'Cannot open file %s: %s',[EPath.Text, e.Message]),True);
          end;
       end;
       if LFile.Count = 0 then
           Exit; // Nothing in the file

       // Skip Lines
       Row := -1;
       for Col := 1 to SkipLine.IntValue do begin
          if not NextLine(true) then
             Exit;
       end;

       if not NextLine then
          Exit; // Nothing Left

       //Test for header line
       TestBool := True;
       for Col := 0 to lLine.Count - 1 do begin
          {if not (LLine[C] > ' ') then begin
             TestBool := False;
             Break;
          end else }
          if not IsAlphaOnly(LLine[Col]) then
          if IsNumericOnly(LLine[Col]) then begin
             TestBool := False;
             Break;
          end;
       end;
       if TestBool then begin
          // All Text, Must be header (No valid amount Or Date)
          CHFirstLine.Checked := True;
          CHFirstLine.Enabled := False;
       end else
          CHFirstLine.Enabled := True;

       // Fill in the First line


       for Col := 0 to lLine.Count - 1 do with AddColumn('',0) do begin
          if CHFirstLine.Checked
          and (lLine[Col] > ' ') then
             Text := lLine[Col]  // Use as header
          else
             Text := Format('Column %d',[Col + 1]);

       end;
       
       if CHFirstLine.Checked then
          if not NextLine then  //Get The first 'Real' Line
            Exit;

        AddCurCols(tNone,-1);     
       // read the rest of the file...
       repeat
          InItem := TFileitem.Create;
          InItem.Assign(LLine);
          fFilelist.Add(InItem);
          InItem.ListNode := vsFile.AddChild(nil,nil);

          OutItem := TOutItem.Create;
          OutItem.OutDate := 0;
          OutItem.Matched := nil;
          for Col := 0 to vsOut.Header.Columns.Count - 1 do
             OutItem.Add('');
          fOutlist.Add(OutItem);
          outItem.ListNode := vsOut.AddChild(nil,nil);
       until not NextLine;

       vsFile.Header.AutoFitColumns(False);

       AmountColumnCount := 0;
       for Col := 0 to vsFile.Header.Columns.Count - 1 do begin
          if IsAlphaOnly(Col) then begin
             // has no digits.. cannot be a Date or amount
             // Could still be Debit or Credit Column
             if IsDebitCredit(Col) then begin
                vsFile.Header.Columns[Col].Tag := TagDebitCredit;
             end else
                vsFile.Header.Columns[Col].Tag := TagAlpha;
          end else if IsNumericOnly(Col) then begin
             // Has No Letters
             case IsAmount(Col) of
             NotAmount : TryDate(Col);
             Amount : begin
                   vsFile.Header.Columns[Col].Tag := TagAmount;
                   inc(AmountColumnCount);

                end;
             AmountWithSign :begin
                vsFile.Header.Columns[Col].Tag := TagAmountSign;
             end;
             end;
          end else begin
             // Can have Numbers and Letters
             // Could Be a Date...
             TryDate(Col);
          end;
          if vsFile.header.Columns[Col].Tag in [TagAmount,TagAmountSign] then begin
             AddCurCols( vsFile.header.Columns[Col].Text,Col);
          end;

       end;

       // Do some obvious defaults.
       SetDefault('date',cbDate);
       SetCurColDefaults;
      

   finally
      vsFile.EndUpdate;
      vsOut.EndUpdate;
      lFile.Free;
      lLine.Free;
      EndUpdate;
      Freloading := False;
   end;
end;


procedure TImportExchange.ReloadTimerTimer(Sender: TObject);
begin
   ReloadTimer.Enabled := False;
   SkipLine.ValidateEdit;
   if ePath.Text > '' then
      ReloadFile;
end;

procedure TImportExchange.SkipLineChange(Sender: TObject);
begin
   ReloadTimer.Enabled := False;
   ReloadTimer.Enabled := True;
end;

procedure TImportExchange.SetSelectedCol(Index: Integer; const Value: Boolean);
var
   ColType: integer;

   procedure SelectObject(Value: integer; InCombo:TComboBox);
   var I: Integer;
   begin
     I := InCombo.Items.IndexOfObject(TObject(Value));
     if I >=0 then begin
        InCombo.ItemIndex := I;
        InCombo.OnChange(InCombo);
     end;
   end;

begin
   ColType := 0;

   if pcFormat.ActivePageIndex  > 0 then
     ColType := piRate;

   case ColType of
   piDate : SelectObject(Index, cbDate);
   piRate : begin
              //Select rate in current tabs currency combobox
              if pcFormat.ActivePage.Controls[1] is TComboBox then
                SelectObject(Index, TComboBox(pcFormat.ActivePage.Controls[1]) );
            end;
   end;
end;

procedure TImportExchange.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Importing_historical_data;
end;

function TImportExchange.StrToCurr(Value: string): Currency;
var I: Integer;
    S: string;
    IsNeg : Boolean;
begin
   Result := 0;
   if Value > '' then begin
      IsNeg := False;
      S := '';

      for I := 1 to Length(Value) do
         case Value[I] of
         '0'..'9',
         '.', '-' : S := S +  Value[I]; // Keep these

         '(' : IsNeg := True; // Braketed

         'd','D' : Isneg := True; //DR
         #0 .. ' ':;    //Trim
         #128 .. #255:; //Trim (Notably #160, fixed space) also includes  '£'
         'c','C','r','R', // DR, CR
         '$', ',', '+', ')':; // These are fine too...

         else raise Exception.Create(format( 'Illegal Char [%s]:%d',[Value[I],Integer(Value[I])]) );

         end;
      if S > '' then
         Result := sysutils.StrToCurr(s);
      if IsNeg then
         Result := -Result;
   end;

end;

function TImportExchange.StrtoDate(Value,Mask: string): Integer;
var p, I: Integer;

  M,D,Y : Integer;
  function NextMask: Char;
  begin
     Result := #0;
     while (P < Length(Mask)) do begin
        inc(p);
        if Result > '' then begin
           if Result <> Mask[p] then
              Exit;
        end else if Mask[p] in ['M','D','Y'] then
           Result := Mask[p];

     end;
  end;
begin
  P := 0;
  M := 0;
  D := 0;
  Y := 0;
  for I := 1 to 3 do

  case NextMask of
  'D' : begin
          D := ReadNum(Value);
          Value := Copy(Value,2,200);
        end;
  'M' : begin
          M := ReadNum(Value);
          if M = 0 then
             M := ReadMonth(Value);
           Value := Copy(Value,2,200);
        end;
  'Y' : begin
          Y := ReadNum(Value);
          Value := Copy(Value,2,200);
        end;
  end;

  Result := DMYtoStDate(D, M, Y, BKDATEEPOCH);
  if Result = BadDate then
     Result := 0;
end;

function TImportExchange.SwapMonth(const Value: string): string;
var I: Integer;
begin
   SetLength(Result,Length(value));
   for I := 1 to Length(value) do
      case Value[I] of
      'M' : Result[I] := 'D';
      'D' : Result[I] := 'M';
      else Result[I] := Value[I];
      end;

end;


procedure TImportExchange.vsFileBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
begin
   TargetCanvas.Brush.Color := ColumnColor(Column);
   TargetCanvas.FillRect(CellRect);
end;

procedure TImportExchange.vsFileChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
   if Assigned(Node) then
      vsOut.Selected[TOutItem(fOutList[Node.Index]).ListNode] := true;
end;

procedure TImportExchange.vsFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(fFilelist.Count) then
      Exit;
   with TstringList( fFilelist[Node.Index]) do begin
      if Column >= Count then
         Exit;
      CellText := Strings[Column];
   end;
end;

procedure TImportExchange.vsFileHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if IsValidColumn(Column) then begin
      SelectedCol [Column] := true;
      vsFile.Invalidate;
   end;
end;

procedure TImportExchange.vsFilePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
   if Assigned(Node) then begin
      if (vsSelected in Node.States) then
         if (Sender.Focused) then
            TargetCanvas.Font.Color := clHighlightText
         else
            TargetCanvas.Font.Color := clwindowText
      else
         if SelectedCol[Column] then
            TargetCanvas.Font.Color := clHighlightText
         else
            if isValidColumn(Column) then
               TargetCanvas.Font.Color := clwindowText
            else
               TargetCanvas.Font.Color := clGrayText;
   end;

end;

procedure TImportExchange.vsOutChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
   if Assigned(Node) then
      vsFile.Selected[TFileItem(fFileList[Node.Index]).ListNode] := true;
end;

procedure TImportExchange.vsOutGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(fOutlist.Count) then
      Exit;
   with TOutItem(fOutlist[Node.Index]) do begin
      if Column >= Count then
         Exit;
      CellText := Strings[Column];
   end;
end;

procedure TImportExchange.vsOutHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PCFormat.ActivePageIndex :=  vsOut.header.Columns[Column].Position;
  PCFormat.OnChange(nil);
end;

procedure TImportExchange.vsOutBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
  procedure SetHighLight(Value: Boolean);
  begin
     if value then begin
        TargetCanvas.Brush.Color := clHighLight;
        TargetCanvas.FillRect(CellRect);
     end;
  end;
begin
   case PCFormat.ActivePageIndex of
     piDate:      SetHighLight(Column = Subdate);

     piRate..
     piRate + 99:    SetHighLight(Column = PCFormat.ActivePageIndex);


     else SetHighLight(False);
  end;
end;


procedure TImportExchange.vsOutPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);

  procedure SetHighLight(Value: Boolean);
  begin
     if (vsSelected in Node.States) then
        if Sender.Focused then
           TargetCanvas.Font.Color := clHighlightText
        else
           TargetCanvas.Font.Color := clWindowText
     else
        if Value then
           TargetCanvas.Font.Color := clHighlightText
        else
           TargetCanvas.Font.Color := clWindowText;
  end;
 
begin
  if not Assigned(Node) then
     Exit;

  if (Column = SubDate) then begin

     if (not Assigned(TOutItem(FOutList[Node.Index]).Matched))
     or (not TOutItem(FOutList[Node.Index]).Matched.Locked) then
        SetHighLight(PCFormat.ActivePageIndex = piDate)
     else
        TargetCanvas.Font.Color := clRed

  end else

  case PCFormat.ActivePageIndex of
     piDate: ; // Already handeled
     piRate..
     piRate + 99:    SetHighLight(Column = PCFormat.ActivePageIndex );

     else SetHighLight(False);
  end;
end;



procedure TImportExchange.SetColumnControls(const value: ControlList);
begin
   FColumnControls := value;
end;



procedure TImportExchange.SetDateMask(const Value: string);
begin
  FDateMask := Value;
  EDate.Text := Value;
end;

procedure TImportExchange.SetDefault(Value: string; ComboBox: TComboBox; default: integer = 0);
var I: Integer;
begin
   if ComboBox.Items.Count > 0 then begin

      for I := 0 to ComboBox.Items.Count - 1 do begin
         if pos(Value, Lowercase(ComboBox.Items[I])) > 0 then begin
            ComboBox.ItemIndex := I;
            break;
         end;
      end;
      if ComboBox.ItemIndex < 0  then begin
         if Default >= 0 then
            ComboBox.Itemindex := default
         else    
      end;

   end;
   if Assigned(ComboBox.OnChange) then
      ComboBox.OnChange(ComboBox)
end;

procedure TImportExchange.SetExchangeSource(const Value: PExchangeSource);
var
    C: Integer;
    R: Integer;

    procedure AddTab(Name: string);
    var
       LTabSheet: TTabsheet;
    begin
       LTabSheet := TTabsheet.Create(PCFormat);
       lTabSheet.Caption := Name;
       LTabSheet.PageControl := PCFormat;

       with Tlabel.Create(LTabSheet) do begin
          Parent := LTabsheet;
          Caption := 'Rate column';
          Left := 10;
          Top := 20;
       end;

       CurColumns[R] := TComboBox.Create(LTabSheet);
       with CurColumns[R] do begin
          Parent := LTabsheet;
          Style := csDropDownList;
          Tag := R + 1;
          OnChange := cbRateChange;
          //Name := Format('RateCombo%d',[R]);
          Left := 90;
          Top := 18;
       end;
       Inc(R);
    end;

    function AddColumn(Name: string; aTag: Integer):TVirtualTreeColumn;
    begin
       Result := vsOut.Header.Columns.Add;
       with Result do begin
          Text := Name;
          Width := 100;
          Minwidth := 100;
          Tag := aTag;
       end;
    end;

begin
  FExchangeSource := Value;

   vsout.BeginUpdate;
   try
      vsout.Header.Columns.Clear;
      AddColumn('Date',piDate);


      R := 0;
      SetLength(CurColumns,FExchangeSource.Width); // Skip the base one??
      for C := low(FExchangeSource.Header.ehISO_Codes) to
        (Low(FExchangeSource.Header.ehISO_Codes) + FExchangeSource.Width) - 1 do
           if FExchangeSource.Header.ehCur_Type[C] <> ct_Base then begin
              AddColumn(FExchangeSource.Header.ehISO_Codes[C],PiRate + C).Alignment := taRightJustify;
              AddTab(FExchangeSource.Header.ehISO_Codes[C]);
           end;

      //Set tab and column indexs to match columns in exchange rates table
{      for i := 0 to Pred(FISOColumns.Count) do begin
        for j := 0 to Pred(PCFormat.PageCount) do
          if (PCFormat.Pages[j].Caption = FISOColumns[i].Text) then begin
            PCFormat.Pages[j].PageIndex := (FISOColumns[i].Position - 1);
            PCFormat.Pages[j].Tag := (i + piRate);
            Break;
          end;
        for j := 0 to Pred(vsOut.Header.Columns.Count) do
          if (vsOut.Header.Columns[j].Text = FISOColumns[i].Text) then begin
            vsOut.Header.Columns[j].Position := (FISOColumns[i].Position - 1);
            Break;
          end;
      end; }

  finally
      vsout.EndUpdate;
  end;

end;

procedure TImportExchange.SetFileLvChanged(const Value: Boolean);
begin
  if value <> FFileLvChanged then begin
     if Value then
        if fLockCount = 0 then begin
           vsFile.Invalidate;
           Exit;
        end;
     FFileLvChanged := Value;
  end;
end;




procedure TImportExchange.SetOutLvChanged(const Value: Boolean);
begin
  if value <> FOutLvChanged then begin
     if Value then
        if fLockCount = 0 then begin
           vsOut.Invalidate;
           Exit;
        end;
     FOutLvChanged := Value;
  end;
end;



end.
