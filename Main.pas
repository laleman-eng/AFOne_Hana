namespace Activo_Fijo__IFRS;

interface

uses
  SAPbobsCOM,
  SAPbouiCOM,
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel,
  System.IO,
  VisualD.vkFormInterface,
  VisualD.vkBaseForm,
  VisualD.GlobalVid,
  VisualD.untLog,
  VisualD.Main,
  VisualD.uEncrypt,
  VisualD.MultiFunctions,
  VisualD.SBOObjectMg1,
  AF_IFRS.ActivoObj;

type
  MainForm = partial class(System.Windows.Forms.Form)
  private
    MainClass   : TMainClassExt:= New TMainClassExt;
    method MainForm_Load(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(disposing: Boolean); override;
  public
    constructor;
  end;

  TMainClassExt = class (TMainClass)
  private    
    method CloseSplash;
    method Is_IFRS: Boolean;
  public
    method SetFiltros; override;
    method InitApp; override;
    constructor;
  end;

implementation

constructor MainForm;
begin
  InitializeComponent();
  MainClass.MainObj.Add(New TActivo());
  MainClass.Init;
end;

method MainForm.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();
  end;
  inherited Dispose(disposing);
end;

method MainForm.MainForm_Load(sender: System.Object; e: System.EventArgs);
begin
  showintaskbar := false;
  hide();
end;


method TMainClassExt.SetFiltros;
var
   oFilters: SAPbouiCOM.EventFilters;
   oFilter:  SAPbouiCOM.EventFilter;
begin
   inherited SetFiltros;
   oFilters := SBOApplication.GetFilter;


   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_CHOOSE_FROM_LIST);      // 0
      oFilter.AddEx('VID_AFFiltroREP');
      oFilter.AddEx('VID_AFLOC');
      oFilter.AddEx('VID_AFTRS');
      oFilter.AddEx('VID_mAFAdAc');
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');
      oFilter.AddEx('VID_mAFBaja');
      oFilter.AddEx('VID_mAFBVT');
      oFilter.AddEx('VID_mAFGR');
      oFilter.AddEx('VID_mAFREV');
      oFilter.AddEx('VID_mAFUS');
      oFilter.AddEx('VID_UPDATEPROJECT');
      oFilter.AddEx('VID_mAFPA');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_CLICK);                 // 1
      oFilter.AddEx('9999');
      oFilter.AddEx('VID_mAFASIF');
      oFilter.AddEx('VID_mAFCMIF');
      oFilter.AddEx('VID_mSU_');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_COMBO_SELECT);          // 2
      oFilter.AddEx('VID_AFADQ');
      oFilter.AddEx('VID_AFDefSerie');
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');
      oFilter.AddEx('VID_mAFPA');
      oFilter.AddEx('VID_UPDATEPROJECT');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_DATASOURCE_LOAD);       // 3
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_DOUBLE_CLICK);          // 4
      oFilter.AddEx('VID_AFADQ');
      oFilter.AddEx('VID_mAFCMIF');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_ACTIVATE);         // 5

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_CLOSE);            // 6
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_DATA_ADD);         // 7
      oFilter.AddEx('141');
      oFilter.AddEx('720');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_DATA_LOAD);        // 8
      oFilter.AddEx('150');
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');
      oFilter.AddEx('VID_mAFBaja');
      oFilter.AddEx('VID_mAFGR');
      oFilter.AddEx('VID_mAFREV');
      oFilter.AddEx('VID_mAFUS');
      oFilter.AddEx('VID_UPDATEPROJECT');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_DATA_UPDATE);      // 9

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_LOAD);             // 10

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_RESIZE);           // 11

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_FORM_UNLOAD);           // 12

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_GOT_FOCUS);             // 13
      oFilter.AddEx('VID_AFLOC');
      oFilter.AddEx('VID_mAFAdAc');
      oFilter.AddEx('VID_mAFREV');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_ITEM_PRESSED);          // 14
      oFilter.AddEx('141');
      oFilter.AddEx('150');
      oFilter.AddEx('720');
      oFilter.AddEx('9999');
      oFilter.AddEx('VID_AFADQ');
      oFilter.AddEx('VID_AFCIUDAD');
      oFilter.AddEx('VID_AFCOMUNA');
      oFilter.AddEx('VID_AFDefSerie');
      oFilter.AddEx('VID_AFFiltroREP');
      oFilter.AddEx('VID_AFLOC');
      oFilter.AddEx('VID_AFTRS');
      oFilter.AddEx('VID_mAFAdAc');
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');
      oFilter.AddEx('VID_mAFBaja');
      oFilter.AddEx('VID_mAFBVT');
      oFilter.AddEx('VID_mAFCMIF');
      oFilter.AddEx('VID_mAFGR');
      oFilter.AddEx('VID_mAFPA');
      oFilter.AddEx('VID_mAFREV');
      oFilter.AddEx('VID_mAFUS');
      oFilter.AddEx('VID_mSU_');
      oFilter.AddEx('VID_PrActFi');
      oFilter.AddEx('VID_PrActFiIF');
      oFilter.AddEx('VID_UPDATEPROJECT');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_KEY_DOWN);              // 15
      oFilter.AddEx('9999');
      oFilter.AddEx('VID_mSU_');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_LOST_FOCUS);            // 16

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_MATRIX_LINK_PRESSED);   // 17

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_MATRIX_LOAD);           // 18
      oFilter.AddEx('VID_AFDefSerie');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_MENU_CLICK);            // 19
      oFilter.AddEx('VID_mAFREV');
      oFilter.AddEx('VID_mAFBVT');

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_RIGHT_CLICK);           // 20

   oFilter := SBOFunctions.GetFilterByEventType(oFilters ,SAPbouiCOM.BoEventTypes.et_VALIDATE);              // 21
      oFilter.AddEx('VID_AFADQ');
      oFilter.AddEx('VID_AFCIUDAD');
      oFilter.AddEx('VID_AFCOMUNA');
      oFilter.AddEx('VID_AFDefSerie');
      oFilter.AddEx('VID_AFLOC');
      oFilter.AddEx('VID_mAFAdAc');
      oFilter.AddEx('VID_mAFAS');
      oFilter.AddEx('VID_mAFASIF');
      oFilter.AddEx('VID_mAFBVT');
      oFilter.AddEx('VID_mAFGR');
      oFilter.AddEx('VID_mAFREV');
      oFilter.AddEx('VID_mAFUS');

   SBOApplication.SetFilter(oFilters);  
