object frmHttpsProgress: TfrmHttpsProgress
  Left = 0
  Top = 0
  Caption = 'Secure Http'
  ClientHeight = 81
  ClientWidth = 235
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 8
    Top = 8
    Width = 63
    Height = 13
    Caption = 'Processing...'
  end
  object prgProgress: TProgressBar
    Left = 8
    Top = 27
    Width = 219
    Height = 17
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 80
    Top = 50
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object ipsHTTPS: TipsHTTPS
    FirewallPort = 80
    SSLCertStore = 'MY'
    OnConnected = ipsHTTPSConnected
    OnConnectionStatus = ipsHTTPSConnectionStatus
    OnDisconnected = ipsHTTPSDisconnected
    OnEndTransfer = ipsHTTPSEndTransfer
    OnError = ipsHTTPSError
    OnHeader = ipsHTTPSHeader
    OnRedirect = ipsHTTPSRedirect
    OnSetCookie = ipsHTTPSSetCookie
    OnSSLServerAuthentication = ipsHTTPSSSLServerAuthentication
    OnSSLStatus = ipsHTTPSSSLStatus
    OnStartTransfer = ipsHTTPSStartTransfer
    OnStatus = ipsHTTPSStatus
    OnTransfer = ipsHTTPSTransfer
    Left = 184
    Top = 48
  end
end
