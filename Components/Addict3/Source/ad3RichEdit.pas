{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10851: ad3RichEdit.pas 
{
{   Rev 1.4    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:24 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:48 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:34 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:46 AM  mnovak
}
{
{   Rev 1.4    12/17/2002 6:01:06 PM  mnovak
{ Added documentation Hints for Time2Help
}
{
{   Rev 1.3    12/17/2002 1:07:06 PM  mnovak
{ Expose AggressiveContextMenu property
}
{
{   Rev 1.2    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.1    7/29/2002 11:59:56 PM  mnovak
{ Added requested OnWordCheck event
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

Livespell enabled RichEdit component

History:
11/11/00    - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3RichEdit;

{$I addict3.inc}

interface

uses
    ComCtrls, messages, classes, graphics, richedit, windows,
    ad3Util,
    ad3ParserBase,
    ad3LiveRichEdit,
    ad3SpellBase;

type
    //************************************************************
    // Livespell enabled RichEdit component
    //************************************************************

    TAddictRichEdit = class(TRichEdit)
    private
        procedure WMCreate(var Message: TWMCreate); message WM_CREATE;
        procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
        procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
        procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
        procedure WMSize(var Message: TWMSize); message WM_SIZE;
        procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
        {$IFDEF UsingDelphi4}
        procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
        {$ENDIF}
        procedure EMSetReadOnly(var Message: TMessage); message EM_SETREADONLY;
        procedure EMSetTargetDevice(var Message:TMessage); message EM_SETTARGETDEVICE;

    protected
        FLiveInterface  :TAddictLiveRichEdit;

        procedure Notification( AComponent:TComponent; Operation:TOperation ); override;
        procedure KeyPress(var Key: Char); override;
        procedure SelectionChange; override;

        function ReadParsingEngine:TParsingEngine; virtual;
        procedure WriteParsingEngine( NewParsingEngine:TParsingEngine ); virtual;
        function ReadExpansionChars:String; virtual;
        procedure WriteExpansionChars( NewChars:String ); virtual;
        function ReadIrregularLineHeights:Boolean; virtual;
        procedure WriteIrregularLineHeights( NewValue:Boolean ); virtual;
        function ReadIrregularLeftMargin:Boolean; virtual;
        procedure WriteIrregularLeftMargin( NewValue:Boolean ); virtual;
        function ReadAggressiveContextMenu:Boolean; virtual;
        procedure WriteAggressiveContextMenu( NewValue:Boolean ); virtual;
        function ReadLiveSpelling:Boolean; virtual;
        procedure WriteLiveSpelling( Live:Boolean ); virtual;
        function ReadLiveCorrect:Boolean; virtual;
        procedure WriteLiveCorrect( Correct:Boolean ); virtual;
        function ReadAddictSpell:TAddictSpell3Base; virtual;
        procedure WriteAddictSpell( Addict:TAddictSpell3Base ); virtual;
        function ReadLiveSpellingColor:TColor; virtual;
        procedure WriteLiveSpellingColor( NewColor:TColor ); virtual;
        function ReadDoubleBuffered:Boolean; virtual;
        procedure WriteDoubleBuffered( Buffered:Boolean ); virtual;
        function ReadLiveSpellingOptions:Boolean; virtual;
        procedure WriteLiveSpellingOptions( UseOptions:Boolean ); virtual;
        function ReadLiveMenuOptions:TSpellPopupOptions; virtual;
        procedure WriteLiveMenuOptions( NewOptions:TSpellPopupOptions ); virtual;
        function ReadLiveReadOnly:Boolean; virtual;
        procedure WriteLiveReadOnly( NewReadOnly:Boolean ); virtual;
        function ReadVersion:String;
        procedure WriteVersion( NewVersion:String );
        function ReadOnWordCheck:TWordCheckEvent; virtual;
        procedure WriteOnWordCheck( NewEvent:TWordCheckEvent ); virtual;

    public
        {$IFNDEF T2H}
        constructor Create( AOwner:TComponent ); override;
        destructor Destroy; override;
        {$ENDIF}

        procedure Check( CheckType:TCheckType ); virtual;

        // Public properties

        property ParsingEngine:TParsingEngine read ReadParsingEngine write WriteParsingEngine;
        property ExpansionChars:String read ReadExpansionChars write WriteExpansionChars;
        property IrregularLineHeights:Boolean read ReadIrregularLineHeights write WriteIrregularLineHeights;
        property IrregularLeftMargin:Boolean read ReadIrregularLeftMargin write WriteIrregularLeftMargin;
        property AggressiveContextMenu:Boolean read ReadAggressiveContextMenu write WriteAggressiveContextMenu;

    published
        property LiveSpelling:Boolean read ReadLiveSpelling write WriteLiveSpelling;
        property LiveCorrect:Boolean read ReadLiveCorrect write WriteLiveCorrect;
        property AddictSpell:TAddictSpell3Base read ReadAddictSpell write WriteAddictSpell;
        property LiveSpellingColor:TColor read ReadLiveSpellingColor write WriteLiveSpellingColor;
        property DoubleBuffered:Boolean read ReadDoubleBuffered write WriteDoubleBuffered;
        property LiveSpellingOptions:Boolean read ReadLiveSpellingOptions write WriteLiveSpellingOptions;
        property LiveMenuOptions:TSpellPopupOptions read ReadLiveMenuOptions write WriteLiveMenuOptions;
        property LiveSpellingReadOnly:Boolean read ReadLiveReadOnly write WriteLiveReadOnly;

        property Version:String read ReadVersion write WriteVersion stored false;

        //#<Events>
        property OnWordCheck:TWordCheckEvent read ReadOnWordCheck write WriteOnWordCheck;
        //#</Events>
    end;


implementation



//************************************************************
// TAddictRichEdit
//************************************************************

constructor TAddictRichEdit.Create( AOwner:TComponent );
begin
    inherited Create( AOwner );

    FLiveInterface              := TAddictLiveRichEdit.Create;

    CheckStandardVersion;
    CheckTrialVersion;
end;

//************************************************************

destructor TAddictRichEdit.Destroy;
begin
    FLiveInterface.Free;

    inherited Destroy;
end;

//************************************************************

procedure TAddictRichEdit.Notification( AComponent:TComponent; Operation:TOperation );
begin
    FLiveInterface.Notification( AComponent, Operation );

    inherited Notification( AComponent, Operation );
end;

//************************************************************

procedure TAddictRichEdit.KeyPress(var Key: Char);
begin
    inherited;

    FLiveInterface.KeyPress( Key );
end;

//************************************************************

procedure TAddictRichEdit.SelectionChange;
begin
    inherited;

    FLiveInterface.NotifySelectionChange;
end;

//************************************************************

procedure TAddictRichEdit.WMCreate(var Message: TWMCreate);
begin
    inherited;

    if not(assigned(FLiveInterface.WinControl))  then
    begin
        FLiveInterface.WinControl := Self;
    end;
end;

//************************************************************

procedure TAddictRichEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
    if (FLiveInterface.WMEraseBkgnd( Message )) then
    begin
        inherited;
    end;
end;

//************************************************************

procedure TAddictRichEdit.WMPaint(var Message: TWMPaint);
var
    Cleanup :Boolean;
begin
    if (FLiveInterface.WMPaint( Message, Cleanup )) then
    begin
        inherited;
    end;
    if (Cleanup) then
    begin
        FLiveInterface.WMPaintCleanup( Message );
    end;
end;

//************************************************************

procedure TAddictRichEdit.WMContextMenu(var Message: TWMContextMenu);
begin
    if (FLiveInterface.WMContextMenu(Message)) then
    begin
        inherited;
    end;
end;

//************************************************************

procedure TAddictRichEdit.WMSize(var Message: TWMSize);
begin
    FLiveInterface.WMSize(Message);
    inherited;
end;

//************************************************************

procedure TAddictRichEdit.WMKeyUp(var Message: TWMKeyUp);
begin
    FLiveInterface.WMKeyUp(Message);
    inherited;
end;

//************************************************************

{$IFDEF UsingDelphi4}
procedure TAddictRichEdit.WMRButtonUp(var Message: TWMRButtonUp);
begin
    if (FLiveInterface.WMRButtonUp( Message )) then
    begin
        inherited;
    end;
end;
{$ENDIF}

//************************************************************

procedure TAddictRichEdit.EMSetReadOnly(var Message: TMessage);
begin
    inherited;
    FLiveInterface.EMSetReadOnly;
end;

//************************************************************

procedure TAddictRichEdit.EMSetTargetDevice(var Message:TMessage);
begin
    FLiveInterface.EMSetTargetDevice;
    inherited;
end;

//************************************************************

procedure TAddictRichEdit.Check( CheckType:TCheckType );
var
    OldHideSel  :Boolean;
begin
    OldHideSel      := HideSelection;
    HideSelection   := False;

    FLiveInterface.Check( CheckType );

    HideSelection   := OldHideSel;
end;


//************************************************************
// Simple property read/write functions
//************************************************************

function TAddictRichEdit.ReadParsingEngine:TParsingEngine;
begin
    Result := FLiveInterface.ParsingEngine;
end;

procedure TAddictRichEdit.WriteParsingEngine( NewParsingEngine:TParsingEngine );
begin
    FLiveInterface.ParsingEngine := NewParsingEngine;
end;

function TAddictRichEdit.ReadExpansionChars:String;
begin
    Result := FLiveInterface.ExpansionChars;
end;

procedure TAddictRichEdit.WriteExpansionChars( NewChars:String );
begin
    FLiveInterface.ExpansionChars := NewChars;
end;

function TAddictRichEdit.ReadIrregularLineHeights:Boolean;
begin
    Result := FLiveInterface.IrregularLineHeights;
end;

procedure TAddictRichEdit.WriteIrregularLineHeights( NewValue:Boolean );
begin
    FLiveInterface.IrregularLineHeights := NewValue;
end;

function TAddictRichEdit.ReadIrregularLeftMargin:Boolean;
begin
    Result := FLiveInterface.IrregularLeftMargin;
end;

procedure TAddictRichEdit.WriteIrregularLeftMargin( NewValue:Boolean );
begin
    FLiveInterface.IrregularLeftMargin := NewValue;
end;

function TAddictRichEdit.ReadAggressiveContextMenu:Boolean;
begin;
    Result := FLiveInterface.AggressiveContextMenu;
end;

procedure TAddictRichEdit.WriteAggressiveContextMenu( NewValue:Boolean );
begin
    FLiveInterface.AggressiveContextMenu := NewValue;
end;

function TAddictRichEdit.ReadLiveSpelling:Boolean;
begin
    Result := FLiveInterface.LiveSpelling;
end;

procedure TAddictRichEdit.WriteLiveSpelling( Live:Boolean );
begin
    FLiveInterface.LiveSpelling := Live;
end;

function TAddictRichEdit.ReadLiveCorrect:Boolean;
begin
    Result := FLiveInterface.LiveCorrect;
end;

procedure TAddictRichEdit.WriteLiveCorrect( Correct:Boolean );
begin
    FLiveInterface.LiveCorrect := Correct;
end;

function TAddictRichEdit.ReadAddictSpell:TAddictSpell3Base;
begin
    Result := FLiveInterface.AddictSpell;
end;

procedure TAddictRichEdit.WriteAddictSpell( Addict:TAddictSpell3Base );
begin
    FLiveInterface.AddictSpell := Addict;
end;

function TAddictRichEdit.ReadLiveSpellingColor:TColor;
begin
    Result := FLiveInterface.LiveSpellingColor;
end;

procedure TAddictRichEdit.WriteLiveSpellingColor( NewColor:TColor );
begin
    FLiveInterface.LiveSpellingColor := NewColor;
end;

function TAddictRichEdit.ReadDoubleBuffered:Boolean;
begin
    Result := FLiveInterface.DoubleBuffered;
end;

procedure TAddictRichEdit.WriteDoubleBuffered( Buffered:Boolean );
begin
    FLiveInterface.DoubleBuffered := Buffered;
end;

function TAddictRichEdit.ReadLiveSpellingOptions:Boolean;
begin
    Result := FLiveInterface.LiveSpellingOptions;
end;

procedure TAddictRichEdit.WriteLiveSpellingOptions( UseOptions:Boolean );
begin
    FLiveInterface.LiveSpellingOptions := UseOptions;
end;

function TAddictRichEdit.ReadLiveMenuOptions:TSpellPopupOptions;
begin
    Result := FLiveInterface.LiveMenuOptions;
end;

procedure TAddictRichEdit.WriteLiveMenuOptions( NewOptions:TSpellPopupOptions );
begin
    FLiveInterface.LiveMenuOptions := NewOptions;
end;

function TAddictRichEdit.ReadLiveReadOnly:Boolean;
begin
    Result := FLiveInterface.LiveSpellingReadOnly;
end;

procedure TAddictRichEdit.WriteLiveReadOnly( NewReadOnly:Boolean );
begin
    FLiveInterface.LiveSpellingReadOnly := NewReadOnly;
end;

function TAddictRichEdit.ReadVersion:String;
begin
    Result := GetAddictVersion;
end;

procedure TAddictRichEdit.WriteVersion( NewVersion:String );
begin
end;

function TAddictRichEdit.ReadOnWordCheck:TWordCheckEvent;
begin
    Result := FLiveInterface.OnWordCheck;
end;

procedure TAddictRichEdit.WriteOnWordCheck( NewEvent:TWordCheckEvent );
begin
    FLiveInterface.OnWordCheck := NewEvent;
end;

//************************************************************

end.
