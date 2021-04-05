namespace AF_IFRS.AgrupacionIFRS;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  System.Collections.Generic,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.vkBaseForm, 
  VisualD.SBOGeneralService,
  VisualD.vkFormInterface,
  Visuald.MultiFunctions,
  Visuald.ReportWindowFr;

type
  TAgrupacionIFRS = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    Lista:      List<String>;
    ListaMx:    List<String>;
    VID_AFAS:   String;
    VID_AFGR:   String; 
    method   ValidacionFinal(var oForm: SAPbouiCOM.Form; var mtx: SAPbouiCOM.Matrix): boolean;
    method   CargarActivos(var oForm: SAPbouiCOM.Form);
    method   CargarGrupo(var oForm: SAPbouiCOM.Form);
    method   MostrarAgrupaciones(var oForm: SAPbouiCOM.Form);
    method   AgregarAgrupacion(var oForm: SAPbouiCOM.Form);
    method   EliminarAgrupacion(var oForm: SAPbouiCOM.Form);
 public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TAgrupacionIFRS.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm: SAPbouiCOM.Form;
   oSql : string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista     := New List<String>;
   ListaMx   := New List<String>;
   try
      FSBOf.LoadForm(xmlPath,'VID_AgrupacionActivos_IFRS.srf', Uid);

      oForm   := FSBOApp.Forms.Item(uid);
      VID_DelRow := true;

      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := 15;             // afm_All

                           // Ok Ad  Fnd Vw Rq Sec
//      Lista.Add( 'OriCode ,  f,  t,  t,  f, r, 1 ');

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      if (not GlobalSettings.IFRSActivo) then
         exit;

      if (GlobalSettings.IFRSNativo) then begin
         VID_AFAS   := iif(GlobalSettings.RunningUnderSQLServer,'[@VID_AFAS]', '"@VID_AFAS"');
         VID_AFGR   := iif(GlobalSettings.RunningUnderSQLServer,'[@VID_AFGR]', '"@VID_AFGR"');
      end
      else begin 
         VID_AFAS   := iif(GlobalSettings.RunningUnderSQLServer,'[@VID_AFASIF]', '"@VID_AFASIF"');
         VID_AFGR   := iif(GlobalSettings.RunningUnderSQLServer,'[@VID_AFGR]', '"@VID_AFGR"');
      end;

      oForm.DataSources.DataTables.Add('DT_Activos');
      oForm.DataSources.DataTables.Add('DT_Agrupacion');
      oForm.DataSources.DataTables.Add('DT_Grupos');

      oForm.DataSources.UserDataSources.Add('AgrpCode', BoDataType.dt_SHORT_TEXT, 20);
      oForm.DataSources.UserDataSources.Add('AgrpName', BoDataType.dt_SHORT_TEXT, 100);
      oForm.DataSources.UserDataSources.Add('GrpCode' , BoDataType.dt_SHORT_TEXT, 8);
      oForm.DataSources.UserDataSources.Add('ActCode' , BoDataType.dt_SHORT_TEXT, 20);
      EditText(oForm.Items.Item('AgrpCode').Specific).DataBind.SetBound(true, '', 'AgrpCode');
      EditText(oForm.Items.Item('AgrpName').Specific).DataBind.SetBound(true, '', 'AgrpName');
      EditText(oForm.Items.Item('ActCode' ).Specific).DataBind.SetBound(true, '', 'ActCode' );
      ComboBox(oForm.Items.Item('GrpCode' ).Specific).DataBind.SetBound(true, '', 'GrpCode' );

      // Grupos
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select  code,  name from " + VID_AFGR + " order by name", 
                  'Select  "Code" "code", "Name" "name" from ' + VID_AFGR + ' order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('GrpCode').Specific), var oRecordSet, true);

//      LinkedButton(oForm.Items.Item('lnkCalen').Specific).LinkedObject := BoLinkedObject.lf_None;

      oForm.Freeze(False);

      MostrarAgrupaciones(var oForm);

      oForm.Visible := true;
