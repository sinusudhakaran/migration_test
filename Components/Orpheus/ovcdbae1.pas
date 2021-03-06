{*********************************************************}
{*                  OVCDBAE1.PAS 4.05                    *}
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

unit ovcdbae1;
  {-Picture mask property editor for data-aware array editors}

interface

uses
  Windows, Classes, Graphics, Forms, Controls, Buttons, StdCtrls, SysUtils,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  OvcConst, OvcData;

type
  TOvcfrmDbAeSimpleMask = class(TForm)
    cbxMaskCharacter: TComboBox;
    lblPictureChars: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cbxMaskCharacterChange(Sender: TObject);
  protected
    { Private declarations }
    Mask : Char;
  end;

type
  {property editor for db array editor picture mask}
  TDbAeSimpleMaskProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes;
      override;
    function AllEqual: Boolean;
      override;
    procedure Edit;
      override;
    function GetEditLimit : Integer;
      override;
  end;


implementation


uses
  OvcSf, OvcDbAe;

{$R *.DFM}

procedure TOvcfrmDbAeSimpleMask.FormCreate(Sender: TObject);
var
  I : Word;
  S : string;
begin
  {load mask character strings}
  for I := stsmFirst to stsmLast do begin
    S := GetOrphStr(I);
    cbxMaskCharacter.Items.Add(S);
  end;
end;

procedure TOvcfrmDbAeSimpleMask.cbxMaskCharacterChange(Sender: TObject);
var
  S : string;
begin
  with cbxMaskCharacter do
    S := Items[ItemIndex];
  if Length(S) > 0 then
    Mask := S[1];
end;


{*** TDbAeSimpleMaskProperty ***}

function TDbAeSimpleMaskProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect]
end;

function TDbAeSimpleMaskProperty.AllEqual: Boolean;
begin
  Result := True;
end;

procedure TDbAeSimpleMaskProperty.Edit;
var
  SfPE : TOvcfrmDbAeSimpleMask;
  I, J : Integer;
  C    : TComponent;
  S    : string;
begin
  SfPE := TOvcfrmDbAeSimpleMask.Create(Application);
  try
    C := TComponent(GetComponent(0));
    if C is TOvcDbSimpleArrayEditor then begin
      S := TOvcDbSimpleArrayEditor(C).PictureMask;
      if Length(S) > 0 then
        SfPE.Mask := S[1];
    end;

    J := -1;
    {if only one field is selected select the combo box item}
    {that corresponds to the current mask character}
    if PropCount = 1 then begin
      with SfPE.cbxMaskCharacter do begin
        for I := 0 to Items.Count-1 do begin
          if Items[I][1] = SfPE.Mask then begin
            J := I;
            Break;
          end;
        end;
        ItemIndex := J;
      end;
    end;

    {show the form}
    SfPE.ShowModal;

    if SfPe.ModalResult = idOK then begin
      {update all selected components with new mask}
      for I := 0 to PropCount-1 do begin
        C := TComponent(GetComponent(I));
        if C is TOvcDbSimpleArrayEditor then
          TOvcDbSimpleArrayEditor(C).PictureMask := SfPE.Mask;
      end;
      Modified;
    end;
  finally
    SfPE.Free;
  end;
end;

function TDbAeSimpleMaskProperty.GetEditLimit : Integer;
begin
  Result := 1;
end;


end.
