namespace AF_IFRS.FiltroReportes;

// Constante para la definicion de archivos temporales y de reportes

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
  VisualD.MultiFunctions,
  VisualD.ReportWindowFr;

type
   TFiltroReportes = class(TvkBaseForm, IvkFormInterface)
   private
      oPath:      string;
      Freport:    integer;
      oRecordSet: SAPbobsCOM.Recordset;
      sLocCode:   string;
      sItmGrpCD:  string;
      sProfitCT:  string;
      sProject:   string;
      sPerDepre:  string;
      sPerReman:  string;
      sValNeto:   string;
      sValRema:   string;
      sGrpLevel:  string;
      sTipLevel:  string;
      sYear:      string;
      sPerIni:    string;
      sPerFin:    string;
      method  AddChooseFromList(oForm: SAPbouiCOM.Form);
      method   SetWhereConds(oForm: SAPbouiCOM.Form): string;
      method   EjecutarReporte(oForm: SAPbouiCOM.Form; Titulo, Reporte: string): IvkFormInterface;
   public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
      property    Report:        integer                read  FReport   write FReport;
   end;

implementation

uses
  System.Globalization;

method   TFiltroReportes.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm : SAPbouiCOM.Form;
   oSql  : string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   try
      oPath := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath );

      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_AFFiltrosReportes_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_AFFiltrosReportes.srf', Uid);

      oForm       := FSBOApp.Forms.Item(uid);
      oForm.Mode  := SAPbouiCOM.BoFormMode.fm_OK_MODE;

      oForm.DataSources.UserDataSources.Add('LocCode'  ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,8);
      oForm.DataSources.UserDataSources.Add('Comuna'   ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,8);
      oForm.DataSources.UserDataSources.Add('Ciudad'   ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,8);
      oForm.DataSources.UserDataSources.Add('CardCode' ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,15);
      oForm.DataSources.UserDataSources.Add('ItmGrpCd' ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,8);
      oForm.DataSources.UserDataSources.Add('ProfitCt' ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,8);
      oForm.DataSources.UserDataSources.Add('Project'  ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,30);
      oForm.DataSources.UserDataSources.Add('PerDepIn' ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,4);
      oForm.DataSources.UserDataSources.Add('PerDepFn' ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,4);
      oForm.DataSources.UserDataSources.Add('PerRemIn' ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,4);
      oForm.DataSources.UserDataSources.Add('PerRemFn' ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,4);
      oForm.DataSources.UserDataSources.Add('ValNetIn' ,SAPbouiCOM.BoDataType.dt_SUM,0);
      oForm.DataSources.UserDataSources.Add('ValNetFn' ,SAPbouiCOM.BoDataType.dt_SUM,0);
      oForm.DataSources.UserDataSources.Add('ValRemIn' ,SAPbouiCOM.BoDataType.dt_SUM,0);
      oForm.DataSources.UserDataSources.Add('ValRemFn' ,SAPbouiCOM.BoDataType.dt_SUM,0);
      oForm.DataSources.UserDataSources.Add('Year'     ,SAPbouiCOM.BoDataType.dt_SHORT_NUMBER,4);
      oForm.DataSources.UserDataSources.Add('BtnOpt'   ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,1);
      oForm.DataSources.UserDataSources.Add('BtnOptFR' ,SAPbouiCOM.BoDataType.dt_SHORT_TEXT,1);

      EditText(oForm.Items.Item('LocCode' ).Specific).DataBind.SetBound(true,'','LocCode' );
      ComboBox(oForm.Items.Item('Comuna'  ).Specific).DataBind.SetBound(true,'','Comuna'  );
      ComboBox(oForm.Items.Item('Ciudad'  ).Specific).DataBind.SetBound(true,'','Ciudad'  );
      EditText(oForm.Items.Item('CardCode').Specific).DataBind.SetBound(true,'','CardCode');
      ComboBox(oForm.Items.Item('ItmGrpCd').Specific).DataBind.SetBound(true,'','ItmGrpCd');
      ComboBox(oForm.Items.Item('ProfitCt').Specific).DataBind.SetBound(true,'','ProfitCt');
      ComboBox(oForm.Items.Item('Project' ).Specific).DataBind.SetBound(true,'','Project' );
      EditText(oForm.Items.Item('PerDepIn').Specific).DataBind.SetBound(true,'','PerDepIn');
      EditText(oForm.Items.Item('PerDepFn').Specific).DataBind.SetBound(true,'','PerDepFn');
      EditText(oForm.Items.Item('PerRemIn').Specific).DataBind.SetBound(true,'','PerRemIn');
      EditText(oForm.Items.Item('PerRemFn').Specific).DataBind.SetBound(true,'','PerRemFn');
      EditText(oForm.Items.Item('ValNetIn').Specific).DataBind.SetBound(true,'','ValNetIn');
      EditText(oForm.Items.Item('ValNetFn').Specific).DataBind.SetBound(true,'','ValNetFn');
      EditText(oForm.Items.Item('ValRemIn').Specific).DataBind.SetBound(true,'','ValRemIn');
      EditText(oForm.Items.Item('ValRemFn').Specific).DataBind.SetBound(true,'','ValRemFn');
      EditText(oForm.Items.Item('Year'    ).Specific).DataBind.SetBound(true,'','Year'    );

      OptionBtn(oForm.Items.Item('LvlGrupo').Specific).DataBind.SetBound(true,'','BtnOpt');
      OptionBtn(oForm.Items.Item('LvlDeta' ).Specific).GroupWith('LvlGrupo');

         oForm.Items.Item('LvlGrupo').Visible := true;
         oForm.Items.Item('LvlDeta' ).Visible := true;
         oForm.Items.Item('RectGrp' ).Visible := true;
         OptionBtn(oForm.Items.Item('LvlDeta').Specific).Selected := true;

      OptionBtn(oForm.Items.Item('LvlFinan').Specific).DataBind.SetBound(true,'','BtnOptFR');
      OptionBtn(oForm.Items.Item('LvlRefer').Specific).GroupWith('LvlFinan');
      OptionBtn(oForm.Items.Item('LvlFinan').Specific).Selected := true;

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      // comunas
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select code, name from [@VID_AFCOMUNA] order by name", 
                  'Select "Code" code, "Name" name from "@VID_AFCOMUNA" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('Ciudad').Specific), var oRecordSet, true);
      // ciudades
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select code, name from [@VID_AFCIUDAD] order by name", 
                  'Select "Code" code, "Name" name from "@VID_AFCIUDAD" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('Comuna').Specific), var oRecordSet, true);
      // Project
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select U_UsarProj from [@VID_AFPA]", 
                  'Select "U_UsarProj" from "@VID_AFPA"');
      oRecordSet.DoQuery(oSql);
      if (System.String(oRecordSet.Fields.Item('U_UsarProj').Value).Trim = 'N') then begin
         oForm.Items.Item('tx_project').Enabled := false;
         oForm.Items.Item('Project').Enabled    := false;
         oForm.Items.Item('tx_project').Width := -1;
         oForm.Items.Item('Project').Width    := -1;
      end
      else begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select prjcode code, prjname name from oprj where prjcode <> '' order by prjname", 
                     'Select "PrjCode" "code", "PrjName" "name" from OPRJ where "PrjCode" <> '''' order by "PrjName" ');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('Project').Specific), var oRecordSet, true);
      end;

      // ProfitCt
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select ocrcode code, ocrname name from oocr where direct = 'Y' order by name", 
                  'Select "OcrCode" "code", "OcrName" "name" from OOCR where "Direct" = ''Y'' order by "OcrName"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitCt').Specific), var oRecordSet, true);
      // Grupos
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select  code,  name from [@VID_AFGR] order by name", 
                  'Select  "Code" "code",  "Name" "name" from "@VID_AFGR" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('ItmGrpCd').Specific), var oRecordSet, true);

      //CFL
      AddChooseFromList(oForm);
      EditText(oForm.Items.Item('CardCode').Specific).ChooseFromListUID   := 'CFL1';
      EditText(oForm.Items.Item('CardCode').Specific).ChooseFromListAlias := 'CardCode';
      EditText(oForm.Items.Item('LocCode' ).Specific).ChooseFromListUID   := 'CFLUB';
      EditText(oForm.Items.Item('LocCode' ).Specific).ChooseFromListAlias := 'Code';

      oForm.Visible := true;
   except
      on e:exception do begin
        OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
        FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;

   oForm.Freeze (False)
end;

method TFiltroReportes.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
   oCFLCreationParams.ObjectType := '2';    // 2 => BP
   oCFLCreationParams.UniqueID   := 'CFL1';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'CardType';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'C';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := 'VID_AFLOC';    //
   oCFLCreationParams.UniqueID   := 'CFLUB';
   oCFL := oCFLs.Add(oCFLCreationParams);
end;

method   TFiltroReportes.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm       : SAPbouiCOM.Form;
   oFormIvk    : IvkFormInterface;
   oDataTable  : SAPbouiCOM.DataTable;
   sValue      : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   try
      oForm := FSBOApp.Forms.Item(pVal.FormUID);

      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'LocCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('Code', 0));
            except
               ;
            end;
            oForm.DataSources.UserDataSources.Item('LocCode').ValueEx := sValue;
         end;
         if (pVal.ItemUID = 'CardCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('CardCode', 0));
            except
               ;
            end;
            oForm.DataSources.UserDataSources.Item('CardCode').ValueEx := sValue;
         end;
      end;

      if (pVal.ItemUID = '1') and (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = False) then begin
         oFormIvk := nil;

         SetWhereConds(oForm);
         if (FCmpny.language = BoSuppLangs.ln_English) then begin
            case Report of
               1: oFormIvk := EjecutarReporte(oForm, 'Listado de Activos'     , '\Reports\RptListadoGeneral_EN.fr3');
               2: oFormIvk := EjecutarReporte(oForm, 'Depreciación Mensual'   , '\Reports\RptDepreciacionMensual_EN.fr3');
               3: oFormIvk := EjecutarReporte(oForm, 'Resumen Depreciación'   , '\Reports\RptResumenDepreciacion_EN.fr3');
               4: oFormIvk := EjecutarReporte(oForm, 'Cuentas de Activos'     , '\Reports\RptCuentasdeActivos_EN.fr3');
               5: oFormIvk := EjecutarReporte(oForm, 'Analisis de Activos'    , '\Reports\RptAnalisisdeActivos_EN.fr3');
               6: oFormIvk := EjecutarReporte(oForm, 'Notas Contables'        , '\Reports\RptNotasContables_EN.fr3');
               7: oFormIvk := EjecutarReporte(oForm, 'Depreciación Futura'    , '\Reports\RptDepreciacionFutura_EN.fr3');
               8: oFormIvk := EjecutarReporte(oForm, 'Historial de Traslados' , '\Reports\RptHistorialTraslados_EN.fr3');
            end;
         end
         else begin
            case Report of
               1: oFormIvk := EjecutarReporte(oForm, 'Listado de Activos'     , '\Reports\RptListadoGeneral.fr3');
               2: oFormIvk := EjecutarReporte(oForm, 'Depreciación Mensual'   , '\Reports\RptDepreciacionMensual.fr3');
               3: oFormIvk := EjecutarReporte(oForm, 'Resumen Depreciación'   , '\Reports\RptResumenDepreciacion.fr3');
               4: oFormIvk := EjecutarReporte(oForm, 'Cuentas de Activos'     , '\Reports\RptCuentasdeActivos.fr3');
               5: oFormIvk := EjecutarReporte(oForm, 'Analisis de Activos'    , '\Reports\RptAnalisisdeActivos.fr3');
               6: oFormIvk := EjecutarReporte(oForm, 'Notas Contables'        , '\Reports\RptNotasContables.fr3');
               7: oFormIvk := EjecutarReporte(oForm, 'Depreciación Futura'    , '\Reports\RptDepreciacionFutura.fr3');
               8: oFormIvk := EjecutarReporte(oForm, 'Historial de Traslados' , '\Reports\RptHistorialTraslados.fr3');
            end;
         end;

         if(oFormIvk<>nil) then begin
           oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings);
           ooForms.Add(oFormIvk);
         end;
         oForm.Close;
      end;

   except
      on e:exception do begin
         OutLog('FiltroReporteComex.pas - FormEvent() - exception: ' + e.Message + ' ** Trace: ' + e.StackTrace);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method  TFiltroReportes.SetWhereConds(oForm: SAPbouiCOM.Form): string;
var
   s2   : string;
   s    :  string;
begin
   // LocCode
   sLocCode := '';
   if (oForm.DataSources.UserDataSources.Item('LocCode').ValueEx <> '') then begin
      sLocCode := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_LocCode =  '{0}' ", ' and af."U_LocCode" = ''{0}'' ');
      sLocCode := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('LocCode').ValueEx);
   end
   else begin
      s2 := ' and af.U_LocCode in (select Code from [@VID_AFLOC] where 1=1 ';
      sLocCode := '';
      if (oForm.DataSources.UserDataSources.Item('Comuna'  ).ValueEx <> '') then begin
         sLocCode := sLocCode + iif(GlobalSettings.RunningUnderSQLServer, " and U_Comuna = '{0}' ", ' and "U_Comuna" = ''{0}'' ');
         sLocCode := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('Comuna').ValueEx.Trim);
      end;
      if (oForm.DataSources.UserDataSources.Item('Ciudad'  ).ValueEx <> '') then begin
         sLocCode := sLocCode + iif(GlobalSettings.RunningUnderSQLServer, " and U_Ciudad = '{0}' ", ' and "U_Ciudad" = ''{0}'' ');
         sLocCode := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('Ciudad').ValueEx.Trim);
      end;
      if (oForm.DataSources.UserDataSources.Item('CardCode').ValueEx <> '') then begin
         sLocCode := sLocCode + iif(GlobalSettings.RunningUnderSQLServer, " and U_CardCode = '{0}' ", ' and "U_CardCode" = ''{0}'' ');
         sLocCode := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('CardCode').ValueEx.Trim);
      end;

      if (sLocCode <> '') then
         sLocCode := s2 + sLocCode + ') ';
   end;

   //ItmGrpCD
   sItmGrpCD := '';
   if (oForm.DataSources.UserDataSources.Item('ItmGrpCD').ValueEx <> '') then begin
      s := oForm.DataSources.UserDataSources.Item('ItmGrpCD').ValueEx.Trim;
      try
         s := ComboBox(oForm.Items.Item('ItmGrpCd').Specific).ValidValues.Item(s).Value;
         sItmGrpCD := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_ItmGrpCD = '{0}' ", ' and af."U_ItmGrpCD" = ''{0}'' ');
         sItmGrpCD := string.Format(sLocCode, s);
      except
         s := '';
      end;
   end;

   //ProfitCT
   sProfitCT := '';
   if (oForm.DataSources.UserDataSources.Item('ProfitCT').ValueEx <> '') then begin
      sProfitCT := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_ProfitCT = '{0}' ", ' and af."U_ProfitCT" = ''{0}'' ');
      sProfitCT := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ProfitCT').ValueEx.Trim);
   end;

   //Project
   sProject := '';
   if (oForm.DataSources.UserDataSources.Item('Project').ValueEx <> '') then begin
      sProject := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_Project = '{0}' ", ' and af."U_Project" = ''{0}'' ');
      sProject := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('Project').ValueEx.Trim);
   end;

   // PerDepre
   sPerDepre := '';
   if (oForm.DataSources.UserDataSources.Item('PerDepIn').ValueEx <> '') and (oForm.DataSources.UserDataSources.Item('PerDepFn').ValueEx <> '') then begin
      sPerDepre := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_PerDepre between {0} and {1} ", ' and af."U_PerDepre" between {0} and {1} ');
      sPerDepre := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('PerDepIn').ValueEx, oForm.DataSources.UserDataSources.Item('PerDepFn').ValueEx);
   end
   else if (oForm.DataSources.UserDataSources.Item('PerDepIn').ValueEx <> '') then begin
      sPerDepre := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_PerDepre >= {0} ", ' and af."U_PerDepre" >= {0} ');
      sPerDepre := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('PerDepIn').ValueEx);
   end
   else if (oForm.DataSources.UserDataSources.Item('PerDepFn').ValueEx<> '') then begin
      sPerDepre := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_PerDepre <= {0} ", ' and af."U_PerDepre" <= {0} ');
      sPerDepre := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('PerDepFn').ValueEx);
   end;

   // PerReman
   sPerReman := '';
   if (oForm.DataSources.UserDataSources.Item('PerRemIn').ValueEx <> '') and (oForm.DataSources.UserDataSources.Item('PerRemFn').ValueEx <> '') then begin
      sPerReman := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_VidaUtil between {0} and {1} ", ' and af."U_VidaUtil" between {0} and {1} ');
      sPerReman := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('PerRemIn').ValueEx, oForm.DataSources.UserDataSources.Item('PerRemFn').ValueEx);
   end
   else if (oForm.DataSources.UserDataSources.Item('PerRemIn').ValueEx<> '') then begin
      sPerReman := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_VidaUtil >= {0} ", ' and af."U_VidaUtil" >= {0} ');
      sPerReman := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('PerRemIn').ValueEx);
   end
   else if (oForm.DataSources.UserDataSources.Item('PerRemFn').ValueEx<> '') then begin
      sPerReman := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_VidaUtil <= {0} ", ' and af."U_VidaUtil" <= {0} ');
      sPerReman := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('PerRemFn').ValueEx);
   end;

   // ValNeto
   sValNeto := '';
   if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValNetIn').ValueEx) <> 0) and (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValNetFn').ValueEx) <> 0) then begin
      sValNeto := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_CurVal + af.U_CorAnuAc between {0} and {1} ", ' and af."U_CurVal" + af."U_CorAnuAc" between {0} and {1} ');
      sValNeto := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ValNetIn').ValueEx, oForm.DataSources.UserDataSources.Item('ValNetFn').ValueEx);
   end
   else if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValNetIn').ValueEx) <> 0) then begin
      sValNeto := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_CurVal + af.U_CorAnuAc >= {0} ", ' and af."U_CurVal" + af."U_CorAnuAc" >= {0} ');
      sValNeto := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ValNetIn').ValueEx);
   end
   else if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValNetFn').ValueEx) <> 0) then begin
      sValNeto := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_CurVal + af.U_CorAnuAc <= {0} ", ' and af."U_CurVal" + af."U_CorAnuAc" <= {0} ');
      sValNeto := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ValNetFn').ValueEx);
   end;

   // ValRema
   sValRema := '';
   if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValRemIn').ValueEx) <> 0) and (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValRemFn').ValueEx) <> 0) then begin
      sValRema := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_CurVal + af.U_CorAnuAc - af.U_DepAcum - af.U_CorAnuDe - af.U_DepreAnu between {0} and {1} ", ' and af."U_CurVal" + af."U_CorAnuAc" - af."U_DepAcum" - af."U_CorAnuDe" - af."U_DepreAnu" between {0} and {1} ');
      sValRema := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ValRemIn').ValueEx, oForm.DataSources.UserDataSources.Item('ValRemFn').ValueEx);
   end
   else if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValRemIn').ValueEx) <> 0) then begin
      sValRema := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_CurVal + af.U_CorAnuAc - af.U_DepAcum - af.U_CorAnuDe - af.U_DepreAnu >= {0} ", ' and af."U_CurVal" + af."U_CorAnuAc" - af."U_DepAcum" - af."U_CorAnuDe" - af."U_DepreAnu" >= {0} ');
      sValRema := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ValRemIn').ValueEx);
   end
   else if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('ValRemFn').ValueEx) <> 0) then begin
      sValRema := iif(GlobalSettings.RunningUnderSQLServer, " and af.U_CurVal + af.U_CorAnuAc - af.U_DepAcum - af.U_CorAnuDe - af.U_DepreAnu <= {0} ", ' and af."U_CurVal" + af."U_CorAnuAc" - af."U_DepAcum" - af."U_CorAnuDe" - af."U_DepreAnu" <= {0} ');
      sValRema := string.Format(sLocCode, oForm.DataSources.UserDataSources.Item('ValRemFn').ValueEx);
   end;

   //GrpLevel
   sGrpLevel := '';
   if (OptionBtn(oForm.Items.Item('LvlGrupo').Specific).Selected) then
      sGrpLevel := 'G'
   else if (OptionBtn(oForm.Items.Item('LvlDeta').Specific).Selected) then
      sGrpLevel := 'D';

   //sTipLevel
   sTipLevel := '';
   if (OptionBtn(oForm.Items.Item('LvlFinan').Specific).Selected) then
      sTipLevel := 'F'
   else if (OptionBtn(oForm.Items.Item('LvlRefer').Specific).Selected) then
      sTipLevel := 'R';

   //Year
   sYear := '';
   if (FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('Year').ValueEx) <> 0) then
      sYear := oForm.DataSources.UserDataSources.Item('Year').ValueEx;

   //Periodos
   sPerIni := '';
   if (FSBOf.StrToInteger(oForm.DataSources.UserDataSources.Item('PerDepIn').ValueEx) <> 0) then
      sPerIni := oForm.DataSources.UserDataSources.Item('PerDepIn').ValueEx;

   sPerFin := '';
   if (FSBOf.StrToInteger(oForm.DataSources.UserDataSources.Item('PerDepFn').ValueEx) <> 0) then
      sPerFin := oForm.DataSources.UserDataSources.Item('PerDepFn').ValueEx;
end;

method   TFiltroReportes.EjecutarReporte(oForm: SAPbouiCOM.Form; Titulo, Reporte: string): IvkFormInterface;
var
   oFormvk: IvkFormInterface;
begin
   oFormvk := IvkFormInterface(New TReportWindowFR_1);
   TReportWindowFR_1(oFormvk).FormTitle  := Titulo;
   TReportWindowFR_1(oFormvk).ReportFR3  := oPath + Reporte;
   TReportWindowFR_1(oFormvk).ReportParams := ' -LocCode  "' + FSBOf.ParamReportNil( sLocCode  ) + '"' +
                                              ' -ItmGrpCD "' + FSBOf.ParamReportNil( sItmGrpCD ) + '"' +
                                              ' -ProfitCT "' + FSBOf.ParamReportNil( sProfitCT ) + '"' +
                                              ' -Project  "' + FSBOf.ParamReportNil( sProject  ) + '"' +
//                                              ' -PerDepre "' + FSBOf.ParamReportNil( sPerDepre ) + '"' +
//                                              ' -PerReman "' + FSBOf.ParamReportNil( sPerReman ) + '"' +
                                              ' -ValNeto  "' + FSBOf.ParamReportNil( sValNeto  ) + '"' +
                                              ' -ValRema  "' + FSBOf.ParamReportNil( sValRema  ) + '"' +
                                              ' -Year     "' + FSBOf.ParamReportNil( sYear     ) + '"' +
                                              ' -PerIni   "' + FSBOf.ParamReportNil( sPerIni   ) + '"' +
                                              ' -PerFin   "' + FSBOf.ParamReportNil( sPerFin   ) + '"' +
                                              ' -TipLevel "' + FSBOf.ParamReportNil( sTipLevel ) + '"' +
                                              ' -GrpLevel "' + FSBOf.ParamReportNil( sGrpLevel ) + '"' ;
   result := oFormvk;
end;

end.
