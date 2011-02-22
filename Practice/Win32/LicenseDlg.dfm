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
      
        'Software End-User Licence Agreement for Media Transfer Services ' +
        'Limited and Media Transfer Services UK Limited '
      ''
      
        'IMPORTANT NOTICE PLEASE READ CAREFULLY BEFORE INSTALLING OR USIN' +
        'G THE SOFTWARE:'
      ''
      '1'#9'Agreement'
      ''
      
        '1.1'#9'This Software End-User Licence Agreement ('#39'Agreement'#39') is be' +
        'tween '
      #9'you and BankLink. '
      ''
      
        '1.2'#9'If you acquired this software in the United Kingdom, Austral' +
        'ia or '
      #9'New Zealand, '#39'BankLink'#39' means Media Transfer Services Limited. '
      ''
      
        '1.3'#9'This computer software, together with any supporting documen' +
        'tation '
      #9'and any modifications or amendments made by BankLink ('#8216'the '
      
        #9'Software'#8217'), is owned by Media Transfer Services Limited and may' +
        ' be '
      
        #9'sub-licensed by Media Transfer Services UK Limited.'#160' Provided y' +
        'our '
      
        #9'copy of the Software has been lawfully obtained, and in relatio' +
        'n '
      #9'to InvoicePlus and PayablesPlus, provided you are a registered '
      #9'user of BankLink'#39's services, you are authorised to use the '
      #9'Software in accordance with this Agreement.'
      ''
      '1.4'#9'By proceeding to install, store, load, execute and display '
      
        #9'(individually or collectively, '#8216'Use'#8217') the Software, you agree t' +
        'o '
      #9'be bound by the terms of this Agreement.'#160' If your copy of the '
      
        #9'Software has not been legally obtained or you do not agree to t' +
        'he '
      
        #9'terms of this Agreement, BankLink is not willing to licence the' +
        ' '
      #9'Software to you and you must not Use the Software.'
      ''
      ''
      '2'#9'Grant of licence'
      ''
      
        '2.1'#9'In consideration of you agreeing to abide by the terms of th' +
        'is '
      #9'Agreement BankLink hereby grants you a non-exclusive, non-'
      
        #9'transferable licence to Use the Software in accordance with thi' +
        's '
      #9'Agreement.'
      ''
      
        '2.2'#9'The licence is perpetual unless terminated in accordance wit' +
        'h '
      #9'clause 7.'#160' '
      ''
      
        '2.3'#9'With regard to the InvoicePlus and PayablesPlus products, yo' +
        'u may '
      #9'Use one copy of the Software on a single computer.'
      ''
      ''
      '3'#9'Limitations on Use'
      ''
      '3.1'#9'The Software licence is personal to you; you cannot sell, '
      
        #9'sub-licence, assign, transfer, charge, lend the Software to any' +
        ' '
      #9'other person or entity or otherwise dispose of the rights or '
      #9'obligations under this Agreement without the written consent of'
      #9'BankLink.'#160' '
      ''
      
        '3.2'#9'You cannot copy, alter, modify or reproduce the Software, bu' +
        't '
      
        #9'you may make one copy of the Software for backup purposes only.' +
        #160' '
      
        #9'Except as otherwise permitted at law, you cannot reverse assemb' +
        'le '
      #9'or reverse compile or directly or indirectly allow or cause a '
      
        #9'third party to reverse assemble or reverse compile the whole or' +
        ' '
      #9'any part of the Software.'
      ''
      '3.3'#9'BankLink may sell, sub-licence, assign, transfer, charge or '
      #9'lend the Software to any other person or entity or otherwise '
      #9'dispose of the rights or obligations under this Agreement at '
      #9'any time without your consent.'
      ''
      ''
      '4'#9'Title'
      ''
      '4.1'#9'All title and intellectual property rights in the Software '
      #9'remain with BankLink (or its Licensors).'#160' You acknowledge '
      #9'that rights in the Software are licensed (not sold) to you, '
      #9'and that you have no rights in, or to, the Software other than '
      #9'the right to Use the Software in accordance with the terms of '
      #9'this Agreement. You acknowledge that you have no right to have '
      #9'access to the Software in source code form or in unlocked '
      #9'coding or with comments.'
      ''
      '4.2'#9'You will notify BankLink as soon as you become aware of any '
      
        #9'infringement, suspected infringement or alleged infringement of' +
        ' '
      #9'BankLink'#8217's intellectual property rights in the Software.'
      ''
      ''
      '5'#9'Warranties'
      ''
      
        '5.1'#9'Except as otherwise agreed, BankLink is not obliged to suppo' +
        'rt the'
      
        #9'Software, whether by providing advice, training, error-correcti' +
        'on,'
      #9'modification, new releases or enhancements or otherwise.'
      ''
      
        '5.2'#9'If you acquired this Software in the UK, to the extent permi' +
        'tted '
      #9'by law, BankLink excludes and disclaims all and any guarantees '
      #9'and/or warranties whether express, implied, statutory or '
      #9'otherwise in respect of the Software and in particular, to the '
      #9'extent that they are applicable, expressly excludes the '
      
        #9'provisions of the Sale of Goods Act 1979 and the Supply of Good' +
        's '
      #9'and Services Act 1982. '
      ''
      '5.3'#9'If you acquired this Software in New Zealand, to the extent '
      #9'permitted by law, BankLink excludes and disclaims all and any'
      
        #9'guarantees and/or warranties whether express, implied, statutor' +
        'y '
      #9'or otherwise in respect of the Software and in particular, to '
      #9'the extent that they are applicable, expressly excludes the '
      #9'provisions of the New Zealand Consumer Guarantees Act 1993 '
      #9'pursuant to clause 43(2) thereof and the provisions of the '
      
        #9'New Zealand Sale of Goods Act 1908 pursuant to clause 56 thereo' +
        'f.  '
      #9'You confirm that you have acquired the Software for business'
      #9'purposes.  '
      ''
      '5.4'#9'If you acquired this Software in Australia, to the extent '
      #9'permitted by law, BankLink excludes and disclaims all and any'
      
        #9'guarantees and/or warranties whether express, implied, statutor' +
        'y '
      
        #9'or otherwise in respect of the Software, except for any conditi' +
        'on,'
      
        #9'warranty, guarantee right or remedy under a mandatory law. Noth' +
        'ing '
      #9'in this clause 5 excludes, restricts or modifies any condition,'
      #9'warranty, guarantee, right or remedy under a mandatory law.'
      ''
      
        '5.5'#9'You acknowledge that BankLink does not warrant or promise th' +
        'at '
      
        #9'the Software will meet your requirements and that you have sole' +
        'ly'
      #9'exercised and relied upon your own skill and judgment in '
      #9'determining whether the Software meets your particular '
      #9'requirements, and have not relied on any statement or '
      #9'representation by or on behalf of BankLink (unless made'
      #9'fraudulently).'
      ''
      '5.6'#9'BankLink is providing this Software to you "AS IS" and you '
      #9'acknowledge that risk of loss or of damage to your computer '
      #9'system or data at all times remains with you.'
      ''
      '5.7'#9'BankLink does not warrant that:'
      ''
      #9'5.7.1'#9'Any of the data provided by or on behalf of BankLink and '
      #9#9'received by you for use with the Software will be accurate '
      #9#9'or virus free;'
      ''
      
        #9'5.7.2'#9'The Software will operate without interruption or errors;' +
        ' or '
      ''
      #9'5.7.3'#9'That the Software will not affect the operation of other '
      #9#9'installed applications.'
      ''
      #9
      '6'#9'Liability'
      ''
      
        '6.1'#9'If you acquired this Software in the UK, then subject only t' +
        'o'
      
        #9'BankLink'#39's liability for death or personal injury resulting fro' +
        'm'
      
        #9'BankLink'#39's negligence, fraud or fraudulent misrepresentation (f' +
        'or'
      #9'which there shall be no limitation or exclusions):'
      ''
      #9'6.1.1'#9'Except as otherwise set out in this agreement, BankLink '
      #9#9'will not be liable to you for any loss or damage of any kind'
      #9#9'arising out of or in connection with this agreement whether'
      #9#9'arising in contract, tort (including negligence),'
      
        #9#9'misrepresentation or otherwise, including, without limitation,' +
        ': '
      ''
      #9#9'(a)'#9'any indirect or consequential loss or damage of any '
      #9#9#9'kind; or'
      #9#9'(b)'#9'any loss of income, loss of profits, loss of savings, '
      #9#9#9'loss of goodwill, loss of contracts, business '
      #9#9#9'interruption, cost of cover or loss of data arising '
      #9#9#9'from your use of or inability to use the Software '
      #9#9#9'or from errors or deficiencies in the Software.'
      ''
      
        #9'This limitation will apply even if BankLink has been advised of' +
        ' the '
      #9'possibility of such damages.'
      ''
      
        #9'6.1.2'#9'The liability of BankLink for any loss arising as a resul' +
        't '
      #9#9'of or in relation to the supply by BankLink of the Software,'
      #9#9'including any economic or consequential loss which may be'
      #9#9'sustained or incurred, shall be limited to (at BankLink'#39's'
      #9#9'option):'
      ''
      #9#9'(a)'#9'The replacement of the Software or the supply of '
      #9#9#9'equivalent Software;'
      #9#9'(b)'#9'The repair of the Software;'
      #9#9'(c)'#9'The payment of the cost of replacing the Software '
      #9#9#9'or acquiring equivalent Software; or'
      #9#9'(d)'#9'The payment of the cost of having the Software '
      #9#9#9'replaced.'
      ''
      #9'6.1.3'#9'Nothing in this Agreement shall limit or exclude the '
      #9#9'liability of BankLink for death or personal injury resulting'
      #9#9'from BankLink'#39's negligence, fraud or fraudulent '
      #9#9'misrepresentation.'
      ''
      
        '6.2'#9'If you acquired this Software in Australia or New Zealand, B' +
        'ankLink'
      #9'will not be liable to you for any loss or damage (including, '
      
        #9'without limitation, consequential loss or damage) suffered by y' +
        'ou'
      #9'whether arising directly or indirectly from the Use of the '
      
        #9'Software or any data provided by or on behalf of BankLink under' +
        ' '
      #9'this Agreement or from any failure or omission on the part of '
      #9'BankLink or otherwise.'
      ''
      
        '6.3'#9'In no event will BankLink be liable for any remote, indirect' +
        ','
      
        #9'consequential, punitive, special or incidental damages, includi' +
        'ng'
      
        #9'without limitation, damages resulting from loss of any data, lo' +
        'ss '
      #9'of income or profits or business interruption, or cost of cover'
      
        #9'whether based in contract, tort (including negligence), at law,' +
        ' in'
      
        #9'equity, under statute or otherwise.'#160' This limitation will apply' +
        ' '
      #9'even if BankLink has been advised of the possibility of such '
      #9'damages.'
      ''
      
        '6.4'#9'Where the Australian mandatory consumer protection legislati' +
        'on'
      
        #9'applies, then the liability of BankLink for any loss arising as' +
        ' a'
      
        #9'result of or in relation to the supply by BankLink of the Softw' +
        'are,'
      #9'including any economic or consequential loss which may be '
      #9'sustained or incurred, shall be limited to:'
      #9
      
        #9'6.4.1'#9'The replacement of the Software or the supply of equivale' +
        'nt'
      #9#9'Software;'
      ''
      #9'6.4.2'#9'The repair of the Software;'
      ''
      #9'6.4.3'#9'The payment of the cost of repairing or replacing the '
      #9#9'Software or acquiring equivalent Software;'
      ''
      #9'6.4.4'#9'The payment of the cost of having the Software replaced;'
      ''
      
        #9'6.4.5'#9'The payment for the reduction in value of the Software; o' +
        'r'
      ''
      
        #9'6.4.6'#9'The cost of the refund of the Software license fee, if an' +
        'y,'
      #9#9'paid by you.  However, nothing in this clause 6 excludes,'
      #9#9'restricts or modifies any condition, warranty, guarantee, '
      #9#9'right or remedy under a mandatory law.'
      ''
      ''
      '7'#9'Termination'
      ''
      
        '7.1'#9'Without prejudice to any other rights, BankLink may terminat' +
        'e this'
      
        #9'Agreement by written notice to you with immediate effect if you' +
        ' '
      #9'fail to comply with the terms and conditions of this Agreement '
      #9'or if you become bankrupt or insolvent (or suffer any similar'
      #9'circumstances anywhere in the world).'#160' '
      ''
      '7.2'#9'Upon termination for any reason:'
      ''
      
        #9'7.2.1'#9'All rights granted to you under this Agreement shall ceas' +
        'e;'
      ''
      #9'7.2.2'#9'You must cease all Use of the Software and any other '
      #9#9'activities authorised by this Agreement; and'
      ''
      #9'7.2.3'#9'You must immediately uninstall the Software and destroy '
      #9#9'all copies of the Software in your possession and all its '
      #9#9'component parts.'
      ''
      ''
      '8'#9'Miscellaneous'
      ''
      #9'Entire Agreement'
      ''
      
        '8.1'#9'This Agreement contains everything the parties have agreed i' +
        'n '
      
        #9'relation to the subject matter it deals with.  No party can rel' +
        'y '
      
        #9'on an earlier written document or anything said or done by or o' +
        'n'
      #9'behalf of another party before this agreement was executed.  '
      #9'Variation'
      ''
      
        '8.2'#9'No variation of this agreement will be of any force or effec' +
        't '
      #9'unless it is in writing and signed by each party to this '
      #9'agreement.  '
      ''
      #9'Privity of contract'
      ''
      
        '8.3'#9'A party who is not you or BankLink shall have no right to en' +
        'force '
      
        #9'any term under this Agreement whether under the Contracts (Righ' +
        'ts '
      #9'of Third Parties) Act 1999 (if you acquired this Software in '
      #9'the UK), the Contracts (Privity) Act 1982 (if you acquired this'
      #9'Software in New Zealand) or any other local Act or provision.  '
      #9'This clause does not affect any right or remedy of any person '
      
        #9'which exists, or is available, other than pursuant to the relev' +
        'ant'
      #9'Act.'
      ''
      #9'Governing law'
      ''
      
        '8.4'#9'If you acquired this Software in the UK, this Agreement and ' +
        'any'
      #9'dispute or non-contractual obligation arising out of or in '
      #9'connection with it shall be governed by and construed in '
      
        #9'accordance with the law of England, and each party hereby submi' +
        'ts '
      #9'to the exclusive jurisdiction of the courts of England over any'
      #9'dispute arising out of or in connection with this Agreement.'
      ''
      
        '8.5'#9'If you acquired this Software in Australia, this Agreement a' +
        'nd '
      #9'any dispute or non-contractual obligation arising out of or in'
      #9'connection with it shall be governed by and construed in '
      
        #9'accordance with the laws of New South Wales, and each party her' +
        'eby'
      
        #9'submits to the exclusive jurisdiction of the courts of New Sout' +
        'h '
      
        #9'Wales over any dispute arising out of or in connection with thi' +
        's'
      #9'Agreement.'
      ''
      
        '8.6'#9'If you acquired this Software in New Zealand, this Agreement' +
        ' and '
      #9'any dispute or non-contractual obligation arising out of or in'
      
        #9'connection with it shall be governed by and construed in accord' +
        'ance'
      
        #9'with the laws of New Zealand, and each party hereby submits to ' +
        'the'
      #9'exclusive jurisdiction of the courts of New Zealand over any '
      #9'dispute arising out of or in connection with this Agreement.'
      ''
      ''
      '9'#9'Collection of Usage Information'
      ''
      #9'You agree that Banklink shall have the right to use, copy, '
      #9'store,transfer, transmit, display and analyse any electronic '
      #9'data, information or material, including the menus you select, '
      #9'the number of times each menu is selected and the number of '
      
        #9'client files involved, which is sourced by or through Use of th' +
        'e'
      #9'Software.'#160
      ''
      #9'You also agree that BankLink may record personal data provided '
      
        #9'by you to BankLink (including, without limitation your name and' +
        ' '
      #9'user code).'#160'BankLink will protect the information collected '
      #9'against unauthorised access, use and disclosure and shall '
      
        #9'process the same only in accordance with BankLink'#39's privacy pol' +
        'icy.'
      ''
      #9'BankLink'#39's privacy policy for New Zealand can be viewed at'
      #9'http://www.banklink.co.nz/docs/privacy.pdf or for Australia at'
      #9'http://www.banklink.com.au/docs/privacy.pdf or for the '
      #9'United Kingdom at'
      #9'http://www.banklink.co.uk/docs/BankLink_UK_Privacy_Policy.pdf')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
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
