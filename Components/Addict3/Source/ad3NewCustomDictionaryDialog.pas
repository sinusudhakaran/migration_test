{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10843: ad3NewCustomDictionaryDialog.pas 
{
{   Rev 1.4    1/27/2005 2:14:18 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:18 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:46 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:32 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:44 AM  mnovak
}
{
{   Rev 1.3    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.2    7/29/2002 10:43:02 PM  mnovak
{ Change back to binary DFMs.
}
{
{   Rev 1.1    26/06/2002 4:45:14 pm  glenn
{ Form Fixes, Font Fix, D7 Support
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

Simple entry form for a new custom-dictionary name

History:
8/15/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3NewCustomDictionaryDialog;

{$I addict3.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ad3ConfigurationDialogCtrl;

type
  TNewCustomDictionary = class(TForm)
    EditLabel: TLabel;
    NameEdit: TEdit;
    OKButton: TButton;
    CancelButton: TButton;
    DialogControl: TConfigurationDialogCtrl;
    procedure DialogControlConfigurationAvailable(
      Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewCustomDictionary: TNewCustomDictionary;

implementation

{$R *.DFM}

uses
    ad3Spell,
    ad3SpellLanguages;

procedure TNewCustomDictionary.DialogControlConfigurationAvailable(
  Sender: TObject);
begin
    Caption                 := DialogControl.GetString( lsNewCustomTitle );

    EditLabel.Caption       := DialogControl.GetString( lsDlgNewCustom );
    OKButton.Caption        := DialogControl.GetString( lsDlgOK );
    CancelButton.Caption    := DialogControl.GetString( lsDlgCancel );

    if (TComponent(DialogControl.AddictSpell) is TAddictSpell3) then
    begin
        (TComponent(DialogControl.AddictSpell) as TAddictSpell3).SetupFormFonts( Self, False );
    end;
end;

procedure TNewCustomDictionary.FormCreate(Sender: TObject);
begin
    {$IFDEF Delphi5AndAbove}
    Position := poOwnerFormCenter;
    {$ENDIF}
end;

end.
