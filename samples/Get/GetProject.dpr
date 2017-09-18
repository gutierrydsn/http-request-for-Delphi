program GetProject;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  http.request in '..\..\src\http.request.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
