unit JobObj;
//------------------------------------------------------------------------------
{
   Title:       Job Obj

   Description: Job Object

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface


uses
  Classes,
  BKDefs,
  bkjhio,
  IOStream,
  ECollect;

type
   tClient_Job_List = class(TExtdSortedCollection)
      constructor Create;
      function Compare(Item1, Item2 : pointer) : integer; override;
   private
   protected
      procedure  FreeItem(Item : Pointer); override;
   public
      function Job_At(Index: LongInt): pJob_Heading_Rec;
      function FindName(Value: string): pJob_Heading_Rec;
      function FindCode(Value: string): pJob_Heading_Rec;
      function JobName(Value: string): string;
      procedure SaveToFile(var S: TIOStream );
      procedure LoadFromFile(var S: TIOStream );
      procedure UpdateCRC(var CRC: LongWord);

      procedure AssigntoDropDown(List: TStrings; ForDate: Integer = 1);
   end;


implementation

uses
 logUtil,
 SysUtils,
 BKDbExcept,
 math,
 malloc,
 tokens,
 bkcrc;

const
   DebugMe : Boolean = FALSE;
   UnitName = 'ClientJobListObj';



{ tClient_Job_List }


function CompareInt(I1,I2 : Integer): Integer;
{ compare two integers, return -1, 0 and 1 for I1<I2, I1=I2 and I1>I2 resp.}
asm
  sub eax, edx
end;


procedure tClient_Job_List. AssigntoDropDown(List: TStrings; ForDate: Integer = 1);
var I: integer;
begin
   list.BeginUpdate;
   try
      List.Clear;
      List.AddObject('', TObject(0));// Add a 'Blank' one
      for i := First to Last do
         with job_At(i)^ do
            if jhDate_Completed <= ForDate then
               List.AddObject(jhCode, tObject(job_At(i)));
   finally
      List.EndUpdate;
   end;
end;

function tClient_Job_List.Compare(Item1, Item2: pointer): integer;
begin
   Compare := comparetext (pJob_Heading_Rec(Item1).jhCode, pJob_Heading_Rec(Item2).jhCode);
end;

constructor tClient_Job_List.Create;
begin
   inherited Create;
   Duplicates := false;
end;


function tClient_Job_List.FindCode(Value: string): pJob_Heading_Rec;
var
  L, H, I, C: Integer;
  pJob: pJob_Heading_Rec;
begin
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;      {no items in list}
  repeat
     I := (L + H) shr 1;
     pJob := pJob_Heading_Rec(At(i));
     C := CompareText(Value, pJob^.jhCode);
     if C > 0 then
        L := I + 1
     else
        H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     Result := pJob;
     exit;
  end;
end;


function tClient_Job_List.FindName(Value: string): pJob_Heading_Rec;
var I: Integer;
begin
   Result := nil;
   for I := First to Last do
      if pJob_Heading_Rec(At(I)).jhHeading = Value then begin
          Result := pJob_Heading_Rec(At(I));
          Break;
      end;

end;

procedure tClient_Job_List.FreeItem(Item: Pointer);
begin
   if IsAJob_Heading_Rec(Item) then
     SafeFreeMem(item, Job_heading_Rec_Size);
end;


function tClient_Job_List.JobName(Value: string): string;
var lr: pJob_Heading_Rec;
begin
   lr := FindCode(Value);
   if assigned(Lr) then
      Result := Lr.jhHeading
   else
      Result := '';
end;

function tClient_Job_List.Job_At(Index: Integer): pJob_Heading_Rec;
begin
   Result := pJob_Heading_Rec(At(Index));
   if not IsAJob_Heading_Rec(Result) then
      raise ECorruptDataInFile.Create( 'Not a Job Record');
end;

procedure tClient_Job_List.LoadFromFile(var S: TIOStream);
var Token: Byte;
    NewJob: pJob_Heading_Rec;
begin
   Token := S.ReadToken;
   while (Token <> tkEndSection) do begin
      Case Token of
         tkBegin_Job_Heading : Begin
               SafeGetMem(NewJob, Job_heading_Rec_Size);
               if not Assigned(NewJob) then begin
                  LogUtil.LogMsg(lmError, UnitName, 'Unable to Allocate job record' );
                  raise EInsufficientMemory.Create( 'No room for Job record' );
               end;
               Read_JOB_Heading_Rec (NewJob^, S);
               if NewJob.jhCode = '' then
                 NewJob.jhCode := IntToStr(NewJob.jhLRN);
               repeat
                  try
                     Insert(NewJob);
                     Break;
                  except
                     NewJob.jhCode := '*' + Copy(NewJob.jhCode,1,7);
                  end;
               until False;

            end;
         else
         begin { Should never happen }
            LogUtil.LogMsg(lmError, UnitName, ' ' );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, '' ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
end;


procedure tClient_Job_List.SaveToFile(var S: TIOStream);
var i: Integer;
begin
   S.WriteToken(tkBeginJobList);

   for i := First to Last do
      Write_Job_Heading_Rec (job_At(i)^,S);

   S.WriteToken(tkEndSection);
end;

procedure tClient_Job_List.UpdateCRC(var CRC: LongWord);
var
  i : integer;
begin
  for i := First to Last do
     bkcrc.UpdateCRC (job_At(i)^,CRC);
end;


end.
