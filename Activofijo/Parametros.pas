namespace AF_IFRS.Parametros;

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
  AF_IFRS.ActivoObj;

type
  TParametros = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet : SAPbobsCOM.Recordset;
    Lista      : List<String>;
    ValorResid : Double;
    FActivo    : TActivo;
    PlanIFRS_Elegido : String := "";
    PlanIFRS_Original : String := "";
    method    ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
    method    AddChooseFromList(oForm: SAPbouiCOM.Form);
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    property   oActivoObj : TActivo read FActivo write FActivo;
  end;

implementation

uses
  System.Globalization;

method   TParametros.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm        : SAPbouiCOM.Form;
   oDBDSDetalle : SAPbouiCOM.DBDataSource;
   oSql         : string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista   := New List<String>;
   try
      try
         if (FCmpny.language = BoSuppLangs.ln_English) then
            FSBOf.LoadForm(xmlPath,'VID_Parametros_EN.srf', Uid)
         else
            FSBOf.LoadForm(xmlPath,'VID_Parametros.srf', Uid);

         oForm := FSBOApp.Forms.Item(uid);
         oForm.Freeze(True);
         oForm.AutoManaged    := True;

         SAPbouiCOM.CheckBox(oForm.Items.Item('ActbyLoc').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('ActbyLoc').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Flg').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Flg').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Fin').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Fin').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Ref').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Ref').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Aju').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Aju').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Dct').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Dct').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('AdicVdUt').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('AdicVdUt').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('RevBaja' ).Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('RevBaja' ).Specific).ValOff := 'N';

                              // Ok Ad  Fnd Vw Rq Sec
         Lista.Add( 'JoCorAct ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'JoDepAct ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'JoCorDep ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'DiaConta ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'Bis33Per ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'Bis33Top ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'ValResid ,  f,  t,  f,  f, r, 1');
         Lista.Add( 'FactDec  ,  f,  t,  f,  f, r, >0');

         oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select count(*) cant from [@VID_AFPA]", 
                     'Select count(*) "cant" from "@VID_AFPA"');
         oRecordSet.DoQuery(oSql);
  
         if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
            oForm.SupportedModes := 1;
            oForm.Mode           := BoFormMode.fm_OK_MODE;
         end
         else begin
            oForm.SupportedModes := 3;
            oForm.Mode           := BoFormMode.fm_ADD_MODE;
         end;

         // JoCorAct
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select TrnsCode Code, TrnsCodDsc Name FROM otrc order by TrnsCodDsc", 
                     'Select "TrnsCode" "Code", "TrnsCodDsc" "Name" FROM OTRC order by "TrnsCodDsc"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('JoCorAct').Specific), var oRecordSet, true);
         // JoDepAct
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select TrnsCode Code, TrnsCodDsc Name FROM otrc order by TrnsCodDsc", 
                     'Select "TrnsCode" "Code", "TrnsCodDsc" "Name" FROM OTRC order by "TrnsCodDsc"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('JoDepAct').Specific), var oRecordSet, true);
         // JoCorDep
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select TrnsCode Code, TrnsCodDsc Name FROM otrc order by TrnsCodDsc", 
                     'Select "TrnsCode" "Code", "TrnsCodDsc" "Name" FROM OTRC order by "TrnsCodDsc"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('JoCorDep').Specific), var oRecordSet, true);
         // IPC
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select IdexCode Code, IndexName Name FROM OIDX order by IndexName", 
                     'Select "IdexCode" "Code", "IndexName" "Name" FROM OIDX order by "IndexName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('IPCInd').Specific), var oRecordSet, false);
         // UTM
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select IdexCode Code, IndexName Name FROM OIDX order by IndexName", 
                     'Select "IdexCode" "Code", "IndexName" "Name" FROM OIDX order by "IndexName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('Bis33Ind').Specific), var oRecordSet, false);
         // Planes IFRS 
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select COUNT(*) cant from sys.tables where name = '@VID_OACTH'", 
                     'Select COUNT(*) "cant" from (SELECT TABLE_NAME FROM  M_CS_TABLES WHERE SCHEMA_NAME = CURRENT_SCHEMA) a where TABLE_NAME = ''@VID_OACTH'' ');
         oRecordSet.DoQuery(oSql);
         if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
            if (FCmpny.language = BoSuppLangs.ln_English) then begin
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select 'Native' Code, 'IFRS Native SBO' Name UNION ALL Select Code, Name from [@VID_OACTH] ", 
                           'Select ''Native'' "Code", ''IFRS Native SBO'' "Name" from Dummy UNION ALL Select "Code", "Name" from "@VID_OACTH" ');
               oRecordSet.DoQuery(oSql);
            end
            else begin
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select 'Nativo' Code, 'IFRS SBO Nativo' Name UNION ALL Select Code, Name from [@VID_OACTH] ", 
                           'Select ''Nativo'' "Code", ''IFRS SBO Nativo'' "Name" from Dummy UNION ALL Select "Code", "Name" from "@VID_OACTH" ');
               oRecordSet.DoQuery(oSql);
            end;
            FSBOf.FillCombo(ComboBox(oForm.Items.Item('PlanIFRS').Specific), var oRecordSet, true);
         end
         else begin
            if (FCmpny.language = BoSuppLangs.ln_English) then begin
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select 'Native' Code, 'IFRS Native SBO' Name ", 
                           'Select ''Native'' "Code", ''IFRS Native SBO'' "Name" from Dummy ');
               oRecordSet.DoQuery(oSql);
            end
            else begin
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select 'Native' Code, 'IFRS Native SBO' Name ", 
                           'Select ''Nativo'' "Code", ''IFRS SBO Nativo'' "Name" from Dummy ');
               oRecordSet.DoQuery(oSql);
            end;
            FSBOf.FillCombo(ComboBox(oForm.Items.Item('PlanIFRS').Specific), var oRecordSet, true);
         end;

         //CFL
         AddChooseFromList(oForm);
         EditText(oForm.Items.Item('ItemCode').Specific).ChooseFromListUID   := 'CFL1';
         EditText(oForm.Items.Item('ItemCode').Specific).ChooseFromListAlias := 'ItemCode';

         if (oForm.SupportedModes = 1) then begin
            oDBDSDetalle    := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFPA'));
            oDBDSDetalle.Query(nil);
            ValorResid        := FSBOf.StrToDouble(oDBDSDetalle.GetValue('U_ValResid', 0));
            PlanIFRS_Elegido  := oDBDSDetalle.GetValue('U_PlanIFRS', 0);
            PlanIFRS_Original := oDBDSDetalle.GetValue('U_PlanIFRS', 0);

            if (oDBDSDetalle.GetValue('U_PlanIFRS', 0).Trim = "") or (oDBDSDetalle.GetValue('U_PlanIFRS', 0).Trim = "Nativo") then begin
               oForm.Items.Item("ConMSCFi").Enabled := true;
               oForm.Items.Item("DepUsoAc").Enabled := true;
            end
            else begin
               oForm.Items.Item("ConMSCFi").Enabled := false;
               oForm.Items.Item("DepUsoAc").Enabled := false;
            end;
         end;
      except
         on e:exception do begin
            FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            OutLog(e.Message + ' - ' + e.StackTrace);
         end;
      end;
   finally
         oForm.Freeze(False);
         oForm.Visible := true;
   end;
