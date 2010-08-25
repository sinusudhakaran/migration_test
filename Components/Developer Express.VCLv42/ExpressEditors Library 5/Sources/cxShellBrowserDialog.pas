
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxShellBrowserDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  cxShellCommon, cxSHellControls,
  cxShellDlgs, cxShellBrowser, cxLookAndFeels;

type
  { TcxCustomShellBrowserDialog }

  TcxCustomShellBrowserDialog = class(TComponent)
  private
    FDlg: TcxShellBrowserDlg;
    FFolderCaption: string;
    FLookAndFeel: TcxLookAndFeel;
    FPath: string;
    FRoot: TcxDlgShellRoot;
    FShButtons: Boolean;
    FShellOptions: TcxDlgShellOptions;
    FShInfoTips: Boolean;
    FShShowLines: Boolean;
    FShShowRoot: Boolean;
    FTitle: string;
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
  protected
    function CreateForm: TcxShellBrowserDlg; dynamic;
    property FolderLabelCaption: string read FFolderCaption write FFolderCaption;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    property Options: TcxDlgShellOptions read fShellOptions write fShellOptions;
    property Path: string read fPath write fPath;
    property Root: TcxDlgShellRoot read fRoot write fRoot;
    property ShowButtons: Boolean read FShButtons write FShButtons default True;
    property ShowInfoTips: Boolean read FShInfoTips write FShInfoTips default False;
    property ShowLines: Boolean read fShShowLines write fShShowLines default True;
    property ShowRoot: Boolean read FShShowRoot write FShShowRoot default True;
    property Title: string read FTitle write FTitle;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
  end;

  { TcxShellBrowserDialog } 

  TcxShellBrowserDialog = class(TcxCustomShellBrowserDialog)
  published
    property FolderLabelCaption;
    property LookAndFeel;
    property Options;
    property Path;
    property Root;
    property ShowButtons;
    property ShowInfoTips;
    property ShowLines;
    property ShowRoot;
    property Title;
  end;

implementation

{ TcxCustomShellBrowser }

constructor TcxCustomShellBrowserDialog.Create(aOwner: TComponent);
begin
  inherited;
  fShellOptions := TcxDlgShellOptions.Create;
  fRoot := TcxDlgShellRoot.Create;
  Title := '';
  FShShowRoot := True;
  FShButtons := True;
  fShShowLines := True;
  FLookAndFeel := TcxLookAndFeel.Create(Self);
end;

destructor TcxCustomShellBrowserDialog.Destroy;
begin
  FreeAndNil(FLookAndFeel);
  fRoot.Free;
  fShellOptions.Free;
  inherited;
end;

function TcxCustomShellBrowserDialog.Execute: Boolean;
var
  vOc: TCursor;
begin
  vOc := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    FDlg := CreateForm;
    with FDlg do
    begin
      if Length(Title) > 0 then
        DlgCaption := Title;
      if Length(FFolderCaption) > 0 then
        DlgFolderLabelCaption := FFolderCaption;
      DlgOptions.ShowFolders := fShellOptions.ShowFolders;
      DlgOptions.ShowToolTip := fShellOptions.ShowToolTip;
      DlgOptions.TrackShellChanges := fShellOptions.TrackShellChanges;
      DlgOptions.ContextMenus := fShellOptions.ContextMenus;
      DlgOptions.ShowNonFolders := fShellOptions.ShowNonFolders;
      DlgOptions.ShowHidden := fShellOptions.ShowHidden;
      DlgRoot.BrowseFolder := fRoot.BrowseFolder;
      DlgRoot.CustomPath := fRoot.CustomPath;
      DlgShowButtons := ShowButtons;
      DlgShowInfoTips := ShowInfoTips;
      DlgShowLines := ShowLines;
      DlgShowRoot := ShowRoot;
      DlgFolder := fPath;
      FDlg.LookAndFeel.MasterLookAndFeel := Self.LookAndFeel;
      Result := ShowModal = idOk;
      if Result then
        fPath := FDlg.DlgFolder;
    end;
  finally
    FreeAndNil(FDlg);
    Screen.Cursor := vOc;
  end;
end;

function TcxCustomShellBrowserDialog.CreateForm: TcxShellBrowserDlg;
begin
  Result := TcxShellBrowserDlg.Create(Application);
end;

procedure TcxCustomShellBrowserDialog.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
end;

end.
