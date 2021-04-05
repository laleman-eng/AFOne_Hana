namespace AF_IFRS.ProcesoAF;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  System.Collections.Generic,
  System.Runtime.InteropServices,
  System.Diagnostics,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.vkBaseForm, 
  VisualD.SBOGeneralService,
  VisualD.vkFormInterface,
  Visuald.MultiFunctions,
  AF_IFRS.RealizaProcesoAFS;


type
  TProcesoAF = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oFactDec    : integer;
    oRndDec     : boolean;
    G_TipoProc  : String;
    G_Periodo   : Integer;
    G_Year      : Integer;
    G_DSGrupo   : String := '';
    oDBPassword : String;
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method   Procesar;
 end;

implementation

uses
  System.Globalization;

method   TProcesoAF.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm      : SAPbouiCOM.Form;
   oRecordSet : SAPbobsCOM.Recordset;
   i          : Integer;
   oSql       : string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   try

      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_ProcesoAF_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_ProcesoAF.srf', Uid);

      try
         oForm := FSBOApp.Forms.Item(uid);
         oForm.Freeze(True);
         oForm.AutoManaged    := True;
         oForm.SupportedModes := -1;             // afm_All
         oForm.Mode           := SAPbouiCOM.BoFormMode.fm_OK_MODE;

         oForm.DataSources.UserDataSources.Add('DSYear' ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,4);
         oForm.DataSources.UserDataSources.Add('DSPer'  ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,3);
         oForm.DataSources.UserDataSources.Add('DSGrupo',SAPbouiCOM.BoDataType.dt_SHORT_TEXT  ,30);
         EditText(oForm.Items.Item('Year'  ).Specific).DataBind.SetBound(true,'','DSYear' );
         EditText(oForm.Items.Item('Period').Specific).DataBind.SetBound(true,'','DSPer'  );
         ComboBox(oForm.Items.Item('Grupo' ).Specific).DataBind.SetBound(true,'','DSGrupo');

         oRecordSet      := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

         // Pasword Database
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select U_Srvr, U_Usr, U_Pw, U_UsrAdm, U_AppPath,U_Width,U_Height from [@VID_MenuSU]", 
                     'Select "U_Srvr", "U_Usr", "U_Pw", "U_UsrAdm", "U_AppPath", "U_Width", "U_Height" from "@VID_MENUSU"');
         oRecordSet.DoQuery(oSql);
         if (not oRecordSet.EoF) then 
            oDBPassword := System.String(oRecordSet.Fields.Item('U_Pw').Value)
         else
            raise New Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Parmetros_Reportes_No_Definido]);

         // Decimales de redondeo
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Decimals from OCRN where CurrCode = '{0}'", 
                     'Select "Decimals" from OCRN where "CurrCode" = ''{0}''');
         oSql := string.Format(oSql, FCmpny.GetCompanyService.GetAdminInfo.LocalCurrency);
         oRecordSet.DoQuery(oSql);
         i := -1;
         if (not oRecordSet.EoF) then 
            i := System.Int32(oRecordSet.Fields.Item('Decimals').Value);
         if (i = -1) then
            GlobalSettings.LocalCurr_Dec := FCmpny.GetCompanyService.GetAdminInfo.TotalsAccuracy
         else 
            GlobalSettings.LocalCurr_Dec := i;
        //Moneda de systema
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Decimals from OCRN where CurrCode = '{0}'", 
                     'Select "Decimals" from OCRN where "CurrCode" = ''{0}''');
         oSql := string.Format(oSql, FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency);
         oRecordSet.DoQuery(oSql);
         i := -1;
         if (not oRecordSet.EoF) then 
            i := System.Int32(oRecordSet.Fields.Item('Decimals').Value);
         if (i = -1) then
            GlobalSettings.SysCurr_Dec := FCmpny.GetCompanyService.GetAdminInfo.TotalsAccuracy
         else 
            GlobalSettings.SysCurr_Dec := i;
        //Fin decimales de redondeo

         ComboBox(oForm.Items.Item('Grupo' ).Specific).ValidValues.Add('', GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Todos_los_activos]);
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code, Name From [@VID_AFGR] order by Name", 
                     'Select "Code", "Name" From "@VID_AFGR" order by "Name"');
         oRecordSet.DoQuery(oSql);
         oRecordSet.MoveFirst;
         While (not oRecordSet.EoF) do begin
            ComboBox(oForm.Items.Item('Grupo' ).Specific).ValidValues.Add(System.String(oRecordSet.Fields.Item('Code').Value), System.String(oRecordSet.Fields.Item('Name').Value));
            oRecordSet.MoveNext;
         end;

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "SELECT isnull(U_FactDec,99) factdec, isnull(U_DecRound,'R') decround  FROM [@VID_AFPA]", 
                     'SELECT IfNull("U_FactDec", 99) "factdec", IfNull("U_DecRound", ''R'') "decround"  FROM "@VID_AFPA"');
         oRecordSet.DoQuery(oSql);
         oFactDec := System.int32(oRecordSet.Fields.Item('factdec').value);
         if (oFactDec < 1) or (oFactDec > 9) then
            oFactDec := 10;

         oRndDec := true;
         if (System.String(oRecordSet.Fields.Item('decround').value) = 'T') then
           oRndDec := false;
      finally
         FSBOf._ReleaseCOMObject(oRecordSet);
         oForm.Freeze(False);
         oForm.Visible := true;
      end;

   except
      on e:exception do begin
         FSBOApp.MessageBox(e.Message,1,'Ok','','');
         OutLog('InitForm: ' + e.Message);
      end;
   end;
