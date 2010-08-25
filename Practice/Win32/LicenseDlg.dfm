object DlgLicense: TDlgLicense
  Left = 367
  Top = 332
  BorderStyle = bsDialog
  Caption = 'Licence Agreement'
  ClientHeight = 317
  ClientWidth = 536
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lRead: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 6
    Width = 504
    Height = 42
    Margins.Left = 16
    Margins.Top = 6
    Margins.Right = 16
    Align = alTop
    AutoSize = False
    Caption = 
      'Please read the following Licence Agreement. Use the scroll bar ' +
      'or press the Page Down key to view the rest of the agreement.'
    WordWrap = True
    ExplicitTop = 8
    ExplicitWidth = 505
  end
  object lAccept: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 229
    Width = 504
    Height = 41
    Margins.Left = 16
    Margins.Right = 16
    Margins.Bottom = 6
    Align = alBottom
    AutoSize = False
    Caption = 
      'Do you accept all the terms of the preceding Licence Agreement? ' +
      'If you choose No, you will not be able to login. To use BankLink' +
      ' Practice you must accept this agreement.'
    WordWrap = True
    ExplicitTop = 224
    ExplicitWidth = 509
  end
  object mmoEULA: TMemo
    AlignWithMargins = True
    Left = 16
    Top = 54
    Width = 504
    Height = 169
    Margins.Left = 16
    Margins.Right = 16
    Align = alClient
    Lines.Strings = (
      'Software End-User Licence Agreement'
      'for Media Transfer Services Limited ('#8216'BankLink'#8217')'
      ''
      'Read this before proceeding:'
      ''
      '1'#9'Agreement'
      ''
      
        'This computer software, together with any supporting documentati' +
        'on '
      
        'and any modifications or amendments made by BankLink ('#8216'the Softw' +
        'are'#8217'), '
      
        'is owned by BankLink.  Provided your copy of the Software has be' +
        'en '
      
        'lawfully obtained, you are authorised to use the Software in acc' +
        'ordance '
      'with this agreement.'
      ''
      
        'By proceeding to install, store, load, execute and display (indi' +
        'vidually '
      
        'or collectively, '#8216'Use'#8217') the Software, you agree to be bound by t' +
        'he terms '
      
        'of this agreement.  If your copy of the Software has not been le' +
        'gally '
      
        'obtained or you do not agree to the terms of this agreement, do ' +
        'not '
      'install or Use the Software.'
      ''
      '2'#9'Grant of licence'
      ''
      
        'BankLink grants you a non-exclusive licence to Use the Software ' +
        'in '
      'accordance with this agreement.'
      ''
      
        'The licence will be perpetual unless terminated in accordance wi' +
        'th '
      
        'clause 7.1.  You may Use one copy of the Software on a single co' +
        'mputer.'
      ''
      '3'#9'Limitations on Use'
      ''
      
        'The Software licence is personal to you, you cannot sell, sub-li' +
        'cence, '
      
        'assign, transfer or lend the Software to any other person or ent' +
        'ity.  '
      
        'You cannot copy, alter, modify or reproduce the Software, but yo' +
        'u may '
      
        'make one copy of the Software for backup purposes only.  You can' +
        'not reverse '
      
        'assemble or reverse compile or directly or indirectly allow or c' +
        'ause a '
      
        'third party to reverse assemble or reverse compile the whole or ' +
        'any '
      'part of the Software.'
      ''
      '4'#9'Title'
      ''
      
        'All title and intellectual property rights in the Software remai' +
        'n with '
      
        'BankLink.  You will notify BankLink as soon as you become aware ' +
        'of any '
      
        'infringement, suspected infringement or alleged infringement of ' +
        'BankLink'#8217's '
      'intellectual property rights.'
      ''
      '5'#9'Warranties'
      ''
      
        'Except as otherwise agreed, BankLink is not obliged to support t' +
        'he Software, '
      
        'whether by providing advice, training, error-correction, modific' +
        'ation, '
      'new releases or enhancements or otherwise.'
      ''
      
        'To the extent permitted by law, BankLink excludes and disclaims ' +
        'all and '
      
        'any guarantees and/or warranties whether express, implied, statu' +
        'tory or '
      
        'otherwise in respect of the Software and in particular, to the e' +
        'xtent that '
      
        'they are applicable, expressly excludes the provisions of the Ne' +
        'w Zealand '
      
        'Consumer Guarantees Act 1993 pursuant to clause 43(2) thereof an' +
        'd the '
      
        'provisions of the New Zealand Sale of Goods Act 1908 pursuant to' +
        ' clause 56 '
      
        'thereof.  Where the Australian Trade Practices Act 1974 applies,' +
        ' then the '
      
        'liability of BankLink for any loss arising as a result of or in ' +
        'relation to '
      
        'the supply by BankLink of the Software, including any economic o' +
        'r consequential '
      'loss which may be sustained or incurred, shall be limited to:'
      ''
      
        '(a)'#9'The replacement of the Software or the supply of equivalent ' +
        'Software;'
      '(b)'#9'The repair of the Software;'
      
        '(c)'#9'The payment of the cost of replacing the Software or acquiri' +
        'ng '
      '                      equivalent Software; or'
      '(d)'#9'The payment of the cost of having the Software replaced.'
      ''
      
        'You acknowledge that you have solely exercised and relied upon y' +
        'our own skill '
      
        'and judgment in determining whether the Software meets your part' +
        'icular '
      
        'requirements, and have not relied on any statement or representa' +
        'tion by or '
      'on behalf of BankLink.'
      ''
      
        'Risk of loss or of damage to your computer system at all times r' +
        'emains with you.'
      'BankLink does not warrant that:'
      
        #183#9'Any of the data provided by or on behalf of BankLink and recei' +
        'ved by '
      
        '                      you for use with the Software will be accu' +
        'rate or virus free;'
      #183#9'The Software is free from defects; or'
      #183#9'The Software will operate without interruption or errors.'
      ''
      '6'#9'Liability'
      ''
      
        'BankLink will not be liable to you for any loss or damage (inclu' +
        'ding, without '
      
        'limitation, consequential loss or damage) suffered by you whethe' +
        'r arising '
      
        'directly or indirectly from the Use of the Software or any data ' +
        'provided by '
      
        'or on behalf of BankLink under this agreement or from any failur' +
        'e or omission '
      'on the part of BankLink or otherwise.'
      ''
      
        'In no event will BankLink be liable for any remote, indirect, co' +
        'nsequential, '
      
        'special or incidental damages, including without limitation, dam' +
        'ages '
      
        'resulting from loss of any data, loss of profits or business int' +
        'erruption, '
      
        'or cost of cover.  This limitation will apply even if BankLink h' +
        'as been advised '
      'of the possibility of such damages.'
      ''
      '7'#9'Termination'
      ''
      
        'Without prejudice to any other rights, BankLink may terminate th' +
        'is agreement '
      
        'if you fail to comply with the terms and conditions of this agre' +
        'ement.  In such '
      
        'event, you must destroy all copies of the Software and all its c' +
        'omponent parts.'
      ''
      '8'#9'Other agreements'
      ''
      
        'This agreement may be modified by the terms of another written a' +
        'greement '
      'entered into by you and BankLink.'
      ''
      '9'#9'Governing law'
      ''
      
        'If you acquired this Software in Australia, this agreement is go' +
        'verned by '
      'the laws of New South Wales, Australia.'
      
        'If you acquired this Software in New Zealand, this agreement is ' +
        'governed by '
      'the laws of New Zealand.'
      ''
      '10'#9'Collection of Usage Information'
      ''
      
        'You agree that BankLink may record the menus you select and coun' +
        't the '
      
        'number of times each menu is selected, and the number of client ' +
        'files involved, '
      
        'while you use BankLink'#39's product for the purpose of ascertaining' +
        ' which features'
      
        'of BankLink'#39's software are most commonly accessed, allowing Bank' +
        'Link to '
      
        'focus future development to enhance functionality in these areas' +
        '.  '
      
        'You also agree that BankLink may record your name and user code ' +
        'for the'
      
        'same purpose.  BankLink will protect the information collected a' +
        'gainst'
      'unauthorised access, use and disclosure. ')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object pBtn: TPanel
    Left = 0
    Top = 276
    Width = 536
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnNo: TButton
      Left = 448
      Top = 8
      Width = 75
      Height = 25
      Caption = '&No'
      ModalResult = 7
      TabOrder = 0
    end
    object btnYes: TButton
      Left = 360
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Yes'
      ModalResult = 6
      TabOrder = 1
    end
  end
end
