unit help32;
{------------------------------------------------}
{ allows 32bit delphi to read the tvision help files}
{
{ the help topic maintains a list of loaded paragraphs and a
{ list of strings for displaying in a multiline edit control
{ such as a rich text control
{
{ developed by Matthew Hopkins   Apr 1998
{
{------------------------------------------------}
interface

!!  No longer Used

uses windows,classes,dialogs, sysutils;

type
    {THelpTopic}
    TParaDetails = class
      Size : word;
      Wrap : byte;
    end;

    TCrossRef = record
      Ref : Word;
      Offset : SmallInt;
      Length : byte;
    end;

    PCrossRefs = ^TCrossRefs;
    TCrossRefs = Array[1..10000] of TCrossRef;

    THelpTopic = class
      constructor Create;
      destructor  Destroy; override;

      constructor   Load(var S : TFileStream);
    private
      RawText        : String;  {long string to hold all of topic}
      CrossRefs   : pCrossRefs;
      Paragraphs  : TStringList;
    public
      Lines       : TStringList;
      numRefs     : smallint;
      function CrossRefOffset(index :integer) : integer;
      function CrossRefLen(index : integer) : integer;
      function CrossRefContext(index:integer):integer;
    end;

    {THelpIndex}
    PIndexArray = ^TIndexArray;
    TIndexArray = Array[0..16380] of integer;
    PContextArray = ^TContextArray;
    TContextArray = Array[0..16380] of Word;

    THelpIndex = class
      constructor Create(var S :TFileStream);
      destructor  Destroy; override;

      function Position(I: Word):LongInt;
//    private
    public
      Size : word;
      Used : word;
      Contexts : PContextArray;
      Index    : PIndexArray;

      function Find(I:word):word;
    end;

    {THelpFile}
    THelpFile = class
      constructor Create(fname: string);
      destructor  Destroy;  override;
    private
      HStream : TFileStream;
      Index : THelpIndex;
      IndexPos : LongInt;
    public
      HelpFileOK : boolean;
      Topics : TStringList;
      function GetTopic(I :word) : THelpTopic;
      procedure TopicList;
    end;

{------------------------------------------------}
implementation
uses
   WarningMoreFrm;
{------------------------------------------------}
{THelpTopic}
constructor THelpTopic.Create;
begin
   inherited Create;

   Paragraphs := TStringList.Create;
   Lines      := TStringList.Create;
   CrossRefs  := nil;
   numRefs := 0;
end;

{------------------------------------------------}
constructor THelpTopic.Load(var S : TFileStream);
{creates and loads a help topic from the stream provided}
var
     Buff     : Array[0..32767] of Char;
     ParaDetail : TParaDetails;

  {-------------------------}
  procedure ReadParagraphs;
  var
     PascalID : word;
     I,Size   : smallInt;
     Wrap     : byte;
     ParaString : string;
  begin
     Paragraphs := TStringList.Create;

     S.Read(PascalID,SizeOf(PascalID));
     S.Read(I,SizeOf(I));

     while I > 0 do
     begin
        FillChar(Buff,SizeOf(Buff),0);

        S.Read(Size,SizeOf(Size));
        S.Read(Wrap,SizeOf(Wrap));
        S.Read(Buff,Size);

        ParaString := Buff;
        ParaDetail := TParaDetails.Create;
        ParaDetail.Size := Size;
        ParaDetail.Wrap := Wrap;

        Paragraphs.AddObject(Buff,ParaDetail);
        RawText := RawText + Buff;
        Dec(I);
     end;
  end;

  {-------------------------}
  procedure ReadCrossRefs;
  begin
     S.Read(NumRefs, SizeOf(NumRefs));
     GetMem(CrossRefs, SizeOf(TCrossRef) * NumRefs);
     if CrossRefs <> nil then
     begin
       FillChar(CrossRefs^,Sizeof(TCrossRef)*NumRefs,0);
       S.Read(CrossRefs^, SizeOf(TCrossRef) * NumRefs);
     end;
  end;

  {-------------------------}
  function OffsetDelta(linkOffset : integer) : integer;
  var
     CurrPara,CurrPos,CurrOffset,count13,countp : integer;
  begin
     result := 0;

     currPara := 0;
     currPos := 1;
     currOffset := 1;

     count13 := 0;
     countp  := 0;

     while (CurrPara <= Paragraphs.Count -1) and (currOffset <= LinkOffset) do
     begin
        if Copy(Paragraphs.Strings[currPara],CurrPos,1) = #13 then
          inc(count13);

        Inc(CurrPos);
        Inc(currOffset);

        if CurrPos > TParaDetails(Paragraphs.Objects[currPara]).Size then
        begin
           Inc(currPara);
           CurrPos := 1;
           inc(countp);
        end;
     end;
     result := (count13 + countp*2) -1;
  end;

  {-------------------------}
  procedure RecalcOffsets;
  var
    i: integer;
  begin
     for i := 1 to numRefs do
        CrossRefs^[i].Offset := CrossRefs^[i].Offset + OffsetDelta(CrossRefs^[i].Offset);
  end;

  {------------------------------------------------}
  {main routine starts here}
  {------------------------------------------------}
var
   i,LinePos : integer;
   Line    : string;
   ParaString : string;

begin
   inherited Create;

   ReadParagraphs;
   ReadCrossRefs;

   {at this point have a string list of paragraphs and hyperlinks}
   {now go thru and break into lines and recalc the hyperlink offsets}
   RecalcOffsets;

   {create lines}
   Lines      := TStringList.Create;
   parastring := '';

   for i := 0 to Paragraphs.Count-1 do
   begin
      ParaString := Paragraphs.Strings[i];
      LinePos := Pos(#13,ParaString);

      While LinePos > 0 do   {while there are #13's}
      begin
         Line := Copy(ParaString,1,LinePos-1);
         Lines.add(Line);
         ParaString := Copy(ParaString,LinePos+1,length(ParaString));
         LinePos := Pos(#13,ParaString);
      end;

      Lines.add(ParaString);
   end;
end;

{------------------------------------------------}
function THelpTopic.CrossRefOffset(index : integer) : integer;
begin
  result := CrossRefs^[index].Offset;
end;

{------------------------------------------------}
function THelpTopic.CrossRefLen(index : integer) : integer;
begin
   result := CrossRefs^[index].Length;
end;

{------------------------------------------------}
function THelpTopic.CrossRefContext(index:integer):integer;
begin
  result := CrossRefs^[index].Ref;
end;

{------------------------------------------------}
destructor THelpTopic.Destroy;
begin
   Paragraphs.Free;
   Lines.Free;
   if Assigned(CrossRefs) then FreeMem(CrossRefs, SizeOf(TCrossRef) * NumRefs);

   inherited Destroy;
end;

{------------------------------------------------}
{THelpIndex}
{------------------------------------------------}
constructor THelpIndex.Create(var S :TFileStream);
var
   PascalID : word;
begin
   inherited Create;
   S.Read(PascalID,SizeOf(PascalID));
   S.Read(Used,SizeOf(Used));
   S.Read(Size,SizeOf(Size));

   if Size = 0 then
   begin
     Contexts := nil;
     Index    := nil;
   end
   else
   begin
     GetMem(Contexts,SizeOf(Contexts^[0])*Size);
     S.Read(Contexts^,SizeOf(Contexts^[0])*Size);

     GetMem(Index,SizeOf(Index^[0])*Size);
     S.Read(Index^,SizeOf(Index^[0])*Size);
   end;
end;

{------------------------------------------------}
destructor THelpIndex.Destroy;
begin
   FreeMem(Index,SizeOf(Index^[0])*Size);
   FreeMem(Contexts,SizeOf(Contexts^[0])*Size);

   inherited Destroy;
end;

{------------------------------------------------}
function THelpIndex.Find(I: Word): Word;
var
  Hi, Lo, Pos: Integer;
begin
  Lo := 0;
  if Used > 0 then
  begin
    Hi := Used - 1;
    while Lo <= Hi do
    begin
      Pos := (Lo + Hi) div 2;
      if I > Contexts^[Pos] then
        Lo := Pos + 1
      else
      begin
        Hi := Pos - 1;
        if I = Contexts^[Pos] then
          Lo := Pos;
      end;
    end;
  end;
  result := Lo;
end;

{------------------------------------------------}
function THelpIndex.Position(I: Word): Longint;
begin
  Position := Index^[Find(I)];
end;

{------------------------------------------------}
{THelpFile}
{------------------------------------------------}
const
  MagicHeader = $46484246; {'FBHF'}

{------------------------------------------------}
constructor THelpFile.Create(fname : string);
var
  Magic : longint;
begin
   inherited Create;
   HelpFileOK := false;
   Topics := TStringList.Create;

   {open help file}
   try
     HStream := TFileStream.Create(fname, fmOPenRead or fmShareDenyNone);

     magic := 0;
     HStream.Seek(0,soFromBeginning);
     if HStream.Size > SizeOf(Magic) then
       HStream.Read(Magic,SizeOf(Magic));

     if Magic = MagicHeader then
     begin
        HelpFileOK := true;

        {now create index object}
        HStream.Seek(8,soFromBeginning);
        HStream.Read(IndexPos, SizeOf(IndexPos));
        HStream.Seek(IndexPos,soFromBeginning);
        Index := THelpIndex.Create(HStream);
     end;
   except
     on e : EFOpenError do HelpfulWarningMsg('Unable to Open Help File'+#13+#13+fname+'. Please check this file is in the current directory.',0);
   end;
end;

{------------------------------------------------}
destructor THelpFile.Destroy;
begin
   HStream.Free;
   Index.Free;
   Topics.Free;

   inherited Destroy;
end;

{------------------------------------------------}
function THelpFile.GetTopic(I :word) : THelpTopic;
{returns a newly created help topic.  It is the responsibility of the
 caller to then dispose of the object later
}
var
   Pos : LongInt;
begin
   if HelpFileOK then
   begin
     Pos := Index.Position(I);

     if Pos > 0 then
     begin
       HStream.Seek(Pos,soFromBeginning);
       result := THelpTopic.Load(HStream);  {returns a new help topic}
     end
     else
     begin
       result := THelpTopic.Create;
       result.Paragraphs.Add('Invalid Help Topic Context');
     end;
   end
   else
   begin   {shouldn't actually get here at all}
      result := THelpTopic.Create;
      result.Paragraphs.Add('Help File Unavailable');
   end;
end;

procedure THelpFile.TopicList;
var
   i,j :integer;
   pos : longint;
   Topic : THelpTopic;
   found : boolean;
   line : string;
begin
   Topics.Sorted := true;
   for i:= 0 to Index.Used-1 do
   begin
      pos := Index.Index^[i];
      HStream.Seek(Pos,soFromBeginning);
      Topic := THelpTopic.Load(HStream);  {returns a new help topic}
      j := 0;
      found := false;

      while (j < Topic.Lines.Count) and not found do
      begin
        if trim(Topic.Lines[j]) <> '' then
        begin
           found := true;
           line := Topic.Lines[j]+','+inttostr(Index.Contexts^[i]);
        end;
        j := j +1;
      end;
      Topics.Add(Line);
      Topic.Free;
   end;
end;

{------------------------------------------------}
{------------------------------------------------}
end.