end;

method TMainClassExt.CloseSplash;
begin
end;

method TMainClassExt.initApp;
var
   XlsFile : String;
   oRS     : SAPbobsCOM.Recordset;
   sUser   : Boolean;
//   Msg     : String;
//   _Result : Boolean;
begin
   inherited initAPP();   
   GlobalSettings.SBO_f := SBOFunctions;
   InitOK := false;
   try
      sUser := false;
      oRS := SAPbobsCOM.RecordSet(SBOCompany.GetBusinessObject(BoObjectTypes.BoRecordSet));
      oRS.DoQuery('select SUPERUSER from OUSR where INTERNAL_K = ' + SBOCompany.UserSignature.ToString);
      if (not oRS.EoF) then
         if (System.String(oRS.Fields.Item('SUPERUSER').Value) = 'Y') then
            sUser := true;
   finally
      SBOfunctions._ReleaseCOMObject(oRS);
   end;

   if (sUser) then begin

     XlsFile := Path.GetDirectoryName( TMultiFunctions.ParamStr(0) ) + '\Docs\' +'EDAF.xls';
     if not SBOFunctions.ValidEstructSHA1(XlsFile) then
     begin
         oLog.OutLog('InitApp: Estructura de datos (1)');
         SBOApplication.StatusBar.SetText('Inicializando AddOn Activo Fijo', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
         if (not SBOMetaData.SyncTablasUdos('1.1', XlsFile)) then begin
            SBOFunctions.DeleteSHA1FromTable('EDAF.xls');
            oLog.OutLog('InitApp: sincronización de Estructura de datos fallo');
            CloseSplash;
            SBOApplication.MessageBox('Estructura de datos con problemas, consulte a soporte...', 1, 'Ok', '', '');
            halt(0);
         end;
      end;

     XlsFile := Path.GetDirectoryName( TMultiFunctions.ParamStr(0) ) + '\Docs\' +'EDAF_IFRS.xls';
     if not SBOFunctions.ValidEstructSHA1(XlsFile) then
     begin
         oLog.OutLog('InitApp: Estructura de datos (1)');
         SBOApplication.StatusBar.SetText('Inicializando AddOn Activo IFRS', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
         if (not SBOMetaData.SyncTablasUdos('1.1', XlsFile)) then begin
            SBOFunctions.DeleteSHA1FromTable('EDAF_IFRS.xls');
            oLog.OutLog('InitApp: sincronización de Estructura de datos fallo');
            CloseSplash;
            SBOApplication.MessageBox('Estructura de datos con problemas, consulte a soporte...', 1, 'Ok', '', '');
            halt(0);
         end;
      end;
   end;

   
   MainObj[0].GlobalSettings := GlobalSettings;
   MainObj[0].SBOApplication := SBOApplication;
   MainObj[0].SBOCompany     := SBOCompany;
   MainObj[0].oLog           := oLog;
   MainObj[0].SBOFunctions   := SBOFunctions;

//   if (Is_IFRS) then 
      GlobalSettings.IFRSActivo := true;

   SetFiltros;

   MainObj[0].AddMenus;

   InitOk := true;
   oLog.OutLog('Delphi Prism');
   SBOApplication.StatusBar.SetText('Activo fijo Inicializado.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);

end;

constructor TMainClassExt;
begin
  inherited;
  GlobalSettings.SBOSpaceName:='VID_AFOne';
end;

method TMainClassExt.IS_IFRS: Boolean;
begin
  result := SBOfunctions.AddonsList.IndexOf('AFOne Opcion IFRS') >= 0;
end;

end.