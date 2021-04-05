namespace AF_IFRS.GrupoArticulos;

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
  TGrupoArticulos = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet : SAPbobsCOM.Recordset;
    Lista      : List<String>;
    PlanIFRS   : String;
    method   ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
    method   LlenarForm(oForm: SAPbouiCOM.Form);
    method   LimpiarForm(oForm: SAPbouiCOM.Form; oTodo: boolean);
    method   AddChooseFromList(oForm: SAPbouiCOM.Form);
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method   MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean); reintroduce;
    method   FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TGrupoArticulos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
   oSql :    string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista   := New List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_GrupoActivoFijo_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_GrupoActivoFijo.srf', Uid);

      oForm := FSBOApp.Forms.Item(uid);
      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := -1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_FIND_MODE;

      oForm.DataSources.UserDataSources.Add('DSDescAcFi',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DsDescCoAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescCoDA',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescDeAc',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescGaDe',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescGaBj',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescAdAc',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescReAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescDeAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DDescBis33',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIAcFi',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIDeAc',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIGaDe',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIGaBj',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIAdAc',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIReAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDesIDeAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      EditText(oForm.Items.Item('DescAcFi').Specific).DataBind.SetBound(true,'','DSDescAcFi');
      EditText(oForm.Items.Item('DescCoAF').Specific).DataBind.SetBound(true,'','DSDescCoAF');
      EditText(oForm.Items.Item('DescCoDA').Specific).DataBind.SetBound(true,'','DSDescCoDA');
      EditText(oForm.Items.Item('DescDeAc').Specific).DataBind.SetBound(true,'','DSDescDeAc');
      EditText(oForm.Items.Item('DescGaDe').Specific).DataBind.SetBound(true,'','DSDescGaDe');
      EditText(oForm.Items.Item('DescGaBj').Specific).DataBind.SetBound(true,'','DSDescGaBj');
      EditText(oForm.Items.Item('DescAdAc').Specific).DataBind.SetBound(true,'','DSDescAdAc');
      EditText(oForm.Items.Item('DescReAF').Specific).DataBind.SetBound(true,'','DSDescReAF');
      EditText(oForm.Items.Item('DescDeAF').Specific).DataBind.SetBound(true,'','DSDescDeAF');
      EditText(oForm.Items.Item('DescBis33').Specific).DataBind.SetBound(true,'','DDescBis33');
      EditText(oForm.Items.Item('DesIAcFi').Specific).DataBind.SetBound(true,'','DSDesIAcFi');
      EditText(oForm.Items.Item('DesIDeAc').Specific).DataBind.SetBound(true,'','DSDesIDeAc');
      EditText(oForm.Items.Item('DesIGaDe').Specific).DataBind.SetBound(true,'','DSDesIGaDe');
      EditText(oForm.Items.Item('DesIGaBj').Specific).DataBind.SetBound(true,'','DSDesIGaBj');
      EditText(oForm.Items.Item('DesIAdAc').Specific).DataBind.SetBound(true,'','DSDesIAdAc');
      EditText(oForm.Items.Item('DesIReAF').Specific).DataBind.SetBound(true,'','DSDesIReAF');
      EditText(oForm.Items.Item('DesIDeAF').Specific).DataBind.SetBound(true,'','DSDesIDeAF');


      oForm.DataSources.UserDataSources.Add('DSFmtActFi',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DsFmtCorAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtCorDA',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtDepAc',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtGasDe',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtGasBj',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtAdqAc',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtReaAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtDetAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtBis33',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIActFi',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIDepAc',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIGasDe',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIGasBj',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIAdqAc',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIReaAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmIDetAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      EditText(oForm.Items.Item('FmtActFi').Specific).DataBind.SetBound(true,'','DSFmtActFi');
      EditText(oForm.Items.Item('FmtCorAF').Specific).DataBind.SetBound(true,'','DSFmtCorAF');
      EditText(oForm.Items.Item('FmtCorDA').Specific).DataBind.SetBound(true,'','DSFmtCorDA');
      EditText(oForm.Items.Item('FmtDepAc').Specific).DataBind.SetBound(true,'','DSFmtDepAc');
      EditText(oForm.Items.Item('FmtGasDe').Specific).DataBind.SetBound(true,'','DSFmtGasDe');
      EditText(oForm.Items.Item('FmtGasBj').Specific).DataBind.SetBound(true,'','DSFmtGasBj');
      EditText(oForm.Items.Item('FmtAdqAc').Specific).DataBind.SetBound(true,'','DSFmtAdqAc');
      EditText(oForm.Items.Item('FmtReaAF').Specific).DataBind.SetBound(true,'','DSFmtReaAF');
      EditText(oForm.Items.Item('FmtDetAF').Specific).DataBind.SetBound(true,'','DSFmtDetAF');
      EditText(oForm.Items.Item('FmtBis33').Specific).DataBind.SetBound(true,'','DSFmtBis33');
      EditText(oForm.Items.Item('FmtIActFi').Specific).DataBind.SetBound(true,'','DSFmIActFi');
      EditText(oForm.Items.Item('FmtIDepAc').Specific).DataBind.SetBound(true,'','DSFmIDepAc');
      EditText(oForm.Items.Item('FmtIGasDe').Specific).DataBind.SetBound(true,'','DSFmIGasDe');
      EditText(oForm.Items.Item('FmtIGasBj').Specific).DataBind.SetBound(true,'','DSFmIGasBj');
      EditText(oForm.Items.Item('FmtIAdqAc').Specific).DataBind.SetBound(true,'','DSFmIAdqAc');
      EditText(oForm.Items.Item('FmtIReaAF').Specific).DataBind.SetBound(true,'','DSFmIReaAF');
      EditText(oForm.Items.Item('FmtIDetAF').Specific).DataBind.SetBound(true,'','DSFmIDetAF');

                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'Code     , f,  t,  t,  f, r, 1');
      Lista.Add( 'Name     , t,  t,  f,  f, r, 1');
      Lista.Add( 'IdSerie  , t,  t,  t,  f, n, 1');
      Lista.Add( 'ItmGrpCd , t,  t,  t,  f, n, 1');
      Lista.Add( 'VidaUtil,  t,  t,  t,  f, n, 1');
      Lista.Add( 'VidaUtiR,  t,  t,  t,  f, n, 1');
      Lista.Add( 'VidaUtiF,  t,  t,  t,  f, n, 1');
      FSBOf.SetAutoManaged(oForm, Lista);

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      PlanIFRS := nil;
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                 "Select U_PlanIFRS from [@VID_AFPA]", 
                 'Select "U_PlanIFRS" from "@VID_AFPA"');
      oRecordSet.DoQuery(oSql);
      if (not oRecordSet.EoF) then
         if (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value) <> '') and (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value) <> nil) then
            PlanIFRS := System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim;

      // Grupos asociados
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                 "Select CONVERT(VarChar,ItmsGrpCod) Code, ItmsGrpNam Name from OITB order by ItmsGrpNam", 
                 'Select Cast("ItmsGrpCod" as VarChar) "Code", "ItmsGrpNam" "Name" from OITB order by "ItmsGrpNam"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('ItmGrpCd').Specific), var oRecordSet, true);
      // Series asociadas
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                 "Select Code,  Name from [@VID_AFDEFSERIE] order by Name", 
                 'Select "Code",  "Name" from "@VID_AFDEFSERIE" order by "Name"');
      oRecordSet.DoQuery(oSql);
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('IdSerie').Specific), var oRecordSet, false);
      ComboBox(oForm.Items.Item('IdSerie').Specific).ValidValues.Add('', GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.No_Aplicar_Serie]);

      // CFL CardCode
      AddChooseFromList(oForm);
      EditText(oForm.Items.Item('FmtActFi').Specific).ChooseFromListUID   := 'CFL1';
      EditText(oForm.Items.Item('FmtActFi').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtCorAF').Specific).ChooseFromListUID   := 'CFL2';
      EditText(oForm.Items.Item('FmtCorAF').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtCorDA').Specific).ChooseFromListUID   := 'CFL3';
      EditText(oForm.Items.Item('FmtCorDA').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtDepAc').Specific).ChooseFromListUID   := 'CFL4';
      EditText(oForm.Items.Item('FmtDepAc').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtGasDe').Specific).ChooseFromListUID   := 'CFL5';
      EditText(oForm.Items.Item('FmtGasDe').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtGasBj').Specific).ChooseFromListUID   := 'CFL6';
      EditText(oForm.Items.Item('FmtGasBj').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtAdqAc').Specific).ChooseFromListUID   := 'CFL7';
      EditText(oForm.Items.Item('FmtAdqAc').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtReaAF').Specific).ChooseFromListUID   := 'CFL8';
      EditText(oForm.Items.Item('FmtReaAF').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtDetAF').Specific).ChooseFromListUID   := 'CFL9';
      EditText(oForm.Items.Item('FmtDetAF').Specific).ChooseFromListAlias := 'FormatCode';
      EditText(oForm.Items.Item('FmtBis33').Specific).ChooseFromListUID   := 'CFL10';
      EditText(oForm.Items.Item('FmtBis33').Specific).ChooseFromListAlias := 'FormatCode';

      if (GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo) then begin
         EditText(oForm.Items.Item('FmtIActFi').Specific).ChooseFromListUID   := 'CFL11';
         EditText(oForm.Items.Item('FmtIActFi').Specific).ChooseFromListAlias := 'U_FormatCo';
         EditText(oForm.Items.Item('FmtIReaAF').Specific).ChooseFromListUID   := 'CFL12';
         EditText(oForm.Items.Item('FmtIReaAF').Specific).ChooseFromListAlias := 'U_FormatCo';
         EditText(oForm.Items.Item('FmtIDetAF').Specific).ChooseFromListUID   := 'CFL13';
         EditText(oForm.Items.Item('FmtIDetAF').Specific).ChooseFromListAlias := 'U_FormatCo';
         EditText(oForm.Items.Item('FmtIDepAc').Specific).ChooseFromListUID   := 'CFL14';
         EditText(oForm.Items.Item('FmtIDepAc').Specific).ChooseFromListAlias := 'U_FormatCo';
         EditText(oForm.Items.Item('FmtIGasDe').Specific).ChooseFromListUID   := 'CFL15';
         EditText(oForm.Items.Item('FmtIGasDe').Specific).ChooseFromListAlias := 'U_FormatCo';
         EditText(oForm.Items.Item('FmtIGasBj').Specific).ChooseFromListUID   := 'CFL16';
         EditText(oForm.Items.Item('FmtIGasBj').Specific).ChooseFromListAlias := 'U_FormatCo';
         EditText(oForm.Items.Item('FmtIAdqAc').Specific).ChooseFromListUID   := 'CFL17';
         EditText(oForm.Items.Item('FmtIAdqAc').Specific).ChooseFromListAlias := 'U_FormatCo';
         oForm.Items.Item('tab1').Visible := true;
         oForm.Items.Item('tab2').Visible := true;
      end
      else begin
         oForm.Items.Item('tab1').Visible := false;
         oForm.Items.Item('tab2').Visible := false;
      end;

      if (GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo) then 
         oForm.PaneLevel := 1
      else if (GlobalSettings.IFRSActivo) then
         oForm.PaneLevel := 2
      else
         oForm.PaneLevel := 1;

      oForm.DataBrowser.BrowseBy := 'Code';
      oForm.Freeze(False);

      oForm.Visible := true;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TGrupoArticulos.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL1';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL2';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL3';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL4';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL5';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL6';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL7';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL8';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL9';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL10';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   //////////////

  if (GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo) then begin
      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL11';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);

      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL12';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);

      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL13';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);

      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL14';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);

      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL15';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);

      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL16';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);

      oCFLCreationParams.MultiSelection := False;
      oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
      oCFLCreationParams.UniqueID   := 'CFL17';
      oCFL := oCFLs.Add(oCFLCreationParams);

      oCons := oCFL.GetConditions();
      oCon := oCons.Add();
      oCon.Alias := 'U_Postable';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := 'Y';
      oCon.Relationship := BoConditionRelationship.cr_AND;
      oCon := oCons.Add();
      oCon.Alias := 'U_Code';
      oCon.Operation := BoConditionOperation.co_EQUAL;
      oCon.CondVal := PlanIFRS;
      oCFL.SetConditions(oCons);
   end;
end;

method   TGrupoArticulos.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
var
   oForm           : SAPbouiCOM.Form;
begin
   inherited MenuEvent(var pVal, var BubbleEvent);
   try
      oForm           := FSBOApp.Forms.Item(Self.getFormId);

      // Proceso de MenuEvent
      if (pVal.MenuUid <> '') and  (pVal.BeforeAction = false) then begin
//            if (pVal.MenuUID = '1288') or (pVal.MenuUID = '1289')  or (pVal.MenuUID = '1290')  or (pVal.MenuUID = '1291') then
//               LlenarForm(oForm);
            if (pVal.MenuUID = '1281') or  (pVal.MenuUID = '1282')then
               LimpiarForm(oForm, true);
      end;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method   TGrupoArticulos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   sValue          : string;
   oDataTable      : SAPbouiCOM.DataTable;
   oSBObob         : SAPbobsCOM.SBObob;
   oSql            : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);
   oSBObob := SBObob(FCmpny.GetbusinessObject(BoObjectTypes.BoBridge));

   try
      if (not EnableValidate) then
         exit;
  try 
      oForm.Freeze(True);

      // CFL
      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'FmtActFi') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaActFi', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtCorAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescCoAF').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtCorAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaCorAF', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtCorDA') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescCoDA').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtCorDA').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaCorDA', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtDepAc') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaDepAc', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtGasDe') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaGasDe', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtGasBj') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaGasBj', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtAdqAc') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaAdqAc', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtReaAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaReaAF', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtDetAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaDetAF', 0, sValue);
         end
         else if (pVal.ItemUID = 'FmtBis33') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                       'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DDescBis33').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtBis33').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtaBis33', 0, sValue);
         end;

         //////////////

         if (GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo) then begin
            if (pVal.ItemUID = 'FmtIActFi') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiAcFi').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIActFi').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIActFi', 0, sValue);
            end
            else if (pVal.ItemUID = 'FmtIReaAF') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiReAF').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIReaAF').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIReaAF', 0, sValue);
            end
            else if (pVal.ItemUID = 'FmtIDetAF') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiDeAF').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIDetAF').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIDetAF', 0, sValue);
            end
            else if (pVal.ItemUID = 'FmtIDepAc') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiDeAc').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIDepAc').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIDepAc', 0, sValue);
            end
            else if (pVal.ItemUID = 'FmtIGasDe') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiGaDe').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIGasDe').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIGasDe', 0, sValue);
            end
            else if (pVal.ItemUID = 'FmtIGasBj') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiGaBj').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIGasBj').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIGasBj', 0, sValue);
            end
            else if (pVal.ItemUID = 'FmtIAdqAc') then begin
               oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
               try
                  sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
               except
                  ;
               end;
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = '{0}'", 
                          'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where  "U_AcctCode" = ''{0}'' ');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               oForm.DataSources.UserDataSources.Item('DSDesiAdAc').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
               oForm.DataSources.UserDataSources.Item('DSFmIAdqAc').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
               oForm.DataSources.DBDataSources.Item('@VID_AFGR').SetValue('U_CtIAdqAc', 0, sValue);
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'Name') then begin
   // Validacion no  utiliada - ene-2011
            BubbleEvent := false;
   //            sValue := EditText(oForm.Items.Item('Name').Specific).Value;
   //            oRecordSet.DoQuery ('Select count(*) cant from [@VID_AFGR] where Name = ''' + sValue + '''');
   //            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
   //               FSBOApp.StatusBar.SetText('Nombre de grupo de artículos ya ingresado ', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
   //               EditText(oForm.Items.Item('Name').Specific).Value := '';
   //            end
   //            else
               BubbleEvent := true;
         end;
         if (pVal.ItemUID = 'Code') then begin
            BubbleEvent := false;
            sValue := EditText(oForm.Items.Item('Code').Specific).Value;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select count(*) cant from [@VID_AFGR] where Code = '{0}'", 
                       'Select count(*) "cant" from "@VID_AFGR" where "Code" = ''{0}'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Grupo_Ya_ingresado], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               EditText(oForm.Items.Item('Code').Specific).Value := '';
            end
            else
               BubbleEvent := true;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = True) then begin
         if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) then begin
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualizar_Grupo_QM], 1, 'Ok', 'Cancelar','')) then
               BubbleEvent := False
            else begin
               BubbleEvent := ValidacionFinal(oForm);
            end;
         end

         else if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) then begin
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualizar_Grupo_QM], 1, 'Ok', 'Cancelar','')) then
               BubbleEvent := False
            else
               BubbleEvent := ValidacionFinal(oForm);
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = false) then begin
         if (pVal.ItemUID = 'tab1') then
            oForm.PaneLevel := 1;
         if (pVal.ItemUID = 'tab2') then
            oForm.PaneLevel := 10;
         if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) then begin
            if (pVal.ActionSuccess) then
               LimpiarForm(oForm, true);
         end
      end;
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

