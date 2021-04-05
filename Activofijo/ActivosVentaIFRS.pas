namespace AF_IFRS.ActivosVentaIFRS;

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
  TActivosVentaIFRS = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    Lista:      List<String>;
    ListaMx:    List<String>;
    PeriodoProcesado: boolean := false;
    method   limpiarDataset(var oForm: SAPbouiCOM.Form; lin: integer);
    method   ValidacionFinal(var oForm: SAPbouiCOM.Form; var mtx: SAPbouiCOM.Matrix): boolean;
    method   AddChooseFromList(var oForm: SAPbouiCOM.Form);
    method   LimpiarFila(var oForm: SAPbouiCOM.Form);
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method  FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
    method  MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TActivosVentaIFRS.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista     := New List<String>;
   ListaMx   := New List<String>;
   try
      FSBOf.LoadForm(xmlPath,'VID_ActivosParaVenta_IFRS.srf', Uid);

      oForm   := FSBOApp.Forms.Item(uid);
      VID_DelRow := true;

      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := 15;             // afm_All

                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'Fecha   ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'Year    ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'Periodo ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'In      ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'Out     ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'Comments,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'mtx_0   ,  f,  t,  f,  f, n, 1 ');
      FSBOf.SetAutoManaged(oForm, Lista);

      ListaMx.Add('ActCode  , r ,   ');
      ListaMx.Add('ValVta    , r , >0');

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      if (not GlobalSettings.IFRSActivo) then
         exit;

        // CFL ItemCode
      AddChooseFromList(var oForm);
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListUID   := 'CFLAct';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListAlias := 'U_ActCode';

//      LinkedButton(oForm.Items.Item('lnkCalen').Specific).LinkedObject := BoLinkedObject.lf_None;

      // Moneda
//      oRecordSet.DoQuery('SELECT T0.CurrCode Code, T0.CurrName Name FROM OCRN T0');
//      FSBOf.FillComboMtx(Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('Moneda'), var oRecordSet, false);

      oForm.Freeze(False);
      oForm.DataBrowser.BrowseBy := 'DocNum';
      oForm.Visible := true;

      System.Runtime.InteropServices.Marshal.ReleaseComObject(oForm);
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TActivosVentaIFRS.AddChooseFromList(var oForm: SAPbouiCOM.Form);
var
   oCFLs: SAPbouiCOM.ChooseFromListCollection;
   oCFL:  SAPbouiCOM.ChooseFromList;
   oCFLCreationParams: SAPbouiCOM.ChooseFromListCreationParams;
   oCons: SAPbouiCOM.Conditions;
   oCon:  SAPbouiCOM.Condition;
begin
         oCFLs := oForm.ChooseFromLists;
         oCFLCreationParams := ChooseFromListCreationParams(FSBOApp.CreateObject(SAPbouiCOM.BoCreatableObjectType.cot_ChooseFromListCreationParams));

         oCFLCreationParams.MultiSelection := False;
         if (GlobalSettings.IFRSNativo) then
            oCFLCreationParams.ObjectType := 'VID_mAFAS'
         else
            oCFLCreationParams.ObjectType := 'VID_mAFASIF';
         oCFLCreationParams.UniqueID := 'CFLAct';
         oCFL := oCFLs.Add(oCFLCreationParams);
         oCons := oCFL.GetConditions();
         oCon := oCons.Add();
         oCon.Alias := 'U_DeBaja';
         oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
         oCon.CondVal := 'Y';
         oCon.Relationship := BoConditionRelationShip.cr_AND;
         oCon := oCons.Add();
         oCon.Alias := 'U_ActTipo';
         oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
         oCon.CondVal := 'T';
         oCFL.SetConditions(oCons);
end;

method  TActivosVentaIFRS.LimpiarFila(var oForm: SAPbouiCOM.Form);
var
   oDBDSD          : SAPbouiCOM.DBDataSource;
begin
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFBVTD');
   oDBDSD.SetValue('U_ActCode', 0, '');
   oDBDSD.SetValue('U_ActName' , 0, '');
//   oDBDSD.SetValue('U_Moneda'  , 0, '');
   oDBDSD.SetValue('U_ValVta'  , 0, '0');
end;

