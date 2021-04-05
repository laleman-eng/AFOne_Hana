namespace AF_IFRS.Adiciones;

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
  TAdiciones = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet:  SAPbobsCOM.Recordset;
    Lista:       List<String>;
    ListaMx:     List<String>;
    oCode:       string;
    oUltFecProc: DateTime;
    Valor_resid  : Double;
    method    AddChooseFromList(oForm: SAPbouiCOM.Form);
    method    UpdateActivo(oForm: SAPbouiCOM.Form);
    method    BorrarLinea(oForm: SAPbouiCOM.Form);
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TAdiciones.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
   oMatrix:  SAPbouiCOM.Matrix;
   oSql:     string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista   := new List<String>;
   ListaMx := new List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_Adiciones_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_Adiciones.srf', Uid);

      oForm := FSBOApp.Forms.Item(uid);
      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := 1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_OK_MODE;
      VID_DelRow          := true;

      oMatrix := Matrix(oForm.Items.Item('Mx_Adicion').Specific);
      oMatrix.Columns.Item('Year').Editable := false;
      oMatrix.Columns.Item('Periodo').Editable := false;
      oMatrix.Columns.Item('PerVidUt').Editable := true;

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select U_AdicVdUt, U_ValResid from [@VID_AFPA]", 
                  'Select "U_AdicVdUt", "U_ValResid" from "@VID_AFPA"');
      oRecordSet.DoQuery(oSql);
      if (oRecordSet.EoF) then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         oForm.Close;
         exit;
      end;
      
      if (System.String(oRecordSet.Fields.Item('U_AdicVdUt').Value) <> 'Y') then
         oMatrix.Columns.Item('PerVidUt').Editable := false;

      Valor_Resid := System.Double(oRecordSet.Fields.Item('U_ValResid').Value);

      // Grupos
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select  code,  name from [@VID_AFGR] order by name", 
                  'Select  "Code" "code", "Name" "name" from "@VID_AFGR" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('ItmGrpCd').Specific), var oRecordSet, true);

      // CFL CardCode
      AddChooseFromList(oForm);
      EditText(oForm.Items.Item('ActCode').Specific).ChooseFromListUID   := 'CFL1';
      EditText(oForm.Items.Item('ActCode').Specific).ChooseFromListAlias := 'U_ActCode';

      oForm.DataSources.UserDataSources.Add('DSEmpName',SAPbouiCOM.BoDataType.dt_LONG_TEXT,100);
      EditText(oForm.Items.Item('EmpName').Specific).DataBind.SetBound(true,'','DSEmpName');

      oForm.DataSources.UserDataSources.Add('DSValResi',SAPbouiCOM.BoDataType.dt_PRICE,12);
      oForm.DataSources.UserDataSources.Add('DSValNeto',SAPbouiCOM.BoDataType.dt_PRICE,12);
      EditText(oForm.Items.Item('ValorResi').Specific).DataBind.SetBound(true,'','DSValResi');
      EditText(oForm.Items.Item('ValorNeto').Specific).DataBind.SetBound(true,'','DSValNeto');

      oForm.Freeze(False);
      oForm.Update;
      oForm.Visible := true;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

   method TAdiciones.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
            oCFLCreationParams.ObjectType := 'VID_mAFAS';    // 1VID_mAFGR => Grupos
            oCFLCreationParams.UniqueID   := 'CFL1';
            oCFL := oCFLs.Add(oCFLCreationParams);

            oCons := oCFL.GetConditions();
            oCon := oCons.Add();
            oCon.Alias := 'U_DeBaja';
            oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
            oCon.CondVal := 'Y';
            oCon.Relationship := BoConditionRelationship.cr_OR;
            oCon := oCons.Add();
            oCon.Alias := 'U_DeBaja';
            oCon.Operation := BoConditionOperation.co_IS_NULL;
            oCFL.SetConditions(oCons);
    end;

