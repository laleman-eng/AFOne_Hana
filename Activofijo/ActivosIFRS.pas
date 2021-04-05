namespace AF_IFRS.ActivosIFRS;

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
  TActivosIFRS = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet      : SAPbobsCOM.Recordset;
    oCompanyService : SAPbobsCOM.CompanyService;
    Lista     : List<String>;
    PlanIFRS  : String;
    method   LlenarFinanzasDesdeGrupo(oForm: SAPbouiCOM.Form);
    method   LlenarFinanzas(oForm: SAPbouiCOM.Form);
    method   LimpiarFinanzas(oForm: SAPbouiCOM.Form);
    method   ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
    method   SetVisibilidad(oForm: SAPbouiCOM.Form);
    method   AddChooseFromList(oForm: SAPbouiCOM.Form);
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method   MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean); reintroduce;
    method   FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization, 
  AF_IFRS.UbicacionesActivos;

method   TActivosIFRS.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:     SAPbouiCOM.Form;
   oMatrixAC: SAPbouiCOM.Matrix;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista     := new List<String>;
   try
      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      // Es Activo Fijo - SBO 9.0
      oCompanyService := company.GetCompanyService;

      PlanIFRS := nil;
      oRecordSet.DoQuery('Select U_PlanIFRS from [@VID_AFPA]');
      if (not oRecordSet.EoF) then
         if (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value) <> '') and (System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value) <> nil) then
            PlanIFRS := System.String(oRecordSet.Fields.Item('U_PlanIFRS').Value).Trim;
      if (PlanIFRS = nil) then begin
         result := false;
         FSBOApp.StatusBar.SetText('Plan de cuentas IFRS, no seleccionado' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      FSBOf.LoadForm(xmlPath,'VID_Activos_IFRS.srf', Uid);

      oForm := FSBOApp.Forms.Item(uid);
      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := -1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_FIND_MODE;

      oForm.DataSources.UserDataSources.Add('DSDescAcFi',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DsDescReAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescDeAF',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescDeAc',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescGaDe',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescGaBj',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSDescAdAc',SAPbouiCOM.BoDataType.dt_LONG_TEXT,210);
      EditText(oForm.Items.Item('DescAcFi').Specific).DataBind.SetBound(true,'','DSDescAcFi');
      EditText(oForm.Items.Item('DescReAF').Specific).DataBind.SetBound(true,'','DSDescReAF');
      EditText(oForm.Items.Item('DescDeAF').Specific).DataBind.SetBound(true,'','DSDescDeAF');
      EditText(oForm.Items.Item('DescDeAc').Specific).DataBind.SetBound(true,'','DSDescDeAc');
      EditText(oForm.Items.Item('DescGaDe').Specific).DataBind.SetBound(true,'','DSDescGaDe');
      EditText(oForm.Items.Item('DescGaBj').Specific).DataBind.SetBound(true,'','DSDescGaBj');
      EditText(oForm.Items.Item('DescAdAc').Specific).DataBind.SetBound(true,'','DSDescAdAc');


      oForm.DataSources.UserDataSources.Add('DSFmtActFi',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DsFmtReaAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtDetAF',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtDepAc',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtGasDe',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtGasBj',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      oForm.DataSources.UserDataSources.Add('DSFmtAdqAc',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,210);
      EditText(oForm.Items.Item('FmtActFi').Specific).DataBind.SetBound(true,'','DSFmtActFi');
      EditText(oForm.Items.Item('FmtReaAF').Specific).DataBind.SetBound(true,'','DSFmtReaAF');
      EditText(oForm.Items.Item('FmtDetAF').Specific).DataBind.SetBound(true,'','DSFmtDetAF');
      EditText(oForm.Items.Item('FmtDepAc').Specific).DataBind.SetBound(true,'','DSFmtDepAc');
      EditText(oForm.Items.Item('FmtGasDe').Specific).DataBind.SetBound(true,'','DSFmtGasDe');
      EditText(oForm.Items.Item('FmtGasBj').Specific).DataBind.SetBound(true,'','DSFmtGasBj');
      EditText(oForm.Items.Item('FmtAdqAc').Specific).DataBind.SetBound(true,'','DSFmtAdqAc');

      oForm.DataSources.UserDataSources.Add('DSEmpName',SAPbouiCOM.BoDataType.dt_LONG_TEXT,100);
      EditText(oForm.Items.Item('EmpName').Specific).DataBind.SetBound(true,'','DSEmpName');

      oForm.DataSources.UserDataSources.Add('DSValNeto' ,SAPbouiCOM.BoDataType.dt_SUM,12);
      EditText(oForm.Items.Item('ValorNeto').Specific).DataBind.SetBound(true,'','DSValNeto' );

      oForm.DataSources.UserDataSources.Add('TabName',SAPbouiCOM.BoDataType.dt_SHORT_TEXT,1);
      oForm.DataSources.UserDataSources.Item('TabName').ValueEx := '1';

      SAPbouiCOM.CheckBox(oForm.Items.Item('ConDepre').Specific).ValOn  := 'Y';
      SAPbouiCOM.CheckBox(oForm.Items.Item('ConDepre').Specific).ValOff := 'N';
      SAPbouiCOM.CheckBox(oForm.Items.Item('DeBaja'  ).Specific).ValOn  := 'Y';
      SAPbouiCOM.CheckBox(oForm.Items.Item('DeBaja'  ).Specific).ValOff := 'N';

                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'ActCode  ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActName  ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'ItemCode ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'ItemName ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'DeBaja   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InDate   ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'InitYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'InitPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocName  ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'OriVal   ,  f,  t,  f,  f, r, >0');
      Lista.Add( 'OriFec   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriValIn ,  f,  t,  f,  f, r, >0');
      Lista.Add( 'PorResid ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDp ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriDepre ,  f,  t,  f,  f, r, l');
      Lista.Add( 'InvDate  ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  f,  t,  f,  f, n, 1 ');

      Lista.Add( 'CtaActFi ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'CtaReaAF ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'CtaDetAF ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'CtaDepAc ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'CtaGasDe ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'CtaGasBj ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'CtaAdqAc ,  f,  t,  f,  f, r, 1 ');

      Lista.Add( 'VidaUtil ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'PerDepre ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'NextYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NextPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'CurVal   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepAcum  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepreAnu ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Adicion,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'Mx_Compo  ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFAC,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFSA,  f,  f,  f,  f, n, 1 ');

      FSBOf.SetAutoManaged(oForm, Lista);

      //Tabs
      SAPbouiCOM.Folder(oForm.Items.Item('TabDatos').Specific).Select;
      SAPbouiCOM.Folder(oForm.Items.Item('TabDepre').Specific).GroupWith('TabDatos');
      SAPbouiCOM.Folder(oForm.Items.Item('TabFinan').Specific).GroupWith('TabDepre');
      SAPbouiCOM.Folder(oForm.Items.Item('TabAdiCom').Specific).GroupWith('TabFinan');
      SAPbouiCOM.Folder(oForm.Items.Item('TabActiv').Specific).GroupWith('TabAdiCom');
      SAPbouiCOM.Folder(oForm.Items.Item('TabSaldo').Specific).GroupWith('TabActiv');

      oForm.PaneLevel := 1;

      oForm.Items.Item('TabDatos').AffectsFormMode := false;
      oForm.Items.Item('TabDepre').AffectsFormMode := false;
      oForm.Items.Item('TabFinan').AffectsFormMode := false;
      oForm.Items.Item('TabAdiCom').AffectsFormMode := false;
      oForm.Items.Item('TabActiv').AffectsFormMode := false;
      oForm.Items.Item('TabSaldo').AffectsFormMode := false;
      oForm.Items.Item('Mx_Adicion').AffectsFormMode := false;
      oForm.Items.Item('Mx_Compo'  ).AffectsFormMode := false;
      oForm.Items.Item('MxVID_AFAC').AffectsFormMode := false;
      oForm.Items.Item('MxVID_AFSA').AffectsFormMode := false;

      oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFAC').Specific);
      oMatrixAC.Columns.Item('PostFlag').ValOn  := 'Y';
      oMatrixAC.Columns.Item('PostFlag').ValOff := 'N';

      oMatrixAC.Columns.Item('DeprNom' ).Editable := false;
      oMatrixAC.Columns.Item('CorrDepM').Editable := false;

      LinkedButton(oForm.Items.Item('LnLocCode').Specific).LinkedObject := SAPbouiCOM.BoLinkedObject.lf_None;

      // Params
      oRecordSet.DoQuery('Select U_UsarProj from [@VID_AFPA]');
      if (oRecordSet.EoF) then begin
         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         oForm.Close;
         exit;
      end;

         oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFAC').Specific);
         oMatrixAC.Columns.Item('DeprNom').Visible := false;

      // Project
      if (System.String(oRecordSet.Fields.Item('U_UsarProj').Value).Trim = 'N') then begin
         oForm.Items.Item('tx_project').Enabled := false;
         oForm.Items.Item('Project').Enabled    := false;
         oForm.Items.Item('tx_project').Width := -1;
         oForm.Items.Item('Project').Width    := -1;
      end
      else begin
         oRecordSet.DoQuery('select prjcode code, prjname name from oprj where prjcode <> '''' order by name');
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('Project').Specific), var oRecordSet, true);
      end;

      // ProfitCt
      oRecordSet.DoQuery('select ocrcode code, ocrname name from oocr where direct = ''Y'' order by name');
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitCt').Specific), var oRecordSet, true);
      // Grupos
      oRecordSet.DoQuery('select  code,  name from [@VID_AFGR] order by name');
      FSBOf.FillCombo(ComboBox(oForm.Items.Item('ItmGrpCd').Specific), var oRecordSet, true);

      // CFL CardCode
      AddChooseFromList(oForm);

      EditText(oForm.Items.Item('FmtActFi').Specific).ChooseFromListUID   := 'CFL1';
      EditText(oForm.Items.Item('FmtActFi').Specific).ChooseFromListAlias := 'U_FormatCo';
      EditText(oForm.Items.Item('FmtReaAF').Specific).ChooseFromListUID   := 'CFL2';
      EditText(oForm.Items.Item('FmtReaAF').Specific).ChooseFromListAlias := 'U_FormatCo';
      EditText(oForm.Items.Item('FmtDetAF').Specific).ChooseFromListUID   := 'CFL3';
      EditText(oForm.Items.Item('FmtDetAF').Specific).ChooseFromListAlias := 'U_FormatCo';
      EditText(oForm.Items.Item('FmtDepAc').Specific).ChooseFromListUID   := 'CFL4';
      EditText(oForm.Items.Item('FmtDepAc').Specific).ChooseFromListAlias := 'U_FormatCo';
      EditText(oForm.Items.Item('FmtGasDe').Specific).ChooseFromListUID   := 'CFL5';
      EditText(oForm.Items.Item('FmtGasDe').Specific).ChooseFromListAlias := 'U_FormatCo';
      EditText(oForm.Items.Item('FmtGasBj').Specific).ChooseFromListUID   := 'CFL51';
      EditText(oForm.Items.Item('FmtGasBj').Specific).ChooseFromListAlias := 'U_FormatCo';
      EditText(oForm.Items.Item('FmtAdqAc').Specific).ChooseFromListUID   := 'CFL52';
      EditText(oForm.Items.Item('FmtAdqAc').Specific).ChooseFromListAlias := 'U_FormatCo';

      EditText(oForm.Items.Item('ItemCode').Specific).ChooseFromListUID   := 'CFL6';
      EditText(oForm.Items.Item('ItemCode').Specific).ChooseFromListAlias := 'ItemCode';
      EditText(oForm.Items.Item('EmpId'   ).Specific).ChooseFromListUID   := 'CFL7';
      EditText(oForm.Items.Item('EmpId'   ).Specific).ChooseFromListAlias := 'EmpId';
      EditText(oForm.Items.Item('LocCode' ).Specific).ChooseFromListUID   := 'CFL9';
      EditText(oForm.Items.Item('LocCode' ).Specific).ChooseFromListAlias := 'Code';

      // Formato Matrices
      oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFAC').Specific);
      oMatrixAC.Columns.Item('CorrActi').Visible := false;
      oMatrixAC.Columns.Item('CorrDepr').Visible := false;
      oMatrixAC.Columns.Item('CorrDepM').Visible := false;
      oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFSA').Specific);
      oMatrixAC.Columns.Item('CorAnuAc').Visible := false;
      oMatrixAC.Columns.Item('CorAnuDe').Visible := false;
      oMatrixAC.Columns.Item('Bis33'   ).Visible := false;


      oForm.DataBrowser.BrowseBy := 'ActCode';
      oForm.Freeze(False);
      oForm.Update;
      oForm.Visible := true;
     except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('InitForm: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

   method TActivosIFRS.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
            oCFLCreationParams.ObjectType := 'VID_OACT';    // 1 => Charts of accounts
            oCFLCreationParams.UniqueID   := 'CFL1';
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
            oCFLCreationParams.UniqueID   := 'CFL2';
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
            oCFLCreationParams.UniqueID   := 'CFL3';
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
            oCFLCreationParams.UniqueID   := 'CFL4';
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
            oCFLCreationParams.UniqueID   := 'CFL5';
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
            oCFLCreationParams.UniqueID   := 'CFL51';
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
            oCFLCreationParams.UniqueID   := 'CFL52';
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
            oCFLCreationParams.ObjectType := '4';    // 1 => ItemCode
            oCFLCreationParams.UniqueID   := 'CFL6';
            oCFL := oCFLs.Add(oCFLCreationParams);

            oCons := oCFL.GetConditions();
            oCon := oCons.Add();
            // Es Activo Fijo - SBO 9.0
            if (oCompanyService.GetCompanyInfo.Version >= 900000) then 
               oCon.Alias := 'U_VID_AFAF'
            else
               oCon.Alias := 'AssetItem';
            oCon.Operation := BoConditionOperation.co_EQUAL;
            oCon.CondVal := 'Y';
            oCFL.SetConditions(oCons);

            oCFLCreationParams.MultiSelection := False;
            oCFLCreationParams.ObjectType := '171';    // 171 => Employee inof
            oCFLCreationParams.UniqueID   := 'CFL7';
            oCFL := oCFLs.Add(oCFLCreationParams);

            oCFLCreationParams.MultiSelection := False;
            oCFLCreationParams.ObjectType := 'VID_mAFGR';    // 1VID_mAFGR => Grupos
            oCFLCreationParams.UniqueID   := 'CFL8';
            oCFL := oCFLs.Add(oCFLCreationParams);

            oCFLCreationParams.MultiSelection := False;
            oCFLCreationParams.ObjectType := 'VID_AFLOC';    // 171 => Localidades
            oCFLCreationParams.UniqueID   := 'CFL9';
            oCFL := oCFLs.Add(oCFLCreationParams);
    end;

method   TActivosIFRS.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
var
   oForm : SAPbouiCOM.Form;
begin
   inherited MenuEvent(var pVal, var BubbleEvent);
   try
      oForm   := FSBOApp.Forms.Item(Self.getFormId);

      // Proceso de MenuEvent
      if (pVal.MenuUID <> '') and  (pVal.BeforeAction = false) then begin
//         if (pVal.MenuUID = '1288') or (pVal.MenuUID = '1289')  or (pVal.MenuUID = '1290')  or (pVal.MenuUID = '1291') then begin
//            LimpiarFinanzas(oForm);
//            LlenarFinanzas(oForm);
//         end;
         if (pVal.MenuUID = '1281') or (pVal.MenuUID = '1282')then begin
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').Clear;
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').InsertRecord(0);
            LimpiarFinanzas(oForm);
            oForm.Items.Item('TabDatos').Click(BoCellClickType.ct_Regular);
         end;
      end;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('MenuEvent: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method   TActivosIFRS.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMatrixCo       : SAPbouiCOM.Matrix;
   oDBDS           : SAPbouiCOM.DBDataSource;
   oDBDSAux        : SAPbouiCOM.DBDataSource;
   i               : integer;
   sValue          : string;
   s               : string;
   oFormIvk        : IvkFormInterface;
   y,m,d           : integer;
   Yr, Pr          : integer;
   oDataTable      : SAPbouiCOM.DataTable;
begin
   try
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm           := FSBOApp.Forms.Item(pVal.FormUID);
   oMatrixCo       := Matrix(oForm.Items.Item('Mx_Compo').Specific);
   oDBDS           := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFASIF'));

      if (not EnableValidate) then
         exit;

      if (pVal.EventType = BoEventTypes.et_FORM_CLOSE) and (not cancelingForm) then begin
         BubbleEvent := false;
         FSBOApp.StatusBar.SetText('Utilizar boton cancelar', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end

      // CLICK
      else if (pVal.EventType = BoEventTypes.et_CLICK) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = 'LnLocCode') then begin
            sValue := EditText(oForm.Items.Item('LocCode').Specific).Value;
            if (sValue = '') then
               exit;
            oFormIvk := IvkFormInterface(new TUbicacionesActivos);
            TUbicacionesActivos(oFormIvk).LocCode  := sValue;
            if(oFormIvk<>nil) then begin
               oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings);
               ooForms.Add(oFormIvk);
            end;
         end;
      end

      // CFL
      else if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = 'FmtActFi') or (pVal.ItemUID = 'FmtReaAF') or
            (pVal.ItemUID = 'FmtDetAF') or (pVal.ItemUID = 'FmtDepAc') or
            (pVal.ItemUID = 'FmtGasDe') or (pVal.ItemUID = 'FmtGasBj') or
            (pVal.ItemUID = 'FmtAdqAc') then begin
            if (not oForm.Items.Item('InDate').Enabled) then begin
               if (1 <> FSBOApp.MessageBox('Modificar esta cuenta contable, cambiara la contabilización del activo. ¿Desea continuar?', 2, 'Ok', 'Cancelar','')) then
                  BubbleEvent := false;
            end;
         end;
      end
      else if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'ItemCode') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('ItemCode', 0));
               EditText(oForm.Items.Item('ItemCode').Specific).Value := sValue;
            except
               ;
            end;
            oRecordSet.DoQuery ('Select ItemName from OITM where  ItemCode = ''' + sValue + '''');
            EditText(oForm.Items.Item('ItemName').Specific).value := System.String(oRecordSet.Fields.Item('ItemName').Value);
         end;

         if (pVal.ItemUID = 'EmpId') then begin
            sValue := '';
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := TMultiFunctions.IntToStr(System.Int32(oDataTable.GetValue('empID', 0)));
            except
               ;
            end;
            if (sValue <> '') then begin
               oRecordSet.DoQuery ('Select empid, firstname, lastname, branch from ohem where EmpId = ' + sValue);
               s := System.String(oRecordSet.Fields.Item('lastname').Value) + ', ' +
                    System.String(oRecordSet.Fields.Item('firstname').Value);
               oDBDS.SetValue('U_EmpId'  , 0, sValue);
               oForm.DataSources.UserDataSources.Item('DSEmpName').ValueEx := s;
               if (oForm.Mode = BoFormMode.fm_OK_MODE) then
                  oForm.Mode := BoFormMode.fm_UPDATE_MODE;
            end;
         end;

         if (pVal.ItemUID = 'LocCode') then begin
            sValue := '';
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('Code', 0));
               s       := System.String(oDataTable.GetValue('Name', 0));
            except
               ;
            end;
            if (sValue <> '') then begin
               oDBDS.SetValue('U_LocCode', 0, sValue);
               oDBDS.SetValue('U_LocName', 0, s);
               if (oForm.Mode = BoFormMode.fm_OK_MODE) then
                  oForm.Mode := BoFormMode.fm_UPDATE_MODE;
            end;
         end;

         if (pVal.ItemUID = 'FmtActFi') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescAcFi').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtActFi').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaActFi', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtReaAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescReAF').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtReaAF').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaReaAF', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtDetAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescDeAF').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtDetAF').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaDetAF', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtDepAc') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescDeAc').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtDepAc').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaDepAc', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtGasDe') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescGaDe').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtGasDe').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaGasDe', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtGasBj') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescGaBj').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtGasBj').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaGasBj', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtAdqAc') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('U_AcctCode', 0));
            except
               ;
            end;
            oRecordSet.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where  U_AcctCode = ''' + sValue + '''');
            oForm.DataSources.UserDataSources.Item('DSDescAdAc').Value := System.String(oRecordSet.Fields.Item('U_AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').Value := System.String(oRecordSet.Fields.Item('U_FormatCo').Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaAdqAc', 0, sValue);
         end;
      end

      // Validación de valores
      else if ( pVal.EventType = BoEventTypes.et_VALIDATE ) and ( pVal.BeforeAction = true ) and
              ( (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) or (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) ) then begin
         // ActCode
         if (pVal.ItemUID = 'ActCode') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (system.String(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_ConDepre', 0)) = '') then
               oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_ConDepre',0,'N');
            if (system.String(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_DeBaja', 0)) = '') then
               oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_DeBaja',0,'N');
            if (sValue = '') then
               BubbleEvent     := true
            else begin
               oRecordSet.DoQuery ('Select Count(*) cant from [@VID_AFASIF] where U_ActCode = ' + TMultiFunctions.QuotedStr(sValue));
               oRecordSet.MoveFirst;
               if (System.Int32(oRecordSet.Fields.Item('cant').value) > 0) then
                  FSBOApp.StatusBar.SetText('Código existente', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
               else
                  BubbleEvent     := true;
            end;
         end;
         // InDate
         if (pVal.ItemUID = 'InDate') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            y := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Year;
            m := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Month;
            d := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Day;

            if (sValue = '') then
               BubbleEvent     := true
            else begin
               if (FSBOf.StrToInteger(EditText(oForm.Items.Item('InitYear').Specific).Value) <> y) or
                  (FSBOf.StrToInteger(EditText(oForm.Items.Item('InitPer').Specific).Value)  <> m) then begin
                  oDBDS.SetValue('U_InitYear', 0 , TMultiFunctions.inttostr(y));
                  oDBDS.SetValue('U_InitPer' , 0 , TMultiFunctions.inttostr(m));
                     oDBDS.SetValue('U_NxYrDepr', 0 , TMultiFunctions.inttostr(y));
                     oDBDS.SetValue('U_NxPrDepr', 0 , TMultiFunctions.inttostr(m));
                     oDBDS.SetValue('U_NextYear', 0 , TMultiFunctions.inttostr(y));
                     oDBDS.SetValue('U_NextPer' , 0 , TMultiFunctions.inttostr(m));
               end;
               BubbleEvent    := true;
            end;
         end;
         // NxYrDepr
         if (pVal.ItemUID = 'NxYrDepr') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (EditText(oForm.Items.Item('InDate').Specific).Value = '') then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Fecha_Ingr_Sin_Datos], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               BubbleEvent     := true;
            end
            else begin
               y := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Year;
               m := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Month;
               d := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Day;
               Yr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxYrDepr').Specific).Value);
               Pr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxPrDepr').Specific).Value);
               if ( Yr < y) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Dep_Anterior_Ingreso], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxYrDepr', 0, TMultiFunctions.inttostr(Yr));
               end
               else if (Yr = y) and (Pr < m) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Dep_Anterior_Ingreso_Per], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxPrDepr', 0, TMultiFunctions.inttostr(Pr));
               end
               else
                  BubbleEvent    := true;
            end;
         end;
         // NxPrDepr
         if (pVal.ItemUID = 'NxPrDepr') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (FSBOf.StrToInteger(sValue) < 1) then
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_Mayor_1], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (FSBOf.StrToInteger(sValue) > 12) then
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Periodo_Menor_12], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (EditText(oForm.Items.Item('InDate').Specific).Value = '') then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Fecha_Ingr_Sin_Datos], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               BubbleEvent     := true;
            end
            else if (EditText(oForm.Items.Item('NxYrDepr').Specific).Value = '') then begin
               FSBOApp.StatusBar.SetText('Año primera depreciación sin datos', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               BubbleEvent     := true;
            end
            else begin
               y := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Year;
               m := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Month;
               d := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Day;
               Yr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxYrDepr').Specific).Value);
               Pr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxPrDepr').Specific).Value);
               if ( Yr < y) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Dep_Anterior_Ingreso], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxYrDepr', 0, TMultiFunctions.inttostr(Yr));
               end
               else if (Yr = y) and (Pr < m) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Dep_Anterior_Ingreso_Per], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxPrDepr', 0, TMultiFunctions.inttostr(Pr));
               end
               else
                  BubbleEvent    := true;
            end;
         end;

         // PerVidaU
         if (pVal.ItemUID = 'PerVidaU') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (TMultiFunctions.StrToInt(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Vida_Cero], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (TMultiFunctions.StrToInt(svalue) < FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDp').Specific).Value)) then
               FSBOApp.StatusBar.SetText('Depreciación original no puede ser mayor que la vida util.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               oDBDS.SetValue('U_PerDepre',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDp').Specific).Value)));
               oDBDS.SetValue('U_VidaUtil',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('PerVidaU').Specific).Value) -
                                                       FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDp').Specific).Value)));
               BubbleEvent     := true;
            end;
         end;

         // OriPerDp
         if (pVal.ItemUID = 'OriPerDp') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (TMultiFunctions.StrToInt(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Depreciación original no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (TMultiFunctions.StrToInt(svalue) > FSBOf.StrToInteger(EditText(oForm.Items.Item('PerVidaU').Specific).Value)) then
               FSBOApp.StatusBar.SetText('Depreciación original no puede ser mayor que la vida util.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               oDBDS.SetValue('U_PerDepre',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDp').Specific).Value)));
               oDBDS.SetValue('U_VidaUtil',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('PerVidaU').Specific).Value) -
                                                                                                   FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDp').Specific).Value)));
               BubbleEvent     := true;
            end;
         end;

         // OriVal
         if (pVal.ItemUID = 'OriVal') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (FSBOf.StrToDouble(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Valor de compra no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (FSBOf.StrToDouble(svalue) > FSBOf.StrToDouble(EditText(oForm.Items.Item('OriValIn').Specific).Value)) and
                    (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriValIn').Specific).Value) <> 0) then
               FSBOApp.StatusBar.SetText('Valor de compra no puede ser mayor a valor de compra corregido.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               if (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriValIn').Specific).Value) = 0) then begin
                  oDBDS.SetValue('U_OriValIn', 0, sValue);
                  oDBDS.SetValue('U_CurVal'  , 0, sValue);
               end;
               BubbleEvent     := true;
            end;
         end;

         // OriValIn
         if (pVal.ItemUID = 'OriValIn') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (FSBOf.StrToDouble(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Valor de compra corregido no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriVal').Specific).Value) <> 0) and
                    (FSBOf.StrToDouble(svalue) < FSBOf.StrToDouble(EditText(oForm.Items.Item('OriVal').Specific).Value)) then
               FSBOApp.StatusBar.SetText('Valor de compra no puede ser mayor a valor de compra corregido.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               if (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriVal').Specific).Value) = 0) then
                  oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_OriVal', 0, sValue);
               oDBDS.SetValue('U_CurVal', 0, sValue);
               BubbleEvent     := true;
            end;
         end;

         // OriDepre
         if (pVal.ItemUID = 'OriDepre') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (FSBOf.StrToDouble(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Depreciación corregida no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               oDBDS.SetValue('U_DepAcum', 0, sValue);
               BubbleEvent     := true;
            end;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = 'ItmGrpCd')  then begin
            if (not oForm.Items.Item('InDate').Enabled) then begin
               if (1 <> FSBOApp.MessageBox('Modificar el grupo, cambiara la contabilización del activo. ¿Desea continuar?', 2, 'Ok', 'Cancelar','')) then
                  BubbleEvent := false;
            end;
            FSBOApp.StatusBar.SetText('Modificar el grupo, cambiara la contabilización del activo', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
         end
      end

      else if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'ItmGrpCd')  then begin
            sValue  := oDBDS.GetValue('U_ItmGrpCd', 0);
            if (sValue <> '') then begin
               LlenarFinanzasDesdeGrupo(oForm);
               LlenarFinanzas(oForm);
            end;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = True) then begin
         if  (pVal.ItemUID = 'TabDatos') then begin
            oForm.PaneLevel := 1;
            oForm.DataSources.UserDataSources.Item('TabName').Value := '1';
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabDepre') then begin
            oForm.PaneLevel := 2;
            oForm.DataSources.UserDataSources.Item('TabName').Value := '2';
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabFinan') then begin
            oForm.PaneLevel := 3;
            oForm.DataSources.UserDataSources.Item('TabName').Value := '3';
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabAdiCom') then begin
            oForm.PaneLevel := 7;
            oForm.DataSources.UserDataSources.Item('TabName').Value := '7';
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabActiv') then begin
            oForm.PaneLevel := 9;
            oForm.DataSources.UserDataSources.Item('TabName').Value := '9';
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabSaldo') then begin
            oForm.PaneLevel := 11;
            oForm.DataSources.UserDataSources.Item('TabName').Value := '0';
//            FSBOf.ActPosFormBorde_VID(oForm);
         end

         else if (pVal.ItemUID = '1') and ((oForm.Mode = SAPbouiCOM.BoFormMode.fm_ADD_MODE) or (oForm.Mode = SAPbouiCOM.BoFormMode.fm_UPDATE_MODE)) then begin
            BubbleEvent := false;
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualizar_informacion_QM], 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(oForm)) then
               exit;
            if (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) then begin
               oRecordSet.DoQuery ('select AutoKey from ONNM where ObjectCode = ''VID_mAFASIF'' ');
               EditText(oForm.Items.Item('Code').Specific).String := TMultiFunctions.inttostr(System.Int32(oRecordSet.Fields.Item('AutoKey').Value));
               BubbleEvent     := true;
            end
            else
               BubbleEvent     := true;
         end
         // Addrow de Mx_Compo
         else if (pVal.ItemUID = 'Mx_Compo') and ( (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) or
                (BoFormMode(pVal.FormMode) = BoFormMode.fm_OK_MODE ) or (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) ) then begin
              if (oMatrixCo.RowCount = 0) then
                 oMatrixCo.AddRow(1, -1)
              else if (EditText(oMatrixCo.Columns.Item('Cantidad').Cells.Item(oMatrixCo.RowCount).Specific).Value <> '') then begin
                 DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFCOIF')).Clear;
                oMatrixCo.AddRow(1, oMatrixCo.RowCount);
             end;
         end
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = false) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = SAPbouiCOM.BoFormMode.fm_ADD_MODE) or (oForm.Mode = SAPbouiCOM.BoFormMode.fm_UPDATE_MODE)) and
            (pVal.Action_Success) then begin
            LimpiarFinanzas(oForm);
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').Clear;
            oForm.DataSources.DBDataSources.Item('@VID_AFASIF').InsertRecord(0);
         end;
         if (pVal.ItemUID = 'Imprimir') then begin
            oFormIvk := IvkFormInterface(New TReportWindowFR_1);
            TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptActivoFijo.fr3';
            TReportWindowFR_1(oFormIvk).ReportParams := ' -code "' + EditText(oForm.Items.Item('Code').Specific).value + '"';
            if(oFormIvk<>nil) then begin
               oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings);
               ooForms.Add(oFormIvk);
            end;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_DATASOURCE_LOAD) and (pVal.BeforeAction = false) then begin
          if (pVal.ItemUID = 'MxVID_AFAC') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFACIF');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'MxVID_AFSA') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFSAIF');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'Mx_Adicion') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFADIF');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'Mx_Compo') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFCOIF');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (FSBOf.StrToInteger(oDBDSAux.GetValue('U_Cantidad', i)) <= 0) then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
      end;
   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TActivosIFRS.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm           : SAPbouiCOM.Form;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);

   oForm   := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);

   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (BusinessObjectInfo.BeforeAction = false) and (BusinessObjectInfo.ActionSuccess) then begin
      LimpiarFinanzas(oForm);
      LlenarFinanzas(oForm);
      SetVisibilidad(oForm);
   end;
end;

method TActivosIFRS.LlenarFinanzasDesdeGrupo(oForm: SAPbouiCOM.Form);
var
   s:       string;
   oRecordSet1: SAPbobsCOM.Recordset;
begin
   try
      EnableValidate := false;
      s := oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_ItmGrpCd', 0);
      oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      oRecordSet1.DoQuery ('Select U_CtIActFi,U_CtIReaAF,U_CtIGasDe,U_CtIDetAF,U_CtIDepAc, U_CtIGasBj, U_CtIAdqAc, U_VidaUtIF ' +
                           '  from [@VID_AFGR] where Code  = ' + TMultiFunctions.QuotedStr(s));
      oRecordSet1.MoveFirst;
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaReaAF',0,System.String(oRecordSet1.Fields.Item('U_CtIReaAF').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaGasDe',0,System.String(oRecordSet1.Fields.Item('U_CtIGasDe').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaDetAF',0,System.String(oRecordSet1.Fields.Item('U_CtIDetAF').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaActFi',0,System.String(oRecordSet1.Fields.Item('U_CtIActFi').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaDepAc',0,System.String(oRecordSet1.Fields.Item('U_CtIDepAc').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaGasBj',0,System.String(oRecordSet1.Fields.Item('U_CtIGasBj').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_CtaAdqAc',0,System.String(oRecordSet1.Fields.Item('U_CtIAdqAc').Value));
      if (oForm.Items.Item('InDate').Enabled) then begin
         EditText(oForm.Items.Item('VidaUtil').Specific).value := TMultiFunctions.IntToStr(System.Int32(oRecordSet1.Fields.Item('U_VidaUtIF').Value));
         EditText(oForm.Items.Item('PerVidaU').Specific).value := TMultiFunctions.IntToStr(System.Int32(oRecordSet1.Fields.Item('U_VidaUtIF').Value));
      end;

      EnableValidate := true;
      oForm.Update;
   except
      on e:exception do begin
         OutLog('LlenarFinanzasDesdeGrupo : ' + e.Message + ' - ' + e.StackTrace );
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TActivosIFRS.LlenarFinanzas(oForm: SAPbouiCOM.Form);
var
   oRecordSet1: SAPbobsCOM.Recordset;
   s       : string;
begin
   try
      // llenar finanzas
      oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaActFi', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescAcFi').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtActFi').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaReaAF', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescReAF').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtReaAF').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaDetAF', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescDeAF').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtDetAF').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaDepAc', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescDeAc').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtDepAc').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaGasDe', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescGaDe').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtGasDe').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaGasBj', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescGaBj').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtGasBj').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CtaAdqAc', 0));
      if (s <> '') then begin
         oRecordSet1.DoQuery ('Select U_AcctName, U_FormatCo from [@VID_OACT] where U_AcctCode  = ''' + s + '''');
         oForm.DataSources.UserDataSources.Item('DSDescAdAc').Value := System.String(oRecordSet1.Fields.Item('U_AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').Value := System.String(oRecordSet1.Fields.Item('U_FormatCo').Value);
      end;

      s := FSBOf.DoubleToStr( FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_CurVal'  , 0)) +
                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_AdicAnu' , 0)) -
                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_DepAcum' , 0)) -
                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_DepreAnu', 0))
                            );
      oForm.DataSources.UserDataSources.Item('DSValNeto').ValueEx := s;

      s := EditText(oForm.Items.Item('EmpId').Specific).value;
      if (s <> '') then begin
         oRecordSet.DoQuery ('Select empid, firstname, lastname, branch from ohem where EmpId = ' + s);
         s := System.String(oRecordSet.Fields.Item('lastname').Value) + ', ' +
              System.String(oRecordSet.Fields.Item('firstname').Value);
         oForm.DataSources.UserDataSources.Item('DSEmpName').Value := s;
      end;

{      if (oForm.Mode = BoFormMode.fm_UPDATE_MODE) or (oForm.Mode = BoFormMode.fm_ADD_MODE) then
         exit
      else

      if (CheckBox(oForm.Items.Item('DeBaja').Specific).Checked) then begin 
         oForm.Mode := BoFormMode.fm_VIEW_MODE;
      end

      else
         oForm.Mode := BoFormMode.fm_OK_MODE;
}

      oForm.Update;
   except
      on e:exception do begin
         OutLog('LlenarFinanzas : ' + e.Message + ' - ' + e.StackTrace );
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TActivosIFRS.LimpiarFinanzas(oForm: SAPbouiCOM.Form);
begin
   try
      EnableValidate := false;
      oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSEmpName' ).ValueEx := '';
      EnableValidate := true;

      if (oForm.DataSources.DBDataSources.Item('@VID_AFASIF').GetValue('U_ConDepre', 0) = '') then
         oForm.DataSources.DBDataSources.Item('@VID_AFASIF').SetValue('U_ConDepre', 0, 'Y');

   except
      on e:exception do begin
         OutLog('Limpiar Finanzas : ' + e.Message + ' - ' + e.StackTrace );
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TActivosIFRS.ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
var
   s:      string;
   oDSD:   DBDataSource;
   i:      integer;
   maxlin: integer;
begin
   result := false;          // esta condicion debe mejorarse
   s := FSBOf.VerificarItemsRequeridos(oForm, Lista);
   if (s <> '') then begin
      FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      exit;
   end;

   Matrix(oForm.Items.Item('Mx_Compo').Specific).FlushToDataSource;
   oDSD := oForm.DataSources.DBDataSources.Item('@VID_AFCOIF');
   i:=0;
   while i <= oDSD.Size-1 do begin
      if (oDSD.GetValue('U_Cantidad', i) = '') then
         oDSD.RemoveRecord(i)
      else
         inc(i);
   end;
   maxlin := 0;
   for i:=0 to oDSD.Size-1 do begin
      if (oDSD.GetValue('LineId', i) = '') then
         continue;
      if (maxlin < TMultiFunctions.strtoint(oDSD.GetValue('LineId', i))) then
         maxlin := TMultiFunctions.strtoint(oDSD.GetValue('LineId', i));
   end;
   for i:=0 to oDSD.Size-1 do begin
      if (oDSD.GetValue('LineId', i) = '') then begin
         inc(maxlin);
         oDSD.SetValue('LineId', i, maxlin.ToString)
      end;
   end;
   Matrix(oForm.Items.Item('Mx_Compo').Specific).LoadFromDataSource;

   result := true;
end;

method TActivosIFRS.SetVisibilidad(oForm: SAPbouiCOM.Form);
var
   s: string;
   i: integer;
begin
   try
      oForm.Freeze(true);
      s := 'select count(*) cant from [@vid_afacif] where u_year is not null and code = ''' + EditText(oForm.Items.Item('Code').Specific).value + '''';
      oRecordSet.DoQuery(s);
      i := System.Int32(oRecordSet.Fields.Item('cant').Value);
      if (i = 0) and (not CheckBox(oForm.Items.Item('DeBaja').Specific).Checked) then begin
      Lista.Clear;
                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'ActCode  ,  t,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActName  ,  t,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActSerNu ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ItemCode ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'ItemName ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'DeBaja   ,  t,  f,  f,  f, n, 1 ');
      Lista.Add( 'InDate   ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'InitYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'InitPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocName  ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'OriVal   ,  t,  t,  f,  f, r, >0');
      Lista.Add( 'OriFec   ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriValIn ,  t,  t,  f,  f, r, >0');
      Lista.Add( 'PorResid ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDp ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriDepre ,  t,  t,  f,  f, r, l');
      Lista.Add( 'InvDate  ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  t,  t,  f,  f, n, 1 ');

      Lista.Add( 'FmtActFi ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtReaAF ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtDetAF ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtDepAc ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasDe ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasBj ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtAdqAc ,  t,  t,  f,  f, r, 1 ');

      Lista.Add( 'VidaUtil ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'PerDepre ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'NextYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NextPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'CurVal   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepAcum  ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'DepreAnu ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Adicion,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'Mx_Compo  ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFAC,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFSA,  f,  f,  f,  f, n, 1 ');

{
         oForm.Items.Item('ActCode').Enabled  := true;
         oForm.Items.Item('ActName').Enabled  := true;
         oForm.Items.Item('ItemCode').Enabled := true;
//         oForm.Items.Item('ItemName').Enabled := true;
         oForm.Items.Item('ItmGrpCd').Enabled := true;
         oForm.Items.Item('ConDepre').Enabled := true;
         oForm.Items.Item('Bis33Flg').Enabled := true;
         oForm.Items.Item('InDate').Enabled   := true;
//         oForm.Items.Item('InitYear').Enabled := true;
//         oForm.Items.Item('InitPer').Enabled  := true;
         oForm.Items.Item('PerVidaU').Enabled := true;
         oForm.Items.Item('NxYrDepr').Enabled := true;
         oForm.Items.Item('NxPrDepr').Enabled := true;
         oForm.Items.Item('EmpId').Enabled    := true;
         oForm.Items.Item('LocCode').Enabled  := true;

         oForm.Items.Item('PerVidaR').Enabled := true;
         oForm.Items.Item('OriValCR').Enabled := true;
         oForm.Items.Item('OriPerDR').Enabled := true;
         oForm.Items.Item('OriDeprR').Enabled := true;

         oForm.Items.Item('OriVal').Enabled   := true;
         oForm.Items.Item('OriValIn').Enabled := true;
         oForm.Items.Item('OriFec').Enabled   := true;
         oForm.Items.Item('PorResid').Enabled := true;
         oForm.Items.Item('InvNum').Enabled   := true;
         oForm.Items.Item('InvLine').Enabled  := true;
         oForm.Items.Item('InvDate').Enabled  := true;
         oForm.Items.Item('OriPerDp').Enabled := true;
         oForm.Items.Item('OriDepre').Enabled := true;

         oForm.Items.Item('FmtActFi').Enabled := true;
         oForm.Items.Item('FmtReaAF').Enabled := true;
         oForm.Items.Item('FmtDetAF').Enabled := true;
         oForm.Items.Item('FmtDepAc').Enabled := true;
         oForm.Items.Item('FmtGasDe').Enabled := true;
         oForm.Items.Item('FmtGasBj').Enabled := true;
         oForm.Items.Item('FmtAdqAc').Enabled := true;
}
      end
      else if (not CheckBox(oForm.Items.Item('DeBaja').Specific).Checked) then begin
      Lista.Clear;
                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'ActCode  ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActName  ,  t,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActSerNu ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ItemCode ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'ItemName ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'DeBaja   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InDate   ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'InitYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'InitPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocName  ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'OriVal   ,  f,  t,  f,  f, r, >0');
      Lista.Add( 'OriFec   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriValIn ,  f,  t,  f,  f, r, >0');
      Lista.Add( 'PorResid ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDp ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriDepre ,  f,  t,  f,  f, r, l');
      Lista.Add( 'InvDate  ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  f,  t,  f,  f, n, 1 ');

      Lista.Add( 'FmtActFi ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtReaAF ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtDetAF ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtDepAc ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasDe ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasBj ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtAdqAc ,  f,  t,  f,  f, r, 1 ');
                  
      Lista.Add( 'VidaUtil ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'PerDepre ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'NextYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NextPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'CurVal   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepAcum  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepreAnu ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Adicion,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'Mx_Compo  ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFAC,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFSA,  f,  f,  f,  f, n, 1 ');
      end

      else  begin
      Lista.Clear;
                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'ActCode  ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'ActName  ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'ActSerNu ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'ItemCode ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'ItemName ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'DeBaja   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InDate   ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'InitYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'InitPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'LocName  ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'OriVal   ,  f,  f,  f,  f, r, >0');
      Lista.Add( 'OriFec   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'OriValIn ,  f,  f,  f,  f, r, >0');
      Lista.Add( 'PorResid ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDp ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'OriDepre ,  f,  f,  f,  f, r, l');
      Lista.Add( 'InvDate  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'FmtActFi ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtReaAF ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtDetAF ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtDepAc ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasDe ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasBj ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtAdqAc ,  f,  f,  f,  f, r, 1 ');

      Lista.Add( 'VidaUtil ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'PerDepre ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'NextYear ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NextPer  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'CurVal   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepAcum  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'DepreAnu ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Adicion, f,  f,  f,  f, n, 1 ');
      Lista.Add( 'Mx_Compo  , f,  f,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFAC, f,  f,  f,  f, n, 1 ');
      Lista.Add( 'MxVID_AFSA, f,  f,  f,  f, n, 1 ');
      end;

      FSBOf.SetAutoManaged(oForm, Lista);
   finally
      oForm.Freeze(false);
//      oForm.Update;
   end;
end;

end.
