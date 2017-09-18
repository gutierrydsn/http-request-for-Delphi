unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, HTTP.request, Vcl.StdCtrls,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TForm1 = class(TForm)
    btnGet: TButton;
    Memo1: TMemo;
    procedure btnGetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnGetClick(Sender: TObject);
begin
  Memo1.Text := HTTPRequest.GET('http://fipeapi.appspot.com/api/1/carros/marcas.json');
end;

end.
