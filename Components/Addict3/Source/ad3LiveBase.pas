{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10837: ad3LiveBase.pas 
{
{   Rev 1.4    1/27/2005 2:14:18 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:14 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:42 PM  mnovak
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
{   Rev 1.3    12/17/2002 6:31:16 PM  mnovak
{ Corrected compiler hint.
}
{
{   Rev 1.2    12/17/2002 9:36:10 AM  mnovak
{ Fix WriteLiveControl to preserve the current LiveSpelling/LiveCorrect state
{ on subsequent calls.
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

LiveSpell base class integration component

History:
11/12/00    - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3LiveBase;

{$I addict3.inc}

interface

uses
    windows, sysutils, classes, controls,
    ad3Configuration,
    ad3Spell,
    ad3SpellBase,
    ad3ParserBase;

type
    //************************************************************
    // LiveSpell base class integration component
    //************************************************************

    TLiveAddictSpellBase = class(TAddictSpell3)
    protected
        FLiveControl            :TWinControl;
        FLiveSpell              :Boolean;
        FLiveCorrect            :Boolean;
        FLiveMenuOptions        :TSpellPopupOptions;
        FLiveOptions            :Boolean;

        FLiveEnabled            :Boolean;
        FCorrectEnabled         :Boolean;
        FFirstLiveControl       :Boolean;

        FMenuShowing            :Boolean;
        FRemovingComponent      :Boolean;

    protected
        procedure Notification( AComponent:TComponent; Operation:TOperation ); override;

        procedure ResynchOptions( ForceRefresh:Boolean ); override;

        procedure CheckSelected; virtual; abstract;
        procedure StartLiveSpell; virtual; abstract;
        procedure StopLiveSpell; virtual; abstract;
        procedure StartLiveCorrect; virtual; abstract;
        procedure StopLiveCorrect; virtual; abstract;

        function ShowMenu( Parser:TControlParser; var Word:String ):TSpellPopupOption; virtual;

        procedure WriteLiveControl( Control:TWinControl ); virtual;
        procedure WriteLiveSpelling( Live:Boolean ); virtual;
        procedure WriteLiveCorrect( Correct:Boolean ); virtual;
        procedure WriteLiveOptions( Options:Boolean ); virtual;

        procedure EnableLiveSpell( Enabled:Boolean ); virtual;
        procedure EnableLiveCorrect( Enabled:Boolean ); virtual;

    public
        {$IFNDEF T2H}
        constructor Create(AOwner:TComponent); override;
        {$ENDIF}

        {$IFNDEF T2H}
        function CheckWord( Word:String ):Boolean; virtual;
        {$ENDIF}

    protected   // derived classes will publish

        property LiveSpelling:Boolean read FLiveSpell write WriteLiveSpelling;
        property LiveCorrect:Boolean read FLiveCorrect write WriteLiveCorrect;
        property LiveMenuOptions:TSpellPopupOptions read FLiveMenuOptions write FLiveMenuOptions;
        property LiveSpellingOptions:Boolean read FLiveOptions write WriteLiveOptions;
    end;



implementation


//************************************************************
// AddictSpell 3rd party integration component
//************************************************************

constructor TLiveAddictSpellBase.Create(AOwner:TComponent);
begin
    inherited Create(AOwner);

    FLiveControl            := nil;
    FLiveSpell              := True;
    FLiveCorrect            := True;
    FLiveMenuOptions        := [spDialog, spAutoCorrect, spChangeAll, spAdd, spIgnore, spIgnoreAll, spReplace];
    FLiveOptions            := True;

    FLiveEnabled            := False;
    FCorrectEnabled         := False;
    FFirstLiveControl       := True;

    FMenuShowing            := False;
    FRemovingComponent      := False;

    // AddictSpell overrides

    FAvailableOptions       := [ soUpcase, soNumbers, soPrimaryOnly, soRepeated, soDUalCaps, soLiveSpelling, soLiveCorrect ];
end;


//************************************************************
// Protected Notifications
//************************************************************

procedure TLiveAddictSpellBase.Notification( AComponent:TComponent; Operation:TOperation );
begin
    if (Operation = opRemove) and (AComponent = TComponent(FLiveControl)) then
    begin
        FRemovingComponent  := True;

        EnableLiveSpell( False );
        EnableLiveCorrect( False );
        FLiveControl := nil;

        FRemovingComponent  := False;
    end;
	inherited Notification( AComponent, Operation );
end;

//************************************************************

procedure TLiveAddictSpellBase.ResynchOptions( ForceRefresh:Boolean );
var
    Refresh :Boolean;
begin
    if  (csReading in ComponentState) or
        (csDesigning in ComponentState) then
    begin
        inherited;
        Exit;
    end;

    Refresh := (FOldOptions <> FConfiguration.SpellOptions) or (ForceRefresh);

    inherited;

    if Refresh and FLiveOptions then
    begin
        EnableLiveSpell( soLiveSpelling in Configuration.SpellOptions );
        EnableLiveCorrect( soLiveCorrect in Configuration.SpellOptions );
    end
end;

//************************************************************

function TLiveAddictSpellBase.CheckWord( Word:String ):Boolean;
begin
    Result := WordAcceptable( Word );
    if (FUseExclude and Result) then
    begin
        Result := not WordExcluded( Word );
    end;
end;

//************************************************************

function TLiveAddictSpellBase.ShowMenu( Parser:TControlParser; var Word:String ):TSpellPopupOption;
var
    XStart          :LongInt;
    YStart          :LongInt;
    XEnd            :LongInt;
    YEnd            :LongInt;
    SelectionRect   :TRect;
    OldEndMessage   :TSpellEndMessage;
    OldInitialPos   :TSpellDialogInitialPos;
begin
    if (FMenuShowing) then
    begin
        Result := spCancel;
        exit;
    end;

    FMenuShowing := True;

    SelectionRect := Rect( 0, 0, 0, 0 );
    Parser.Initialize( FLiveControl );
    Parser.GetSelectionPosition( XStart, YStart, XEnd, YEnd );
    Parser.SetPosition( XStart, YStart, ptCurrent );
    Parser.GetSelectionScreenPosition( SelectionRect );

    Result := ShowPopupMenu( FLiveControl, FLiveMenuOptions, SelectionRect.Left, SelectionRect.Bottom, Word );

    case (Result) of
    spDialog:
        begin
            OldEndMessage       := FEndMessage;
            FEndMessage         := emNever;
            OldInitialPos       := DialogInitialPos;
            DialogInitialPos    := ipUnderSelection;

            CheckSelected;

            DialogInitialPos    := OldInitialPos;
            FEndMessage         := OldEndMessage;
        end;
    end;

    FMenuShowing := False;
end;



//************************************************************
// Property Read/Write Functions
//************************************************************

procedure TLiveAddictSpellBase.WriteLiveControl( Control:TWinControl );
var
    OldLiveSpell    :Boolean;
    OldLiveCorrect  :Boolean;
begin
    if (Control <> FLiveControl) then
    begin
        OldLiveSpell        := FLiveEnabled    or FFirstLiveControl;
        OldLiveCorrect      := FCorrectEnabled or FFirstLiveControl;
        FFirstLiveControl   := False;

        EnableLiveSpell( False );
        EnableLiveCorrect( False );

        FLiveControl := Control;

        EnableLiveSpell( OldLiveSpell );
        EnableLiveCorrect( OldLiveCorrect );
    end;
end;

//************************************************************

procedure TLiveAddictSpellBase.WriteLiveSpelling( Live:Boolean );
begin
    if (FLiveSpell <> Live) then
    begin
        FLiveSpell  := Live;
        EnableLiveSpell( Live );
    end;
end;

//************************************************************

procedure TLiveAddictSpellBase.WriteLiveCorrect( Correct:Boolean );
begin
    if (FLiveCorrect <> Correct) then
    begin
        FLiveCorrect := Correct;
        EnableLiveCorrect( Correct );
    end;
end;

//************************************************************

procedure TLiveAddictSpellBase.WriteLiveOptions( Options:Boolean );
begin
    if (FLiveOptions <> Options) then
    begin
        FLiveOptions := Options;

        if (FLiveOptions) then
        begin
            EnableLiveSpell( soLiveSpelling in Configuration.SpellOptions );
            EnableLiveCorrect( soLiveCorrect in Configuration.SpellOptions );
        end
        else
        begin
            EnableLiveSpell( FLiveSpell );
            EnableLiveCorrect( FLiveCorrect );
        end;
    end;
end;



//************************************************************
// Utility Function
//************************************************************

procedure TLiveAddictSpellBase.EnableLiveSpell( Enabled:Boolean );
var
    Live    :Boolean;
begin
    if (FLiveOptions) then
    begin
        Live := soLiveSpelling in Configuration.SpellOptions;
    end
    else
    begin
        Live := FLiveSpell;
    end;

    if (FLiveEnabled <> Enabled) then
    begin
        if  Enabled and Assigned(FLiveControl) and Live then
        begin
            if (csDesigning in ComponentState) then
            begin
                exit;
            end;

            FLiveEnabled := True;

            StartLiveSpell;
        end;

        if not Enabled then
        begin
            FLiveEnabled := False;

            if (Assigned(FLiveControl)) then
            begin
                StopLiveSpell;
            end;
        end;
    end;
end;

//************************************************************

procedure TLiveAddictSpellBase.EnableLiveCorrect( Enabled:Boolean );
var
    Correct :Boolean;
begin
    if (FLiveOptions) then
    begin
        Correct := soLiveCorrect in Configuration.SpellOptions;
    end
    else
    begin
        Correct := FLiveCorrect;
    end;

    if (FCorrectEnabled <> Enabled) then
    begin
        if Enabled and Assigned(FLiveControl) and Correct then
        begin
            if (csDesigning in ComponentState) then
            begin
                exit;
            end;

            FCorrectEnabled := True;

            StartLiveCorrect;
        end;

        if not Enabled then
        begin
            FCorrectEnabled := False;

            if (Assigned(FLiveControl)) then
            begin
                StopLiveCorrect;
            end;
        end;
    end;
end;



end.