end;

method   TParametros.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oDBDSDetalle    : SAPbouiCOM.DBDataSource;
   sValue          : string;
   oDataTable      : SAPbouiCOM.DataTable;
   s : String;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm := FSBOApp.Forms.Item(pVal.FormUID);

   try

      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'ItemCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            if (oForm.Mode = SAPbouiCOM.BoFormMode.fm_OK_MODE) then 
              oForm.Mode := SAPbouiCOM.BoFormMode.fm_UPDATE_MODE;

            try
               sValue  := System.String(oDataTable.GetValue('ItemCode', 0));
               //sValaux := System.String(oDataTable.GetValue('CardName', 0));
            except
               ;
            end;

            if oForm.DataSources.DBDataSources.Item('@VID_AFPA').GetValue('U_TipoDoc', 0).Trim <> "" then
            begin
              if (GlobalSettings.RunningUnderSQLServer) then
                s := "SELECT InvntItem FROM OITM WHERE ItemCode = '{0}'"
              else
                s := 'SELECT "InvntItem" FROM "OITM" WHERE "ItemCode" = ''{0}'' '; 
              s := String.Format(s, sValue); 
              oRecordSet.DoQuery(s);
              if (System.String(oRecordSet.Fields.Item("InvntItem").Value).Trim = "N") and (oForm.DataSources.DBDataSources.Item('@VID_AFPA').GetValue('U_TipoDoc', 0).Trim = "T") then
                  FSBOApp.StatusBar.SetText("Debe seleccionar un articulo inventariable", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
              else
                  oForm.DataSources.DBDataSources.Item('@VID_AFPA').SetValue('U_ItemCode', 0, sValue);
            end
            else
              FSBOApp.StatusBar.SetText("Debe seleccionar primero Tipo documento", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (not pVal.BeforeAction) then begin
         oDBDSDetalle    := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFPA'));
         if (oDBDSDetalle.GetValue('U_PlanIFRS', 0).Trim = "") and (PlanIFRS_Elegido <> oDBDSDetalle.GetValue('U_PlanIFRS', 0).Trim) then begin
            oForm.Items.Item("ConMSCFi").Enabled := true;
            oForm.Items.Item("DepUsoAc").Enabled := true;
            oDBDSDetalle.SetValue('U_ConMSCFi', 0, "N");
            oDBDSDetalle.SetValue('U_DepUsoAc', 0, "N");
         end
         else begin
            oForm.Items.Item("ConMSCFi").Enabled := false;
            oForm.Items.Item("DepUsoAc").Enabled := false;
            oDBDSDetalle.SetValue('U_ConMSCFi', 0, "N");
            oDBDSDetalle.SetValue('U_DepUsoAc', 0, "N");
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
           BubbleEvent := ValidacionFinal(oForm);
           if (not BubbleEvent) then
              Exit;
         end;
         if (pVal.ItemUID = '1') and (oForm.SupportedModes = 3) then begin
           EditText(oForm.Items.Item('Code').specific).Value := '1';
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') and (pVal.ActionSuccess) then begin
            oDBDSDetalle    := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFPA'));
            if (oDBDSDetalle.GetValue('U_PlanIFRS', 0) <> PlanIFRS_Elegido) then begin
               PlanIFRS_Elegido := oDBDSDetalle.GetValue('U_PlanIFRS', 0);
               
               FActivo.DeleteMenus();
               FActivo.AddMenus();
            end;
         end;
         if (pVal.ItemUID = '1') and (oForm.SupportedModes = 3) and (pVal.ActionSuccess) then begin
              oForm.SupportedModes := 1;
              oDBDSDetalle := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFPA'));
              oDBDSDetalle.Query(nil);
              oForm.Mode := BoFormMode.fm_OK_MODE;
         end;
      end

   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TParametros.ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
var
   oSql, s : string;
   oDBDS   : SAPbouiCOM.DBDataSource;
begin
   try
      result := false;

      oDBDS := oForm.DataSources.DBDataSources.Item('@VID_AFPA');
      if (FSBOf.StrToDouble(oDBDS.GetValue('U_ValResid', 0)) <> 0) and (FSBOf.StrToDouble(oDBDS.GetValue('U_ValResid', 0)) <> ValorResid) then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select count(*) cant from  [@VID_AFAS] where U_ValResid <> 0", 
                     'Select Count(*) "cant" from  "@VID_AFAS" where "U_ValResid" <> 0');
         oRecordSet.DoQuery(oSql);
         if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
            raise new Exception('Activo fijo con valor residual, no puede modificar este parametro.');
      end;

      if (oDBDS.GetValue('U_PlanIFRS', 0) <> PlanIFRS_Original) and (PlanIFRS_Original <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select count(*) cant from  [@VID_AFAC] where U_PostFlag = 'Y' ", 
                     'Select Count(*) "cant" from  "@VID_AFAC" where "U_PostFlag" = ''Y'' ');
         oRecordSet.DoQuery(oSql);
         if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
            if (1 = FSBOApp.MessageBox(' Modificar el plan contable afectara las contabilizaciones y reversas. ' +
                                       ' ¿ Desea continuar ?', 1, 'Cancel', 'Ok', '')) then
               exit;
      end;

      if (oDBDS.GetValue('U_Bis33Fin', 0) = '') then
         oDBDS.SetValue('U_Bis33Fin', 0, 'N');
      if (oDBDS.GetValue('U_Bis33Ref', 0) = '') then
         oDBDS.SetValue('U_Bis33Ref', 0, 'N');
      if (oDBDS.GetValue('U_Bis33Aju', 0) = '') then
         oDBDS.SetValue('U_Bis33Aju', 0, 'N');
      if (oDBDS.GetValue('U_Bis33Dct', 0) = '') then
         oDBDS.SetValue('U_Bis33Dct', 0, 'N');

      if (oDBDS.GetValue('U_Bis33Flg', 0) = 'Y') then begin
         if (oDBDS.GetValue('U_Bis33Fin', 0) = 'N') and (oDBDS.GetValue('U_Bis33Ref', 0) = 'N') then
            raise new Exception('Bis33 esta activo, debe activarse Bis33 Referencial o Bis33 Financiero o ambos.');
         if (FSBOf.StrToDouble(oDBDS.GetValue('U_Bis33Per', 0)) = 0.0) then
            raise new Exception('Bis33 esta activo, debe ingresar porcentaje.');
         if (FSBOF.StrToDouble(oDBDS.GetValue('U_Bis33Top', 0)) = 0.0) then
            raise new Exception('Bis33 esta activo, debe ingresar tope UTM.');
         if (oDBDS.GetValue('U_Bis33Ind', 0) = '') then
            raise new Exception('Bis33 esta activo, debe ingresar indice.');
      end;

      //if (oDBDS.GetValue('U_ConMSCFi', 0) = 'Y') and (oDBDS.GetValue('U_PostSysCu', 0) = 'Y') then  // ConMSCFi
      //   raise new Exception('Solo se puede seleccionar la opción 1)Contabilizar con tasa fija o la opción 2)Utilizar moneda del sistema para contabilizar. Pero no ambas simultaneamente');

      s := FSBOf.VerificarItemsRequeridos(oForm, Lista);
      if (s <> '') then begin
         FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      result := true;
   except
      on e:exception do begin
         OutLog(e.Message + ' - ' + e.StackTrace);
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TParametros.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
            oCFLCreationParams.ObjectType := '4';    // 2 => BP
            oCFLCreationParams.UniqueID   := 'CFL1';
            oCFL := oCFLs.Add(oCFLCreationParams);

//            oCons := oCFL.GetConditions();
//            oCon := oCons.Add();
//            oCon.Alias := 'CardType';
//            oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
//            oCon.CondVal := 'L';
//            oCFL.SetConditions(oCons);
    end;

end.