unit utTPRExtact;

{$TYPEINFO ON} //Needed for classes with published methods

//------------------------------------------------------------------------------
interface

uses
  TestFramework,
  ATOFixedWidthFileExtract;

type
  //----------------------------------------------------------------------------
  TATOExtractTest = class(TTestCase)
  private
    fATOFixedWidthFileExtract : TATOFixedWidthFileExtract;

    function GetSpaces(aAmount : integer) : string;
    function GetZeros(aAmount: integer): string;
  public
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestExport;
  end;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils,
  Classes,
  Windows,
  Globals,
  bkConst,
  StrUtils;

const
  TEST_CSV = 'c:\temp\Test_ATO_Extract.C01';

{ TATOExtractTest }
//------------------------------------------------------------------------------
function TATOExtractTest.GetSpaces(aAmount: integer): string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to aAmount do
    Result := Result + ' ';
end;

//------------------------------------------------------------------------------
function TATOExtractTest.GetZeros(aAmount: integer): string;
var
  Index : integer;
begin
  Result := '';
  for Index := 1 to aAmount do
    Result := Result + '0';
end;

procedure TATOExtractTest.SetUp;
begin
  inherited;

  fATOFixedWidthFileExtract := TATOFixedWidthFileExtract.Create;
end;

//------------------------------------------------------------------------------
procedure TATOExtractTest.TearDown;
begin
  FreeAndNil(fATOFixedWidthFileExtract);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TATOExtractTest.TestExport;
var
  TestDate : TDateTime;
  FileStream : TFileStream;
  StringStream : TStringStream;
  LineNo : integer;
