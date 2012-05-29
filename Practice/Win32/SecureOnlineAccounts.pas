unit SecureOnlineAccounts;

interface

uses
  SysUtils, CsvParser;

type
  TSecureOnlineAccounts = class(TDelimitedFile)
  private
    FCurrentRow: Integer;

    FAccountNo: TDelimitedField;
    FAccountName: TDelimitedField;
    FCoreAccountID: TDelimitedField;
    FFileCode: TDelimitedField;
    FCostCode: TDelimitedField;
    FCurrentBalance: TDelimitedField;
    FLastTransactionDate: TDelimitedField;
    FSecureCode: TDelimitedField;

    function GetAccountName: String;
    function GetAccountNo: String;
    function GetCodeAccountID: String;
    function GetCostCode: String;
    function GetCurrentBalance: String;
    function GetFileCode: String;
    function GetLastTransactionDate: String;
    function GetSecureCode: String;
    function GetEof: Boolean;
  public
    procedure LoadFromFile(const FileName: String); reintroduce;

    procedure First;
    procedure Next;
    
    property AccountNo: String read GetAccountNo;
    property AccountName: String read GetAccountName;
    property CoreAccountID: String read GetCodeAccountID;
    property FileCode: String read GetFileCode;
    property CostCode: String read GetCostCode;
    property CurrentBalance: String read GetCurrentBalance;
    property LastTransactionDate: String read GetLastTransactionDate;
    property SecureCode: String read GetSecureCode;
    
    property Eof: Boolean read GetEof;

    property CurrentRow: Integer read FCurrentRow;
  end;

implementation

{ TSecureOnlineAccounts }

procedure TSecureOnlineAccounts.First;
begin
  FCurrentRow := 0;
end;

function TSecureOnlineAccounts.GetAccountName: String;
begin
  Result := FAccountName.Values[FCurrentRow];
end;

function TSecureOnlineAccounts.GetAccountNo: String;
begin
  Result := FAccountNo.Values[FCurrentRow];
end;

function TSecureOnlineAccounts.GetCodeAccountID: String;
begin
  Result := FCoreAccountID.Values[FCurrentRow];
end;

function TSecureOnlineAccounts.GetCostCode: String;
begin
  Result := FCostCode.Values[FCurrentRow]; 
end;

function TSecureOnlineAccounts.GetCurrentBalance: String;
begin
  Result := FCurrentBalance.Values[FCurrentRow];
end;

function TSecureOnlineAccounts.GetEof: Boolean;
begin
  Result := FCurrentRow > RowCount -1;
end;

function TSecureOnlineAccounts.GetFileCode: String;
begin
  Result := FFileCode.Values[FCurrentRow];
end;

function TSecureOnlineAccounts.GetLastTransactionDate: String;
begin
  Result := FLastTransactionDate.Values[FCurrentRow];
end;

function TSecureOnlineAccounts.GetSecureCode: String;
begin
  Result := FSecureCode.Values[FCurrentRow];
end;

procedure TSecureOnlineAccounts.LoadFromFile(const FileName: String);

  function GetField(const FieldName: String): TDelimitedField;
  begin
    if FieldExists(FieldName) then
    begin
      Result := FieldByName(FieldName);
    end
    else
    begin
      raise Exception.Create('Field ' + FieldName + ' not found');
    end;
  end;
  
begin
  FCurrentRow := 0;

  inherited LoadFromFile(FileName, True);

  if FieldCount > 0 then
  begin
    FAccountNo := GetField('Account No');
    FAccountName := GetField('Account Name');
    FCoreAccountID := GetField('Account ID');
    FFileCode := GetField('File Code');
    FCostCode := GetField('Cost Code');
    FCurrentBalance := GetField('Current Balance');
    FLastTransactionDate := GetField('Last Transaction Date');
    FSecureCode := GetField('Client');
  end;
end;

procedure TSecureOnlineAccounts.Next;
begin
  if not Eof then
  begin
    Inc(FCurrentRow);
  end;
end;

end.
