{*********************************************************}
{* SysTools: StAbout0.pas 3.03                           *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: Version property "About Box" form           *}
{*********************************************************}

{$I StDefine.inc}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{$W-} {Windows Stack Frame}
{$X+} {Extended Syntax}

{$IFDEF Win16}
  {$G+} {286 Instructions}
  {$N+} {Numeric Coprocessor}
  {$C MOVEABLE,DEMANDLOAD,DISCARDABLE}
{$ENDIF}

unit StAbout0;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  {$IFDEF WIN16}
  WinTypes,
  WinProcs,
  {$ENDIF}
  {$IFDEF VERSION6}
  DesignIntf,
  DesignEditors,
  {$ELSE}
  DsgnIntf,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, StConst;

type
  TStAboutForm = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lblVersion: TLabel;
    btnOK: TButton;
    Bevel1: TBevel;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TStVersionProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes;
      override;
    procedure Edit;
      override;
  end;

implementation

{$R *.DFM}


{*** TEsVersionProperty ***}

function TStVersionProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

procedure TStVersionProperty.Edit;
begin
  with TStAboutForm.Create(Application) do begin
    try
      ShowModal;
    finally
      Free;
    end;
  end;
end;


{*** TStAboutForm ***}

procedure TStAboutForm.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TStAboutForm.FormCreate(Sender: TObject);
begin
  Top := (Screen.Height - Height) div 3;
  Left := (Screen.Width - Width) div 2;
  lblVersion.Caption := 'Version ' + StVersionStr;
end;

end.