method TAdiciones.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm      : SAPbouiCOM.Form;
   oDBDSH     : SAPbouiCOM.DBDataSource;
   oDBDSD     : SAPbouiCOM.DBDataSource;
   oCons      : SAPbouiCOM.Conditions;
   oCon       : SAPbouiCOM.Condition;
   oDataTable : SAPbouiCOM.DataTable;
   oMatrix    : SAPbouiCOM.Matrix;
   sValue     : string;
   s               : string;
   y, m, d         : integer;
   s1,s2           : string;
   IniYr, IniPr    : string;
   oSql            : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);
   oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFAS');
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFAD');
   oMatrix := Matrix(oForm.Items.Item('Mx_Adicion').Specific);

   try
    try
      oForm.Freeze(True);

      // CFL
      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'ActCode')  then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            sValue := '';
            try
               sValue  := System.String(oDataTable.GetValue('U_ActCode', 0));
            except
               ;
            end;

            oDBDSH.Clear;
            oDBDSD.Clear;
            oMatrix.LoadFromDataSource;
            oCode         := '';

            if (sValue <> '') then begin
               try
                  oCons := new SAPbouiCOM.ConditionsClass;
                  oCon  := oCons.Add();

                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select Code, U_NextYear, U_NextPer from [@VID_AFAS] where U_ActCode = '{0}'", 
                              'Select "Code", "U_NextYear", "U_NextPer" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
                  oSql := string.Format(oSql, sValue);
                  oRecordSet.DoQuery(oSql);
                  oCode       :=  System.String(oRecordSet.Fields.Item('Code').Value).Trim;

                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select isnull(max(u_year*12 + u_periodo-1), 22800) Fecha_Proc from [@vid_afac] " +
                              " where code =  '{0}'", 
                              'Select IfNull(max("U_Year" * 12 + "U_Periodo" - 1), 22800) "Fecha_Proc" from "@VID_AFAC" ' +
                              ' where "Code" = ''{0}''');
                  oSql := string.Format(oSql, oCode);
                  oRecordSet.DoQuery(oSql);
                  oUltFecProc := TMultiFunctions.EncodeDate(System.int32( oRecordSet.Fields.Item('Fecha_Proc').Value ) div 12,
                                            System.int32( oRecordSet.Fields.Item('Fecha_Proc').Value ) mod 12 + 1,
                                            1);
                  oUltFecProc := oUltFecProc.AddMonths(1);

                  oCon.Alias := 'Code';
                  oCon.Operation := BoConditionOperation.co_EQUAL;
                  oCon.CondVal := oCode;
                  oDBDSH.Query(oCons);

                  s := oDBDSH.GetValue('U_EmpId', 0);
                  if (s <> '') then begin
                     oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                                 "Select empid, firstname, lastname, branch from ohem where EmpId = {0}", 
                                 'Select "empID" "empid", "firstName" "firstname", "lastName" lastname, "branch" from OHEM where "empID" = {0}');
                     oSql := string.Format(oSql, s);
                     oRecordSet.DoQuery(oSql);
                     s := System.String(oRecordSet.Fields.Item('lastname').Value) + ', ' +
                          System.String(oRecordSet.Fields.Item('firstname').Value);
                  end;
                  oForm.DataSources.UserDataSources.Item('DSEmpName').Value := s;

                  IniYr := oDBDSH.GetValue('U_NextYear', 0);
                  IniPr := TMultiFunctions.inttostr(TMultiFunctions.strtoint(oDBDSH.GetValue('U_NextPer', 0)) - 1);

                  if (TMultiFunctions.StrToInt(IniPr) = 0) then begin
                    IniYr := TMultiFunctions.inttostr(TMultiFunctions.strtoint(IniYr) - 1);
                    IniPr := '12';
                  end;

                  s1 := oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_InitYear', 0);
                  if (s1 = '')  then
                     s1 := '0';
                  s2 := oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_InitPer', 0);
                  if (s2 = '')  then
                     s2 := '0';

                  if (GlobalSettings.IFRSNativo) and (FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CorAnuAc', 0)) > 0) then 
                     s := FSBOf.DoubleToStr( FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CorAnuAc', 0)) +
                                             FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_AdicAnuC', 0)) )
                  else
                     s := FSBOf.DoubleToStr( FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CurVal'  , 0)) +
                                             FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CorAnuAc', 0)) +
                                             FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_AdicAnuC', 0)) );
                  oForm.DataSources.UserDataSources.Item('DSValNeto').ValueEx := s;

                  if (GlobalSettings.IFRSNativo) then 
                     s := FSBOf.DoubleToStr( FSBOf.StrToDouble(s) -
                                             (FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DepAcum' , 0)) +
                                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DepreAnu', 0)))  )
                  else
                     s := FSBOf.DoubleToStr( FSBOf.StrToDouble(s) -
                                             (FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DepAcum' , 0)) +
                                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CorAnuDe', 0)) +
                                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_Bis33Fin', 0)) +
                                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DepreAnu', 0)))  );
                  oForm.DataSources.UserDataSources.Item('DSValResi').ValueEx := s;
                  if (FSBOf.StringToDouble(s) = 0.0) then
                      oForm.DataSources.UserDataSources.Item('DSValResi').ValueEx := FSBOf.DoubleToStr(Valor_Resid);

                  oCon.Alias := 'Code';
                  oCon.Operation := BoConditionOperation.co_EQUAL;
                  oCon.CondVal := oCode;
                  oDBDSD.Query(oCons);

                  oMatrix.LoadFromDataSource;

               finally
                  FSBOf._ReleaseCOMObject(oCons)
               end;
            end;

            oDBDSD.Offset := 0;
            if (oDBDSD.Size = 0) then
               oDBDSD.InsertRecord(0);

            oDBDSD.SetValue('U_Procesad' , 0, 'N');
            oDBDSD.SetValue('U_Adicion'  , 0, '');
            oDBDSD.SetValue('U_Descrip'  , 0, '');
            oDBDSD.SetValue('U_Valor'    , 0, '');
            oDBDSD.SetValue('U_ValorAct' , 0, '');
            oDBDSD.SetValue('U_PerVidUt' , 0, '');
            oDBDSD.SetValue('U_Fecha'    , 0, '');
            oDBDSD.SetValue('U_Year'     , 0, '');
            oDBDSD.SetValue('U_Periodo'  , 0, '');
            oMatrix.AddRow(1, oMatrix.RowCount);

            oForm.Mode := BoFormmode.fm_OK_MODE;
         end;
      end
      // No permite modificar lo procesado
      else if (pVal.EventType = BoEventTypes.et_GOT_FOCUS) and (pVal.Row > -1) then begin
         if ( CheckBox(oMatrix.Columns.Item('Procesad').Cells.Item(pVal.Row).Specific).Checked ) then begin
            FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Adicion_Procesada],  BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            oForm.Items.Item('ActCode').Click(BoCellClickType.ct_Regular);
         end;
      end

      // Validación de valores
      else if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction) and (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) then begin
         if (pVal.ColUID = 'Adicion') then begin
            sValue := EditText(oMatrix.Columns.Item('Adicion').Cells.Item(pVal.Row).Specific).Value;
            if (oMatrix.RowCount = pVal.Row) and (sValue <> '') then begin
               oDBDSD.SetValue('U_Procesad' , 0, 'N');
               oDBDSD.SetValue('U_Adicion'  , 0, '');
               oDBDSD.SetValue('U_Descrip'  , 0, '');
               oDBDSD.SetValue('U_Valor'    , 0, '');
               oDBDSD.SetValue('U_ValorAct' , 0, '');
               oDBDSD.SetValue('U_PerVidUt' , 0, '');
               oDBDSD.SetValue('U_Fecha'    , 0, '');
               oDBDSD.SetValue('U_Year'     , 0, '');
               oDBDSD.SetValue('U_Periodo'  , 0, '');
               oMatrix.AddRow(1, oMatrix.RowCount);
            end;
         end;

         if (pVal.ColUID = 'Fecha') then begin
            sValue := EditText(oMatrix.Columns.Item('Fecha').Cells.Item(pVal.Row).Specific).Value;
            if (sValue = '') then
               exit
            else if (FSBOf.StrToDate(sValue) < FSBOf.StrToDate(oDBDSH.GetValue('U_InDate', 0))) then begin;
                FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Adicion_Fecha_Anterior], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                BubbleEvent := false;
            end
            else if (FSBOf.StrToDate(sValue) < oUltFecProc) then begin;
                FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Adicion_Fecha_Posterior], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                BubbleEvent := false;
            end
            else begin
               sValue  := EditText(oMatrix.Columns.Item('Fecha').Cells.Item(pVal.Row).Specific).Value;
                y := FSBOf.StrToDate(sValue).Year;
                m := FSBOf.StrToDate(sValue).Month;
                d := FSBOf.StrToDate(sValue).Day;
               EditText(oMatrix.Columns.Item('Year').Cells.Item(pVal.Row).Specific).Value := TMultiFunctions.inttostr(y);
               EditText(oMatrix.Columns.Item('Periodo').Cells.Item(pVal.Row).Specific).Value := TMultiFunctions.inttostr(m);
            end;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) and  (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE)  then begin
         if (pVal.ItemUID = '1') then begin
            BubbleEvent := false;
            if (1 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Adicion_Procesar_QM], 1, 'Ok', 'Cancelar','')) then
               UpdateActivo(oForm);
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) and  ((BoFormMode(pVal.FormMode) = BoFormMode.fm_OK_MODE) or (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE))  then begin
         if (pVal.ItemUID = 'Borrar') then begin
            BubbleEvent := false;
            if (1 = FSBOApp.MessageBox("¿Desea borrar Adición?", 1, 'Ok', 'Cancelar','')) then
               BorrarLinea(oForm);
            if (BoFormMode(pVal.FormMode) = BoFormMode.fm_OK_MODE) then
               oForm.Mode := BoFormMode.fm_UPDATE_MODE;
         end;
      end

    finally 
      oForm.Freeze(False);
    end;
   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TAdiciones.UpdateActivo(oForm: SAPbouiCOM.Form);
