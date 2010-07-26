{***************************************************************************}
{ TDateLabel component                                                      }
{ for Delphi & C++Builder                                                   }
{ version 1.1                                                               }
{                                                                           }
{ written by                                                                }
{   TMS Software                                                            }
{   Copyright © 1999-2004                                                   }
{   Email : info@tmssoftware.com                                            }
{   Web : http://www.tmssoftware.com                                        }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit datelbl;

{$I TMSDEFS.INC}
interface

{$IFDEF TMSDOTNET}
{$R TDateLabel.bmp}
{$ENDIF}

uses
 stdctrls,messages,classes,sysutils, windows, ExtCtrls;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

type
  TDateLabel = class(TLabel)
               private
                FDateTimeFormat:string;
                FTimer: TTimer;
                FRefreshInterval: Integer;
                FRefreshEnabled: Boolean;
                procedure SetFormat(const Value:string);
                function GetVersion: string;
                procedure SetVersion(const Value: string);
                Procedure SetInterval(Const Value: Integer);
                Procedure SetRefreshEnabled(Const Value: Boolean);
               protected
                function GetVersionNr: Integer; virtual;
                procedure Loaded; override;
               public
                constructor Create(AOwner: TComponent); override;
                Destructor Destroy; Override;
                Procedure RefreshLabel(Sender: TObject);
               published
                property DateTimeFormat:string read FDateTimeFormat write SetFormat;
                property Version: string read GetVersion write SetVersion;
                Property RefreshInterval: Integer Read FRefreshInterval Write SetInterval;
                Property RefreshEnabled: Boolean Read FRefreshEnabled Write SetRefreshEnabled;

               end;


procedure Register;

implementation

constructor tdatelabel.Create(AOwner: TComponent);
begin
 inherited Create(aOwner);
 caption:=datetostr(Now);
 fdatetimeformat:='d/m/yyyy';
 FRefreshInterval := 0;
 FRefreshEnabled := False;
 FTimer := TTimer.Create(Self);
 FTimer.OnTimer := Self.RefreshLabel;
end;

Destructor TDateLabel.Destroy;

Begin
  FTimer.Free;
  Inherited;
End;

Procedure TDateLabel.SetInterval(Const Value: Integer);

Begin
  FRefreshInterval := Value;
  FTimer.Interval := FRefreshInterval;
End;


Procedure TDateLabel.SetRefreshEnabled(Const Value: Boolean);

Begin
  FRefreshEnabled := Value;
  FTimer.Enabled := False;
  If FRefreshInterval > 0 Then
    FTimer.Enabled := FRefreshEnabled;
End;


Procedure TDateLabel.RefreshLabel(Sender: TObject);

Begin
  self.caption:=formatdatetime(fdatetimeformat,now);
End;

procedure TDateLabel.Loaded;
begin
 inherited;
 if (csDesigning in ComponentState) then
   self.caption:=formatdatetime(fdatetimeformat,now);
end;

procedure tdatelabel.SetFormat(const Value: string);
begin
 fDatetimeformat := value;
 if (csDesigning in ComponentState) then
   self.caption:=formatdatetime(fdatetimeformat,now);
end;

function TDateLabel.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TDateLabel.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TDateLabel.SetVersion(const Value: string);
begin

end;

procedure Register;
begin
 RegisterComponents('TMS', [TDateLabel]);
end;


end.

