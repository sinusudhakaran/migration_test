{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10847: ad3ParserBase.pas 
{
{   Rev 1.5    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.4    20/12/2004 3:24:22 pm  Glenn
}
{
{   Rev 1.3    2/21/2004 11:59:46 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    12/3/2003 1:03:34 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.1    11/25/2003 9:14:16 PM  mnovak
{ Added TControlParser2 interface
}
{
{   Rev 1.0    8/25/2003 1:01:44 AM  mnovak
}
{
{   Rev 1.2    12/17/2002 6:01:06 PM  mnovak
{ Added documentation Hints for Time2Help
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

Base class for edit control parsers and other parsing entities

History:
7/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ParserBase;

{$I addict3.inc}

interface

uses
    classes, windows;

const
    ReplacementState_Replace            = 0;
    ReplacementState_ReplaceAll         = 1;
    ReplacementState_AutoCorrect        = 2;
    ReplacementState_Replace_Undo       = 3;
    ReplacementState_ReplaceAll_Undo    = 4;
    ReplacementState_AutoCorrect_Undo   = 5;

    IgnoreState_Ignore              = 10;
    IgnoreState_IgnoreAll           = 11;
    IgnoreState_Add                 = 12;

    UndoState_AddUndo               = 0;
    UndoState_BeforeUndo            = 1;
    UndoState_AfterUndo             = 2;

    CheckType_Selected              = 0;
    CheckType_FromCursor            = 1;
    CheckType_All                   = 2;
    CheckType_Current               = 3;
    CheckType_Smart                 = 4;

type

    TPositionType   = ( ptCurrent, ptEnd );

    //************************************************************
    // Parser Class
    //************************************************************

    TControlParser = class(TObject)
    public
        procedure Initialize( EditControl:Pointer ); virtual; abstract;
        function GetChar : char; virtual; abstract;
        function GetLine : String; virtual; abstract;
        function MoveNext : Boolean; virtual; abstract;
        function MovePrevious : Boolean; virtual; abstract;
        procedure SetPosition( XPos:LongInt; YPos:LongInt; PosType:TPositionType ); virtual; abstract;
        procedure GetPosition( var XPos:LongInt; var YPos:LongInt ); virtual; abstract;
        procedure SelectWord( Length:LongInt ); virtual; abstract;
        procedure ReplaceWord( Replacement:String; State:LongInt ); virtual; abstract;
        procedure IgnoreWord( State:LongInt ); virtual; abstract;
        procedure CenterSelection; virtual; abstract;
        procedure GetCursorPosition( var XPos:LongInt; var YPos:LongInt ); virtual; abstract;
        procedure GetSelectionPosition( var XPosStart:LongInt; var YPosStart:LongInt; var XPosEnd:LongInt; var YPosEnd:LongInt ); virtual; abstract;
        procedure GetControlScreenPosition( var ControlPosition:TRect ); virtual; abstract;
        procedure GetSelectionScreenPosition( var SelectionPosition:TRect ); virtual; abstract;
        procedure UndoLast( UndoState:LongInt; UndoAction:LongInt; var UndoData:LongInt ); virtual; abstract;
    end;

    TControlParser2 = class(TControlParser)
    public
        function GetControl:TComponent; virtual; abstract;
    end;

    //************************************************************
    // Ignore Entity
    //************************************************************

    TParserIgnore = class(TObject)
    public
        function NeededBeforeCheck:Boolean; virtual; abstract;
        function LineCheckNeeded:Boolean; virtual; abstract;
        function ExecuteIgnore( CurrentChar:Char; Parser:TControlParser ):Boolean; virtual; abstract;
        function ExecuteWordIgnorePreCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; virtual; abstract;
        function ExecuteWordIgnorePostCheck( const CurrentWord:String; Parser:TControlParser ):Boolean; virtual; abstract;
        function ExecuteLineIgnore( const CurrentLine:String ):Boolean; virtual; abstract;
    end;

    //************************************************************
    // Parsing Engine
    //************************************************************

    TInlineIgnoreEvent  = procedure( CurrentChar:Char; Parser:TControlParser; var Ignore:Boolean ) of object;
    TWordIgnoreEvent    = procedure( const Word:String; Parser:TControlParser; var Ignore:Boolean ) of object;

    TParsingEngine = class(TObject)
    protected
        FOnInlineIgnore     :TInlineIgnoreEvent;
        FOnPreCheckIgnore   :TWordIgnoreEvent;
    public
        procedure Initialize( Parser:TControlParser; CheckType:LongInt ); virtual; abstract;
        procedure AdjustToPosition( XPos:LongInt; YPos:LongInt ); virtual; abstract;
        function NextWord:String; virtual; abstract;

        //#<Events>
        property OnInlineIgnore:TInlineIgnoreEvent read FOnInlineIgnore write FOnInlineIgnore;
        property OnPreCheckIgnore:TWordIgnoreEvent read FOnPreCheckIgnore write FOnPreCheckIgnore;
        //#</Events>
    end;

implementation

end.

