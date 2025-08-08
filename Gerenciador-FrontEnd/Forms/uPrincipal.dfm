object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Gerenciador de Produtos'
  ClientHeight = 461
  ClientWidth = 1083
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  RoundedCorners = rcOff
  Visible = True
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 15
  object StatusBar: TStatusBar
    Left = 0
    Top = 440
    Width = 1083
    Height = 21
    Color = clWhite
    Panels = <
      item
        Width = 200
      end
      item
        Width = 200
      end>
    ExplicitWidth = 624
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 1083
    Height = 440
    ActivePage = Home
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 624
    object Home: TTabSheet
      Caption = 'Bem-vindo'
    end
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 96
    Top = 40
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 40
    object Controle1: TMenuItem
      Caption = 'Cadastros'
      ImageIndex = 0
      object Produtos1: TMenuItem
        Caption = 'Produtos'
        OnClick = Produtos1Click
      end
    end
    object Sair1: TMenuItem
      Caption = 'Sair'
      OnClick = Sair1Click
    end
  end
end