method TGrupoArticulos.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm           : SAPbouiCOM.Form;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);

   oForm   := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);

   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (BusinessObjectInfo.BeforeAction = false) then begin
      LimpiarForm(oForm, false);
      LlenarForm(oForm);
      oForm.Mode := BoFormMode.fm_OK_MODE;
   end;
end;

method TGrupoArticulos.ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
var
   s:           string;
   oRecordSet1: SAPbobsCOM.Recordset;
   oSql :       string;
begin
   try
      oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      result := true;
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                 "Select count(*) cant from [@VID_AFGR] " +
                 " where Name = '{0}'  " + 
                 "   and Code <> '{1}' " ,
                 'Select count(*) "cant" from "@VID_AFGR" ' +
                 ' where "Name" = ''{0}''  ' + 
                 '   and "Code" <> ''{1}'' ' );
      oSql := string.Format(oSql, EditText(oForm.Items.Item('Name').Specific).Value, EditText(oForm.Items.Item('Code').Specific).Value);
      oRecordSet1.DoQuery(oSql);
      if (System.int32(oRecordSet1.Fields.Item('cant').Value) > 0) then begin
         if (FCmpny.language = BoSuppLangs.ln_English) then
            FSBOApp.StatusBar.SetText('Duplicated asset class ', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
         else
            FSBOApp.StatusBar.SetText('Grupo de artículos duplicado ', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      s := FSBOf.VerificarItemsRequeridos(oForm, Lista);

      if (s <> '') then begin
         if (FCmpny.language = BoSuppLangs.ln_English) then
            FSBOApp.StatusBar.SetText('Field ' + s + ' Required' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
         else
            FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaActFi', 0) = '') then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_ActFij] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaCorAF', 0) = '') and (not GlobalSettings.IFRSActivo) then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_CorrActFij] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaCorDA', 0) = '') and (not GlobalSettings.IFRSActivo) then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_CorrDepr] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0) = '') then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_DepAcum] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0) = '') then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_GasDep] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0) = '') then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_GasBaja] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0) = '') then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_AdqAct] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0) = '') and (GlobalSettings.IFRSActivo) then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_Reavaluo] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end
      else if (oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0) = '') and (GlobalSettings.IFRSActivo) then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Cuenta_no_def_Deterioro] , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;

      ///////////

   except
      on e:exception do begin
         OutLog(e.Message + ' - ' + e.StackTrace);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TGrupoArticulos.LlenarForm(oForm: SAPbouiCOM.Form);