//      System.Runtime.InteropServices.Marshal.ReleaseComObject(oForm);
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method   TAgrupacionIFRS.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMtx1           : SAPbouiCOM.Matrix;
   oMtx2           : SAPbouiCOM.Matrix;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);
   oMtx1   := Matrix(oForm.Items.Item('mtx_1').Specific);
   oMtx2   := Matrix(oForm.Items.Item('mtx_2').Specific);

   try
      if (pVal.EventType = BoEventTypes.et_CLICK) and (pVal.ItemUID = 'mtx_2') then begin
         if (not pVal.BeforeAction) and (pVal.Row > 0)then begin
            oMtx2.SelectRow(pVal.Row, true, false);
            oForm.DataSources.UserDataSources.Item('AgrpCode').ValueEx := EditText(oMtx2.Columns.Item('Grupo' ).Cells.Item(pVal.Row).Specific).Value;
            oForm.DataSources.UserDataSources.Item('AgrpName').ValueEx := EditText(oMtx2.Columns.Item('Nombre').Cells.Item(pVal.Row).Specific).Value;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_DOUBLE_CLICK) and (pVal.ItemUID = 'mtx_0') and (pVal.BeforeAction) then begin
         BubbleEvent := false;
         if (oForm.DataSources.UserDataSources.Item('AgrpCode').ValueEx <> '') and (oForm.DataSources.UserDataSources.Item('AgrpCode').ValueEx <> nil) and (pVal.Row > 0) then begin
            oMtx1.AddRow(1, 0);
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'btnLoad') then
            CargarActivos(var oForm);
         if (pVal.ItemUID = 'btnAdd') then begin
            AgregarAgrupacion(var oForm);
            MostrarAgrupaciones(var oForm);
         end;
         if (pVal.ItemUID = 'btnDel') then
            EliminarAgrupacion(var oForm);
      end;
   except
      on e: exception do begin
         if (FSBOf.Cmpny.InTransaction) then
            FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;


method TAgrupacionIFRS.ValidacionFinal(var oForm: SAPbouiCOM.Form;var mtx: SAPbouiCOM.Matrix): boolean;
var
   s:   string;
   ok:  boolean;
begin
   try
      result := false;
      ok     := false;

      s := FSBOf.VerificarItemsRequeridos(oForm, Lista);
      if (s <> '') then begin
         FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      ok := FSBOf.MatrizConDatosOK(mtx, ListaMx, true, var s);
      if (not ok) and (s <> '') then
         FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido en HH' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);

      result := ok;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method  TAgrupacionIFRS.CargarActivos(var oForm: SAPbouiCOM.Form);
var
   sql : String;
   grp : String;
   acf : String;
   con : String;
   oMtx: SAPbouiCOM.Matrix;
begin
   oMtx := Matrix(oform.Items.Item('mtx_0').Specific);
   acf  := oForm.DataSources.UserDataSources.Item('ActCode').ValueEx;
   grp  := oForm.DataSources.UserDataSources.Item('GrpCode').ValueEx;
   con  := '';

   if (grp <> '') and (grp <> nil) then
      con := string.Format( iif(GlobalSettings.RunningUnderSQLServer, " and U_ItmGrpCd = '{0}' ", ' and "U_ItmGrpCd" = ''{0}'' '), grp);
   if (acf <> '') and (acf <> nil) then
      con := con + string.Format( iif(GlobalSettings.RunningUnderSQLServer, " and U_ActCode like '{0}' ", ' and "U_ActCode" like ''{0}'' '), acf + '%');

   sql := iif(GlobalSettings.RunningUnderSQLServer, 
               "Select U_ActCode, U_ActName from " + VID_AFAS +
               " where U_ActCode not in (select U_ChldCode from [@VID_AFCMIFD]) " +
               con +
               " Order by U_ActCode ", 
               'Select "U_ActCode", "U_ActName" from ' + VID_AFAS +
               ' where "U_ActCode" not in (Select "U_ChldCode" from "@VID_AFCMIFD") ' +
               con +
               ' Order by "U_ActCode"');
   oMtx.Clear; 
   oForm.DataSources.DataTables.Item('DT_Activos').ExecuteQuery(sql);
   oMtx.Columns.Item('Activo').DataBind.Bind('DT_Activos', 'U_ActCode') ;
   oMtx.Columns.Item('Nombre').DataBind.Bind('DT_Activos', 'U_ActName') ;
   oMtx.LoadFromDataSource;
   
end;

