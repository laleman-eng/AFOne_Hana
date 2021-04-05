namespace AF_IFRS.TrasladoActivos;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  System.Collections.Generic,
  System.IO,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.vkBaseForm, 
  VisualD.SBOGeneralService,
  VisualD.vkFormInterface,
  Visuald.MultiFunctions,
  Visuald.ReportWindowFr;

type
  TTrasladoActivos = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    Lista:      List<String>;
    ListaMx:    List<String>;
    method   limpiarDataset(var oForm: SAPbouiCOM.Form; lin: integer);
    method   ValidacionFinal(var oForm: SAPbouiCOM.Form; var mtx: SAPbouiCOM.Matrix): boolean;
    method   UpdLocation(oForm: SAPbouiCOM.Form);
    method   AddChooseFromList(var oForm: SAPbouiCOM.Form);
    method   AddChooseFromListDinamico(oForm: SAPbouiCOM.Form; oLoc: string);
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TTrasladoActivos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista     := New List<String>;
   ListaMx   := New List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_TrasladodeActivos_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_TrasladodeActivos.srf', Uid);

      oForm   := FSBOApp.Forms.Item(uid);
      VID_DelRow := true;

      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := 15;             // afm_All

                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'OriCode ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'DesCode ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'FecTras ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'mtx_0   ,  f,  t,  f,  f, n, 1 ');
      FSBOf.SetAutoManaged(oForm, Lista);

      ListaMx.Add('ActCode  , r ,   ');
      ListaMx.Add('ValAct   , r , >0');

        // CFL ItemCode
      AddChooseFromList(var oForm);
      EditText(oForm.Items.Item('OriCode').Specific).ChooseFromListUID   := 'CFLOri';
      EditText(oForm.Items.Item('OriCode').Specific).ChooseFromListAlias := 'Code';
      EditText(oForm.Items.Item('DesCode').Specific).ChooseFromListUID   := 'CFLDes';
      EditText(oForm.Items.Item('DesCode').Specific).ChooseFromListAlias := 'Code';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListUID := 'CFLAct';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListAlias := 'U_ActCode';

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

//      LinkedButton(oForm.Items.Item('lnkCalen').Specific).LinkedObject := BoLinkedObject.lf_None;

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

method TTrasladoActivos.AddChooseFromList(var oForm: SAPbouiCOM.Form);
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
         oCFLCreationParams.ObjectType := 'VID_AFLOC';    // 4 => Item
         oCFLCreationParams.UniqueID := 'CFLOri';
         oCFL := oCFLs.Add(oCFLCreationParams);

         oCFLCreationParams.MultiSelection := False;
         oCFLCreationParams.ObjectType := 'VID_AFLOC';    // 4 => Item
         oCFLCreationParams.UniqueID := 'CFLDes';
         oCFL := oCFLs.Add(oCFLCreationParams);

         oCFLCreationParams.MultiSelection := False;
         oCFLCreationParams.ObjectType := 'VID_mAFAS';    // 4 => Item
         oCFLCreationParams.UniqueID := 'CFLAct';
         oCFL := oCFLs.Add(oCFLCreationParams);
         oCons := oCFL.GetConditions();
         oCon := oCons.Add();
         oCon.Alias := 'U_LocCode';
         oCon.Operation := BoConditionOperation.co_EQUAL;
         oCon.CondVal := '---';
         oCon.Relationship := BoConditionRelationShip.cr_AND;
         oCon := oCons.Add();
         oCon.Alias := 'U_DeBaja';
         oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
         oCon.CondVal := 'Y';
         oCFL.SetConditions(oCons);
end;

method   TTrasladoActivos.AddChooseFromListDinamico(oForm: SAPbouiCOM.Form; oLoc: string);
var
   oCFLs: SAPbouiCOM.ChooseFromListCollection;
   oCFL:  SAPbouiCOM.ChooseFromList;
   oCons: SAPbouiCOM.Conditions;
   oCon:  SAPbouiCOM.Condition;
   i:     integer;
begin
         oCFLs := oForm.ChooseFromLists;
         oCFL  := oCFLs.Item('CFLAct');

         oCons := oCFL.GetConditions();
          i := 0;
         oCon  := oCons.Item(i);
         oCon.CondVal := oLoc.Trim;

         oCFL.SetConditions(oCons);
