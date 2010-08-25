{*********************************************************}
{*                  OVCXFRC0.PAS 4.05                    *}
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

unit ovcxfrc0;
  {-transfer component editor}


interface

uses
  Windows, Classes,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  ExtCtrls, Forms, Messages, StdCtrls, SysUtils, OvcData;

type
  {component editor for the transfer component}
  TOvcTransferEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index : Integer);
      override;
    function GetVerb(Index : Integer): AnsiString;
      override;
    function GetVerbCount : Integer;
      override;
  end;


implementation

uses
  OvcConst, OvcEF, OvcRLbl, OvcXfer, OvcXfrC1;


{*** TOvcTransferEditor ***}

procedure TOvcTransferEditor.ExecuteVerb(Index : Integer);
var
  frmTransfer : TOvcfrmTransfer;
  I           : Integer;
  Len         : Integer;
  L           : TList;
  C           : TComponent;
  S           : string;
begin
  if Index = 0 then begin
    with TOvcTransfer(Component) do begin
      L := TList.Create;
      try
        frmTransfer := TOvcfrmTransfer.Create(Application);
        try
          {get list of components that are involved in transfer}
          GetTransferList(L);

          with frmTransfer do begin
            {find longest name in list}
            Len := 0;
            for I := 0 to L.Count-1 do begin
              C := TComponent(L[I]);
              if Length(C.Name) > Len then
                Len := Length(C.Name);
            end;

            {force handle creation}
            frmTransfer.HandleNeeded;
            lbAllComponents.HandleNeeded;
            lbAllComponents.Clear;

            {fill ListBox with component and class names}
            for I := 0 to L.Count-1 do begin
              C := TComponent(L[I]);
              S := C.Name + ':' + #9 + C.ClassName;
              lbAllComponents.Items.Add(S);
            end;
            lbAllComponents.SetTabStops([Len+5]);
          end;
          {tell property editor form the components form}
          frmTransfer.ComponentForm := Component.Owner;

          {let form use our component list}
          frmTransfer.ComponentList := L;

          {display the form}
          frmTransfer.ShowModal;
        finally
          frmTransfer.Free;
        end;
      finally
        L.Free;
      end;
    end;
  end;
end;

function TOvcTransferEditor.GetVerb(Index : Integer) : AnsiString;
begin
  Result := 'Generate Transfer Buffer...';
end;

function TOvcTransferEditor.GetVerbCount : Integer;
begin
  Result := 1;
end;


end.
