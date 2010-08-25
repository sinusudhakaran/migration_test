{*********************************************************}
{*                  OVCDBAE2.PAS 4.05                    *}
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

unit ovcdbae2;
  {-Picture mask property editor for data-aware array editors}

interface

uses
  Windows, Classes, Graphics, Forms, Controls, Buttons, StdCtrls,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  SysUtils, ExtCtrls, OvcConst, OvcData, OvcExcpt, OvcMisc, OvcStr;

type
  TOvcfrmDbAePictureMask = class(TForm)
    lblMask: TLabel;
    lblMaskEdit: TLabel;
    Bevel1: TBevel;
    lblMaskDescription: TLabel;
    lblMaskList: TLabel;
    lbMask: TListBox;
    edMask: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure lbMaskClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    { Private declarations }
    Ex : TStringList;
  end;

type
  {property editor for picture masks}
  TDbAePictureMaskProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes;
      override;
    function AllEqual: Boolean;
      override;
    procedure Edit;
      override;
  end;


implementation


uses
  OvcPf, OvcDbAe;

{$R *.DFM}


{*** TDbAePictureMaskProperty ***}

type
  TLocalPF = class(TOvcCustomPictureField);

function TDbAePictureMaskProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect]
end;

function TDbAePictureMaskProperty.AllEqual: Boolean;
begin
  Result := True;
end;

procedure TDbAePictureMaskProperty.Edit;
var
  PfPE : TOvcfrmDbAePictureMask;
  I, J : Integer;
  Mask : string;
  C    : TComponent;
begin
  PfPE := TOvcfrmDbAePictureMask.Create(Application);
  try
    with PfPE do begin
      C := TComponent(GetComponent(0));
      if C is TOvcDbPictureArrayEditor then
        Mask := TOvcDbPictureArrayEditor(C).PictureMask;

      J := -1;
      {if only one field is selected select the combo box item}
      {that corresponds to the current mask character}
      if PropCount = 1 then begin
        with PfPE.lbMask do begin
          for I := 0 to Items.Count-1 do begin
            if Items[I] = Mask then begin
              J := I;
              Break;
            end;
          end;
        end;
      end else
        Mask := '';

      {show current mask at top of combo box list}
      edMask.Text := Mask;

      {set explanation text, if any}
      if J >= 0 then begin
        lbMask.ItemIndex := J;
        lblMask.Caption := Ex.Strings[J]
      end else
        lblMask.Caption := '';

      {show the form}
      ShowModal;

      if ModalResult = idOK then begin
        {update all selected components with new mask}
        for I := 1 to PropCount do begin
          C := TComponent(GetComponent(I-1));
          if C is TOvcDbPictureArrayEditor then
            TOvcDbPictureArrayEditor(C).PictureMask := edMask.Text;
        end;
        Modified;
      end;
    end;
  finally
    PfPE.Free;
  end;
end;


{*** TfrmPictureMask ***}

procedure TOvcfrmDbAePictureMask.FormCreate(Sender: TObject);
var
  I    : Word;
  S1   : string[20];
  S    : string;
begin
  {create a string list for the mask explanation strings}
  Ex := TStringList.Create;

  {load the picture mask strings from the resource file}
  for I := stnmFirst to stnmLast do begin
    {first 20 characters is the sample mask--remaining part}
    {of the string is a short description of the mask}
    S := GetOrphStr(I);
    {trim the left portion and add it to the combo box}
    S1 := Trim(Copy(S, 1, 20));
    lbMask.Items.Add(S1);
    {take the remaining portion of the string, trim it and}
    {add it to the string list}
    S := Trim(Copy(S, 21, 255));
    Ex.Add(S);
  end;
  for I := stpmFirst to stpmLast do begin
    {first 20 characters is the sample mask--remaining part}
    {of the string is a short description of the mask}
    S := GetOrphStr(I);
    {trim the left portion and add it to the combo box}
    S1 := Trim(Copy(S, 1, 20));
    lbMask.Items.Add(S1);
    {take the remaining portion of the string, trim it and}
    {add it to the string list}
    S := Trim(Copy(S, 21, 255));
    Ex.Add(S);
  end;
end;

procedure TOvcfrmDbAePictureMask.lbMaskClick(Sender: TObject);
var
  I : Integer;
begin
  I := lbMask.ItemIndex;
  if (I >= 0) and (I < Ex.Count) then begin
    lblMask.Caption := Ex.Strings[I];
    edMask.Text := lbMask.Items[I];
  end else
    lblMask.Caption := '';
end;

procedure TOvcfrmDbAePictureMask.FormDestroy(Sender: TObject);
begin
  {destroy string list}
  Ex.Free;
end;


end.
