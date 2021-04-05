namespace AF_IFRS.UsoActivos;

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
  Visuald.MultiFunctions;

type
  TUsoActivos = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet : SAPbobsCOM.Recordset;
    Lista      : List<String>;
    method  AddChooseFromList(oForm: SAPbouiCOM.Form);
    method  ValidacionFinal(var oForm: SAPbouiCOM.Form;var mtx: SAPbouiCOM.Matrix): boolean;
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method  FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
    method  DeleteUso(var oForm: SAPbouiCOM.Form);
  end;

implementation

uses
  System.Globalization;

method TUsoActivos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var sboFunctions: VisualD.SBOFunctions.CSBOFunctions; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm: SAPbouiCOM.Form;
   oSql : string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista   := new List<String>;
   try
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_UsoActivos_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_UsoActivos.srf', Uid);

      oForm := FSBOApp.Forms.Item(uid);
      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := -1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_FIND_MODE;

      VID_Delete := true;
                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'Periodo  , f,  f,  t,  f, r, 1');
      Lista.Add( 'Year     , f,  f,  t,  f, r, 1');
      Lista.Add( 'YearPer  , f,  f,  t,  f, r, 1');
      Lista.Add( 'Fecha    , f,  t,  t,  f, r, 1');
      Lista.Add( 'Comment  , t,  t,  f,  f, n, 1');
      Lista.Add( 'mtx_0    , t,  t,  f,  f, n, 1');
      FSBOf.SetAutoManaged(oForm, Lista);

      oForm.DataSources.UserDataSources.Add('Descrip',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,100);
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('Descrip').DataBind.SetBound(true,'','Descrip');

      oRecordSet      := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      //CFL
      AddChooseFromList(oForm);
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListUID   := 'CFL1';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListAlias := 'U_ActCode';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('GrpCode').ChooseFromListUID   := 'CFL2';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('GrpCode').ChooseFromListAlias := 'Code';

      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('SVidaAct').Visible := false;
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('SVidaNew').Visible := false;
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('RVidaAct').Visible := false;
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('RVidaNew').Visible := false;
      oSql := iif(GlobalSettings.RunningUnderSQLServer, "Select U_DepUsoAc from [@VID_AFPA]", 'Select "U_DepUsoAc" from "@VID_AFPA" ');
      oRecordSet.DoQuery(oSql);
      if (not oRecordSet.EoF) then 
         if (System.String(oRecordSet.Fields.Item('U_DepUsoAc').Value) = "Y") then begin
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('SVidaAct').Visible := true;
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('SVidaNew').Visible := true;
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('RVidaAct').Visible := true;
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('RVidaNew').Visible := true;
         end;

      oForm.DataBrowser.BrowseBy := 'YearPer';
   finally
      oForm.Freeze(False);
      oForm.Visible := true;
   end;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + '  ** trace ' +  e.StackTrace);
         oForm.Visible := true;
      end;
   end;
end;

method TUsoActivos.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
   oCFLCreationParams.ObjectType := 'VID_mAFAS';    
   oCFLCreationParams.UniqueID   := 'CFL1';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'U_TipoDep';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal   := 'U';
   oCon.Relationship := BoConditionRelationShip.cr_OR;

   oCon := oCons.Add();
   oCon.Alias := 'U_TipoDepR';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal   := 'U';

   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := 'VID_mAFGR';    
   oCFLCreationParams.UniqueID   := 'CFL2';
   oCFL := oCFLs.Add(oCFLCreationParams);
end;

