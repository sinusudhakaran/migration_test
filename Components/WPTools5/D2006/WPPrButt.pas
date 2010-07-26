unit WpPrButt;
{$I WPINC.INC}

{$IFDEF VER130}
   {$UNDEF DELPHI6ANDUP}  // Delphi 5 or BCB5
{$ENDIF}

interface

uses Windows, SysUtils, Messages, Classes, Graphics,
 {$ifdef DELPHI6ANDUP} DesignIntf, DesignEditors, {$else} DsgnIntf, {$endif} Controls,
  Forms, Dialogs, StdCtrls,  Buttons, ExtCtrls, 
  WPTbar, WPPanel, WPCtrMemo, WPCTRRich;

type
  TWPButtonPropDlg = class(TForm)
    WPToolBar1: TWPToolBar;
    Panel1: TPanel;
    Bevel1: TBevel;
    Definition: TLabel;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    procedure WPToolBar1IconSelection(Sender: TObject; var Typ: TWpSelNr;
      const str: String; const group, num, index: Integer);
    procedure FormCreate(Sender: TObject);
  public
    { Public-Deklarationen }
    FGroup, FNumber : Integer;
  end;

type
  TWPSpeedButtonProperty = class( TPropertyEditor )
  private
     WPButtonPropDlg: TWPButtonPropDlg;
     Fvalue : string;
  public
       function   GetAttributes: TPropertyAttributes; override;
       procedure  Edit; override;
       procedure  SetValue(const Value: string); override;
       function   GetValue :  String; override;
  end;


implementation

{$R *.DFM}

function TWPSpeedButtonProperty.GetAttributes: TPropertyAttributes;
begin
	Result := [paDialog];
end;

procedure TWPSpeedButtonProperty.SetValue(const Value: string);
var
 ed: TPersistent;
begin
     FValue := Value;
     ed := GetComponent(0);
     if ed<>nil then
     begin
       if ed is TWPToolButton then
	  (ed as TWPToolButton).StyleName := Value;
     end;
end;

function  TWPSpeedButtonProperty.GetValue :  String;
var
 ed: TPersistent;
begin
     ed := GetComponent(0);
     if ed<>nil then
     begin
       if ed is TWPToolButton then
	  Result := (ed as TWPToolButton).StyleName;
     end else Result := FValue;
end;

procedure TWPSpeedButtonProperty.Edit;
var
 ed: TPersistent;
begin
   try
     WPButtonPropDlg :=  TWPButtonPropDlg.Create(Application);

     ed := GetComponent(0);
     if ed<>nil then
     begin
       if ed is TWPToolButton then
	  WPButtonPropDlg.Definition.Caption := (ed as TWPToolButton).StyleName;
    end;
     if WPButtonPropDlg.ShowModal = IDOK then   { will only change the first item }
     begin
	 FValue := WPButtonPropDlg.Definition.Caption;
	 ed := GetComponent(0);
	 if ed<>nil then
	 begin
	   if ed is TWPToolButton then with (ed as TWPToolButton) do
	   begin
            StyleName   := '';
	    StyleGroup  := WPButtonPropDlg.FGroup;
	    StyleNumber := WPButtonPropDlg.FNumber;
	    StyleName    := FValue;
	   end;
	   Modified;
	 end;
     end;
   finally
     WPButtonPropDlg.Free;
   end;
end;

procedure TWPButtonPropDlg.WPToolBar1IconSelection(Sender: TObject;
  var Typ: TWpSelNr; const str: String; const group, num, index: Integer);
begin
   Definition.Caption := str;
   FGroup  := group;
   FNumber := num;
end;

procedure TWPButtonPropDlg.FormCreate(Sender: TObject);
begin
  WPToolBar1.UseSameGroupForAllButtons := TRUE;

end;


end.