method   TActivosVentaIFRS.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMtx            : SAPbouiCOM.Matrix;
   oDataTable      : SAPbouiCOM.DataTable;
   oDBDSD          : SAPbouiCOM.DBDataSource;
   sValue          : string;
   sValaux         : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);
   oMtx    := Matrix(oForm.Items.Item('mtx_0').Specific);
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFBVTD');

   try
      if (oForm.Mode = boFormMode.fm_ADD_MODE) and (PeriodoProcesado) then
         PeriodoProcesado := false;

      if (oMtx.RowCount = 0) and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin 
         oMtx.AddRow(1,0);
      end;

      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_ActCode', 0));
               sValaux := System.String(oDataTable.GetValue('U_ActName', 0));
            except
               ;
            end;
            if (sValue = '') then begin
               LimpiarFila(var oForm);
               oMtx.SetLineData(pVal.Row);
               exit;
            end;

            oDBDSD.SetValue('U_ActCode', 0, sValue);
            oDBDSD.SetValue('U_ActName' , 0, sValaux);
            oMtx.SetLineData(pVal.Row);
            LimpiarFila(var oForm);
            if (pVal.Row = oMtx.RowCount) then
               oMtx.AddRow(1, oMtx.RowCount);
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'Fecha') then begin
            sValue  := oForm.DataSources.DBDataSources.Item('@VID_AFBVT').GetValue('U_Fecha', 0);
            if (sValue = '') then begin
               oForm.DataSources.DBDataSources.Item('@VID_AFBVT').SetValue('U_Periodo', 0, '');
               oForm.DataSources.DBDataSources.Item('@VID_AFBVT').SetValue('U_Year'   , 0, '');
            end
            else begin
               sValaux := sValue.Substring(4,2);
               sValue  := sValue.Substring(0,4); 
               oForm.DataSources.DBDataSources.Item('@VID_AFBVT').SetValue('U_Periodo', 0, sValAux);
               oForm.DataSources.DBDataSources.Item('@VID_AFBVT').SetValue('U_Year'   , 0, sValue);
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') then begin
            bubbleEvent := ValidacionFinal(var oForm, var oMtx);
         end;
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

method TActivosVentaIFRS.limpiarDataset(var oForm: SAPbouiCOM.Form; lin: integer);
var
   oDBDSD : SAPbouiCOM.DBDataSource;
begin
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFTRSD');
   oDBDSD.Offset := lin-1;
   oDBDSD.SetValue('U_ActCode', lin-1, '');
   oDBDSD.SetValue('U_ActName', lin-1, '');
   oDBDSD.SetValue('U_ValAct' , lin-1, '0');
end;

method TActivosVentaIFRS.ValidacionFinal(var oForm: SAPbouiCOM.Form;var mtx: SAPbouiCOM.Matrix): boolean;
var
   s:    string;
   s1:   string;
   i:    Integer;
   yr:   integer;
   pr:   integer;
   oSql: string;
begin
   try
      result := false;

      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select isnull(Max(U_Year * 100 + U_Periodo),0) YearPer from [@VID_AFBVT]", 
                  'Select IfNull(Max("U_Year" * 100 + "U_Periodo"),0) "YearPer" from "@VID_AFBVT"'); // Aplicar maximo año
      oRecordSet.DoQuery(oSql);

      i  := System.Int32(oRecordSet.Fields.Item('YearPer').Value);
      yr := i div 100;
      pr := i - yr*100;

      s := oForm.DataSources.DBDataSources.Item("@VID_AFBVT").GetValue("U_Fecha", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar la fecha de bienes para venta.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      s := oForm.DataSources.DBDataSources.Item("@VID_AFBVT").GetValue("U_Year", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar el año de bienes para venta.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      s1 := oForm.DataSources.DBDataSources.Item("@VID_AFBVT").GetValue("U_Periodo", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar el periodo de bienes para venta.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      if (FSBOf.StrToInteger(s) < yr) or ((FSBOf.StrToInteger(s) = yr) and (FSBOf.StrToInteger(s1) <= pr)) then begin
         FSBOApp.StatusBar.SetText("Existe lista de bienes para venta para este periodo o posterior.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      for i:=1 to mtx.RowCount do begin
         s := EditText(mtx.Columns.Item("ActCode").Cells.Item(i).specific).value;
         if (s = '') and (i = mtx.RowCount) then begin
            mtx.DeleteRow(i);
            break;
         end;
         if (s = '') then begin
            FSBOApp.StatusBar.SetText("Activo inexistente en linea: " + i.ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end;
         s := EditText(mtx.Columns.Item("ValVta").Cells.Item(i).specific).value;
         if (FSBOf.StringToDouble(s) = 0) then begin
            FSBOApp.StatusBar.SetText("Nuevo valor no puede ser igual a 0 en linea: " + i.ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end;
      end;

      result := true;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TActivosVentaIFRS.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm   : SAPbouiCOM.Form;
   oDBDS   : SAPbouiCOM.DBDataSource;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);

   oForm := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);
   oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFBVT");

   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (not BusinessObjectInfo.BeforeAction) and (BusinessObjectInfo.ActionSuccess) then begin
      if (oDBDS.GetValue('U_Procesad', 0) = 'Y') then begin
         oForm.Mode := BoFormMode.fm_VIEW_MODE;
         oForm.Items.Item('btnDel').Visible := false;
         PeriodoProcesado := true;
      end
      else begin
         oForm.Mode := BoFormMode.fm_OK_MODE;
         oForm.Items.Item('btnDel').Visible := true;
         PeriodoProcesado := true;
      end;

      oForm.DataSources.DBDataSources.Item("@VID_AFBVT").Offset := 0;
   end;
end;

method   TActivosVentaIFRS.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
var
   oForm : SAPbouiCOM.Form;
begin
   inherited MenuEvent(var pVal, var BubbleEvent);
   try
      oForm           := FSBOApp.Forms.Item(Self.getFormId);

      if (pVal.MenuUid <> '') and  (pVal.BeforeAction) then begin
         if (pVal.MenuUID = '1283') and (PeriodoProcesado) then 
             BubbleEvent := false;
      end;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

end.