method  TAgrupacionIFRS.CargarGrupo(var oForm: SAPbouiCOM.Form);
var
   sql : String;
   grp : String;
   oMtx: SAPbouiCOM.Matrix;
begin
   oMtx := Matrix(oform.Items.Item('mtx_2').Specific);
   grp  := oForm.DataSources.UserDataSources.Item('AgrpCode').ValueEx;

   sql := iif(GlobalSettings.RunningUnderSQLServer, 
              "Select B.U_ChldCode, B.U_ChldName " + 
              "  from [@VID_AFCMIF] A inner join [@VID_AFCMIFD] B on A.Code = B.Code " + 
              " where A.U_CompCode = '{0}' " +
              " order by B.U_ChldCode", 
              'Select B."U_ChldCode", B."U_ChldName" ' + 
              '  from "@VID_AFCMIF" A inner join "@VID_AFCMIFD" B on A."Code" = B."Code" ' + 
              ' where A."U_CompCode" = ''{0}'' ' +
              ' order by B."U_ChldCode"');
   sql := string.Format(sql, grp);
   oMtx.Clear; 
   oForm.DataSources.DataTables.Item('DT_Agrupacion').ExecuteQuery(sql);
   oMtx.Columns.Item('Activo').DataBind.Bind('DT_Agrupacion', 'U_ChldCode') ;
   oMtx.Columns.Item('Nombre').DataBind.Bind('DT_Agrupacion', 'U_ChldName') ;
   oMtx.LoadFromDataSource;
   
end;

method  TAgrupacionIFRS.MostrarAgrupaciones(var oForm: SAPbouiCOM.Form);
var
   sql   : String;
   oMtx  : SAPbouiCOM.Matrix;
begin
   oMtx := Matrix(oForm.Items.Item('mtx_2').Specific);
   sql := iif(GlobalSettings.RunningUnderSQLServer, 
               "Select U_CompCode , U_CompName from [@VID_AFCMIF]", 
               'Select "U_CompCode" , "U_CompName" from "@VID_AFCMIF"');

   oMtx.Clear; 
   oForm.DataSources.DataTables.Item('DT_Grupos').ExecuteQuery(sql);
   oMtx.Columns.Item('Grupo' ).DataBind.Bind('DT_Grupos', 'U_CompCode') ;
   oMtx.Columns.Item('Nombre').DataBind.Bind('DT_Grupos', 'U_CompName') ;
   oMtx.LoadFromDataSource;

end;

method  TAgrupacionIFRS.AgregarAgrupacion(var oForm: SAPbouiCOM.Form);
var
   sql     : String;
   act     : String;
   nam     : String;
   aux     : String;
   oGS     : SAPbobsCOM.GeneralService;
   oGSData : SAPbobsCOM.GeneralData;
   oSql    : string;
begin
   act  := oForm.DataSources.UserDataSources.Item('AgrpCode').ValueEx;
   nam  := oForm.DataSources.UserDataSources.Item('AgrpName').ValueEx;

   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               "Select count(*) cant from [@VID_AFCMIF] where U_CompCode = '{0}'", 
               'Select count(*) "cant" from "@VID_AFCMIF" where "U_CompCode" = ''{0}''');
   oSql := string.Format(oSql, act);
   oRecordSet.DoQuery(oSql);
   if (System.Int32(oRecordSet.Fields.Item('cant').Value) <> 0) then begin
      FSBOApp.StatusBar.SetText('Código de grupo ya ingresado.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      exit;
   end;

   oGS     := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFCMIF'));
   oGSData := SAPbobsCOM.GeneralData(oGS.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralData));
   
   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               "Select max(isnull(docentry, 0)) + 1 DocEntry from [@VID_AFCMIF]", 
               'Select max(IfNull("DocEntry", 0)) + 1 "DocEntry" from "@VID_AFCMIF"');
   oRecordSet.DoQuery(oSql);
   aux := System.Int32(oRecordSet.Fields.Item('DocEntry').Value).ToString;

   oGSData.SetProperty('Code', aux);
   oGSData.SetProperty('U_CompCode', act);
   oGSData.SetProperty('U_CompName', nam);
   oGS.Add(oGSData);

   MostrarAgrupaciones(var oForm); 
end;

method  TAgrupacionIFRS.EliminarAgrupacion(var oForm: SAPbouiCOM.Form);
begin

end;

end.
