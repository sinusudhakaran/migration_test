{*********************************************************}
{*                  OVCABOT0.PAS 4.05                    *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit Ovcabot0;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  ExtCtrls, OvcVer, OvcURL;

type
  TOvcfrmAboutForm = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lblVersion: TLabel;
    btnOK: TButton;
    Bevel1: TBevel;
    OvcURL1: TOvcURL;
    OvcURL2: TOvcURL;
    OvcURL3: TOvcURL;
    OvcURL4: TOvcURL;
    OvcURL5: TOvcURL;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TOvcAboutProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes;
      override;
    procedure Edit;
      override;
  end;

implementation

{$R *.DFM}


{*** TOrAboutProperty ***}

function TOvcAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

procedure TOvcAboutProperty.Edit;
begin
  with TOvcfrmAboutForm.Create(Application) do begin
    try
      ShowModal;
    finally
      Free;
    end;
  end;
end;


{*** TEsAboutForm ***}

procedure TOvcfrmAboutForm.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TOvcfrmAboutForm.FormCreate(Sender: TObject);
begin
  Top := (Screen.Height - Height) div 3;
  Left := (Screen.Width - Width) div 2;

  lblVersion.Caption := 'Version ' + Copy(OrVersionStr, 2, 10);

  OvcURL1.Cursor := crHandPoint;
  OvcURL2.Cursor := crHandPoint;
  OvcURL3.Cursor := crHandPoint;
  OvcURL4.Cursor := crHandPoint;
  OvcURL5.Cursor := crHandPoint;
end;

end.
 
