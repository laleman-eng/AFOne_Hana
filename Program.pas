namespace Activo_Fijo__IFRS;

interface

uses
  System.Threading,
  System.Windows.Forms;

type
  Program = assembly static class
  private
    class method OnThreadException(sender: Object; e: ThreadExceptionEventArgs);
  public
    class method Main;
  end;
  
implementation

/// <summary>
/// The main entry point for the application.
/// </summary>
[STAThread]
class method Program.Main;
begin
  Application.EnableVisualStyles();
  Application.SetCompatibleTextRenderingDefault(false);
  Application.ThreadException += OnThreadException;
  using lMainForm := new MainForm do
    Application.Run(lMainForm);
end;

/// <summary>
/// Default exception handler
/// </summary>
class method Program.OnThreadException(sender: Object; e: ThreadExceptionEventArgs);
begin
  MessageBox.Show(e.Exception.Message);
end;
  
end.