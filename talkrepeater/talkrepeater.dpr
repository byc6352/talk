program talkrepeater;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uDM in 'uDM.pas' {dm: TDataModule},
  uConfig in 'uConfig.pas',
  uLog in 'uLog.pas',
  uOrder in 'uOrder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.
