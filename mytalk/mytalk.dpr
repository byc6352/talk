program mytalk;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uConfig in 'uConfig.pas',
  uDM in 'uDM.pas' {DM: TDataModule},
  uLog in 'uLog.pas',
  uRichEx in 'uRichEx.pas',
  uOrder in 'uOrder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