end;

method   TTrasladoActivos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMtx            : SAPbouiCOM.Matrix;
   oDataTable      : SAPbouiCOM.DataTable;
   oDBDSD          : SAPbouiCOM.DBDataSource;
   oDBDSH          : SAPbouiCOM.DBDataSource;
   oFormIvk        : IvkFormInterface;
   sValue          : string;
   sValue2         : string;
   sValue3         : string;
   i               : integer;
   ExisteCodigo    : boolean;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);
   oMtx    := Matrix(oForm.Items.Item('mtx_0').Specific);
   oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFTRS');
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFTRSD');

   try
      if (oMtx.RowCount = 0) and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
         oDBDSD.Clear;
         oMtx.AddRow(1, 0);
      end;

      // CFL
      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') then begin
            sValue  := oForm.DataSources.DBDataSources.Item('@VID_AFTRS').GetValue('U_OriCode', 0);
            AddChooseFromListDinamico(oForm, sValue.Trim);
         end;
      end
      else if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'OriCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('Code', 0));
            except
               ;
            end;
            if (sValue = '') then
               exit;
            if (EditText(oForm.Items.Item('DesCode').Specific).Value = sValue) then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Origen_distinto_destino], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            oDBDSH.SetVAlue('U_OriCode', 0, sValue);
            oMtx.Clear;
            oMtx.FlushToDataSource;
         end;
         if (pVal.ItemUID = 'DesCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('Code', 0));
            except
               ;
            end;
            if (sValue = '') then
               exit;
            if (EditText(oForm.Items.Item('OriCode').Specific).Value = sValue) then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Origen_distinto_destino], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            oDBDSH.SetVAlue('U_DesCode', 0, sValue);
         end;
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_ActCode', 0));
               sValue2 := System.String(oDataTable.GetValue('U_ActName', 0));
               sValue3 := FSBOf.DoubleToStr(System.Double(oDataTable.GetValue('U_CurVal' , 0)));
            except
               ;
            end;
            if (sValue = '') then begin
               limpiarDataset(var oForm, pVal.Row);
               oMtx.SetLineData(pVal.Row);
               exit;
            end;

            ExisteCodigo := false;
            for i:=1 to oMtx.RowCount do
               if (i <> pVal.Row) and (sValue = EditText(oMtx.Columns.Item('ActCode').Cells.Item(i).Specific).Value) then
                  ExisteCodigo := true;
            if (ExisteCodigo) then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Activo_Ya_Ingresado], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               limpiarDataset(var oForm, pVal.Row);
               oMtx.SetLineData(pVal.Row);
               exit;
            end;

            if (not ExisteCodigo) then begin
               if (pVal.Row = oMtx.RowCount) then begin
                  limpiarDataset(var oForm, pVal.Row);
                  oMtx.AddRow(1, oMtx.RowCount);
               end;

               oMtx.FlushToDataSource;
               oDBDSD.Offset := pVal.Row-1;
               oDBDSD.SetValue('U_ActCode', pVal.Row-1, sValue );
               oDBDSD.SetValue('U_ActName', pVal.Row-1, sValue2);
               oDBDSD.SetValue('U_ValAct' , pVal.Row-1, sValue3);
               oMtx.SetLineData(pVal.Row);
            end
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Trasladar_activos_QM], 1, 'Ok', 'Cancelar','')) then
               exit
            else if (ValidacionFinal(var oForm, var oMtx)) then begin
                FSBOf.Cmpny.StartTransaction;
                UpdLocation(oForm);
                BubbleEvent := true;
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = false) then begin
         if (pVal.ItemUID = '1') and (FSBOf.Cmpny.InTransaction) then begin
            if (pVal.ActionSuccess) then
               FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_Commit)
            else
               FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         end;
         
         if (pVal.ItemUID = 'btn_Print') then begin
            if (oForm.Mode <> BoFormMode.fm_OK_MODE) then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Guia_Traslado_no_imprimible], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
               exit;
            end;
            oFormIvk := IvkFormInterface(New TReportWindowFR_1);
            if (FCmpny.language = BoSuppLangs.ln_English) then
               TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptTraslado_EN.fr3'
            else
               TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptTraslado.fr3';

            TReportWindowFR_1(oFormIvk).ReportParams := ' -DocNum "' + EditText(oForm.Items.Item('DocNum').Specific).value + '"';
            if(oFormIvk<>nil) then begin
               oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings);
               ooForms.Add(oFormIvk);
            end;
         end;
      end;

      System.Runtime.InteropServices.Marshal.ReleaseComObject(oForm);
      System.Runtime.InteropServices.Marshal.ReleaseComObject(oMtx);
      System.Runtime.InteropServices.Marshal.ReleaseComObject(oDBDSH);
      System.Runtime.InteropServices.Marshal.ReleaseComObject(oDBDSD);

   except
      on e: exception do begin
         if (FSBOf.Cmpny.InTransaction) then
            FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TTrasladoActivos.limpiarDataset(var oForm: SAPbouiCOM.Form; lin: integer);