method   TUsoActivos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   sValue          : string;
   sVal01          : string;
   sVal02          : string;
   sVal03          : string;
   sValAux         : String;
   oDataTable      : SAPbouiCOM.DataTable;
   oMtx            : SAPbouiCOM.Matrix;
   i               : integer;
   s               : String;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   oForm := FSBOApp.Forms.Item(pVal.FormUID);
   oMtx  := Matrix(oForm.Items.Item('mtx_0').Specific);
   oForm.DataSources.DBDataSources.Item('@VID_AFUSD').Offset := 0;
   try
      if (oMtx.RowCount = 0) then
          oMtx.AddRow(1, oMtx.RowCount);

      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (not pVal.BeforeAction) then begin
         if (pVal.ColUID = 'GrpCode') and (pVal.ItemUID = 'mtx_0') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue := System.String(oDataTable.GetValue('Code'    , 0));
               sVal01 := System.String(oDataTable.GetValue('Name'    , 0));
               sVal02 := System.int32(oDataTable.GetValue('U_VidaUtil', 0)).ToString;
               sVal03 := System.int32(oDataTable.GetValue('U_VidaUtiR', 0)).ToString;
            except
               ;
            end;

            if (sValue = '') then begin
               sVal01 := '';
               sVal02 := '0';
               sVal03 := '0';
            end;

            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_GrpCode' , 0, sValue);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_GrpName' , 0, sVal01);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaAct', 0, sVal02);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaNew', 0, sVal02);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaAct', 0, sVal03);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaNew', 0, sVal03);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_Uso'     , 0, '0');
            oForm.DataSources.UserDataSources.Item('Descrip').ValueEx := sVal01;
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_ActCode' , 0, '');
            oMtx.SetLineData(pVal.Row);
           
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_GrpCode' , 0,'');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_GrpName' , 0,'');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_Uso'     , 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaAct', 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaNew', 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaAct', 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaNew', 0,'0');
            oForm.DataSources.UserDataSources.Item('Descrip').ValueEx := '';

            if (oMtx.RowCount = pVal.Row) then
               oMtx.AddRow(1, oMtx.RowCount);
         end;
         if (pVal.ColUID = 'ActCode') and (pVal.ItemUID = 'mtx_0') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue := System.String(oDataTable.GetValue('U_ActCode', 0));
               sVal01 := System.String(oDataTable.GetValue('U_ActName', 0));
               sVal02 := System.int32(oDataTable.GetValue('U_PerVidaU', 0)).ToString;
               sVal03 := System.int32(oDataTable.GetValue('U_PerVidaR', 0)).ToString;
            except
               ;
            end;

            if (sValue = '') then  begin
               sVal01 := '';
               sVal02 := '0';
               sVal03 := '0';
            end;

            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_ActCode' , 0, sValue);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_ActName' , 0, sVal01);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaAct', 0, sVal02);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaNew', 0, sVal02);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaAct', 0, sVal03);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaNew', 0, sVal02);
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_Uso'     , 0, '0');
            oForm.DataSources.UserDataSources.Item('Descrip').ValueEx := sVal01;
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_GrpCode', 0, '');
            oMtx.SetLineData(pVal.Row);
           
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_ActCode', 0, '');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_ActName', 0, '');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_Uso'    , 0, '0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaAct', 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_SVidaNew', 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaAct', 0,'0');
            oForm.DataSources.DBDataSources.Item('@VID_AFUSD').SetValue('U_RVidaNew', 0,'0');
            oForm.DataSources.UserDataSources.Item('Descrip').ValueEx := '';

            if (oMtx.RowCount = pVal.Row) then
               oMtx.AddRow(1, oMtx.RowCount);
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction) and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
         if (pVal.ItemUID = 'Fecha') then begin
           // Permite solo utilizaciones para periodo siguiente al periodo procesado
            sValue  := EditText(oForm.Items.Item('Fecha').Specific).Value;
            if (sValue.Trim() = '') then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Se ingresar la fecha del documento.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select COUNT(*) cant from [@VID_AFAS] " +
                    " where U_NextYear = {0} and U_NextPer = {1}",
                    'Select COUNT(*) "cant" from "@VID_AFAS" ' +
                    ' where "U_NextYear" = {0} and "U_NextPer" = {1}');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2) );
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) = 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Periodo de utilización sin activos por procesar.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select COUNT(*) cant from [@VID_AFAC] " +
                    " where U_Year = {0} and U_Periodo = {1}",
                    'Select COUNT(*) "cant" from "@VID_AFAC" ' +
                    ' where "U_Year" = {0} and "U_Periodo" = {1}');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2) );
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Periodo de utilización con activos ya procesados, debe reversar.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select COUNT(*) cant from [@VID_AFAS] " +
                    " where ( u_nextyear < {0} or ( u_nextyear = {0} and u_nextper  < {1} ) ) " +
                    "   and isnull(u_debaja,'N')  <> 'Y' ",
                    'Select COUNT(*) "cant" from "@VID_AFAS" ' +
                    ' where ( "U_NextYear" < {0} or ( "U_NextYear" = {0} and "U_NextPer"  < {1} ) ) ' +
                    '   and ifnull("U_DeBaja",''N'')  <> ''Y'' ');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2) );
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Activos sin procesar en periodos anteriores a fecha de utilización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            oRecordSet.DoQuery(s);
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select COUNT(*) cant from [@VID_AFUS] " +
                    " where U_Year = {0} and U_Periodo = {1}",
                    'Select COUNT(*) "cant" from "@VID_AFUS" ' +
                    ' where "U_Year" = {0} and "U_Periodo" = {1}');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2) );
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Utilización para este periodo ya ingresado.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
         end;
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') then begin
            sValue := EditText(oMtx.Columns.Item('ActCode').Cells.Item(pVal.Row).Specific).Value;
            if (sValue = '') then
               exit;
            for i:=1 to oMtx.RowCount do begin
               if (sValue = EditText(oMtx.Columns.Item('ActCode').Cells.Item(i).Specific).Value) and (pVal.Row <> i) then begin
                  bubbleEvent := false;
                  FSBOApp.StatusBar.SetText("Activo ya ingresado en lista de revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               end;
            end;
         end;
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'GrpCode') then begin
            sValue := EditText(oMtx.Columns.Item('GrpCode').Cells.Item(pVal.Row).Specific).Value;
            if (sValue = '') then
               exit;
            for i:=1 to oMtx.RowCount do begin
               if (sValue = EditText(oMtx.Columns.Item('GrpCode').Cells.Item(i).Specific).Value) and (pVal.Row <> i) then begin
                  bubbleEvent := false;
                  FSBOApp.StatusBar.SetText("Grupo ya ingresado en lista de revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               end;
            end;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_VALIDATE) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'Fecha') then begin
            sValue  := oForm.DataSources.DBDataSources.Item('@VID_AFUS').GetValue('U_Fecha', 0);
            if (sValue = '') then begin
               oForm.DataSources.DBDataSources.Item('@VID_AFUS').SetValue('U_Periodo', 0, '');
               oForm.DataSources.DBDataSources.Item('@VID_AFUS').SetValue('U_Year'   , 0, '');
               oForm.DataSources.DBDataSources.Item('@VID_AFUS').SetValue('U_YearPer', 0, '');
            end
            else begin
               sValaux := sValue.Substring(4,2);
               sValue  := sValue.Substring(0,4); 
               oForm.DataSources.DBDataSources.Item('@VID_AFUS').SetValue('U_Periodo', 0, sValAux);
               oForm.DataSources.DBDataSources.Item('@VID_AFUS').SetValue('U_Year'   , 0, sValue);
               oForm.DataSources.DBDataSources.Item('@VID_AFUS').SetValue('U_YearPer', 0, (Int32.Parse(sValue)*100+Int32.Parse(sValAux)).ToString);
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') and (oForm.Mode = BoFormMode.fm_ADD_MODE) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox('¿Ingresar utilización de activo?. Se modificará la vida util en grupos de activos al procesar.', 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(var oForm, var oMtx)) then
               exit;
            BubbleEvent := true;
         end

         else if (pVal.ItemUID = '1') and (oForm.Mode = BoFormMode.fm_UPDATE_MODE) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox('¿Actualizar utilización de activo?. Se modificará la vida util en grupos de activos al procesar.', 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(var oForm, var oMtx)) then
               exit;
            BubbleEvent := true;
         end;

         if (pVal.ItemUID = 'btnDel') and (oForm.Mode = BoFormMode.fm_OK_MODE) and (oForm.Mode <> BoFormMode.fm_ADD_MODE) then begin
            DeleteUso(var oForm);
         end;
      end;

   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' ** trace ' + e.StackTrace);
      end;
   end;
