{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10849: ad3PhoneticsMap.pas 
{
{   Rev 1.4    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:24 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:46 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:34 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:44 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:18 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

AddictSpell Basic Phonetics types

History:
9/5/00      - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3PhoneticsMap;

{$I addict3.inc}

interface

uses
    sysutils,
    windows,
    classes,
    ad3Util;

type

    //************************************************************
    // AddictSpell Phonetics Map
    //************************************************************

    TReplaceNode = class(TObject)
    protected
        FChildren       :Boolean;
        FTree           :Array[0..255] of TReplaceNode;
        FDestination    :Boolean;
        FDestWord       :String;
        FSourceLength   :Integer;
        
    protected

        function GetNextMap( Word:String; var Mapping:String; var MapLength:Integer; Index:LongInt ):Boolean; virtual;

    public
        {$IFNDEF T2H}
        constructor Create; virtual;
        destructor Destroy; override;
        {$ENDIF}

        procedure ClearMap; virtual;
        procedure AddMap( Source:String; Dest:String; SourceLength:Integer ); virtual;
    end;

    //************************************************************

    TPhoneticsMap = class(TReplaceNode)
    protected
        FStartDepth         :Integer;
        FRemoveDupes        :Boolean;
        FLimit              :LongInt;
        FLanguage           :DWORD;
        FDistanceDivisor    :Integer;
        FDistanceMax        :Integer;

    protected
        procedure WriteLanguage( NewLanguage:DWORD ); virtual;
        procedure WriteStartDepth( NewDepth:Integer ); virtual;

    public
        {$IFNDEF T2H}
        constructor Create; override;
        {$ENDIF}

        function GetMapping( Word:String ):String; virtual;
        function AcceptableDistance( const OldWord:String; Dist:Integer ):Boolean; virtual;

        property StartDepth:Integer read FStartDepth write WriteStartDepth;
        property RemoveDupes:Boolean read FRemoveDupes write FRemoveDupes;
        property Limit:LongInt read FLimit write FLimit;
        property Language:DWORD read FLanguage write WriteLanguage;
        property DistanceDivisor:Integer read FDistanceDivisor write FDistanceDivisor;
        property DistanceMax:Integer read FDistanceMax write FDistanceMax;
    end;


implementation

//************************************************************
// TReplaceNode
//************************************************************

constructor TReplaceNode.Create;
var
    Index   :LongInt;
begin
    for Index := 0 to 255 do
    begin
        FTree[Index] := nil;
    end;
    FChildren       := False;
    FDestination    := False;
    FDestWord       := '';
    FSourceLength   := 0;
end;

//************************************************************

destructor TReplaceNode.Destroy;
begin
    ClearMap;
    inherited Destroy;
end;

//************************************************************

procedure TReplaceNode.ClearMap;
var
    Index   :LongInt;
begin
    if (FChildren) then
    begin
        for Index := 0 to 255 do
        begin
            if (Assigned(FTree[Index])) then
            begin
                FTree[Index].Free;
                FTree[Index] := nil;
            end;
        end;
        FChildren := False;
    end;
end;

//************************************************************

procedure TReplaceNode.AddMap( Source:String; Dest:String; SourceLength:Integer );
var
    Pos :LongInt;
begin
    if (Source = '') then
    begin
        FDestination    := True;
        FDestWord       := Dest;
        FSourceLength   := SourceLength;
    end
    else
    begin
        Pos := Ord(Source[1]);
        if (not Assigned(FTree[Pos])) then
        begin
            FChildren   := True;
            FTree[Pos]  := TReplaceNode.Create;
        end;
        delete( Source, 1, 1 );
        FTree[Pos].AddMap( Source, Dest, SourceLength );
    end;
end;

//************************************************************

function TReplaceNode.GetNextMap( Word:String; var Mapping:String; var MapLength:Integer; Index:LongInt ):Boolean;
begin
    Result  := False;
    Mapping := '';

    if  (Index <= Length(Word)) and
        (Assigned( FTree[ Ord(Word[Index]) ] )) then
    begin
        Result := FTree[ Ord(Word[Index]) ].GetNextMap( Word, Mapping, MapLength, Index + 1 );
    end;

    if (not Result) then
    begin
        if (FDestination) then
        begin
            Result      := True;
            MapLength   := FSourceLength;
            Mapping     := FDestWord;
        end;
    end;
end;




//************************************************************
// TPhoneticsMap
//************************************************************

constructor TPhoneticsMap.Create;
begin
    inherited Create;

    FStartDepth         := 2;
    FRemoveDupes        := True;
    FLimit              := 6;
    FLanguage           := $FFFFFFFF;
    FDistanceDivisor    := 2;
    FDistanceMax        := 4;
end;

//************************************************************

procedure TPhoneticsMap.WriteLanguage( NewLanguage:DWORD );
const
    EnglishLanguage         = $0009;
    RussianLanguage         = $0019;
    FrenchLanguage          = $000c;
begin
    if (FLanguage = NewLanguage) then
    begin
        exit;
    end;

    FLanguage := NewLanguage;

    ClearMap;

    if ((FLanguage and $00FF) = EnglishLanguage) then
    begin
        // This sets up a set of rules roughly akin to those used in the
        // Metaphone algorithm.

        AddMap( 'b', 'b', 1 );
        AddMap( 'cia', 'x', 1 );
        AddMap( 'ch', 'x', 2 );
        AddMap( 'ci', 's', 1 );
        AddMap( 'ce', 's', 1 );
        AddMap( 'cy', 's', 1 );
        AddMap( 'c', 'k', 1 );
        AddMap( 'dge', 'j', 2 );
        AddMap( 'dgy', 'j', 2 );
        AddMap( 'dgi', 'j', 2 );
        AddMap( 'd', 't', 1 );
        AddMap( 'f', 'f', 1 );
        AddMap( 'gha', 'k', 2 );
        AddMap( 'ghe', 'k', 2 );
        AddMap( 'ghi', 'k', 2 );
        AddMap( 'gho', 'k', 2 );
        AddMap( 'ghu', 'k', 2 );
        AddMap( 'ghy', 'k', 2 );
        AddMap( 'gh', '', 2 );
        AddMap( 'gn', 'n', 2 );
        AddMap( 'gi', 'j', 1 );
        AddMap( 'ge', 'j', 1 );
        AddMap( 'gy', 'j', 1 );
        AddMap( 'g', 'k', 1 );
        AddMap( 'h', 'h', 1 );
        AddMap( 'aha', 'h', 2 );
        AddMap( 'ahe', 'h', 2 );
        AddMap( 'ahi', 'h', 2 );
        AddMap( 'aho', 'h', 2 );
        AddMap( 'ahu', 'h', 2 );
        AddMap( 'eha', 'h', 2 );
        AddMap( 'ehe', 'h', 2 );
        AddMap( 'ehi', 'h', 2 );
        AddMap( 'eho', 'h', 2 );
        AddMap( 'ehu', 'h', 2 );
        AddMap( 'iha', 'h', 2 );
        AddMap( 'ihe', 'h', 2 );
        AddMap( 'ihi', 'h', 2 );
        AddMap( 'iho', 'h', 2 );
        AddMap( 'ihu', 'h', 2 );
        AddMap( 'oha', 'h', 2 );
        AddMap( 'ohe', 'h', 2 );
        AddMap( 'ohi', 'h', 2 );
        AddMap( 'oho', 'h', 2 );
        AddMap( 'ohu', 'h', 2 );
        AddMap( 'uha', 'h', 2 );
        AddMap( 'uhe', 'h', 2 );
        AddMap( 'uhi', 'h', 2 );
        AddMap( 'uho', 'h', 2 );
        AddMap( 'uhu', 'h', 2 );
        AddMap( 'ah', '', 2 );
        AddMap( 'eh', '', 2 );
        AddMap( 'ih', '', 2 );
        AddMap( 'oh', '', 2 );
        AddMap( 'uh', '', 2 );
        AddMap( 'j', 'j', 1 );
        AddMap( 'ck', 'k', 2 );
        AddMap( 'k', 'k', 1 );
        AddMap( 'l', 'l', 1 );
        AddMap( 'm', 'm', 1 );
        AddMap( 'n', 'n', 1 );
        AddMap( 'ph', 'f', 2 );
        AddMap( 'p', 'p', 1 );
        AddMap( 'q', 'k', 1 );
        AddMap( 'r', 'r', 1 );
        AddMap( 'sh', 'x', 2 );
        AddMap( 'sio', 'x', 1 );
        AddMap( 'sia', 'x', 1 );
        AddMap( 's', 's', 1 );
        AddMap( 'tia', 'x', 1 );
        AddMap( 'tio', 'x', 1 );
        AddMap( 'th', '0', 2 );
        AddMap( 'tch', 'x', 3 );
        AddMap( 't', 't', 1 );
        AddMap( 'v', 'f', 1 );
        AddMap( 'wa', 'w', 1 );
        AddMap( 'we', 'w', 1 );
        AddMap( 'wi', 'w', 1 );
        AddMap( 'wo', 'w', 1 );
        AddMap( 'wu', 'w', 1 );
        AddMap( 'wy', 'w', 1 );
        AddMap( 'x', 'ks', 1 );
        AddMap( 'ya', 'y', 1 );
        AddMap( 'ye', 'y', 1 );
        AddMap( 'yi', 'y', 1 );
        AddMap( 'yo', 'y', 1 );
        AddMap( 'yu', 'y', 1 );
        AddMap( 'yy', 'y', 2 );
        AddMap( 'z', 's', 1 );

        exit;
    end;

    if ((FLanguage and $00FF) = RussianLanguage) then
    begin
        // Ad hoc rules for russion created by Ivan Tugoy

        AddMap( 'ב', 'בü', 1 );
        AddMap( 'ג', 'גü', 1 );
        AddMap( 'ד', 'דü', 1 );
        AddMap( 'ה', 'הü', 1 );
        AddMap( 'ח', 'חü', 1 );
        AddMap( 'ך', 'ךü', 1 );
        AddMap( 'כ', 'כü', 1 );
        AddMap( 'ל', 'לü', 1 );
        AddMap( 'ם', 'םü', 1 );
        AddMap( 'ן', 'ןü', 1 );
        AddMap( 'נ', 'נü', 1 );
        AddMap( 'ס', 'סü', 1 );
        AddMap( 'ע', 'עü', 1 );
        AddMap( 'ח', 'ס', 1 );
        AddMap( 'ז', 'ר', 1 );
        AddMap( 'ך', 'ד', 1 );
        AddMap( 'מ', 'ו', 1 );
        AddMap( 'מ', 'א', 1 );
        AddMap( 'ה', 'ע', 1 );
        AddMap( 'מנמ', 'aנמ', 3 );
        AddMap( 'מנמ', 'מנא', 3 );
        AddMap( 'מכמ', 'aכמ', 3 );
        AddMap( 'מכמ', 'מכא', 3 );
        AddMap( 'םם', 'ם', 2 );
        AddMap( 'סס', 'ס', 2 );
        AddMap( 'וו', 'ו', 2 );
        AddMap( 'זט', 'זû', 2 );
        AddMap( 'רט', 'רû', 2 );
        AddMap( 'ש', 'רü', 1 );
        AddMap( 'שף', 'ר‏', 2 );
        AddMap( 'סק', 'ש', 2 );
        AddMap( 'סר', 'ר', 1 );

        exit;
    end;

    if ((FLanguage and $00FF) = FrenchLanguage) then
    begin
        // Very basic equivalent of French Soundex

        AddMap( 'b', 'b', 1 );
        AddMap( 'p', 'b', 1 );
        AddMap( 'c', 'c', 1 );
        AddMap( 'k', 'c', 1 );
        AddMap( 'q', 'c', 1 );
        AddMap( 'd', 'd', 1 );
        AddMap( 't', 'd', 1 );
        AddMap( 'l', 'l', 1 );
        AddMap( 'm', 'm', 1 );
        AddMap( 'n', 'm', 1 );
        AddMap( 'r', 'r', 1 );
        AddMap( 'g', 'g', 1 );
        AddMap( 'j', 'g', 1 );
        AddMap( 'x', 'x', 1 );
        AddMap( 'z', 'x', 1 );
        AddMap( 's', 'x', 1 );
        AddMap( 'f', 'f', 1 );
        AddMap( 'v', 'f', 1 );

        exit;
    end;

    // Standard soundex algorithm

    AddMap( 'b', 'b', 1 );
    AddMap( 'f', 'b', 1 );
    AddMap( 'p', 'b', 1 );
    AddMap( 'v', 'b', 1 );
    AddMap( 'c', 'k', 1 );
    AddMap( 'g', 'k', 1 );
    AddMap( 'j', 'k', 1 );
    AddMap( 'k', 'k', 1 );
    AddMap( 'q', 'k', 1 );
    AddMap( 's', 'k', 1 );
    AddMap( 'x', 'k', 1 );
    AddMap( 'z', 'k', 1 );
    AddMap( 'd', 'd', 1 );
    AddMap( 't', 'd', 1 );
    AddMap( 'l', 'l', 1 );
    AddMap( 'm', 'm', 1 );
    AddMap( 'n', 'm', 1 );
    AddMap( 'r', 'r', 1 );
end;

//************************************************************

procedure TPhoneticsMap.WriteStartDepth( NewDepth:Integer );
begin
    if (NewDepth >= 1) then
    begin
        FStartDepth := NewDepth;
    end;
end;

//************************************************************

function TPhoneticsMap.GetMapping( Word:String ):String;
var
    Mapping     :String;
    MapLength   :LongInt;
    Limit       :LongInt;
begin
    Word    := AnsiLowerCase( Word );
    Result  := '';
    Limit   := FLimit;

    if (Word = '') then
    begin
        exit;
    end;

    if (FStartDepth > 0) then
    begin
        Result := copy( Word, 1, FStartDepth );
        delete( Word, 1, FStartDepth );
    end;

    while (Word <> '') do
    begin
        Mapping     := '';
        MapLength   := 1;
        if (GetNextMap( Word, Mapping, MapLength, 1 )) then
        begin
            if  (FRemoveDupes) and
                (Length(Result) > 0) and
                (MapLength = 1) and
                (Result[ Length(Result) ] = Mapping[1]) then
            begin
                // no changes for the dupe
            end
            else
            begin
                Result := Result + Mapping;

                dec( Limit, Length(Mapping) );
                if (Limit <= 0) then
                begin
                    break;
                end;
            end;
        end;
        delete( Word, 1, MapLength );
    end;
end;

//************************************************************

function TPhoneticsMap.AcceptableDistance( const OldWord:String; Dist:Integer ):Boolean;
begin
    Result  := False;
    if  ((Dist <= (Length(OldWord) div FDistanceDivisor)) and (Dist <= FDistanceMax)) then
    begin
        Result := True;
    end;
end;



end.

