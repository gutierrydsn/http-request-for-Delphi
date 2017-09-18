object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Sample use http.request'
  ClientHeight = 469
  ClientWidth = 566
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnGet: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Caption = 'GET'
    TabOrder = 0
    OnClick = btnGetClick
  end
  object Memo1: TMemo
    Left = 24
    Top = 39
    Width = 521
    Height = 422
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 1
  end
end