begin
  fATOFixedWidthFileExtract.OpenATOFile(TEST_CSV);
  TestDate := EncodeDate(2014,12,31);
  try
    fATOFixedWidthFileExtract.WriteSupplierDataRecord1('84111122223','T',TestDate);
    fATOFixedWidthFileExtract.WriteSupplierDataRecord2('Supplier Name','Contact Name','000 111 2222','999 888 7777','Supplier Ref');
    fATOFixedWidthFileExtract.WriteSupplierDataRecord3('Address 1','Address 2','Suburb','Sta','1234','New Zealand','Post Address 1','Post Address 2','Post Suburb','Sta','1234','New Zealand','Test@Email.com');
    fATOFixedWidthFileExtract.WritePayerIdentityDataRecord('84111122223','222',2014,'Payer Name','Trade Name','Address 1','Address 2','Suburb','Sta','1234','New Zealand','Contact Name','000 111 2222','999 888 7777','Test@Email.com');
    fATOFixedWidthFileExtract.WriteSoftwareDataRecord('Software Product');
    fATOFixedWidthFileExtract.WritePayeeDataRecord('84111122223','Surname','First Name','Second Name','Business Name','Trade Name','Address 1','Address 2','Suburb','Sta','','New Zealand','000 111 2222','123456','123456789',300,100,150,'O');
    fATOFixedWidthFileExtract.WriteFileTotalDataRecord();
  finally
    fATOFixedWidthFileExtract.CloseATOFile;
  end;

  FileStream := TFileStream.Create(TEST_CSV, fmOpenRead);
  try
    StringStream := TStringStream.Create('');
    try
      StringStream.CopyFrom(FileStream, FileStream.Size);

      // Total File Length should be 704 * 7 lines = 4928
      Check(FileStream.Size = 4928, 'Total Size of file is not correct');

      //Supplier Data Record 1
      LineNo := 0;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'Supplier Data Record 1 - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),14)='IDENTREGISTER1', 'Supplier Data Record 1 - identifier incorrect');
      Check(MidStr(StringStream.DataString,18+(LineNo*704),11)='84111122223',   'Supplier Data Record 1 - ABN incorrect');
      Check(MidStr(StringStream.DataString,29+(LineNo*704),1)='T',              'Supplier Data Record 1 - Run Type incorrect');
      Check(MidStr(StringStream.DataString,30+(LineNo*704),8)='31122014',       'Supplier Data Record 1 - End Date incorrect');
      Check(MidStr(StringStream.DataString,38+(LineNo*704),1)='P',              'Supplier Data Record 1 - Data Type incorrect');
      Check(MidStr(StringStream.DataString,39+(LineNo*704),1)='C',              'Supplier Data Record 1 - Type of Report incorrect');
      Check(MidStr(StringStream.DataString,40+(LineNo*704),1)='M',              'Supplier Data Record 1 - Media incorrect');
      Check(MidStr(StringStream.DataString,41+(LineNo*704),10)='FPAIVV01.0',    'Supplier Data Record 1 - Specification incorrect');
      Check(MidStr(StringStream.DataString,51+(LineNo*704),654)=GetSpaces(654), 'Supplier Data Record 1 - Filler incorrect');

      //Supplier Data Record 2
      LineNo := 1;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'Supplier Data Record 2 - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),14)='IDENTREGISTER2', 'Supplier Data Record 2 - identifier incorrect');
      Check(MidStr(StringStream.DataString,18+(LineNo*704),200)=('Supplier Name'+GetSpaces(187)), 'Supplier Data Record 2 - Supplier Name incorrect');
      Check(MidStr(StringStream.DataString,218+(LineNo*704),38)=('Contact Name'+GetSpaces(26)),   'Supplier Data Record 2 - Contact Name incorrect');
      Check(MidStr(StringStream.DataString,256+(LineNo*704),15)=('000 111 2222'+GetSpaces(3)),    'Supplier Data Record 2 - Contact Phone incorrect');
      Check(MidStr(StringStream.DataString,271+(LineNo*704),15)=('999 888 7777'+GetSpaces(3)),    'Supplier Data Record 2 - Contact Fax incorrect');
      Check(MidStr(StringStream.DataString,286+(LineNo*704),15)=('Supplier Ref'+GetSpaces(3)),    'Supplier Data Record 2 - Supplier Ref incorrect');
      Check(MidStr(StringStream.DataString,302+(LineNo*704),403)=GetSpaces(403),'Supplier Data Record 2 - Filler incorrect');

      //Supplier Data Record 3
      LineNo := 2;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'Supplier Data Record 3 - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),14)='IDENTREGISTER3', 'Supplier Data Record 3 - identifier incorrect');
      Check(MidStr(StringStream.DataString,18+(LineNo*704),38)=('Address 1'+GetSpaces(29)),       'Supplier Data Record 3 - Street Address 1 incorrect');
      Check(MidStr(StringStream.DataString,56+(LineNo*704),38)=('Address 2'+GetSpaces(29)),       'Supplier Data Record 3 - Street Address 2 incorrect');
      Check(MidStr(StringStream.DataString,94+(LineNo*704),27)=('Suburb'+GetSpaces(21)),          'Supplier Data Record 3 - Street Suburb incorrect');
      Check(MidStr(StringStream.DataString,121+(LineNo*704),3)=('Sta'),                           'Supplier Data Record 3 - Street State incorrect');
      Check(MidStr(StringStream.DataString,124+(LineNo*704),4)=('1234'),                          'Supplier Data Record 3 - Street Postcode incorrect');
      Check(MidStr(StringStream.DataString,128+(LineNo*704),20)=('New Zealand'+GetSpaces(9)),     'Supplier Data Record 3 - Street Country incorrect');
      Check(MidStr(StringStream.DataString,148+(LineNo*704),38)=('Post Address 1'+GetSpaces(24)), 'Supplier Data Record 3 - Post Address 1 incorrect');
      Check(MidStr(StringStream.DataString,186+(LineNo*704),38)=('Post Address 2'+GetSpaces(24)), 'Supplier Data Record 3 - Post Address 2 incorrect');
      Check(MidStr(StringStream.DataString,224+(LineNo*704),27)=('Post Suburb'+GetSpaces(16)),    'Supplier Data Record 3 - Post Suburb incorrect');
      Check(MidStr(StringStream.DataString,251+(LineNo*704),3)=('Sta'),                           'Supplier Data Record 3 - Post State incorrect');
      Check(MidStr(StringStream.DataString,254+(LineNo*704),4)=('1234'),                          'Supplier Data Record 3 - Post Postcode incorrect');
      Check(MidStr(StringStream.DataString,258+(LineNo*704),20)=('New Zealand'+GetSpaces(9)),     'Supplier Data Record 3 - Post Country incorrect');
      Check(MidStr(StringStream.DataString,278+(LineNo*704),76)=('Test@Email.com'+GetSpaces(62)), 'Supplier Data Record 3 - Email incorrect');
      Check(MidStr(StringStream.DataString,354+(LineNo*704),351)=GetSpaces(351),'Supplier Data Record 3 - Filler incorrect');

      //PAYER IDENTITY DATA RECORD
      LineNo := 3;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'Payer Data Record - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),8)='IDENTITY',        'Payer Data Record - identifier incorrect');
      Check(MidStr(StringStream.DataString,12+(LineNo*704),11)=('84111122223'), 'Payer Data Record - ABN incorrect');
      Check(MidStr(StringStream.DataString,23+(LineNo*704),3)=('222'),          'Payer Data Record - Branch incorrect');
      Check(MidStr(StringStream.DataString,26+(LineNo*704),4)=('2014'),         'Payer Data Record - Finacial Year incorrect');
      Check(MidStr(StringStream.DataString,30+(LineNo*704),200)=('Payer Name'+GetSpaces(190)),    'Payer Data Record - Payer Name incorrect');
      Check(MidStr(StringStream.DataString,230+(LineNo*704),200)=('Trade Name'+GetSpaces(190)),   'Payer Data Record - Trade Name incorrect');
      Check(MidStr(StringStream.DataString,430+(LineNo*704),38)=('Address 1'+GetSpaces(29)),      'Payer Data Record - Address 1 incorrect');
      Check(MidStr(StringStream.DataString,468+(LineNo*704),38)=('Address 2'+GetSpaces(29)),      'Payer Data Record - Address 2 incorrect');
      Check(MidStr(StringStream.DataString,506+(LineNo*704),27)=('Suburb'+GetSpaces(21)),         'Payer Data Record - Suburb incorrect');
      Check(MidStr(StringStream.DataString,533+(LineNo*704),3)=('Sta'),                           'Payer Data Record - State incorrect');
      Check(MidStr(StringStream.DataString,536+(LineNo*704),4)=('1234'),                          'Payer Data Record - Postcode incorrect');
      Check(MidStr(StringStream.DataString,540+(LineNo*704),20)=('New Zealand'+GetSpaces(9)),     'Payer Data Record - Country incorrect');
      Check(MidStr(StringStream.DataString,560+(LineNo*704),38)=('Contact Name'+GetSpaces(26)),   'Payer Data Record - Contact Name incorrect');
      Check(MidStr(StringStream.DataString,598+(LineNo*704),15)=('000 111 2222'+GetSpaces(3)),    'Payer Data Record - Contact Phone incorrect');
      Check(MidStr(StringStream.DataString,613+(LineNo*704),15)=('999 888 7777'+GetSpaces(3)),    'Payer Data Record - Contatc Fax incorrect');
      Check(MidStr(StringStream.DataString,628+(LineNo*704),76)=('Test@Email.com'+GetSpaces(62)), 'Payer Data Record - Email incorrect');
      Check(MidStr(StringStream.DataString,704+(LineNo*704),1)=GetSpaces(1),'Payer Data Record - Filler incorrect');

      //SOFTWARE DATA RECORD
      LineNo := 4;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'Software Data Record - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),8)='SOFTWARE',        'Software Data Record - identifier incorrect');
      Check(MidStr(StringStream.DataString,12+(LineNo*704),80)=('Software Product'+GetSpaces(64)), 'Software Data Record - Software Product incorrect');
      Check(MidStr(StringStream.DataString,92+(LineNo*704),613)=GetSpaces(613), 'Software Data Record - Filler incorrect');

      //PAYEE DATA RECORD
      LineNo := 5;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'Payee Data Record - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),6)='DPAIVS',          'Payee Data Record - identifier incorrect');
      Check(MidStr(StringStream.DataString,10+(LineNo*704),11)=('84111122223'), 'Payee Data Record - ABN incorrect');
      Check(MidStr(StringStream.DataString,21+(LineNo*704),30)=('Surname'+GetSpaces(23)),         'Payee Data Record - Surname incorrect');
      Check(MidStr(StringStream.DataString,51+(LineNo*704),15)=('First Name'+GetSpaces(5)),       'Payee Data Record - First Name incorrect');
      Check(MidStr(StringStream.DataString,66+(LineNo*704),15)=('Second Name'+GetSpaces(4)),      'Payee Data Record - Second Name incorrect');
      Check(MidStr(StringStream.DataString,81+(LineNo*704),200)=('Business Name'+GetSpaces(187)), 'Payee Data Record - Business Name incorrect');
      Check(MidStr(StringStream.DataString,281+(LineNo*704),200)=('Trade Name'+GetSpaces(190)),   'Payee Data Record - Trade Name incorrect');
      Check(MidStr(StringStream.DataString,481+(LineNo*704),38)=('Address 1'+GetSpaces(29)),      'Payee Data Record - Address 1 incorrect');
      Check(MidStr(StringStream.DataString,519+(LineNo*704),38)=('Address 2'+GetSpaces(29)),      'Payee Data Record - Address 2 incorrect');
      Check(MidStr(StringStream.DataString,557+(LineNo*704),27)=('Suburb'+GetSpaces(21)),         'Payee Data Record - Suburb incorrect');
      Check(MidStr(StringStream.DataString,584+(LineNo*704),3)=('Sta'),                           'Payee Data Record - State incorrect');
      Check(MidStr(StringStream.DataString,587+(LineNo*704),4)=('9999'),                          'Payee Data Record - Postcode incorrect');
      Check(MidStr(StringStream.DataString,591+(LineNo*704),20)=('New Zealand'+GetSpaces(9)),     'Payee Data Record - Country incorrect');
      Check(MidStr(StringStream.DataString,611+(LineNo*704),15)=('000 111 2222'+GetSpaces(3)),    'Payee Data Record - Contact Phone incorrect');
      Check(MidStr(StringStream.DataString,626+(LineNo*704),6)=('123456'),                        'Payee Data Record - BSB incorrect');
      Check(MidStr(StringStream.DataString,632+(LineNo*704),9)=('123456789'),                     'Payee Data Record - Account incorrect');
      Check(MidStr(StringStream.DataString,641+(LineNo*704),11)=(GetZeros(8)+'300'),              'Payee Data Record - Amount Paid incorrect');
      Check(MidStr(StringStream.DataString,652+(LineNo*704),11)=(GetZeros(8)+'100'),              'Payee Data Record - Tax Withheld incorrect');
      Check(MidStr(StringStream.DataString,663+(LineNo*704),11)=(GetZeros(8)+'150'),              'Payee Data Record - Total GST incorrect');
      Check(MidStr(StringStream.DataString,674+(LineNo*704),1)=('O'),           'Payee Data Record - Email incorrect');
      Check(MidStr(StringStream.DataString,675+(LineNo*704),30)=GetSpaces(30),  'Payee Data Record - Filler incorrect');

      //FILE TOTAL DATA RECORD
      LineNo := 6;
      Check(MidStr(StringStream.DataString,1+(LineNo*704),3)='704',             'File Total Data Record - Length incorrect');
      Check(MidStr(StringStream.DataString,4+(LineNo*704),10)='FILE-TOTAL',     'File Total Data Record - identifier incorrect');
      Check(MidStr(StringStream.DataString,14+(LineNo*704),8)=(GetZeros(7)+'7'),'File Total Data Record - Number of Records incorrect');
      Check(MidStr(StringStream.DataString,22+(LineNo*704),683)=GetSpaces(683), 'File Total Data Record - Filler incorrect');

    finally
      FreeAndNil(StringStream);
    end;
  finally
    FreeAndNil(FileStream);
  end;

  DeleteFile(TEST_CSV);
end;

//------------------------------------------------------------------------------
initialization

begin
  TestFramework.RegisterTest(TATOExtractTest.Suite);
end;

end.
