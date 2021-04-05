namespace Activo_Fijo__IFRS;

interface

uses
  System.Windows.Forms,
  System.Drawing;

type
  MainForm = partial class
  {$REGION Windows Form Designer generated fields}
  private
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method MainForm.InitializeComponent;
begin
  var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeOf(MainForm));
  self.SuspendLayout();
  // 
  // MainForm
  // 
  self.ClientSize := new System.Drawing.Size(292, 273);
  self.Icon := (resources.GetObject('$this.Icon') as System.Drawing.Icon);
  self.Name := 'MainForm';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.Text := 'MainForm';
  self.UseWaitCursor := true;
  self.WindowState := System.Windows.Forms.FormWindowState.Minimized;
  self.Load += new System.EventHandler(@self.MainForm_Load);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.