var
   oActivos           : SAPbobsCOM.GeneralService;
   oActivosData       : SAPbobsCOM.GeneralData;
   oActivosParameter  : SAPbobsCOM.GeneralDataParams;
   oActivosLines      : SAPbobsCOM.GeneralDataCollection;
   oActivosLinesData  : SAPbobsCOM.GeneralData;

   oMtx               : SAPbouiCOM.Matrix;
   oDBDSH             : SAPbouiCOM.DBDataSource;
   oDBDSD             : SAPbouiCOM.DBDataSource;
   s                  : string;
   i                  : integer;
begin
   try
      oActivos          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));
      oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

         oMtx    := Matrix(oForm.Items.Item('Mx_Adicion').Specific);
         oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFAS');
         oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFAD');

         s := oDBDSH.GetValue('Code', 0);
         oActivosParameter.SetProperty('Code', s);
         oActivosData := oActivos.GetByParams(oActivosParameter);

         oActivosLines     := oActivosData.Child('VID_AFAD');
         oActivosLinesData := oActivosLines.Add;

         // Borrar lo existente;
         i := 0;
         while (i <= oActivosLines.Count - 1) do
            oActivosLines.Remove(i);

         oMtx.FlushToDataSource;
         // Agregar Datos
         for i:=0 to oDBDSD.Size-1 do begin
            if (oDBDSD.GetValue('U_Adicion'  , i).Trim = '') and (oDBDSD.GetValue('U_Fecha'  , i).Trim = '') then
               Continue;
            if (oDBDSD.GetValue('U_Fecha'  , i).Trim = '') then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Linea_Fecha_invalida] + i.ToString);
            if (FSBOf.StrToDouble( oDBDSD.GetValue('U_Valor'    , i)) < 0) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Linea_Valor_Negativo] + i.ToString);
            if (FSBOf.StrToDouble( oDBDSD.GetValue('U_ValorAct' , i)) < 0) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Linea_Valor_Negativo] + i.ToString);
            if (FSBOf.StrToDouble( oDBDSD.GetValue('U_PerVidUt' , i)) < 0) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Linea_Periodo_Negativo] + i.ToString);

            oActivosLinesData := oActivosLines.Add;

            oActivosLinesData.SetProperty('U_Procesad', oDBDSD.GetValue('U_Procesad' , i) );
            oActivosLinesData.SetProperty('U_Adicion' , oDBDSD.GetValue('U_Adicion'  , i) );
            oActivosLinesData.SetProperty('U_Descrip' , oDBDSD.GetValue('U_Descrip'  , i) );
            oActivosLinesData.SetProperty('U_Valor'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_Valor'    , i)) );
            oActivosLinesData.SetProperty('U_ValorAct', FSBOf.StrToDouble(oDBDSD.GetValue('U_ValorAct' , i)) );
            oActivosLinesData.SetProperty('U_PerVidUt', FSBOf.StrToInteger(oDBDSD.GetValue('U_PerVidUt' , i)) );
            oActivosLinesData.SetProperty('U_Fecha'   , FSBOf.StrToDate(oDBDSD.GetValue('U_Fecha'    , i)) );
            oActivosLinesData.SetProperty('U_Year'    , FSBOf.StrToInteger(oDBDSD.GetValue('U_Year'     , i)) );
            oActivosLinesData.SetProperty('U_Periodo' , FSBOf.StrToInteger(oDBDSD.GetValue('U_Periodo'  , i)) );
         end;

         oActivos.Update(oActivosData);
         oDBDSH.Clear;
         oDBDSH.InsertRecord(0);
         oDBDSD.Clear;
         oMtx.LoadFromDataSource;
         oCode         := '';

         FSBOApp.StatusBar.SetText('Ok',  BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
         oForm.Mode := BoFormMode.fm_OK_MODE;
   finally

   end;
end;


method TAdiciones.BorrarLinea(oForm: SAPbouiCOM.Form);
var
   oMtx               : SAPbouiCOM.Matrix;
   i                  : integer;
begin
   try
         oMtx    := Matrix(oForm.Items.Item('Mx_Adicion').Specific);
         // Borrar lo existente;
         i := 1;
         while (i <= oMtx.RowCount) do begin
              if oMtx.IsRowSelected(i) then begin
                if ( CheckBox(oMtx.Columns.Item('Procesad').Cells.Item(i).Specific).Checked ) then 
                  FSBOApp.StatusBar.SetText('Linea ya se encuentra procesada, no se puede borrar',  BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning)
                else
                begin
                  oMtx.DeleteRow(i); 
                  FSBOApp.StatusBar.SetText('Ok Borrado',  BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
                end;
                break;
              end;
             inc(i); 
         end;
         oMtx.FlushToDataSource;
   finally

   end;
end;

end.