end;

method TUsoActivos.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm      : SAPbouiCOM.Form;
   Pr, Yr     : integer;
   s          : String;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);

   oForm   := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);

   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (not BusinessObjectInfo.BeforeAction) and (BusinessObjectInfo.ActionSuccess) then begin
      Yr := FSBOf.StrToInteger(oForm.DataSources.DBDataSources.Item('@VID_AFUS').GetValue('U_Year'   , 0));
      Pr := FSBOf.StrToInteger(oForm.DataSources.DBDataSources.Item('@VID_AFUS').GetValue('U_Periodo', 0));

      s := iif(GlobalSettings.RunningUnderSQLServer, 
              "Select COUNT(*) cant from [@VID_AFAC] " +
              " where U_Year = {0} and U_Periodo = {1}",
              'Select COUNT(*) "cant" from "@VID_AFAC" ' +
              ' where "U_Year" = {0} and "U_Periodo" = {1}');
      s := string.Format(s, Yr.ToString, Pr.ToString );
      oRecordSet.DoQuery(s);
      if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
         oForm.Mode := BoFormMode.fm_VIEW_MODE;
         oForm.Items.Item('btnDel').Visible := false;
      end
      else begin
         oForm.Mode := BoFormMode.fm_OK_MODE;
         oForm.Items.Item('btnDel').Visible := true;
      end;

   end;