var
   oDBDSD : SAPbouiCOM.DBDataSource;
begin
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFTRSD');
   oDBDSD.Offset := lin-1;
   oDBDSD.SetValue('U_ActCode', lin-1, '');
   oDBDSD.SetValue('U_ActName', lin-1, '');
   oDBDSD.SetValue('U_ValAct' , lin-1, '0');
end;

method TTrasladoActivos.ValidacionFinal(var oForm: SAPbouiCOM.Form;var mtx: SAPbouiCOM.Matrix): boolean;
var
   s:   string;
   ok:  boolean;
   oDBDSH: SAPbouiCOM.DBDataSource;
begin
   try
      result := false;
      ok     := false;
      oDBDSH := oForm.DataSources.DBDataSources.Item('@VID_AFTRS');
      s := FSBOf.VerificarItemsRequeridos(oForm, Lista);
      if (s <> '') then begin
         FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      ok := FSBOf.MatrizConDatosOK(mtx, ListaMx, true, var s);
      if (not ok) and (s <> '') then
         FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido en HH' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);


      //consultar en parametros para ver si se tiene lo necesario para crear transferencia
      if (GlobalSettings.RunningUnderSQLServer) then
        s := "SELECT TOP 1 U_AddTransf, U_TipoDoc, U_ItemCode FROM [@VID_AFPA]"
      else
        s := 'SELECT TOP 1 "U_AddTransf", "U_TipoDoc", "U_ItemCode" FROM "@VID_AFPA" '; 
      oRecordSet.DoQuery(s);
      if (oRecordSet.RecordCount = 0) then 
         FSBOApp.StatusBar.SetText("Addon no se encuentra parametrizado" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
      else
      begin
         if (System.String(oRecordSet.Fields.Item("U_AddTransf").Value) = "") then 
            FSBOApp.StatusBar.SetText("No se encuentra parametrizado, si debe crear documento SAP" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
         else if (System.String(oRecordSet.Fields.Item("U_TipoDoc").Value) = "") then 
            FSBOApp.StatusBar.SetText("No se encuentra parametrizado tipo documento SAP" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
         else 
         begin 
            if (System.String(oRecordSet.Fields.Item("U_AddTransf").Value) = "Y") then
            begin
               
               if (System.String(oRecordSet.Fields.Item("U_ItemCode").Value) = "") then 
                  FSBOApp.StatusBar.SetText("No se encuentra parametrizado si tipo documento SAP" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
               else
               begin
                  if (GlobalSettings.RunningUnderSQLServer) then
                    s := "SELECT T0.U_CardCode, T0.U_Address, T0.U_WhsCode, T1.Name 'Ciudad', T2.Name 'Comuna'
                            FROM [@VID_AFLOC] T0
                            LEFT JOIN [@VID_AFCIUDAD] T1 ON T1.Code = T0.U_Ciudad
                            LEFT JOIN [@VID_AFCOMUNA] T2 ON T2.Code = T0.U_Comuna
                           WHERE T0.Code = '{0}'"
                  else
                    s := 'SELECT T0."U_CardCode", T0."U_Address", T0."U_WhsCode", T1."Name" "Ciudad", T2."Name" "Comuna" '+
                           ' FROM "@VID_AFLOC" T0 ' + 
                           ' LEFT JOIN "@VID_AFCIUDAD" T1 ON T1."Code" = T0."U_Ciudad" ' +
                           ' LEFT JOIN "@VID_AFCOMUNA" T2 ON T2."Code" = T0."U_Comuna" ' +
                           ' WHERE T0."Code" = ''{0}'' '; 
                  s := String.Format(s, oDBDSH.GetValue('U_DesCode', 0).Trim);
                  oRecordSet.DoQuery(s);
                  if (System.String(oRecordSet.Fields.Item("U_CardCode").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Socio Negocio en Ubicaciones de Activo Fijo, Bodega Destino" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("U_Address").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Direccion en Ubicaciones de Activo Fijo, Bodega Destino" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("U_WhsCode").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Bodega SAP en Ubicaciones de Activo Fijo, Bodega Destino" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("Ciudad").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Ciudad en Ubicaciones de Activo Fijo, Bodega Destino" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("Comuna").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Comuna en Ubicaciones de Activo Fijo, Bodega Destino" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);

                  if (GlobalSettings.RunningUnderSQLServer) then
                    s := "SELECT T0.U_CardCode, T0.U_Address, T0.U_WhsCode, T1.Name 'Ciudad', T2.Name 'Comuna'
                            FROM [@VID_AFLOC] T0
                            LEFT JOIN [@VID_AFCIUDAD] T1 ON T1.Code = T0.U_Ciudad
                            LEFT JOIN [@VID_AFCOMUNA] T2 ON T2.Code = T0.U_Comuna
                           WHERE T0.Code = '{0}'"
                  else
                    s := 'SELECT T0."U_CardCode", T0."U_Address", T0."U_WhsCode", T1."Name" "Ciudad", T2."Name" "Comuna" '+
                           ' FROM "@VID_AFLOC" T0 ' + 
                           ' LEFT JOIN "@VID_AFCIUDAD" T1 ON T1."Code" = T0."U_Ciudad" ' +
                           ' LEFT JOIN "@VID_AFCOMUNA" T2 ON T2."Code" = T0."U_Comuna" ' +
                           ' WHERE T0."Code" = ''{0}'' '; 
                  s := String.Format(s, oDBDSH.GetValue('U_OriCode', 0).Trim);
                  oRecordSet.DoQuery(s);
                  if (System.String(oRecordSet.Fields.Item("U_CardCode").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Socio Negocio en Ubicaciones de Activo Fijo, Bodega Origen" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("U_Address").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Direccion en Ubicaciones de Activo Fijo, Bodega Origen" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("U_WhsCode").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Bodega SAP en Ubicaciones de Activo Fijo, Bodega Origen" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("Ciudad").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Ciudad en Ubicaciones de Activo Fijo, Bodega Origen" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
                  else if (System.String(oRecordSet.Fields.Item("Comuna").Value) = "") then
                     FSBOApp.StatusBar.SetText("No se encuentra parametrizado Comuna en Ubicaciones de Activo Fijo, Bodega Origen" , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               end;
            end;
         end;
      end;

      result := ok;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TTrasladoActivos.UpdLocation(oForm: SAPbouiCOM.Form);
var
   oDBDSH: SAPbouiCOM.DBDataSource;
   oDBDSD: SAPbouiCOM.DBDataSource;
   oMtx:   SAPbouiCOM.Matrix;
   i:      integer;
   sql:    string;
   bAdd: Boolean;
   TipoDoc: string;
   ItemCode: string;
   ItemCodeAF: string;
   ItemName: String;
   NroGuia: String;
   WhsCode: String;
   s: string;
   oStockTransfer: SAPbobsCOM.StockTransfer := StockTransfer(FCmpny.GetBusinessObject(BoObjectTypes.oStockTransfer));
   oDoc : SAPbobsCOM.Documents := SAPbobsCOM.Documents(FCmpny.GetBusinessObject(BoObjectTypes.oDeliveryNotes));
   bPaso : Boolean := false;
   lRetCode: Int32;
   errMsg: string;
   Serie: String;
begin
   oDBDSH := oForm.DataSources.DBDataSources.Item('@VID_AFTRS');
   oDBDSD := oForm.DataSources.DBDataSources.Item('@VID_AFTRSD');
   oMtx   := Matrix(oForm.Items.Item('mtx_0').Specific);
   if (EditText(oMtx.Columns.Item('ActCode').Cells.Item(oMtx.RowCount).Specific).Value = '') then
      oMtx.DeleteRow(oMtx.RowCount);
   
   oMtx.FlushToDataSource;

    if (GlobalSettings.RunningUnderSQLServer) then
        s := "SELECT TOP 1 U_AddTransf, U_TipoDoc, U_ItemCode, U_Serie FROM [@VID_AFPA]"
    else
        s := 'SELECT TOP 1 "U_AddTransf", "U_TipoDoc", "U_ItemCode", "U_Serie"  FROM "@VID_AFPA" '; 
    oRecordSet.DoQuery(s);
    bAdd := iif(System.String(oRecordSet.Fields.Item("U_AddTransf").Value).Trim() = "Y", true, false); 
    TipoDoc := System.String(oRecordSet.Fields.Item("U_TipoDoc").Value).Trim();
    ItemCode := System.String(oRecordSet.Fields.Item("U_ItemCode").Value).Trim();
    NroGuia := oDBDSH.GetValue('U_GuiaDesp', 0).Trim;
    Serie := System.String(oRecordSet.Fields.Item("U_Serie").Value).Trim();

    if Serie <> "" then
    begin
      if (GlobalSettings.RunningUnderSQLServer) then
          s := "SELECT Cast(Series AS VARCHAR(20)) 'Series' FROM NNM1 WHERE ObjectCode = '{0}' AND SeriesName = '{1}'" 
      else
          s := 'SELECT Cast("Series" AS VARCHAR(20)) "Series" FROM "NNM1" WHERE "ObjectCode" = ''{0}'' AND "SeriesName" = ''{1}'' ' ;
      s := String.Format(s, iif(TipoDoc = "E", "15", "67"), Serie);
      oRecordSet.DoQuery(s);
      if (oRecordSet.RecordCount = 0) then
        Serie := ""
      else
        Serie := system.String(oRecordSet.Fields.Item("Series").Value).Trim; 
    end;
    
    if (bAdd) then 
    begin
       if (TipoDoc = "E") then
       begin
          s := oDBDSH.GetValue('U_FecTras', 0).Trim;
          oDoc.DocDate := DateTime.ParseExact(s, "yyyyMMdd",CultureInfo.InvariantCulture);
          oDoc.TaxDate := DateTime.ParseExact(s, "yyyyMMdd",CultureInfo.InvariantCulture);
          oDoc.DocDueDate := DateTime.ParseExact(s, "yyyyMMdd",CultureInfo.InvariantCulture);
          if Serie <> "" then
            oDoc.Series := Convert.ToInt32(Serie); 
          if NroGuia <> "" Then
            oDoc.FolioNumber := Convert.ToInt32(NroGuia);
          if (oDBDSH.GetValue('U_GuiaDesp', 0).Trim <> "") then 
             oDoc.FolioNumber := Convert.ToInt32(oDBDSH.GetValue('U_GuiaDesp', 0).Trim);

          if (GlobalSettings.RunningUnderSQLServer) then
             s := "SELECT T0.U_CardCode, T0.U_Address, T0.U_WhsCode, T1.Name 'Ciudad', T2.Name 'Comuna'
                            FROM [@VID_AFLOC] T0
                            LEFT JOIN [@VID_AFCIUDAD] T1 ON T1.Code = T0.U_Ciudad
                            LEFT JOIN [@VID_AFCOMUNA] T2 ON T2.Code = T0.U_Comuna
                           WHERE T0.Code = '{0}'"
          else
             s := 'SELECT T0."U_CardCode", T0."U_Address", T0."U_WhsCode", T1."Name" "Ciudad", T2."Name" "Comuna" '+
                           ' FROM "@VID_AFLOC" T0 ' + 
                           ' LEFT JOIN "@VID_AFCIUDAD" T1 ON T1."Code" = T0."U_Ciudad" ' +
                           ' LEFT JOIN "@VID_AFCOMUNA" T2 ON T2."Code" = T0."U_Comuna" ' +
                           ' WHERE T0."Code" = ''{0}'' '; 
          s := String.Format(s, oDBDSH.GetValue('U_DesCode', 0).Trim);
          oRecordSet.DoQuery(s);
          oDoc.CardCode := System.String(oRecordSet.Fields.Item("U_CardCode").Value).Trim;
          oDoc.AddressExtension.BillToCity := System.String(oRecordSet.Fields.Item("Ciudad").Value).Trim;
          oDoc.AddressExtension.BillToCounty := System.String(oRecordSet.Fields.Item("Comuna").Value).Trim;
          oDoc.AddressExtension.BillToStreet := System.String(oRecordSet.Fields.Item("U_Address").Value).Trim;
          oDoc.AddressExtension.ShipToCity := System.String(oRecordSet.Fields.Item("Ciudad").Value).Trim;
          oDoc.AddressExtension.ShipToCounty := System.String(oRecordSet.Fields.Item("Comuna").Value).Trim;
          oDoc.AddressExtension.ShipToStreet := System.String(oRecordSet.Fields.Item("U_Address").Value).Trim;
          oDoc.Comments := "Creado por AFOne";
          WhsCode := System.String(oRecordSet.Fields.Item("U_WhsCode").Value);
       end
       else
       begin
          s := oDBDSH.GetValue('U_FecTras', 0).Trim;
          oStockTransfer.DocDate := DateTime.ParseExact(s, "yyyyMMdd",CultureInfo.InvariantCulture);
          oStockTransfer.TaxDate := DateTime.ParseExact(s, "yyyyMMdd",CultureInfo.InvariantCulture);
          if Serie <> "" then
            oStockTransfer.Series := Convert.ToInt32(Serie); 
          if (GlobalSettings.RunningUnderSQLServer) then
             s := "SELECT T0.U_CardCode, T0.U_Address, T0.U_WhsCode, T1.Name 'Ciudad', T2.Name 'Comuna'
                            FROM [@VID_AFLOC] T0
                            LEFT JOIN [@VID_AFCIUDAD] T1 ON T1.Code = T0.U_Ciudad
                            LEFT JOIN [@VID_AFCOMUNA] T2 ON T2.Code = T0.U_Comuna
                           WHERE T0.Code = '{0}'"
          else
             s := 'SELECT T0."U_CardCode", T0."U_Address", T0."U_WhsCode", T1."Name" "Ciudad", T2."Name" "Comuna" '+
                           ' FROM "@VID_AFLOC" T0 ' + 
                           ' LEFT JOIN "@VID_AFCIUDAD" T1 ON T1."Code" = T0."U_Ciudad" ' +
                           ' LEFT JOIN "@VID_AFCOMUNA" T2 ON T2."Code" = T0."U_Comuna" ' +
                           ' WHERE T0."Code" = ''{0}'' '; 
          s := String.Format(s, oDBDSH.GetValue('U_DesCode', 0).Trim);
          oRecordSet.DoQuery(s);
          oStockTransfer.Address := System.String(oRecordSet.Fields.Item("U_Address").Value).Trim + ", " +  System.String(oRecordSet.Fields.Item("Comuna").Value).Trim + ", " + System.String(oRecordSet.Fields.Item("Ciudad").Value).Trim; 
          oStockTransfer.CardCode := System.String(oRecordSet.Fields.Item("U_CardCode").Value); 
          oStockTransfer.ToWarehouse := System.String(oRecordSet.Fields.Item("U_WhsCode").Value);
          if NroGuia <> "" Then
            oStockTransfer.FolioNumber := Convert.ToInt32(NroGuia);

          if (GlobalSettings.RunningUnderSQLServer) then
             s := "SELECT T0.U_CardCode, T0.U_WhsCode
                            FROM [@VID_AFLOC] T0
                           WHERE T0.Code = '{0}'"
          else
             s := 'SELECT T0."U_CardCode", T0."U_WhsCode" ' +
                           ' FROM "@VID_AFLOC" T0 ' + 
                           ' WHERE T0."Code" = ''{0}'' '; 
          s := String.Format(s, oDBDSH.GetValue('U_OriCode', 0).Trim);
          oRecordSet.DoQuery(s); 
          oStockTransfer.FromWarehouse :=System.String(oRecordSet.Fields.Item("U_WhsCode").Value);
          oStockTransfer.Comments := "Creado por AFOne"; 
       end;
       //hacer que cargue el detalle de los documentos***********************************\
       for i:=0 to oDBDSD.Size-1 do 
       begin
            if (GlobalSettings.RunningUnderSQLServer) then
              s := "SELECT U_ProfitCt, U_ProfitC2, U_ProfitC3, U_ProfitC4, U_ProfitC5, U_Project, U_ItemCode, U_ActName FROM [@VID_AFAS] WHERE U_ActCode = '{0}'"
            else
              s := 'SELECT "U_ProfitCt", "U_ProfitC2", "U_ProfitC3", "U_ProfitC4", "U_ProfitC5", "U_Project", "U_ItemCode", "U_ActName" FROM "@VID_AFAS" WHERE "U_ActCode" = ''{0}'' ';
            s := String.Format(s, oDBDSD.GetValue('U_ActCode', i).Trim);
            oRecordSet.DoQuery(s); 
            ItemName := System.String(oRecordSet.Fields.Item("U_ActName").Value).Trim();
            ItemCodeAF := system.String(oRecordSet.Fields.Item("U_ItemCode").Value).Trim; 

            if (TipoDoc = "E") then 
            begin
               if (i > 0) then 
                  oDoc.Lines.Add()
               else
               begin
                  if (System.String(oRecordSet.Fields.Item("U_Project").Value).Trim <> "") then 
                     oDoc.Project := System.String(oRecordSet.Fields.Item("U_Project").Value).Trim;
               end;
               oDoc.Lines.ItemCode := iif(ItemCodeAF = "", ItemCode, ItemCodeAF);
               oDoc.Lines.ItemDescription := ItemName;
               oDoc.Lines.Quantity := 1;
               oDoc.Lines.WarehouseCode := WhsCode;
               if (System.String(oRecordSet.Fields.Item("U_Project").Value).Trim) <> "" then
                   oDoc.Lines.ProjectCode := System.String(oRecordSet.Fields.Item("U_Project").Value).Trim;
               if (System.String(oRecordSet.Fields.Item("U_ProfitCt").Value).Trim) <> "" then begin
                   oDoc.Lines.COGSCostingCode := System.String(oRecordSet.Fields.Item("U_ProfitCt").Value).Trim;
                   oDoc.Lines.CostingCode := System.String(oRecordSet.Fields.Item("U_ProfitCt").Value).Trim;
               end;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC2").Value).Trim) <> "" then begin
                   oDoc.Lines.COGSCostingCode2 := System.String(oRecordSet.Fields.Item("U_ProfitC2").Value).Trim;
                   oDoc.Lines.CostingCode2 := System.String(oRecordSet.Fields.Item("U_ProfitC2").Value).Trim;
               end;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC3").Value).Trim) <> "" then begin
                   oDoc.Lines.COGSCostingCode3 := System.String(oRecordSet.Fields.Item("U_ProfitC3").Value).Trim;
                   oDoc.Lines.CostingCode3 := System.String(oRecordSet.Fields.Item("U_ProfitC3").Value).Trim;
               end;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC4").Value).Trim) <> "" then begin
                   oDoc.Lines.COGSCostingCode4 := System.String(oRecordSet.Fields.Item("U_ProfitC4").Value).Trim;
                   oDoc.Lines.CostingCode4 := System.String(oRecordSet.Fields.Item("U_ProfitC4").Value).Trim;
               end;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC5").Value).Trim) <> "" then begin
                   oDoc.Lines.COGSCostingCode5 := System.String(oRecordSet.Fields.Item("U_ProfitC5").Value).Trim;
                   oDoc.Lines.CostingCode5 := System.String(oRecordSet.Fields.Item("U_ProfitC5").Value).Trim;
               end;
            end
            else
            begin
               if (i > 0) then 
                  oStockTransfer.Lines.Add();
               oStockTransfer.Lines.ItemCode := iif(ItemCodeAF = "", ItemCode, ItemCodeAF);
               oStockTransfer.Lines.ItemDescription :=  ItemName;
               oStockTransfer.Lines.Quantity := 1;
               oStockTransfer.Lines.WarehouseCode := oStockTransfer.ToWarehouse;
               oStockTransfer.Lines.FromWarehouseCode := oStockTransfer.FromWarehouse;
               if (System.String(oRecordSet.Fields.Item("U_Project").Value).Trim) <> "" then
                  oStockTransfer.Lines.ProjectCode := System.String(oRecordSet.Fields.Item("U_Project").Value).Trim;
               if (System.String(oRecordSet.Fields.Item("U_ProfitCt").Value).Trim) <> "" then
                  oStockTransfer.Lines.DistributionRule := System.String(oRecordSet.Fields.Item("U_ProfitCt").Value).Trim;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC2").Value).Trim) <> "" then
                  oStockTransfer.Lines.DistributionRule2 := System.String(oRecordSet.Fields.Item("U_ProfitC2").Value).Trim;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC3").Value).Trim) <> "" then
                  oStockTransfer.Lines.DistributionRule3 := System.String(oRecordSet.Fields.Item("U_ProfitC3").Value).Trim;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC4").Value).Trim) <> "" then
                  oStockTransfer.Lines.DistributionRule4 := System.String(oRecordSet.Fields.Item("U_ProfitC4").Value).Trim;
               if (System.String(oRecordSet.Fields.Item("U_ProfitC5").Value).Trim) <> "" then
                  oStockTransfer.Lines.DistributionRule5 := System.String(oRecordSet.Fields.Item("U_ProfitC5").Value).Trim;
            end;
       end;//fin for de detalle
       var oFile   : String;
           oFile := System.IO.Path.GetDirectoryName(System.Windows.Forms.Application.ExecutablePath) + "\oStockTransfer.xml"; 
            oStockTransfer.SaveToFile(oFile);

       if (TipoDoc = "E") then 
         lRetCode := oDoc.Add()
       else
         lRetCode := oStockTransfer.Add(); 
        
       if (lRetCode <> 0) then
       begin
           FCmpny.GetLastError(out lRetCode, out errMsg);
           
           FSBOApp.StatusBar.SetText("No se ha creado documento, " + errMsg, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
           bPaso := false;
       end
       else
       begin
            var Key := FCmpny.GetNewObjectKey();
            if (GlobalSettings.RunningUnderSQLServer) then
               s := "SELECT DocNum FROM {1} WHERE DocEntry = {0}"
            else
               s := 'SELECT "DocNum" FROM "{1}" WHERE "DocEntry" = {0}';
            s := String.Format(s, Key, iif(TipoDoc = "E", "ODLN", "OWTR"));
            oRecordSet.DoQuery(s);
            FSBOApp.StatusBar.SetText("Se ha creado documento numero " + System.Int32(oRecordSet.Fields.Item("DocNum").Value).ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
            bPaso := true;
       end;
    end
    else
       bPaso := true;



    if (bPaso) then 
    begin
       for i:=0 to oDBDSD.Size-1 do begin
          sql:= iif(GlobalSettings.RunningUnderSQLServer, 
                    ' Update [@VID_AFAS] ' +
                    '    set U_LocCode = Tb.LocCode, ' +
                    '        U_LocName = Tb.LocName  ' +
                    " from [@VID_AFAS] join ( select Code LocCode, Name LocName, '{0}'  ActCode  " +
                    '                           from [@VID_AFLOC]      ' +
                    "                          where Code = '{1}' ) Tb " +
                    '                    ON [@VID_AFAS].U_ActCode = Tb.ActCode ',
                    ' Update "@VID_AFAS" ' +
                    '    set "U_LocCode" = Tb."LocCode", ' +
                    '        "U_LocName" = Tb."LocName"  ' +
                    ' from "@VID_AFAS" join ( Select "Code" "LocCode", "Name" "LocName", ''{0}''  "ActCode"  ' +
                    '                           from "@VID_AFLOC"      ' +
                    '                          where "Code" = ''{1}'' ) Tb ' +
                    '                    ON "@VID_AFAS"."U_ActCode" = Tb."ActCode" ');
          sql := string.Format(sql, oDBDSD.GetValue('U_ActCode', i).Trim, oDBDSH.GetValue('U_DesCode', 0).Trim);
          oRecordSet.DoQuery(sql);
      end;
   end;


end;

end.