var
   s:       string;
   oRecordSet1: SAPbobsCOM.Recordset;
   oSBObob: SAPbobsCOM.SBObob;
   oSql :   string;
begin
   try
   try
      oForm.Freeze(True);

      oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      oSBObob := SBObob(FCmpny.GetBusinessObject(BoObjectTypes.BoBridge));

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaActFi', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaCorAF', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescCoAF').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtCorAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaCorDA', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescCoDA').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtCorDA').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDepAc', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaGasDe', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaGasBj', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaAdqAc', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaReaAF', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaDetAF', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtaBis33', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                    "Select AcctName, FormatCode from OACT where AcctCode  ='{0}'", 
                    'Select "AcctName", "FormatCode" from OACT where "AcctCode"  = ''{0}'' ');
         oSql := string.Format(oSql, s);
         oRecordSet.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DDescBis33').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtBis33').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      //////////////////

      if (GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo) then begin
         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIActFi', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
            oForm.DataSources.UserDataSources.Item('DSDesiAcFi').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIActFi').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;

         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIReaAF', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDesiReAF').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIReaAF').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;

         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIDetAF', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDesiDeAF').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIDetAF').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;

         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIDepAc', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDesiDeAc').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIDepAc').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;

         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIGasDe', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDesiGaDe').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIGasDe').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;

         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIGasBj', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDesiGaBj').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIGasBj').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;

         s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFGR').GetValue('U_CtIAdqAc', 0));
         if (s <> '') then begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = '{0}'", 
                       'Select "U_AcctName", "U_FormatCo" from "@VID_OACT" where "U_AcctCode"  = ''{0}'' ');
            oSql := string.Format(oSql, s);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDesiAdAc').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmIAdqAc').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
         end;
      end;

      oForm.Mode := BoFormMode.fm_OK_MODE;
   finally 
     oForm.Freeze(False);
   end;
   except
      on e:exception do begin
         OutLog(e.Message + ' - ' + e.StackTrace);
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TGrupoArticulos.LimpiarForm(oForm: SAPbouiCOM.Form; oTodo: boolean);
begin
   try
   try 
     oform.Freeze(True);
      if (oTodo) then begin
         oForm.DataSources.DBDataSources.Item('@VID_AFGR').Clear;
         oForm.DataSources.DBDataSources.Item('@VID_AFGR').InsertRecord(0);
      end;
      oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DsDescCoAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescCoDA').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DDescBis33').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DsFmtCorAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtCorDA').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtBis33').ValueEx := '';

      //////////////

      oForm.DataSources.UserDataSources.Item('DSDesiAcFi').Value := '';
      oForm.DataSources.UserDataSources.Item('DSDesiReAF').Value := '';
      oForm.DataSources.UserDataSources.Item('DSDesiDeAF').Value := '';
      oForm.DataSources.UserDataSources.Item('DSDesiDeAc').Value := '';
      oForm.DataSources.UserDataSources.Item('DSDesiGaDe').Value := '';
      oForm.DataSources.UserDataSources.Item('DSDesiGaBj').Value := '';
      oForm.DataSources.UserDataSources.Item('DSDesiAdAc').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIActFi').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIReaAF').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIDetAF').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIDepAc').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIGasDe').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIGasBj').Value := '';
      oForm.DataSources.UserDataSources.Item('DSFmIAdqAc').Value := '';
   finally 
     oForm.Freeze(False);
   end;
   except
      on e:exception do begin
         OutLog(e.Message + ' - ' + e.StackTrace);
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

end.