end;

method TUsoActivos.ValidacionFinal(var oForm: SAPbouiCOM.Form;var mtx: SAPbouiCOM.Matrix): boolean;
var
   s :   string;
   s1:   string;
   i :   Integer;
   yr:   integer;
   pr:   integer;
begin
   try
      result := false;

      s := iif(GlobalSettings.RunningUnderSQLServer, 
              "Select isnull(Max(U_Year * 100 + U_Periodo),0) YearPer from [@VID_AFUS]",       
              'Select ifnull(Max("U_Year" * 100 + "U_Periodo"),0) "YearPer" from "@VID_AFUS"');   // Aplicar maximo año
      s := string.Format(s, Yr.ToString, Pr.ToString );
      oRecordSet.DoQuery(s);
      i  := System.Int32(oRecordSet.Fields.Item('YearPer').Value);
      yr := i div 100;
      pr := i - yr*100;

      s := oForm.DataSources.DBDataSources.Item("@VID_AFUS").GetValue("U_Fecha", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar la fecha de la utilización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      s := oForm.DataSources.DBDataSources.Item("@VID_AFUS").GetValue("U_Year", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar el año de la utilización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      s := oForm.DataSources.DBDataSources.Item("@VID_AFUS").GetValue("U_Periodo", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar el periodo de la utilización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      i := mtx.RowCount;
      while (i > 0) do begin
         s  := EditText(mtx.Columns.Item("ActCode").Cells.Item(i).specific).value;
         s1 := EditText(mtx.Columns.Item("GrpCode").Cells.Item(i).specific).value;
         if (s = '') and (s1 = '') then
            mtx.DeleteRow(i);
         dec(i);
      end;

      for i:=1 to mtx.RowCount do begin
         s := EditText(mtx.Columns.Item("Uso").Cells.Item(i).specific).value;
         if (FSBOf.StringToDouble(s) <= 0) then begin
            FSBOApp.StatusBar.SetText("Utilización no puede ser menor o igual a 0 en linea: " + i.ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end;
         s := EditText(mtx.Columns.Item("SVidaNew").Cells.Item(i).specific).value;
         if (FSBOf.StringToDouble(s) < 0) then begin
            FSBOApp.StatusBar.SetText("Saldo de uso no puede ser menor a 0 en linea: " + i.ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end;
      end;

      result := true;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TUsoActivos.DeleteUso(var oForm: SAPbouiCOM.Form);
var
   oReval          : SAPbobsCOM.GeneralService;
   oRevalParameter : SAPbobsCOM.GeneralDataParams;
   s               : String;
begin
   oReval          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFUS'));
   oRevalParameter := SAPbobsCOM.GeneralDataParams(oReval.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

   s := oForm.DataSources.DBDataSources.Item('@VID_AFUS').GetValue('DocEntry', 0);
   oRevalParameter.SetProperty('DocEntry', FSBOf.StrToInteger(s));

   oReval.Delete(oRevalParameter);
 
   FSBOApp.StatusBar.SetText("Revalorazación eliminada.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
   oForm.DataSources.DBDataSources.Item('@VID_AFUS').Clear;
   oForm.DataSources.DBDataSources.Item('@VID_AFUSD').Clear;
   oForm.DataSources.DBDataSources.Item('@VID_AFUS').InsertRecord(0);
   oForm.DataSources.DBDataSources.Item('@VID_AFUSD').InsertRecord(0);
   Matrix(oForm.Items.Item('mtx_0').Specific).Clear;
   oForm.Mode := BoFormMode.fm_ADD_MODE;
end;

end.