end;

method   TProcesoAF.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm      : SAPbouiCOM.Form;
   nErr       : integer;
   sErr       : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   oForm    := FSBOApp.Forms.Item(pVal.FormUID);

   try
      // Validacion valores
      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) and
         ( (pVal.ItemUID = 'Procesar') or (pVal.ItemUID = 'Contab') or (pVal.ItemUID = 'Reversar') ) then begin
         G_Year    := FSBOf.StrToInteger(EditText(oForm.Items.Item('Year').specific).Value);
         G_Periodo := FSBOf.StrToInteger(EditText(oForm.Items.Item('Period').specific).Value);
         G_DSGrupo := oForm.DataSources.UserDataSources.Item('DSGrupo').ValueEx;
         G_TipoProc := "";
         if (pVal.ItemUID = 'Procesar') then begin
            if (1 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Procesar_Activos_QM], 1, 'Ok', 'Cancelar','')) then 
               G_TipoProc := "P";
         end
         else if (pVal.ItemUID = 'Contab') then begin
            if (1 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Post_period_QM], 1, 'Ok', 'Cancelar','')) then 
               G_TipoProc := "C";
         end
         else if (pVal.ItemUID = 'Reversar') then begin
            if (1 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Reverse_Period_QM], 1, 'Ok', 'Cancelar','')) then 
               G_TipoProc := "R";
         end;
      end
      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) and
         ( (pVal.ItemUID = 'Procesar') or (pVal.ItemUID = 'Contab') or (pVal.ItemUID = 'Reversar') ) then begin
         if (G_TipoProc = 'P') or (G_TipoProc = 'C') or (G_TipoProc = 'R')then 
            Procesar();
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = false) then begin
         if (pVal.ItemUID = '1')then
           oForm.Mode := BoFormMode.fm_OK_MODE;
      end

   except
      on e: exception do begin
         OutLog('SBO Previo: ' + e.Message + ' - ' + e.StackTrace);
         if (FCmpny.InTransaction) then
            FCmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FCmpny.GetLastError(out nErr, out sErr);
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('SBO posterior: ' + TMultiFunctions.inttostr(nErr) + '  ' + sErr + 'SO: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TProcesoAF.Procesar;
var
   oProgBar   : SAPbouiCOM.ProgressBar;
   oDoProceso : AF_IFRS.RealizaProcesoAFS.TRealizaProcesoAFS;
   s          : string;
begin
   try
      oProgBar := FSBOApp.StatusBar.CreateProgressBar(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Procesando], 100, false);
      oDoProceso  := new AF_IFRS.RealizaProcesoAFS.TRealizaProcesoAFS(GlobalSettings, FSBOf, FSBOf.Cmpny, G_DSGrupo, G_Year, G_Periodo, var oProgBar);

      if (G_TipoProc = "P") then begin
         s := oDoProceso.ProcesarActivos();
         if (s = "") then
            FSBOf.SBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Proceso_Done], 1, 'Ok', '','')
         else
            FSBOf.SBOApp.MessageBox(s , 1, 'Ok', '','')
      end
      else if (G_TipoProc = "C") then begin
         s := oDoProceso.Centralizar();
         if (s = "") then
            FSBOf.SBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Post_Done], 1, 'Ok', '','')
         else
            FSBOf.SBOApp.MessageBox(s , 1, 'Ok', '','')
      end
      else if (G_TipoProc = "R") then begin
         s := oDoProceso.ReversarCentralizacion();
         if (s = "") then 
             s := oDoProceso.ReversarProcesoActivos();
         if (s = "") then 
            FSBOf.SBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Reverse_Done], 1, 'Ok', '','')
         else
            FSBOf.SBOApp.MessageBox(s , 1, 'Ok', '','')
      end;
   finally
      oProgBar.Stop;
      System.Runtime.InteropServices.Marshal.ReleaseComObject(oProgBar);
      oProgBar := nil;
   end;
end;

end.
