{*********************************************************}
{*                  OVCLKOU0.PAS 4.05                    *}
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

unit ovclkou0;
  {-component editor for the LookoutBars}

interface

uses
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  Forms, SysUtils, OvcData, OvcBase, OvcLkOut, OvcLkOu1, OvcColE0;

type
  TOvcLookoutBarEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index : Integer);
      override;
    function GetVerb(Index : Integer) : string;
      override;
    function GetVerbCount : Integer;
      override;
  end;

  {
  TO32LookoutBarEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index : Integer);
      override;
    function GetVerb(Index : Integer) : string;
      override;
    function GetVerbCount : Integer;
      override;
  end;
  }


implementation


{*** TOvcLookoutBarEditor ***}

procedure TOvcLookoutBarEditor.ExecuteVerb(Index : Integer);
begin
  case Index of
{$IFDEF VERSION5}
    0 : ShowCollectionEditor(Designer,
                            (Component as TOvcLookOutBar).FolderCollection,
                            IsInInLined);
{$ELSE}
    0 : ShowCollectionEditor(Designer, (Component as TOvcLookOutBar).FolderCollection);
{$ENDIF}
    1 : EditLookOut(Designer, (Component as TOvcLookOutBar));
  end;
end;

function TOvcLookoutBarEditor.GetVerb(Index : Integer) : string;
begin
  case Index of
    0 : Result := 'Edit Folders...';
    1 : Result := 'Layout Tool...';
  end;
end;

function TOvcLookoutBarEditor.GetVerbCount : Integer;
begin
  Result := 2;
end;


{*** TO32LookoutBarEditor ***}


//procedure TO32LookoutBarEditor.ExecuteVerb(Index : Integer);
//begin
(*  case Index of
{$IFDEF VERSION5}
    0 : ShowCollectionEditor(Designer,
                            (Component as TO32LookOutBar).FolderCollection,
                            IsInInLined);
{$ELSE}
    0 : ShowCollectionEditor(Designer, (Component as TO32LookOutBar).FolderCollection);
{$ENDIF}
    1 : EditLookOut(Designer, (Component as TO32LookOutBar));
  end;
*)
//end;

//function TO32LookoutBarEditor.GetVerb(Index : Integer) : string;
//begin
(*  case Index of
    0 : Result := 'Edit Folders...';
    1 : Result := 'Layout Tool...';
  end;
*)
//end;

//function TO32LookoutBarEditor.GetVerbCount : Integer;
//begin
//  Result := 2;
//end;

end.
