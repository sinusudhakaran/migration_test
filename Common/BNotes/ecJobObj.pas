unit ecJobObj;

interface

uses
  Classes,
  ECDEFS,
  IOStream,
  ECollect;

type
  TECJob = class
  public
	  jhFields : tJob_Heading_Rec;
    constructor Create;
    destructor Destroy; override;

    procedure SaveToFile( Var S : TIOStream );
    procedure LoadFromFile( Var S : TIOStream );
    procedure UpdateCRC(var CRC : Longword);
  end;

  TECJob_List = class(TExtdSortedCollection)
    constructor Create;
    function Compare( Item1, Item2 : Pointer ) : integer; override;
  private
    function GetNonCompletedJobCount: Integer;
  protected
    procedure FreeItem( Item : Pointer ); override;
  public
    function  Job_At( Index : LongInt ): TECJob;
    function  Find_Job_Number( CONST ANumber: LongInt ): TECJob;
    function  Find_Job_Heading( CONST AHeading: String ): TECJob;
    function  Find_Job_Code( CONST ACode: String ): TECJob;    
    function  Get_New_Job_Number: LongInt;

    procedure SaveToFile( Var S : TIOStream );
    procedure LoadFromFile( Var S : TIOStream );

    procedure UpdateCRC(var CRC : Longword);
    procedure CheckIntegrity;

    property NonCompletedJobCount: Integer read GetNonCompletedJobCount;
    function NonCompletedJobAt(Index: Integer): TECJob;
    function Job_Search(const CodeOrName: string): TECJob;
  end;

implementation

uses ECjhIO, ECCRC, ECTOKENS, StStrS, SysUtils, BKDBExcept;

const
  UnitName = 'ecJobObj';

{ TECJob }

constructor TECJob.Create;
begin
  FillChar( jhFields, Sizeof( jhFields ), 0 );
  jhFields.jhRecord_Type := tkBegin_Job_Heading;
  jhFields.jhEOR := tkEnd_Job_Heading;
end;

destructor TECJob.Destroy;
begin
  Free_Job_Heading_Rec_Dynamic_Fields(jhFields);
  inherited;
end;

procedure TECJob.LoadFromFile(var S: TIOStream);
begin
  ECjhIO.Read_Job_Heading_Rec(jhFields, S);
end;

procedure TECJob.SaveToFile(var S: TIOStream);
begin
  ECjhIO.Write_Job_Heading_Rec(jhFields, S);
end;

procedure TECJob.UpdateCRC(var CRC: Longword);
begin
  ECCRC.UpdateCRC(jhFields, CRC);
end;

{ TECJob_List }

procedure TECJob_List.CheckIntegrity;
var
  LastCode : String[60];
  i : Integer;
  AJob : TECJob;
begin
  LastCode := '';
  for i := First to Last do
  begin
    AJob := Job_At(i);
    if (AJob.jhFields.jhCode < LastCode) then
      Raise Exception.CreateFmt('Job List Sequence : %d', [i]);
    LastCode := AJob.jhFields.jhCode;
  end;

end;

function TECJob_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := StStrS.CompStringS(TECJob(Item1).jhFields.jhCode,TECJob(Item2).jhFields.jhCode);  
end;

constructor TECJob_List.Create;
begin
  inherited;
end;

function TECJob_List.Find_Job_Code(const ACode: String): TECJob;
var
  i : Integer;
  AJob : TECJob;
begin
  Result := nil;

  for i := First to Last do
  begin
    AJob := Job_At(i);
    if CompareText(AJob.jhFields.jhCode, ACode) = 0 then
    begin
      Result := AJob;
      exit;
    end;
  end;

end;

function TECJob_List.Find_Job_Heading(const AHeading: String): TECJob;
var
  i : Integer;
  AJob : TECJob;
begin
  Result := nil;

  for i := First to Last do
  begin
    AJob := Job_At(i);
    if CompareText(AJob.jhFields.jhHeading, AHeading) = 0 then
    begin
      Result := AJob;
      exit;
    end;
  end;
end;

function TECJob_List.Find_Job_Number(const ANumber: Integer): TECJob;
var
  i : Integer;
  AJob : TECJob;
begin
  Result := nil;

  for i := First to Last do
  begin
    AJob := Job_At(i);
    if (AJob.jhFields.jhLRN = ANumber) then
    begin
      Result := AJob;
      exit;
    end;
  end;
end;

procedure TECJob_List.FreeItem(Item: Pointer);
begin
  TECJob(Item).Free;
end;

function TECJob_List.GetNonCompletedJobCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := First to Last do
    if not Job_At(I).jhFields.jhIsCompleted then
      Inc(Result);
end;

function TECJob_List.Get_New_Job_Number: LongInt;
var
  i : Integer;
begin
  Result := -1;
  for i := First to Last do
  begin
    if (Job_At(i).jhFields.jhLRN > Result) then
      Result := Job_At(i).jhFields.jhLRN;
  end;
  if (Result <> -1) then
    Result := Result + 1;
end;

function TECJob_List.Job_At(Index: Integer): TECJob;
begin
  Result := At(Index);
end;

function TECJob_List.Job_Search(const CodeOrName: string): TECJob;
var
  I: Integer;
begin
  Result := nil;
  if CodeOrName = '' then
    Exit;
  for I := First to Last do
  begin
    Result := Job_At(i);
    if CompareText(Result.jhFields.jhCode, CodeOrName) = 0 then
      Exit;
    if CompareText(Result.jhFields.jhHeading, CodeOrName) = 0 then
      Exit;
    Result := nil; //set to nil so it returns nil if nothing is found
  end;
end;

procedure TECJob_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TECJob_List.LoadFromFile';
var
  Token    : Byte;
  Job        : TECJob;
  msg      : string;
begin
   Token := S.ReadToken;
   while ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBegin_Job_Heading :
           begin
              Job := TECJob.Create;
              if not Assigned( Job ) then
              begin
                 Msg := Format( '%s : Unable to allocate Job',[ThisMethodName]);
                 raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
              end;
              Job.LoadFromFile( S );
              Insert( Job );
           end;
      else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
end;

function TECJob_List.NonCompletedJobAt(Index: Integer): TECJob;
var
  I: Integer;
  NonCompleteCount: Integer;
  Job: TECJob;
begin
  //Find the job at the index, when not counting complete jobs
  NonCompleteCount := 0;
  Result := nil;
  for I := First to Last do
  begin
    Job := Job_At(I);
    if not Job.jhFields.jhIsCompleted then
    begin
      if NonCompleteCount = Index then
      begin
        Result := Job;
        Exit;
      end;
      Inc(NonCompleteCount);
    end;
  end;
end;

procedure TECJob_List.SaveToFile(var S: TIOStream);
var
  i : Integer;
begin
   S.WriteToken( tkBeginJobsList );
   for i := First to Last do
     Job_At(i).SaveToFile(S);
   S.WriteToken( tkEndSection );
end;

procedure TECJob_List.UpdateCRC(var CRC: Longword);
var
  i : integer;
begin
  for i := First to Last do
    Job_At(i).UpdateCRC(CRC);
end;

end.
