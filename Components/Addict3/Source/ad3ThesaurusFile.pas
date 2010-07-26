{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10877: ad3ThesaurusFile.pas 
{
{   Rev 1.6    8/30/2005 11:18:22 PM  mnovak
}
{
{   Rev 1.5    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.4    20/12/2004 3:24:44 pm  Glenn
}
{
{   Rev 1.3    9/24/2004 12:31:50 AM  mnovak
{ Fix Fault if thesaurus not unloaded in front of destructor.
}
{
{   Rev 1.2    2/22/2004 12:00:00 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:48 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:56 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:14 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:28 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Thesaurus file reader

History:
9/21/00     - Michael Novak     - Ported from V2.X
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ThesaurusFile;

{$I addict3.inc}

interface

uses
    sysutils, classes,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3Util;

type

    // private thesaurus file support classes

    {$IFNDEF T2H}
    TReverseNode = class(TObject)
    protected
	    LinkPos :LongInt;
    public
	    EW      :Boolean;
	    EWC     :Boolean;
	    RevRef  :Boolean;
	    OneKid  :Boolean;
	    Parent  :Word;
	    Child   :Word;
	    C       :Char;
    public
	    constructor create; virtual;
	    procedure   Retrieve( Pos:Word; ms1, ms2:TMemoryStream ); virtual;
    end;

    TForwardNode = class(TReverseNode)
    public
	    kids  :TList;
	    links :TList;
    public
	    constructor create; override;
	    destructor  Destroy; override;
	    procedure   Retrieve( Pos:Word; ms1, ms2:TMemoryStream ); override;
    end;

    TEntry = class(TObject)
    public
	    Kind   :Integer;
	    Master :Word;
	    Words  :Array[1..4] of TList;
    public
	    constructor create;  virtual;
	    destructor  Destroy; override;
	    procedure   retrieve( Pos:Word; ms3, ms4:TMemoryStream ); virtual;
    end;
    {$ENDIF T2H}


    //************************************************************
    // Public Thesaurus Entry
    //************************************************************

    TThesaurusEntry = class(TObject)
    public
        ContextWord     :String;
        ContextKind     :Integer;
        ContextKindName :String;
        Words           :Array[1..4] of TStringList;

    public
        {$IFNDEF T2H}
        constructor Create; virtual;
        destructor Destroy; override;
        {$ENDIF}
    end;


    //************************************************************
    // Addict Thesaurus File Class
    //************************************************************

    TThesaurusFile = class(TObject)
    protected
	    FLoaded     :Boolean;           (* is the THR loaded? *)
	    FFileName   :String;            (* thesaurus file name *)

	    NumNodes    :LongInt;           (* number of DAWG nodes *)
	    LinkSize    :LongInt;           (* size in bytes of the linking nodes *)
	    MasterSize  :Word;              (* number of entries in context index *)
	    IndexSize   :LongInt;           (* size in bytes of reverse indexing links *)
	    ms1         :TMemoryStream;     (* nodes *)
	    ms2         :TMemoryStream;     (* linking nodes *)
	    ms3         :TMemoryStream;     (* master index *)
	    ms4         :TMemoryStream;     (* reverse index links *)

        FName       :String;            // Name of thesaurus
        FKindNames  :TStringList;       // Name of context topic kinds

        FContexts           :TObjectList;
        FContextWord        :String;
        FAllowCaseChanges   :Boolean;

    protected
	    procedure LoadFile; virtual;
	    procedure UnloadFile; virtual;
	    procedure GetWord( var S:String; Pos:Word ); virtual;
	    function  PLookup( S:String; var Pos:Word ):Boolean; virtual;
	    procedure GetEntryDetails( EN:TEntry; ThesEntry:TThesaurusEntry ); virtual;
        procedure MatchEntryCase( Word:String; Entry:TThesaurusEntry ); virtual;

	    procedure WriteLoaded( Value:boolean ); virtual;
        procedure WriteFilename( NewFilename:String ); virtual;

    public
        {$IFNDEF T2H}
	    constructor Create; virtual;
	    destructor  Destroy; override;
        {$ENDIF}

        function    LookupWord( Lookup:String ):Boolean; virtual;

        property    Loaded:Boolean read FLoaded write WriteLoaded;
        property    FileName:String read FFileName write WriteFilename;
        property    Name:String read FName;
        property    Contexts:TObjectList read FContexts;
        property    ContextWord:String read FContextWord;
        property    ContextKindNames:TStringList read FKindNames;
        property    AllowCaseChanges:Boolean read FAllowCaseChanges write FAllowCaseChanges;
    end;


implementation


//************************************************************
// TReverseNode
//************************************************************

constructor TReverseNode.Create;
begin
  inherited Create;
  EW     := False;
  EWC    := False;
  RevRef := False;
  OneKid := False;
end;

//************************************************************
// Gets a partial node record.  Enough so we can retrieve a word given
// its endword index.

procedure TReverseNode.Retrieve( Pos:Word; ms1, ms2:TMemoryStream );
var
  L, L2:LongInt;
  B:Byte;
begin
  (* the following two lines, though seemingly redundant (why not just call
	 seek for Pos*4?)  Delphi 1.0 has some typing evaluation problems, so we
	 cannot multiply Pos*4.  We must convert it to a LongInt first.
	 This one cost me a few hours of work to catch... *)
  L2 := Pos;
  L2 := L2*4;
  ms1.seek( L2, soFromBeginning );
  ms1.readbuffer( L, 4 );
  EW      := (L and $00800000)<>0;
  EWC     := (L and $00400000)<>0;
  L2      := (L shr 24) and $000000FF;
  C       := Chr(L2);
  RevRef  := (L and $00200000)<>0;
  OneKid  := (L and $00100000)<>0;
  LinkPos := L and $000FFFFF;
  ms2.seek( LinkPos, soFromBeginning );
  if (OneKid) then
	ms2.readbuffer( Child, 2 )
  else begin
	ms2.readbuffer( b, 1 );   (* # children *)
	ms2.seek( b*2, soFromCurrent );
  end;
  if RevRef then
	ms2.readbuffer( Parent, 2 );
end;


//************************************************************
// TForwardNode
//************************************************************

constructor TForwardNode.Create;
begin
  inherited Create;
  kids  := tlist.Create;
  links := tlist.Create;
end;

//************************************************************

destructor TForwardNode.Destroy;
begin
  links.free;
  kids.free;
  inherited Destroy;
end;

//************************************************************
// gets all node information, including children and links

procedure TForwardNode.Retrieve( Pos:Word; ms1, ms2:TMemoryStream );
var
  b:byte;
  w:word;
  L2:LongInt;
begin
  inherited Retrieve( Pos, ms1, ms2 );
  ms2.seek( LinkPos, soFromBeginning );
  kids.clear;
  links.clear;
  if (OneKid) then
    b := 1
  else
    ms2.readbuffer( b, 1 );
  for L2 := 0 to B-1 do begin
    ms2.readbuffer( w, 2 );
    kids.add( pointer(w) );
  end;
  if (EW) or (EWC) then begin
    if (RevRef) then
      ms2.seek( 2, soFromCurrent );
    ms2.readbuffer( b, 1 );
    for L2 := 0 to B-1 do begin
      ms2.readbuffer( w, 2 );
      links.add( pointer(w) );
    end;
  end;
end;


//************************************************************
// TEntry
//************************************************************

constructor TEntry.Create;
var
  b:byte;
begin
  inherited Create;
  for b := 1 to 4 do
    Words[b] := TList.Create;
end;

//************************************************************

destructor TEntry.Destroy;
var
  b:byte;
begin
  for b := 1 to 4 do
    Words[b].Free;
  inherited Destroy;
end;

//************************************************************

procedure TEntry.Retrieve( Pos:Word; ms3, ms4:TMemoryStream );
var
  A:array[1..4] of Word;
  L:LongInt;
  Count, W:Word;
begin
  ms3.seek( Pos*14, soFromBeginning );
  ms3.readbuffer( Master, 2 );
  for W := 1 to 4 do
    ms3.readbuffer( A[W], 2 );
  L:=0;
  ms3.readbuffer( L, 4 );
  ms4.seek( L, soFromBeginning );
  For L := 1 to 4 do begin
    Words[L].Clear;
    For Count := 1 to A[L] do begin
      ms4.readBuffer( W, 2 );
      Words[L].Add( Pointer(W) );
    end;
  end;
end;



//************************************************************
// TThesaurusEntry
//************************************************************

constructor TThesaurusEntry.Create;
begin
    inherited Create;

    ContextWord     := '';
    ContextKind     := 0;
    ContextKindName := '';
    Words[1]        := TStringList.Create;
    Words[2]        := TStringList.Create;
    Words[3]        := TStringList.Create;
    Words[4]        := TStringList.Create;
end;

//************************************************************

destructor TThesaurusEntry.Destroy;
begin
    Words[1].Free;
    Words[2].Free;
    Words[3].Free;
    Words[4].Free;

    inherited Destroy;
end;


//************************************************************
// TThesaurusFile
//************************************************************

constructor TThesaurusFile.Create;
begin
    inherited Create;

    ms1         := TMemoryStream.Create;
    ms2         := TMemoryStream.Create;
    ms3         := TMemoryStream.Create;
    ms4         := TMemoryStream.Create;

    FContexts           := TObjectList.Create;

    FLoaded             := False;
    FFileName           := '';

    FKindNames          := TStringList.Create;
    FAllowCaseChanges   := True;
end;

//************************************************************

destructor  TThesaurusFile.Destroy;
begin
    UnloadFile;

    FContexts.Free;

    FKindNames.Free;

    ms1.free;
    ms2.free;
    ms3.free;
    ms4.free;

    inherited Destroy;
end;

//************************************************************
// Gets a word given its endword index

procedure TThesaurusFile.GetWord( var S:String; Pos:Word );
var
    RN      :TReverseNode;
    TmpRev  :Boolean;
    TmpPar  :Word;
begin
    RN := TReverseNode.Create;
    RN.Retrieve( Pos, ms1, ms2 );
    S := RN.C;
    if (RN.EWC) then
    begin
        TmpRev := RN.RevRef;
        TmpPar := RN.Parent;
        while (RN.OneKid) do
        begin
            RN.Retrieve( RN.Child, ms1, ms2 );
            S := S + RN.C;
        end;
        RN.RevRef := TmpRev;
        RN.Parent := TmpPar;
    end;
    while (RN.RevRef) and (RN.Parent <> 0) do
    begin
        RN.Retrieve( RN.Parent, ms1, ms2 );
        S := RN.C + S;
    end;
    RN.Free;
end;

//************************************************************
// tries to find a word in the DAWG.  Returns success.  If successful
// then Pos will be the index of the word node

function TThesaurusFile.PLookup( S:String; var Pos:Word ):Boolean;
var
    Index   :Word;
    Count   :Word;
    F       :TForwardNode;
    F2      :TForwardNode;
    R       :TReverseNode;
    S2      :String;
begin
    Result  := False;
    R       := TReverseNode.Create;
    F       := TForwardNode.Create;
    F2      := TForwardNode.Create;
    Index   := 0;
    F.Retrieve( Index, ms1, ms2 );      // get root node
    while (Length(S)>0) do
    begin
        if (F.Kids.Count=0) then
        begin
            break;                      // failure - no children
        end;
        Count := 0;
        while (Count < F.Kids.Count) do
        begin
            Index := Word(F.Kids[Count]);
            F2.Retrieve( Index, ms1, ms2 );
            if (F2.C=S[1]) then
            begin
                break;
            end;
            INC(Count);
        end;
        if (Count=F.Kids.Count) then
        begin
            break;                      // failure - not found as child
        end;
        Delete( S, 1, 1 );
        F.Retrieve( Index, ms1, ms2 );
        if (F.EW) and (S='') then
        begin                           // word found - EW reached
            Result := True;
            break;
        end;

        if (F.EWC) then
        begin
            S2 := '';
            if (F.Kids.Count=0) then
            begin
                break;                  // failure - no children
            end;
            R.Child := Word(F.Kids[0]);
            repeat
                R.Retrieve( R.Child, ms1, ms2 );
                S2 := S2+R.C;
            until (not(R.OneKid));
            if (S<>S2) then
            begin
                break;                  // failure - suffix doesn't match
            end;
            Result := True;
            break;                      // success - suffix's match
        end;
    end;
    F2.Free;
    F.Free;
    R.Free;
    if (Result) then
    begin
        Pos := Index;
    end;
end;

//************************************************************

procedure ReadString( FS:TFileStream; var S:String );
var
    Len     :Byte;
    Ch      :Char;
    Index   :LongInt;
begin
    S := '';
    FS.ReadBuffer( Len, 1 );
    for Index := 1 to Len do
    begin
        FS.ReadBuffer( Ch, 1 );
        S := S + Ch;
    end;
end;

procedure TThesaurusFile.LoadFile;
var
    fs      :TFileStream;
    ss      :ShortString;
    S       :String;
    Index   :Integer;
begin
    try
        if (FileExists( FFilename )) then
        begin
            fs := TFileStream.Create( FFileName, fmOpenRead );
            try
                FS.ReadBuffer( SS, 165 );           (* kill header *)

                FKindNames.Clear;
                ReadString( FS, FName );
                for Index := 0 to 4 do
                begin
                    ReadString( FS, S );
                    FKindNames.Add( S );
                end;

                (* read nodes *)
                FS.ReadBuffer( NumNodes, 4 );
                ms1.setsize( NumNodes*4 );
                ms1.seek( 0, soFromBeginning );
                ms1.copyfrom( fs, NumNodes*4 );
                (* read node linking *)
                FS.ReadBuffer( LinkSize, 4 );
                ms2.setsize( LinkSize );
                ms2.seek( 0, soFromBeginning );
                ms2.copyfrom( fs, LinkSize );
                (* read master index *)
                FS.ReadBuffer( MasterSize, 2 );
                ms3.setsize( MasterSize*14 );
                ms3.seek( 0, soFromBeginning );
                ms3.copyfrom( fs, MasterSize*14 );
                (* master index reverse links *)
                FS.ReadBuffer( IndexSize, 4 );
                ms4.setsize( IndexSize );
                ms4.seek( 0, soFromBeginning );
                ms4.copyfrom( fs, IndexSize );
                FLoaded := True;
            finally
                fs.Free;
            end;
        end;
    except
    end;
end;

//************************************************************

procedure TThesaurusFile.UnloadFile;
begin
    if (FLoaded) then
    begin
        ms1.SetSize( 0 );
        ms2.SetSize( 0 );
        ms3.SetSize( 0 );
        ms4.SetSize( 0 );
        FLoaded := False;
    end;
end;

//************************************************************

procedure TThesaurusFile.WriteLoaded( Value:Boolean );
begin
    if (Value = FLoaded) then
    begin
        exit;
    end;

    if (Value) then
    begin
        LoadFile;
    end
    else
    begin
        UnloadFile;
    end;
end;

//************************************************************

procedure TThesaurusFile.WriteFilename( NewFilename:String );
var
    OldLoaded   :Boolean;
begin
    if (NewFilename <> FFileName) and
        FileExists(NewFilename) then
    begin
        OldLoaded   := Loaded;
        FFilename   := NewFilename;
        Loaded      := OldLoaded;
    end;
end;

//************************************************************

procedure TThesaurusFile.GetEntryDetails( EN:TEntry; ThesEntry:TThesaurusEntry );
var
    S       :String;
    WLoop   :Integer;
    Count   :Integer;
begin
    GetWord( ThesEntry.ContextWord, EN.Master );
    ThesEntry.ContextKind       := EN.Kind;
    ThesEntry.ContextKindName   := FKindNames[EN.Kind];

    for WLoop := 1 to 4 do
    begin
        for Count := 0 to EN.Words[WLoop].Count - 1 do
        begin
            GetWord( S, Word(EN.Words[WLoop][Count]) );
            ThesEntry.Words[WLoop].Add( S );
        end;
    end;
end;

//************************************************************

procedure MatchCase( Word:String; var ChangeWord:String );
begin
    if (AnsiUpperCase( Word ) = Word) then
    begin
        ChangeWord := AnsiUpperCase( ChangeWord );
    end
    else if (AnsiUpperCase( Word[1] ) = Word[1]) then
    begin
        ChangeWord[1] := AnsiUpperCase( ChangeWord[1] )[1];
    end;
end;

//************************************************************

procedure TThesaurusFile.MatchEntryCase( Word:String; Entry:TThesaurusEntry );
var
    Count   :Integer;
    Loop    :Integer;
    Str     :String;
begin
    MatchCase( Word, Entry.ContextWord );

    for Loop := 1 to 4 do
    begin
        for Count := 0 to Entry.Words[Loop].Count - 1 do
        begin
            Str := Entry.Words[Loop][Count];
            MatchCase( Word, Str );
            Entry.Words[Loop][Count] := Str;
        end;
    end;
end;

//************************************************************

function TThesaurusFile.LookupWord( Lookup:String ):Boolean;
var
    Index       :Word;
    W           :Word;
    FW          :TForwardNode;
    EN          :TEntry;
    Count       :Integer;
    ThesEntry   :TThesaurusEntry;
    MatchCase   :Boolean;
begin
    Loaded      := True;

    if not(Loaded) then
    begin
        Result := False;
        exit;
    end;

    FContexts.Clear;
    FContextWord    := Lookup;
    MatchCase       := False;

    Result := PLookup( Lookup, W );
    if (not Result) then
    begin
        if (not FAllowCaseChanges) then
        begin
            exit;
        end;
        Result := PLookup( AnsiLowerCase(Lookup), W );
        if (not Result) then
        begin
            exit;
        end;
        MatchCase := True;
    end;

    FW := TForwardNode.Create;
    try
        FW.Retrieve( W, ms1, ms2 );
        for Count := 0 to FW.Links.Count - 1 do
        begin
            EN      := TEntry.Create;
            try
                Index   := Word(FW.Links[Count]) div 5;
                EN.Retrieve( Index, ms3, ms4 );
                EN.Kind := Word(FW.Links[Count]) mod 5;

                ThesEntry := TThesaurusEntry.Create;
                GetEntryDetails( EN, ThesEntry );
                FContexts.Add( ThesEntry );

                if (MatchCase) then
                begin
                    MatchEntryCase( FContextWord, ThesEntry );
                end;

            finally
                EN.Free;
            end;
        end;
    finally
        FW.Free;
    end;
end;

//************************************************************


end.

