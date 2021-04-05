namespace AF_IFRS.UbicacionesActivos;

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
  TUbicacionesActivos = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet : SAPbobsCOM.Recordset;
    Lista      : List<String>;
    FLocCode   : String;
    method  AddChooseFromList(oForm: SAPbouiCOM.Form);
    method  AddChooseFromList2(oForm: SAPbouiCOM.Form);
    method  ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
    method  SetComboAddress(oForm: SAPbouiCOM.Form);
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    Property LocCode: string read FLocCode write FLocCode ;
  end;

implementation

uses
  System.Globalization;

method TUbicacionesActivos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var sboFunctions: VisualD.SBOFunctions.CSBOFunctions; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm: SAPbouiCOM.Form;
   oDBDS: SAPbouiCOM.DBDAtaSource;
   oCons: SAPbouiCOM.Conditions;
   oCon:  SAPbouiCOM.Condition;
   oSql:  string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista   := new List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_UbicacionesActivos_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_UbicacionesActivos.srf', Uid);

      oForm := FSBOApp.Forms.Item(uid);
      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := -1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_FIND_MODE;

                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'Code     , f,  t,  t,  f, r, 1');
      Lista.Add( 'Name     , t,  t,  t,  f, r, 1');
      Lista.Add( 'Address  , t,  t,  f,  f, r, 1');
      Lista.Add( 'CardName , f,  f,  f,  f, n, 1');
      FSBOf.SetAutoManaged(oForm, Lista);

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      // comunas
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  'select code, name from [@VID_AFCOMUNA] order by name',
                  'select "Code", "Name" from "@VID_AFCOMUNA" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('Comuna').Specific), var oRecordSet, true);
      // ciudades
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  'select code, name from [@VID_AFCIUDAD] order by name',
                  'select "Code", "Name" from "@VID_AFCIUDAD" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('Ciudad').Specific), var oRecordSet, true);

      //CFL
      AddChooseFromList(oForm);
      EditText(oForm.Items.Item('CardCode').Specific).ChooseFromListUID   := 'CFL1';
      EditText(oForm.Items.Item('CardCode').Specific).ChooseFromListAlias := 'CardCode';

      //CFL
      AddChooseFromList2(oForm);
      EditText(oForm.Items.Item('WhsCode').Specific).ChooseFromListUID   := 'CFL2';
      EditText(oForm.Items.Item('WhsCode').Specific).ChooseFromListAlias := 'WhsCode';

      if( LocCode <> '') then begin
         oDBDS    := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFLOC'));

         oCons := new SAPbouiCOM.ConditionsClass;
         oCon  := oCons.Add;
         oCon.Alias     := 'Code';
         oCon.Operation := BoConditionOperation.co_EQUAL;
         oCon.CondVal   := LocCode;

         oDBDS.Query(oCons);
      end;

      oForm.DataBrowser.BrowseBy := 'Code';
      oForm.Freeze(False);
      oForm.Update;

      oForm.Visible := true;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + '  ** trace ' +  e.StackTrace);
      end;
   end;
end;

   method TUbicacionesActivos.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
    end;

    method TUbicacionesActivos.AddChooseFromList2(oForm: SAPbouiCOM.Form);
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
            oCFLCreationParams.ObjectType := '64';    // 2 => BP
            oCFLCreationParams.UniqueID   := 'CFL2';
            oCFL := oCFLs.Add(oCFLCreationParams);

//            oCons := oCFL.GetConditions();
//            oCon := oCons.Add();
//            oCon.Alias := 'CardType';
//            oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
//            oCon.CondVal := 'L';
//            oCFL.SetConditions(oCons);
    end;

method   TUbicacionesActivos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   sValue          : string;
   sValaux         : string;
   oDataTable      : SAPbouiCOM.DataTable;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);

   try
      if (not EnableValidate) then
         exit;

      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'CardCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('CardCode', 0));
               sValaux := System.String(oDataTable.GetValue('CardName', 0));
            except
               ;
            end;
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_CardCode', 0, sValue);
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_CardName', 0, sValaux);
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_AddresSN', 0, '');
         end;

         if (pVal.ItemUID = 'WhsCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('WhsCode', 0));
               //sValaux := System.String(oDataTable.GetValue('WhsName', 0));
            except
               ;
            end;
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_WhsCode', 0, sValue);
//            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_CardName', 0, sValaux);
//            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_AddresSN', 0, '');
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_GOT_FOCUS) and (pVal.BeforeAction = false) and (pVal.ItemUID = 'AddresSN') then begin
         SetComboAddress(oForm);
      end;

      if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction = false) then begin
         if (pVal.ItemUID = 'CardCode') and (oForm.DataSources.DBDataSources.Item('@VID_AFLOC').GetValue('U_CardCode', 0).Trim = '') then begin
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_CardCode', 0, '');
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_CardName', 0, '');
            oForm.DataSources.DBDataSources.Item('@VID_AFLOC').SetValue('U_AddresSN', 0, '');
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = True) then begin
         if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualiza_ubicacion_QM], 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(oForm)) then
               exit;
            BubbleEvent := true;
         end

         else if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualiza_ubicacion_QM], 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(oForm)) then
               exit;
            BubbleEvent := true;
         end;
      end;

   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' ** trace ' + e.StackTrace);
      end;
   end;
end;

method TUbicacionesActivos.ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
var
   s:           string;
begin
   try
      result := true;
      s := FSBOf.VerificarItemsRequeridos(oForm, Lista);
      if (s <> '') then begin
         if (FCmpny.language = BoSuppLangs.ln_English) then
            FSBOApp.StatusBar.SetText('Field ' + s + ' Required' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
         else
            FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TUbicacionesActivos.SetComboAddress(oForm: SAPbouiCOM.Form);
var 
    oSql : string;
begin
   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT Address Code, '' Name FROM CRD1 " +
               " where AdresType = 'S' " +
               "   and CardCode  = '{0}' ",
               'SELECT "Address" "Code", '''' Name FROM CRD1 ' +
               ' where "AdresType" = ''S'' ' +
               '   and "CardCode"  = ''{0}'' ');
   oSql := string.Format(oSql, oForm.DataSources.DBDataSources.Item('@VID_AFLOC').GetValue('U_CardCode', 0));
   oRecordSet.DoQuery(oSql);
   FSBOf.FillCombo(ComboBox(oForm.Items.Item('AddresSN').Specific), var oRecordSet, true);
end;

end.
