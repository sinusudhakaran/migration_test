{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10833: ad3Ignore.pas 
{
{   Rev 1.4    1/27/2005 2:14:18 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:12 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:40 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:28 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:40 AM  mnovak
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

Basic ignore entities shipped with AddictSpell

History:
7/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3Ignore;

{$I addict3.inc}

interface

uses
    sysutils,
    ad3ParserBase;

type

    ///***********************************************************
    // Addict Ignore Helper Baseclass
    ///***********************************************************

    TParserIgnoreBase = class(TParserIgnore)
    public
        function NeededBeforeCheck:Boolean; override;
        function LineCheckNeeded:Boolean; override;
        function ExecuteIgnore( CurrentChar:Char; Parser:TControlParser ):Boolean; override;
        function ExecuteWordIgnorePreCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
        function ExecuteLineIgnore( const CurrentLine:String ):Boolean; override;
    end;


    ///***********************************************************
    // HTML Ignore
    ///***********************************************************

    THTMLIgnore = class(TParserIgnoreBase)
    public
        function NeededBeforeCheck:Boolean; override;
        function ExecuteIgnore( CurrentChar:Char; Parser:TControlParser ):Boolean; override;
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
    end;


    ///***********************************************************
    // E-Mail & URL Ignore
    ///***********************************************************

    TURLIgnore = class(TParserIgnoreBase)
    public
        function NeededBeforeCheck:Boolean; override;
        function ExecuteWordIgnorePreCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
    end;


    ///***********************************************************
    // Quoted Line Ignore
    ///***********************************************************

    TQuotedLineIgnore = class(TParserIgnoreBase)
    protected
        FQuoteChars :String;
    public
        function LineCheckNeeded:Boolean; override;
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
        function ExecuteLineIgnore( const CurrentLine:String ):Boolean; override;

        property QuoteChars:String read FQuoteChars write FQuoteChars;
    end;


    ///***********************************************************
    // Uppercase Ignore
    ///***********************************************************

    TUppercaseWordIgnore = class(TParserIgnoreBase)
    public
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
    end;


    ///***********************************************************
    // Words Containing Numbers
    ///***********************************************************

    TNumbersIgnore = class(TParserIgnoreBase)
    public
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
    end;


    ///***********************************************************
    // Abbreviations
    ///***********************************************************

    TAbbreviationsIgnore = class(TParserIgnoreBase)
    public
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; override;
    end;


implementation

const
    EndInternet = #13 + #10 + #9 + #32 + '"()[]{},<>''';


///***********************************************************
// Addict Ignore Helper Baseclass
///***********************************************************

function TParserIgnoreBase.NeededBeforeCheck:Boolean;
begin
    Result := False;
end;

///***********************************************************

function TParserIgnoreBase.LineCheckNeeded:Boolean;
begin
    Result := False;
end;

///***********************************************************

function TParserIgnoreBase.ExecuteIgnore( CurrentChar:Char; Parser:TControlParser ):Boolean;
begin
    Result := False;
end;

///***********************************************************

function TParserIgnoreBase.ExecuteWordIgnorePreCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
begin
    Result := False;
end;

///***********************************************************

function TParserIgnoreBase.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
begin
    Result := False;
end;

///***********************************************************

function TParserIgnoreBase.ExecuteLineIgnore( const CurrentLine:String ):Boolean;
begin
    Result := False;
end;


///***********************************************************
// HTML Ignore
///***********************************************************

function THTMLIgnore.NeededBeforeCheck:Boolean;
begin
    Result := True;
end;

///***********************************************************

function ParserPeek( Lead:String; Parser:TControlParser ):Boolean;
begin
    Result := (Lead[1] = Parser.GetChar);
    if  (Result) and
        (Length(Lead) > 1) then
    begin
        Result := Parser.MoveNext;
        if (Result) then
        begin
            Result := ParserPeek( Copy(Lead, 2, Length(Lead) -1), Parser );
            if (not Result) then
            begin
                Parser.MovePrevious;
            end;
        end;
    end
end;

function THTMLIgnore.ExecuteIgnore( CurrentChar:Char; Parser:TControlParser ):Boolean;
var
    SpecialNeeded   :Boolean;
    LastCharSpecial :Boolean;
    SpecialChar     :Char;
    XMLIgnore       :Boolean;
begin
    Result := False;
    if (CurrentChar = '<') then
    begin
        if (Parser.MoveNext) then
        begin
            XMLIgnore       := ParserPeek( '!--', Parser );
            SpecialChar     := Parser.GetChar;
            SpecialNeeded   := (not XMLIgnore) and (SpecialChar in ['%','?']);
            LastCharSpecial := False;
            while   (XMLIgnore and not(ParserPeek( '-->', Parser ))) or
                    (Parser.GetChar <> '>') or
                    (SpecialNeeded and (not LastCharSpecial)) do
            begin
                LastCharSpecial := (Parser.GetChar = SpecialChar);
                if (not Parser.MoveNext) then
                begin
                    break;
                end;
            end;
        end;
        Result := True;
    end;
end;

///***********************************************************

function THTMLIgnore.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
begin
    Result := (CurrentWord[1] = '&');
end;



///***********************************************************
// E-Mail and URL Ignore
///***********************************************************

function TURLIgnore.NeededBeforeCheck:Boolean;
begin
    Result := True;
end;

///***********************************************************

function TURLIgnore.ExecuteWordIgnorePreCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
var
    NextChar    :Char;
    Word        :String;
begin
    Result      := False;

    NextChar    := Parser.GetChar;
    
    if (NextChar = ':') then
    begin
        Word := AnsiLowerCase(CurrentWord);

        if  (Word = 'http')     or
            (Word = 'ftp')      or
            (Word = 'news')     or
            (Word = 'mailto')   or
            (Word = 'nntp')     or
            (Word = 'file')     or
            (Word = 'https')    or
            (Word = 'telnet')   or
            (Word = 'wais')     then
        begin
            Result := True;
        end;
    end;

    if (NextChar = '@') then
    begin
        Result := True;
    end;

    if (NextChar = '\') or (NextChar = '/') then
    begin
        Word := AnsiLowerCase(CurrentWord);
        if (pos( 'www.', Word ) = 1) then
        begin
            Result := True;
        end;
    end;

    if (Result) then
    begin
        while (Pos( Parser.GetChar, EndInternet ) = 0) do
        begin
            if (not Parser.MoveNext) then
            begin
                break;
            end;
        end;
    end;
end;

///***********************************************************

function TURLIgnore.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
var
    Word    :String;
begin
    Word    := AnsiLowerCase( CurrentWord );
    Result  := (pos( 'www.', Word ) = 1);
end;



///***********************************************************
// Quoted Line Ignore
///***********************************************************

function TQuotedLineIgnore.LineCheckNeeded:Boolean;
begin
    Result := True;
end;

///***********************************************************

function TQuotedLineIgnore.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
begin
    Result  := False;
    if (Assigned(Parser)) then
    begin
        Result := ExecuteLineIgnore( Parser.GetLine );
    end;
end;

///***********************************************************

function TQuotedLineIgnore.ExecuteLineIgnore( const CurrentLine:String ):Boolean;
begin
    Result := False;
    if (Length(CurrentLine) > 0) and (pos( CurrentLine[1], FQuoteChars ) > 0) then
    begin
        Result := True;
    end;
end;


///***********************************************************
// Uppercase Ignore
///***********************************************************

function TUppercaseWordIgnore.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
begin
    Result := False;

    if (AnsiUpperCase(CurrentWord) = CurrentWord) then
    begin
        Result := True;
    end;
end;



///***********************************************************
// Words Containing Numbers
///***********************************************************

{$HINTS OFF}
function TNumbersIgnore.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
var
    Partial     :String;
    Count       :Integer;
    Number      :Integer;
    Index       :Integer;
begin
    Result  := False;

    Count   := 1;
    while (Count <= Length(CurrentWord)) do
    begin
        Partial := CurrentWord[Count];
        Val( Partial, Number, Index );
        if (Index = 0) then
        begin
            Result := True;
            break;
        end;
        INC(Count);
    end;
end;
{$HINTS ON}



///***********************************************************
// Abbreviations
///***********************************************************

function TAbbreviationsIgnore.ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean;
var
    Word        :String;
begin
    Result      := False;

    if (pos( '.', CurrentWord ) > 0) then
    begin
        Word    := CurrentWord;
        while (Length(Word) > 2) and (Word[2] = '.') do
        begin
            Word := Copy( Word, 3, Length(Word) - 2 );
        end;
        Result := (Length(Word) <= 2)
    end;
end;



end.
