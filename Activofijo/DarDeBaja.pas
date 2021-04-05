namespace AF_IFRS.DarDeBaja;

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
  TAFAVRecord = public record
  private
  public
      Id            : integer;
      LineId        : integer;
      U_Year        : integer;    
      U_Periodo     : integer; 
      U_CorrActi    : double;
      U_CorrDepr    : double;
      U_CorrDepM    : double;
      U_Deprecia    : double;
      U_DeprNom     : double;
      U_Adicion     : double;
      U_PerVidUt    : integer;
      U_PerDepre    : integer;
      U_PostFlag    : string;
  end;

  TDarDeBaja = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet   : SAPbobsCOM.Recordset;
    Lista        : List<String>;
    RevBaja      : boolean;
    RevBajaAnual : boolean;
    Repomo       : boolean;
    CorrPos      : boolean;
    Valor_resid  : double;
    Utils        : TUtils;
    ErrCode      : integer;
    ErrMsg       : string;
    oTasaFija    :  boolean := false;
    oPostSysCu   :  boolean := false;
    method   AddChooseFromList(oForm: SAPbouiCOM.Form);
    method   DarDeBaja(oForm: SAPbouiCOM.Form; oYr, oPer: integer): Boolean;
    method   DarDeBajaRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; var oPerIngreso: integer; var oYrIngreso: integer;  
                             var oDBDS             : SAPbouiCOM.DBDataSource;
                             var oActivos          : SAPbobsCOM.GeneralService;
                             var oActivosData      : SAPbobsCOM.GeneralData;
                             var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                             var oValCA            : double;
                             var oValCD            : double;
                             var oValDe            : double;
                             var oValAct           : double;
                             var oFactor           : double;
                             var oValActF          : double;
                             var oValDepA          : double;
                             var oValCASys         : double;
                             var oValCDSys         : double;
                             var oValDeSys         : double;
                             var oValActsys        : double;
                             var oValActFSys       : double;
                             var oValDepASys       : double;
                             var Fecha             : DateTime;
                             var lin               : Integer;
                             var oCtoCost1         : String;
                             var oCtoCost2         : String;
                             var oCtoCost3         : String;
                             var oCtoCost4         : String;
                             var oCtoCost5         : String;
                             var soloTrib          : boolean);
    method   DarDeBajaNoRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
    method   DarDeBajaNoRepomoReversaAnual(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double);
    method   DarDeBajaReferencial(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double);
    method   AnularDarDeBaja(oForm: SAPbouiCOM.Form; oYr, oPer: integer): Boolean;
    method   AnularDarDeBajaRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; var oPerIngreso: integer; var oYrIngreso: integer;  
                             var oDBDS             : SAPbouiCOM.DBDataSource;
                             var oActivos          : SAPbobsCOM.GeneralService;
                             var oActivosData      : SAPbobsCOM.GeneralData;
                             var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                             var oValCA            : double;
                             var oValCD            : double;
                             var oValDe            : double;
                             var oValAct           : double;
                             var oFactor           : double;
                             var oValActF          : double;
                             var oValDepA          : double;
                             var oValCASys         : double;
                             var oValCDSys         : double;
                             var oValDeSys         : double;
                             var oValActsys        : double;
                             var oValActFSys       : double;
                             var oValDepASys       : double;
                             var Fecha             : DateTime;
                             var lin               : Integer;
                             var oCtoCost1         : String;
                             var oCtoCost2         : String;
                             var oCtoCost3         : String;
                             var oCtoCost4         : String;
                             var oCtoCost5         : String;
                             var soloTrib          : boolean);
    method   AnularDarDeBajaNoRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
    method   AnularDarDeBajaNoRepomoReversaAnual(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso: integer; 
                               var oYrIngreso: integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
    method   AnularDarDeBajaReferencial(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso: integer; 
                               var oYrIngreso: integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
    method   AjustarDecimalesSUM(Valor: double): double;
    method   AjustarDecimalesSUMSys(Valor: double): double;
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
  end;

implementation

uses
    AF_IFRS.Utils,
    System.Globalization;

method   TDarDeBaja.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm : SAPbouiCOM.Form;
   sql   : String;
   oSql  : string;
   i     : Integer;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);

   // inicializa variable locales
   Utils := new TUtils(_GlobalSettings, company, SBOFunctions);
   // oDebug
   utils.oDebug := true;

   Lista := new List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_AFDeBaja_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_AFDeBaja.srf', Uid);

      oForm := FSBOApp.Forms.Item(uid);
      oForm.Freeze(True);
      oForm.AutoManaged    := false;
      oForm.SupportedModes := 1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_OK_MODE;

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

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

      // Parametros
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select U_RevBaja, U_RBajaAnu, U_Repomo, U_CorPosit, U_ValResid from [@VID_AFPA]", 
                  'Select "U_RevBaja", "U_RBajaAnu", "U_Repomo", "U_CorPosit", "U_ValResid" from "@VID_AFPA"');
      oRecordSet.DoQuery(oSql);
      if (oRecordSet.EoF) then
         raise new Exception('Parametros indefinidos');

      RevBaja := false;
      if (System.String(oRecordSet.Fields.Item('U_RevBaja').Value).Trim = 'Y') then
         RevBaja := true;

      RevBajaAnual := false;
      if (System.String(oRecordSet.Fields.Item('U_RBajaAnu').Value).Trim = 'Y') then
         RevBajaAnual := true;

      Repomo := False;
      if (System.String(oRecordSet.Fields.Item('U_Repomo').Value).Trim = 'Y') then
         Repomo := True;

      CorrPos := False;
      if (System.String(oRecordSet.Fields.Item('U_CorPosit').Value).Trim = 'Y') then
         CorrPos := True;

      Valor_Resid := System.Double(oRecordSet.Fields.Item('U_ValResid').Value);

      oTasaFija  := false;
      oPostSysCu := false;
      oSql := iif(FGlobalSettings.RunningUnderSQLServer, 
                  "Select U_ConMSCFi, U_PostSysCu  from [@VID_AFPA]",
                  'Select "U_ConMSCFi", "U_PostSysCu" from "@VID_AFPA"');
      oRecordset.DoQuery(oSql);
      if (not oRecordset.EoF) then begin
         if (System.String(oRecordset.Fields.Item('U_ConMSCFi').Value) = 'Y') then 
            oTasaFija := true;
         if (System.String(oRecordset.Fields.Item('U_PostSysCu').Value) = 'Y') then begin
            oPostSysCu := true;
         end;
      end;

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

      oForm.DataSources.UserDataSources.Add('DSValResi',SAPbouiCOM.BoDataType.dt_SUM,12);
      oForm.DataSources.UserDataSources.Add('DSValNeto',SAPbouiCOM.BoDataType.dt_SUM,12);
      EditText(oForm.Items.Item('ValorResi').Specific).DataBind.SetBound(true,'','DSValResi');
      EditText(oForm.Items.Item('ValorNeto').Specific).DataBind.SetBound(true,'','DSValNeto');
      oForm.Freeze(False);
      oForm.Update;

      oForm.Visible := true;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TDarDeBaja.AddChooseFromList(oForm: SAPbouiCOM.Form);
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

   {
   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'U_DeBaja';
   oCon.Operation := BoConditionOperation.co_NOT_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);
   }
end;

method TDarDeBaja.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   sValue          : string;
   oDataTable      : SAPbouiCOM.DataTable;
   oDBDSH          : SAPbouiCOM.DBDataSource;
   oCons           : SAPbouiCOM.Conditions;
   oCon            : SAPbouiCOM.Condition;
   Fecha           : DateTime;
   vPer            : integer;
   vYr             : integer;
   s               : string;
   s1,s2           : string;
   IniYr, IniPr    : string;
   oSql            : string;
   OperacionRealizada : Boolean := false;

   oCodeAct    : string;
   oCode       : string;
   NextYr      : integer;
   NextPr      : integer;
   minYrRv     : integer;
   minPrRv     : integer;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   oForm := FSBOApp.Forms.Item(pVal.FormUID);
   oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFAS');

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
            if (sValue <> '') then begin
               oCons := new SAPbouiCOM.ConditionsClass;
               oCon := oCons.Add();

               oCon.Alias := 'U_ActCode';
               oCon.Operation := BoConditionOperation.co_EQUAL;
               oCon.CondVal := sValue;
               oDBDSH.Query(oCons);

               s := oDBDSH.GetValue('U_EmpId', 0);
               if (s <> '') then begin
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select empid, firstname, lastname, branch from ohem where EmpId = {0}", 
                              'Select "empID" empid, "firstName" firstname, "lastName" lastname, "branch" from ohem where "empID" = {0}');
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

               // Valor libro para activos revalorizados
               oCodeAct := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ActCode', 0));
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select U_NextYear, U_NextPer, Code from [@VID_AFAS] Where U_ActCode = '{0}'", 
                           'Select "U_NextYear", "U_NextPer", "Code" from "@VID_AFAS" Where "U_ActCode" = ''{0}''');
               oSql := string.Format(oSql, oCodeAct);
               oRecordSet.DoQuery(oSql);
               oCode  := System.String(oRecordSet.Fields.Item('Code').Value).Trim;
               NextYr := System.Int32(oRecordSet.Fields.Item('U_NextYear').Value);
               NextPr := System.Int32(oRecordSet.Fields.Item('U_NextPer').Value);
               if (NextPr = 1) then begin
                   NextPr := 12;
                   NextYr := NextYr - 1;
               end
               else
                   NextPr := NextPr - 1;

               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select Month(max(h.U_Fecha)) Mes, Year(max(h.U_Fecha)) Year, count(*) cant   " +
                           "   from [@VID_AFREVD] d inner join [@VID_AFREV] h on h.DocEntry = d.DocEntry " +
                           "  where ((h.U_Year = {0} and h.U_Periodo <= {1}) or (h.U_Year < {0}))        " +
                           "    and d.U_ActCode = '{2}' ", 
                           'Select Month(max(h."U_Fecha")) Mes, Year(max(h."U_Fecha")) Year, count(*) "cant" ' +
                           '  from "@VID_AFREVD" d inner join "@VID_AFREV" h on h."DocEntry" = d."DocEntry"  ' +
                           ' where ((h."U_Year" = {0} and h."U_Periodo" <= {1}) or (h."U_Year" < {0}))       ' + 
                           '   and d."U_ActCode" = ''{2}''');
               oSql := string.Format(oSql, NextYr.ToString, NextPr.ToString, oCodeAct);
               oRecordSet.DoQuery(oSql);
               minYrRv := 0;
               minPrRv := 0;
               if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
                  minYrRv := System.Int32(oRecordSet.Fields.Item('Year').Value);
                  minPrRv := System.Int32(oRecordSet.Fields.Item('Mes').Value);
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select sum(U_Deprecia) Depreciacion  " +
                              "  from [@VID_AFAC]                   " +
                              " where Code = '{0}'                  " +
                              "   and ((U_Year > {1} ) or (U_Year = {1} and U_Periodo >= {2}))", 
                              'Select sum("U_Deprecia") "Depreciacion"  ' +
                              '  from "@VID_AFAC"                       ' +
                              ' where "Code" = ''{0}''                  ' +
                              '   and (("U_Year" > {1} ) or ("U_Year" = {1} and "U_Periodo" >= {2})) ');
                  oSql := string.Format(oSql, oCode, minYrRv.ToString(), minPrRv.ToString());
                  oRecordSet.DoQuery(oSql);
                  s := FSBOf.DoubleToStr( FSBOf.StrToDouble(oForm.DataSources.UserDataSources.Item('DSValNeto').ValueEx) - 
                                          System.Double(oRecordSet.Fields.Item('Depreciacion').Value)   );
                  oForm.DataSources.UserDataSources.Item('DSValResi').ValueEx := s;
               end;
               // Termina Revalorizacion

               if (FSBOf.StringToDouble(s) = 0.0) then
                   oForm.DataSources.UserDataSources.Item('DSValResi').ValueEx := FSBOf.DoubleToStr(Valor_Resid);

               if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DeBaja', 0) = 'Y') then begin
                  oForm.Items.Item('BtnBaja'  ).Enabled := false;
                  oForm.Items.Item('BtnBaja'  ).Visible := false;
                  oForm.Items.Item('btnAnular').Visible := true;
                  oForm.ITems.Item('BajaFec'  ).Enabled := false;
                  //Button(oForm.Items.Item('BtnBaja').Specific).Caption := 'Anular Baja';
               end
               else begin
                  oForm.Items.Item('BtnBaja'  ).Enabled := true;
                  oForm.Items.Item('BtnBaja'  ).Visible := true;
                  oForm.Items.Item('btnAnular').Visible := false;
                  oForm.ITems.Item('BajaFec'  ).Enabled := true;
                  if (FCmpny.language = BoSuppLangs.ln_English) then
                      Button(oForm.Items.Item('BtnBaja').Specific).Caption := 'Retirement'
                  else
                      Button(oForm.Items.Item('BtnBaja').Specific).Caption := 'Dar de Baja';
               end;


               oForm.Mode := BoFormmode.fm_OK_MODE;
               oForm.Items.Item('InDate').Update;
               oForm.Items.Item('ActName').Update;
               oForm.Items.Item('ItmGrpCd').Update;
               oForm.Items.Item('InDate').Update;
               oForm.Items.Item('InitYear').Update;
               oForm.Items.Item('InitPer').Update;
               oForm.Items.Item('EmpId').Update;
               oForm.Items.Item('EmpName').Update;
               oForm.Items.Item('VidaUtil').Update;
               oForm.Items.Item('PerDepre').Update;
               oForm.Items.Item('NextYear').Update;
               oForm.Items.Item('NextPer').Update;
               oForm.Items.Item('OriVal').Update;
               oForm.Items.Item('OriValCo').Update;
               oForm.Items.Item('PorResid').Update;
               oForm.Items.Item('OriPerDp').Update;
               oForm.Items.Item('OriDepre').Update;
               oForm.Items.Item('LocName').Update;

               oForm.Update;
            end
            ;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = True) then begin
         if (pVal.ItemUID = 'btnAnular') then begin
            if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DeBaja', 0) <> 'Y') then 
               exit;

            Fecha := FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value);
            vPer  := TMultiFunctions.strToint(oDBDSH.GetValue('U_NextPer' , 0));
            vYr   := TMultiFunctions.strToint(oDBDSH.GetValue('U_NextYear', 0));

            if (vPer = 1) then begin
               vYr  := vYr - 1;
               vPer := 12;
            end
            else
               vPer := vPer - 1;

            if (2 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Anular_Baja_QM], 1, 'Cancel', 'Ok', '')) then begin
               if (AnularDarDeBaja(oForm, vYr, vPer)) then
                  OperacionRealizada := true;
            end; 
         end;

         if (pVal.ItemUID = 'BtnBaja') then begin
            if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DeBaja', 0) = 'Y') then
               exit;

            Fecha := FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value);

            if (Repomo) then begin
               // Periodo en que se da de baja NO debe estar contabilizado
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select U_PostFlag from [@VID_AFAC] " +
                           " where Code = '{0}'                " +
                           "   and U_Year = {1}                " +
                           "   and U_Periodo = {2}             ", 
                           'Select "U_PostFlag" from "@VID_AFAC" ' +
                           ' where "Code" = ''{0}''              ' +
                           '   and "U_Year" = {1}                ' +
                           '   and "U_Periodo" = {2}             ');
               oSql := string.Format(oSql, oDBDSH.GetValue('Code', 0).Trim, Fecha.Year.ToString, Fecha.Month.ToString);
               oRecordSet.DoQuery(oSql);
               oRecordSet.MoveFirst;
               if (not oRecordSet.EoF) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Per_Post_Actividad], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;

               if (oDBDSH.GetValue('U_ActTipo', 0).Trim = 'T') then
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select 'Y' U_PostFlag from [@VID_AFACR] " +
                              " where Code = '{0}'                " +
                              "   and U_Year = {1}                " +
                              "   and U_Periodo = {2}             ", 
                              'Select ''Y'' "U_PostFlag" from "@VID_AFACR" ' +
                              ' where "Code" = ''{0}''              ' +
                              '   and "U_Year" = {1}                ' +
                              '   and "U_Periodo" = {2}             ')
               else
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select isnull(U_PostFlag, 'N') U_PostFlag from [@VID_AFAC] " +
                              " where Code = '{0}'                " +
                              "   and U_Year = {1}                " +
                              "   and U_Periodo = {2}             ", 
                              'Select IfNull("U_PostFlag", ''N'') "U_PostFlag" from "@VID_AFAC" ' +
                              ' where "Code" = ''{0}''              ' +
                              '   and "U_Year" = {1}                ' +
                              '   and "U_Periodo" = {2}             ');

               oSql := string.Format(oSql, oDBDSH.GetValue('Code', 0).Trim, Fecha.AddMonths(-1).Year.ToString, Fecha.AddMonths(-1).Month.ToString);
               oRecordSet.DoQuery(oSql);
               oRecordSet.MoveFirst;
               if (oRecordSet.EoF) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Depreciar_Activo], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;
               if (System.String(oRecordSet.Fields.Item('U_PostFlag').Value) <> 'Y') then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Contabilizar_Activo], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;

               if (2 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Dar_Baja_QM], 1, 'Cancel', 'Ok', '')) then begin
                   if (DarDeBaja(oForm, Fecha.Year, Fecha.Month)) then
                      OperacionRealizada := true;
               end;
            end
            else begin
               // Periodo en que se da de baja debe estar contabilizado
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select U_PostFlag from [@VID_AFAC] " +
                              " where Code = '{0}'                " +
                              "   and U_Year = {1}                " +
                              "   and U_Periodo = {2}             ", 
                              'Select "U_PostFlag" from "@VID_AFAC" ' +
                              ' where "Code" = ''{0}''              ' +
                              '   and "U_Year" = {1}                ' +
                              '   and "U_Periodo" = {2}             ');
               oSql := string.Format(oSql, oDBDSH.GetValue('Code', 0).Trim, Fecha.AddMonths(1).Year.ToString, Fecha.AddMonths(1).Month.ToString);
               oRecordSet.DoQuery(oSql);
               oRecordSet.MoveFirst;
               if (not oRecordSet.EoF) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Per_Post_Actividad], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;

               if (oDBDSH.GetValue('U_ActTipo', 0).Trim = 'T') then
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select 'Y' U_PostFlag from [@VID_AFACR] " +
                              " where Code = '{0}'                " +
                              "   and U_Year = {1}                " +
                              "   and U_Periodo = {2}             ", 
                              'Select ''Y'' "U_PostFlag" from "@VID_AFACR" ' +
                              ' where "Code" = ''{0}''              ' +
                              '   and "U_Year" = {1}                ' +
                              '   and "U_Periodo" = {2}             ')
               else
                  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                              "Select isnull(U_PostFlag, 'N') U_PostFlag from [@VID_AFAC] " +
                              " where Code = '{0}'                " +
                              "   and U_Year = {1}                " +
                              "   and U_Periodo = {2}             ", 
                              'Select IfNull("U_PostFlag", ''N'') "U_PostFlag" from "@VID_AFAC" ' +
                              ' where "Code" = ''{0}''              ' +
                              '   and "U_Year" = {1}                ' +
                              '   and "U_Periodo" = {2}             ');

               oSql := string.Format(oSql, oDBDSH.GetValue('Code', 0).Trim, Fecha.Year.ToString, Fecha.Month.ToString);
               oRecordSet.DoQuery(oSql);
               oRecordSet.MoveFirst;
               if (oRecordSet.EoF) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Depreciar_Activo], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;
               if (System.String(oRecordSet.Fields.Item('U_PostFlag').Value) <> 'Y') then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Contabilizar_Activo], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;

               if (2 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Dar_Baja_QM], 1, 'Cancel', 'Ok', '')) then begin
                   if (DarDeBaja(oForm, Fecha.Year, Fecha.Month)) then
                      OperacionRealizada := true;
               end;
            end;
         end;
      end

    finally 
      oForm.Freeze(False);
      if (OperacionRealizada) then
         oForm.Close;
    end;
   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TDarDeBaja.DarDeBaja(oForm: SAPbouiCOM.Form; oYr, oPer: integer): Boolean;
var
   oDBDS             : SAPbouiCOM.DBDataSource;
   oActivos          : SAPbobsCOM.GeneralService;
   oActivosData      : SAPbobsCOM.GeneralData;
   oActivosParameter : SAPbobsCOM.GeneralDataParams;
   s                 : string;
   Fecha             : DateTime;
   sql               : string;
   oValCA            : double;
   oValCD            : double;
   oValDe            : double;
   oValAct           : double;
   oFactor           : double;
   oValActF          : double;
   oValDepA          : double;
   oValCASys         : double;
   oValCDSys         : double;
   oValDeSys         : double;
   oValActsys        : double;
   oValActFSys       : double;
   oValDepASys       : double;
   oCorAnuAc         : double;

   lin               : Integer;
   oPerIngreso       : Integer;
   oYrIngreso        : Integer;
   oCtoCost1         : String;
   oCtoCost2         : String;
   oCtoCost3         : String;
   oCtoCost4         : String;
   oCtoCost5         : String;
   soloTrib          : boolean := false;
   oSql              : string;

   // No conatbilizar Gastos depreciacion, genera saldo de activos > 0
   oContabGastDepre  : boolean := false;
   oAux_oValDe: double := 0.0;
begin
      try
         result := false;

         oDBDS     := oForm.DataSources.DBDataSources.Item('@VID_AFAS');

         if (oDBDS.GetValue('U_ActTipo', 0).Trim = 'T') then begin
            soloTrib := true;

            if (oPer = 1) then begin
               oYr  := oYr - 1;
               oPer := 12;
            end
            else
               oPer := oPer - 1;

               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                           "  from [@vid_afacR] d inner join [@vid_afas] h on d.code = h.code " +
                           " where h.u_actcode = '{0}'           " +
                           "   and d.U_Year = {1}                " +
                           "   and d.U_Periodo = {2}             ", 
                           'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                           '  from "@VID_AFACR" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                           ' where h."U_ActCode" = ''{0}''         ' +
                           '   and d."U_Year" = {1}                ' +
                           '   and d."U_Periodo" = {2}             ');

               oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
               oRecordSet.DoQuery(oSql);

            if (oRecordSet.EoF) then
               raise new Exception('Información incompleta para el activo a dar de baja ');

            oFactor := 1.0 - Double(Fecha.Day)/Fecha.DaysInMonth(Fecha.Year, Fecha.Month);;

            oValDe  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor;
            if (not oPostSysCu) then
              oValDe  := AjustarDecimalesSUM(oValDe)
            else
              oValDe  := AjustarDecimalesSUMSys(oValDe);

            oActivos := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));

            oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select Code from [@VID_AFAS] where U_ActCode = '{0}'", 
                        'Select "Code" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
            oSql := string.Format(oSql, EditText(oForm.Items.Item('ActCode').Specific).Value);
            oRecordSet.DoQuery(oSql);
            s := System.string(oRecordSet.Fields.Item('Code').Value);
            oActivosParameter.SetProperty('Code', s);

            oActivosData := oActivos.GetByParams(oActivosParameter);

             if (RevBajaAnual) then
                 DarDeBajaReferencial(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                                               , var oDBDS, var oActivos, var oActivosData, var oActivosParameter
                                               , var oValDe, var oValAct, var oValActF, var oValDepA
                                               , var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                                               , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                                               , var oCorAnuAc);
            s := 'Y';
            oActivosData.SetProperty('U_DeBaja' , s);
            oActivosData.SetProperty('U_ValBaja', oValDe);
            oActivosData.SetProperty('U_BajaFec', FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value));

            oActivos.Update(oActivosData);

            result := true;

            FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Baja_activo] + 
                                      EditText(oForm.Items.Item('ActCode').Specific).Value + 
                                      GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Dado_baja], 
                                      BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
         end;
      except
         on e: exception do begin
            FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            OutLog("Dar de baja: " + e.Message + '  ** Trace: ' + e.StackTrace);
         end;
      end;

      if (soloTrib) then
         exit;

      oCtoCost1 := oDBDS.GetValue('U_ProfitCt', 0).Trim;
      oCtoCost2 := oDBDS.GetValue('U_ProfitC2', 0).Trim;
      oCtoCost3 := oDBDS.GetValue('U_ProfitC3', 0).Trim;
      oCtoCost4 := oDBDS.GetValue('U_ProfitC4', 0).Trim;
      oCtoCost5 := oDBDS.GetValue('U_ProfitC5', 0).Trim;

      Fecha       := FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value);
      oPerIngreso := FSBOf.StrToInteger(oDBDS.GetValue('U_InitPer'  , 0));
      oYrIngreso  := FSBOf.StrToInteger(oDBDS.GetValue('U_InitYear' , 0));

      //AFAC
      try
         oActivos := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));

         oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code from [@VID_AFAS] where U_ActCode = '{0}'", 
                     'Select "Code" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
         oSql := string.Format(oSql, EditText(oForm.Items.Item('ActCode').Specific).Value);
         oRecordSet.DoQuery(oSql);
         s := System.string(oRecordSet.Fields.Item('Code').Value);
         oActivosParameter.SetProperty('Code', s);

         oActivosData := oActivos.GetByParams(oActivosParameter);

         FSBOf.Cmpny.StartTransaction;

         if (oDBDS.GetValue('U_ActTipo', 0).Trim = 'T') or (oDBDS.GetValue('U_ActTipo', 0).Trim = 'N') then begin
             if (RevBajaAnual) then
                 DarDeBajaReferencial(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                                               , var oDBDS, var oActivos, var oActivosData, var oActivosParameter
                                               , var oValDe, var oValAct, var oValActF, var oValDepA
                                               , var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                                               , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                                               , var oCorAnuAc);
         end;

         if (Repomo) then begin
            DarDeBajaRepomo(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                           , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                           , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                           , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                           , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib);   
         end
         else if (RevBajaAnual and RevBaja) and false then begin // por ahora no contabiliza
            DarDeBajaNoRepomoReversaAnual(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                                          , var oDBDS, var oActivos, var oActivosData, var oActivosParameter
                                          , var oValDe, var oValAct, var oValActF, var oValDepA
                                          , var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                                          , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                                          , var oCorAnuAc);
         end
         else begin
            DarDeBajaNoRepomo(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                              , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                              , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                              , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                              , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                              , var oCorAnuAc, var oContabGastDepre, var oAux_oValDe);
         end;

         s := 'Y';
         oActivosData.SetProperty('U_DeBaja' , s);
         oActivosData.SetProperty('U_ValBaja', oValDe);
         oActivosData.SetProperty('U_BajaFec', FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value));

         oActivos.Update(oActivosData);

         FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_Commit);
         result := true;

         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Baja_activo] + 
                                   EditText(oForm.Items.Item('ActCode').Specific).Value + 
                                   GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Dado_baja], 
                                   BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
      except
         on e: exception do begin
            if (FSBOf.Cmpny.InTransaction) then
               FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
            FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            OutLog("Dar de baja: " + e.Message + '  ** Trace: ' + e.StackTrace);
         end;
      end;
end;

method TDarDeBaja.DarDeBajaRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
  var oPerIngreso       : integer; 
  var oYrIngreso        : integer;
  var oDBDS             : SAPbouiCOM.DBDataSource;
  var oActivos          : SAPbobsCOM.GeneralService;
  var oActivosData      : SAPbobsCOM.GeneralData;
  var oActivosParameter : SAPbobsCOM.GeneralDataParams;
  var oValCA            : double;
  var oValCD            : double;
  var oValDe            : double;
  var oValAct           : double;
  var oFactor           : double;
  var oValActF          : double;
  var oValDepA          : double;
  var oValCASys         : double;
  var oValCDSys         : double;
  var oValDeSys         : double;
  var oValActsys        : double;
  var oValActFSys       : double;
  var oValDepASys       : double;
  var Fecha             : DateTime;
  var lin               : Integer;
  var oCtoCost1         : String;
  var oCtoCost2         : String;
  var oCtoCost3         : String;
  var oCtoCost4         : String;
  var oCtoCost5         : String;
  var soloTrib          : boolean);
var
   oJEntries         : SAPbobsCOM.JournalEntries;
   oSql              : string;
   s          : string;
   orst       : SAPbobsCOM.Recordset;
begin
      oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
      orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      try

         if (oPer = 1) then begin
            oYr  := oYr - 1;
            oPer := 12;
         end
         else
            oPer := oPer - 1;

         if ((oPer = oPerIngreso) and (oYr = oYrIngreso)) or (oYr < oYrIngreso) or ((oPer < oPerIngreso) and (oYr = oYrIngreso)) then begin
         end
         else begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                        "  from [@vid_afac] d inner join [@vid_afas] h on d.code = h.code " +
                        " where h.u_actcode = '{0}'           " +
                        "   and d.U_Year = {1}                " +
                        "   and d.U_Periodo = {2}             ", 
                        'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                        '  from "@VID_AFAC" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                        ' where h."U_ActCode" = ''{0}''         ' +
                        '   and d."U_Year" = {1}                ' +
                        '   and d."U_Periodo" = {2}             ');

            oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
            oRecordSet.DoQuery(oSql);
            if (oRecordSet.EoF) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Baja_Info_Incompleta]);
         end;

         oFactor := 0;

         oValAct  := FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0));
         oValDepA := FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0));
         if (not oPostSysCu) then begin
            oValAct  := AjustarDecimalesSUM(oValAct);
            oValDepA := AjustarDecimalesSUM(oValDepA);
         end
         else begin
            oValAct  := AjustarDecimalesSUMSys(oValAct);
            oValDepA := AjustarDecimalesSUMSys(oValDepA);
         end;
         oValDe   := oValAct - oValDepA;

         if (oTasaFija) then begin
           if (not oPostSysCu) then begin
               oValActSys  := (FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDepASys := (FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValActSys  := AjustarDecimalesSUM(oValActSys);
               oValDepASys := AjustarDecimalesSUM(oValDepASys);
               oValDeSys   := oValActSys - oValDepASys;
            end
            else begin
               oValActSys  := (FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDepASys := (FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValActSys  := AjustarDecimalesSUMSys(oValActSys);
               oValDepASys := AjustarDecimalesSUMSys(oValDepASys);
               oValDeSys   := oValActSys - oValDepASys;
            end;
            
         end;

         oJEntries.ReferenceDate := Fecha;
         oJEntries.TaxDate       := Fecha;
         oJEntries.DueDate       := Fecha;
         oJEntries.Reference     := 'AF-Baja';
         oJEntries.Reference2    := oDBDS.GetValue('U_ActCode', 0).Trim;
         oJEntries.TransactionCode := '';
         oJEntries.ProjectCode     := oDBDS.GetValue('U_Project', 0).Trim;

         lin := 0;

            // U_Deprecia
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaDepAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDepA > 0) then
                  oJEntries.Lines.Debit := oValDepA
               else
                  oJEntries.Lines.Credit  := oValDepA * (-1);
               if (oTasaFija) then begin
                  if (oValDepASys > 0) then
                     oJEntries.Lines.DebitSys  := oValDepASys
                  else
                     oJEntries.Lines.CreditSys := oValDepASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDepA > 0) then
                  oJEntries.Lines.FCDebit   := oValDepA
               else
                  oJEntries.Lines.FCCredit  := oValDepA * (-1);

               if (oTasaFija) then begin
                  if (oValDepASys > 0) then
                     oJEntries.Lines.Debit   := oValDepASys
                  else
                     oJEntries.Lines.Credit  := oValDepASys * (-1);

                  if (oValDepA > 0) then
                     oJEntries.Lines.DebitSys   := oValDepA
                  else
                     oJEntries.Lines.CreditSys  := oValDepA * (-1);
               end;
            end;
            inc(lin);

            // U_Venta
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaAdqAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaAdqAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValAct > 0) then
                  oJEntries.Lines.Credit := oValAct
               else
                  oJEntries.Lines.Debit  := (oValAct) * (-1);
               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.CreditSys := oValActSys
                  else
                     oJEntries.Lines.DebitSys  := oValActSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValAct > 0) then
                  oJEntries.Lines.FCCredit   := oValAct
               else
                  oJEntries.Lines.FCDebit  := oValAct * (-1);

               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.Credit   := oValActSys
                  else
                     oJEntries.Lines.Debit  := oValActSys * (-1);

                  if (oValAct > 0) then
                     oJEntries.Lines.CreditSys   := oValAct
                  else
                     oJEntries.Lines.DebitSys  := oValAct * (-1);
               end;
            end;
            inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasBj', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaGasBj', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDe > 0) then
                  oJEntries.Lines.Debit  := oValDe
               else
                  oJEntries.Lines.Credit := oValDe * (-1);
               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.DebitSys  := oValDeSys
                  else
                     oJEntries.Lines.CreditSys := oValDeSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDe > 0) then
                  oJEntries.Lines.FCDebit   := oValDe
               else
                  oJEntries.Lines.FCCredit  := oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.Debit   := oValDeSys
                  else
                     oJEntries.Lines.Credit  := oValDeSys * (-1);

                  if (oValDe > 0) then
                     oJEntries.Lines.DebitSys   := oValDe
                  else
                     oJEntries.Lines.CreditSys  := oValDe * (-1);
               end;
            end;

         errCode := oJEntries.Add;
         if (errCode <> 0) then begin
            FCmpny.GetLastError(out errCode, out errMsg);
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Error_anular_baja] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
         end;
   finally
      FSBOf._ReleaseCOMObject(oJEntries);
   end;
end;

method TDarDeBaja.DarDeBajaNoRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
  var oPerIngreso: integer; 
  var oYrIngreso: integer;
  var oDBDS             : SAPbouiCOM.DBDataSource;
  var oActivos          : SAPbobsCOM.GeneralService;
  var oActivosData      : SAPbobsCOM.GeneralData;
  var oActivosParameter : SAPbobsCOM.GeneralDataParams;
  var oValCA            : double;
  var oValCD            : double;
  var oValDe            : double;
  var oValAct           : double;
  var oFactor           : double;
  var oValActF          : double;
  var oValDepA          : double;
  var oValCASys         : double;
  var oValCDSys         : double;
  var oValDeSys         : double;
  var oValActsys        : double;
  var oValActFSys       : double;
  var oValDepASys       : double;
  var Fecha             : DateTime;
  var lin               : Integer;
  var oCtoCost1         : String;
  var oCtoCost2         : String;
  var oCtoCost3         : String;
  var oCtoCost4         : String;
  var oCtoCost5         : String;
  var soloTrib          : boolean;
  var oCorAnuAc         : double;
  var oContabGastDepre  : boolean;
  var oAux_oValDe       : double);
var
   oSql              : string;
   oJEntries         : SAPbobsCOM.JournalEntries;
   orst       : SAPbobsCOM.Recordset;
   orst1       : SAPbobsCOM.Recordset;
   s          : string;
begin
      oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
      orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      orst1 := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      try

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                     "  from [@vid_afac] d inner join [@vid_afas] h on d.code = h.code " +
                     " where h.u_actcode = '{0}'           " +
                     "   and d.U_Year = {1}                " +
                     "   and d.U_Periodo = {2}             ", 
                     'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                     '  from "@VID_AFAC" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                     ' where h."U_ActCode" = ''{0}''         ' +
                     '   and d."U_Year" = {1}                ' +
                     '   and d."U_Periodo" = {2}             ');

         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then
            raise new Exception('Información incompleta para el activo a dar de baja ');

         oFactor := 1.0 - Double(Fecha.Day)/Fecha.DaysInMonth(Fecha.Year, Fecha.Month);;

         oValCA  := System.Double(oRecordSet.Fields.Item('U_CorrActi').Value) * oFactor;
         oValCD  := System.Double(oRecordSet.Fields.Item('U_CorrDepr').Value) * oFactor;
         if (not oPostSysCu) then begin
            oValCA  := AjustarDecimalesSUM(oValCA);
            oValCD  := AjustarDecimalesSUM(oValCD);
         end
         else begin
            oValCA  := AjustarDecimalesSUMSys(oValCA);
            oValCD  := AjustarDecimalesSUMsys(oValCD);
         end;
         if (CorrPos) then begin
            if (oValCA < 0) then
               oValCA := 0; 
            if (oValCD < 0) then
               oValCD := 0; 
         end;

         oCorAnuac := 0;
         if (not GlobalSettings.IFRSNativo) then 
            oCorAnuAc := FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuAc', 0));

         oValDe  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor;
         if (not oPostSysCu) then begin
             oValDe  := AjustarDecimalesSUM(oValDe);
             oValAct := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0))) + AjustarDecimalesSUM(oCorAnuac) +
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) -
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0))) - AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) -
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0))) - oValCA + oValCD + oValDe;
             oValActF := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal' , 0))) + AjustarDecimalesSUM(oCorAnuac) +
                         AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) - oValCA;
             oValDepA := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum', 0))) + AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) +
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0))) - oValCD - oValDe;
          end
          else
          begin
              oValDe  := AjustarDecimalesSUMSys(oValDe);
             oValAct := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0))) + AjustarDecimalesSUMSys(oCorAnuac) +
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) -
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0))) - AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) -
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0))) - oValCA + oValCD + oValDe;
             oValActF := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal' , 0))) + AjustarDecimalesSUMSys(oCorAnuac) +
                         AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) - oValCA;
             oValDepA := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum', 0))) + AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) +
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0))) - oValCD - oValDe;
          end;

         if (oTasaFija) then begin
            if (not oPostSysCu) then begin
               oValCASys  := System.Double(oRecordSet.Fields.Item('U_CorrActi').Value) * oFactor / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCDSys  := System.Double(oRecordSet.Fields.Item('U_CorrDepr').Value) * oFactor / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCASys  := AjustarDecimalesSUM(oValCASys);
               oValCDSys  := AjustarDecimalesSUM(oValCDSys);
            end
            else begin
               oValCASys  := System.Double(oRecordSet.Fields.Item('U_CorrActi').Value) * oFactor * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCDSys  := System.Double(oRecordSet.Fields.Item('U_CorrDepr').Value) * oFactor * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCASys  := AjustarDecimalesSUMSys(oValCASys);
               oValCDSys  := AjustarDecimalesSUMSys(oValCDSys);
            end;
            
            if (CorrPos) then begin
               if (oValCASys < 0) then
                  oValCASys := 0; 
               if (oValCDSys < 0) then
                  oValCDSys := 0; 
            end;

            if (not oPostSysCu) then begin
               oValDeSys  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDeSys  := AjustarDecimalesSUM(oValDeSys);
               oValActSys := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                             AjustarDecimalesSUM(oCorAnuac / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - 
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys + oValCDSys + oValDeSys;
               oValActFSys := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUM(oCorAnuac / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys;
               oValDepASys := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCDSys - oValDeSys;
            end
            else begin
               oValDeSys  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDeSys  := AjustarDecimalesSUMSys(oValDeSys);
               oValActSys := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                             AjustarDecimalesSUMSys(oCorAnuac * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - 
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys + oValCDSys + oValDeSys;
               oValActFSys := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUMSys(oCorAnuac * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys;
               oValDepASys := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUMsys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCDSys - oValDeSys;
            end;
         end;

         oJEntries.ReferenceDate := Fecha;
         oJEntries.TaxDate       := Fecha;
         oJEntries.DueDate       := Fecha;
         oJEntries.Reference     := 'AF-Baja';
         oJEntries.Reference2    := oDBDS.GetValue('U_ActCode', 0).Trim;
         oJEntries.TransactionCode := '';
         oJEntries.ProjectCode     := oDBDS.GetValue('U_Project', 0).Trim;

         lin := 0;
         // U_CorrActi
         if (oValCA <> 0) then begin
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaActFi', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaActFi', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
              oJEntries.Lines.CostingCode  := oCtoCost1;
              oJEntries.Lines.CostingCode2 := oCtoCost2;
              oJEntries.Lines.CostingCode3 := oCtoCost3;
              oJEntries.Lines.CostingCode4 := oCtoCost4;
              oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCA > 0) then
                  oJEntries.Lines.Credit   := oValCA
               else
                  oJEntries.Lines.Debit  := oValCA * (-1);
               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.CreditSys := oValCASys
                  else
                     oJEntries.Lines.DebitSys  := oValCASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCA > 0) then
                  oJEntries.Lines.FCCredit   := oValCA
               else
                  oJEntries.Lines.FCDebit    := oValCA * (-1);

               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.Credit   := oValCASys
                  else
                     oJEntries.Lines.Debit  := oValCASys * (-1);

                  if (oValCA > 0) then
                     oJEntries.Lines.CreditSys   := oValCA
                  else
                     oJEntries.Lines.DebitSys  := oValCA * (-1);
               end;
            end;
            inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaCorAF', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaCorAF', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCA > 0) then
                  oJEntries.Lines.Debit := oValCA
               else
                  oJEntries.Lines.Credit  := oValCA * (-1);
               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.DebitSys  := oValCASys
                  else
                     oJEntries.Lines.CreditSys := oValCASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCA > 0) then
                  oJEntries.Lines.FCDebit   := oValCA
               else
                  oJEntries.Lines.FCCredit  := oValCA * (-1);

               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.Debit   := oValCASys
                  else
                     oJEntries.Lines.Credit  := oValCASys * (-1);

                  if (oValCA > 0) then
                     oJEntries.Lines.DebitSys   := oValCA
                  else
                     oJEntries.Lines.CreditSys  := oValCA * (-1);
               end;
            end;
            inc(lin);
         end;

            // U_CorrDepr
         if (oValCD <> 0) and (not Repomo) then begin
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaDepAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCD > 0) then
                  oJEntries.Lines.Debit := oValCD
               else
                  oJEntries.Lines.Credit  := oValCD * (-1);
               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.DebitSys  := oValCDSys
                  else
                     oJEntries.Lines.CreditSys := oValCDSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCD > 0) then
                  oJEntries.Lines.FCDebit   := oValCD
               else
                  oJEntries.Lines.FCCredit  := oValCD * (-1);

               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.Debit   := oValCDSys
                  else
                     oJEntries.Lines.Credit  := oValCDSys * (-1);

                  if (oValCD > 0) then
                     oJEntries.Lines.DebitSys   := oValCD
                  else
                     oJEntries.Lines.CreditSys  := oValCD * (-1);
               end;
            end;
            inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaCorDA', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaCorDA', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCD > 0) then
                  oJEntries.Lines.Credit := oValCD
               else
                  oJEntries.Lines.Debit  := oValCD * (-1);
               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.CreditSys := oValCDSys
                  else
                     oJEntries.Lines.DebitSys  := oValCDSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCD > 0) then
                  oJEntries.Lines.FCCredit   := oValCD
               else
                  oJEntries.Lines.FCDebit   := oValCD * (-1);

               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.Credit   := oValCDSys
                  else
                     oJEntries.Lines.Debit  := oValCDSys * (-1);

                  if (oValCD > 0) then
                     oJEntries.Lines.CreditSys   := oValCD
                  else
                     oJEntries.Lines.DebitSys  := oValCD * (-1);
               end;
            end;
            inc(lin);
         end;

         //*************Revalorizacion
         
          oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               " Select Case when rd.U_NewVal > rd.U_ValAnt then 'Rea' else 'Det' end Tipo,
                        Case when rd.U_NewVal > rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end CtaIFRS,  
                        a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, 
                        SUM(Case when rd.U_NewVal > rd.U_ValAnt then rd.U_NewVal - rd.U_ValAnt else rd.U_ValAnt - rd.U_NewVal end) Monto
                   from [@VID_AFAS] a inner join [@VID_AFREVD] rd on a.U_ActCode = rd.U_ActCode
                                      inner join [@VID_AFREV]  rh on rh.DocEntry = rd.DocEntry
                                      inner join [@VID_AFAC]   ac on ac.Code = a.Code and ac.U_Year = rh.U_Year and ac.U_Periodo = rh.U_Periodo
                  where rh.U_Year <= {0} and rh.U_Periodo <= {1}  AND a.U_ActCode = '{2}'
                  group by  Case when rd.U_NewVal> rd.U_ValAnt then 'Rea' else 'Det' end,
                            Case when rd.U_NewVal> rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end,  
                            a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5 ",
               ' Select Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end "Tipo",                  ' +
               '        Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end "CtaIFRS", ' +
               '        a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",              ' +
               '        SUM(Case when rd."U_NewVal" > rd."U_ValAnt" then rd."U_NewVal" - rd."U_ValAnt" else rd."U_ValAnt" - rd."U_NewVal" end) "Monto" ' +
               '   from "@VID_AFAS" a inner join "@VID_AFREVD" rd on a."U_ActCode" = rd."U_ActCode"              ' + 
               '                      inner join "@VID_AFREV"  rh on rh."DocEntry" = rd."DocEntry"               ' +
               '                      inner join "@VID_AFAC"   ac on ac."Code" = a."Code" and ac."U_Year" = rh."U_Year" and ac."U_Periodo" = rh."U_Periodo" ' +
               '  where rh."U_Year" <= {0} and rh."U_Periodo" <= {1}  AND a."U_ActCode" = ''{2}''                                             ' +
               '  group by  Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end,               ' +   
               '            Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end, ' +
               '            a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5" ');
         oSql := String.Format(oSql, oYr.ToString(), oPer.ToString(), oDBDS.GetValue('U_ActCode', 0).Trim());
         orst1.DoQuery(oSql); 
         if (orst1.RecordCount > 0) and (not Repomo) then begin
            while (not orst1.EoF) do begin
                var oValor := system.Double( orst1.Fields.Item('Monto' ).Value );
                if (not oPostSysCu) then
                   oValor    := Utils.AjustarDecimalesSUM(oValor)
                else
                   oValor    := Utils.AjustarDecimalesSUMSys(oValor);
                if (lin > 0) then
                   oJEntries.lines.Add;
                oJEntries.Lines.SetCurrentLine(lin);
                oJEntries.Lines.AccountCode := system.String( orst1.Fields.Item('U_CtaActFi' ).Value );
                oJEntries.Lines.ProjectCode := system.String( orst1.Fields.Item('U_Project' ).Value );
                s := iif(GlobalSettings.RunningUnderSQLServer, 
                   "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
                   'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
                s := String.Format(s, system.String( orst1.Fields.Item('U_CtaActFi' ).Value )); 
                orst.DoQuery(s);
                s := System.String(orst.Fields.Item('ActType').value).Trim();
   
                if (s = 'I') or (s = 'E') then
                begin
                    oJEntries.Lines.CostingCode  := system.String( orst1.Fields.Item('U_ProfitCt' ).Value);
                    oJEntries.Lines.CostingCode2 := system.String( orst1.Fields.Item('U_ProfitC2' ).Value);
                    oJEntries.Lines.CostingCode3 := system.String( orst1.Fields.Item('U_ProfitC3' ).Value);
                    oJEntries.Lines.CostingCode4 := system.String( orst1.Fields.Item('U_ProfitC4' ).Value);
                    oJEntries.Lines.CostingCode5 := system.String( orst1.Fields.Item('U_ProfitC5' ).Value);
                end;

                if (not GlobalSettings.IFRSNativo) then begin
                   if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                      if (oValor < 0) then// se cambio de > a <
                         oJEntries.Lines.Debit   := oValor * (-1)
                      else
                         oJEntries.Lines.Credit  := oValor;// * (-1);
                   end
                   else begin
                      if (oValor < 0) then// se cambio de > a <
                         oJEntries.Lines.Credit   := oValor * (-1)
                      else
                         oJEntries.Lines.Debit  := oValor;// * (-1);
                   end;
                end
                else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
                  if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                      if (oValor < 0) then // se cambio de > a <
                         oJEntries.Lines.FCDebit   := oValor * (-1)
                      else
                         oJEntries.Lines.FCCredit  := oValor;// * (-1);
                   end
                   else begin
                      if (oValor < 0) then// se cambio de > a <
                         oJEntries.Lines.FCCredit   := oValor * (-1)
                      else
                         oJEntries.Lines.FCDebit  := oValor;// * (-1);
                   end;
                end;
                inc(lin);

                if (lin > 0) then
                   oJEntries.lines.Add;
                oJEntries.Lines.SetCurrentLine(lin);
                oJEntries.Lines.AccountCode := system.String( orst1.Fields.Item('CtaIFRS' ).Value );
                oJEntries.Lines.ProjectCode := system.String( orst1.Fields.Item('U_Project' ).Value );
                s := iif(GlobalSettings.RunningUnderSQLServer, 
                   "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
                   'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
                s := String.Format(s, system.String( orst1.Fields.Item('CtaIFRS' ).Value )); 
                orst.DoQuery(s);
                s := System.String(orst.Fields.Item('ActType').value).Trim();
   
                if (s = 'I') or (s = 'E') then
                begin
                    oJEntries.Lines.CostingCode  := system.String( orst1.Fields.Item('U_ProfitCt' ).Value);
                    oJEntries.Lines.CostingCode2 := system.String( orst1.Fields.Item('U_ProfitC2' ).Value);
                    oJEntries.Lines.CostingCode3 := system.String( orst1.Fields.Item('U_ProfitC3' ).Value);
                    oJEntries.Lines.CostingCode4 := system.String( orst1.Fields.Item('U_ProfitC4' ).Value);
                    oJEntries.Lines.CostingCode5 := system.String( orst1.Fields.Item('U_ProfitC5' ).Value);
                end;

                if (not GlobalSettings.IFRSNativo) then begin
                     if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                        if (oValor < 0) then// se cambio de > a <
                           oJEntries.Lines.Credit   := oValor* (-1)
                        else
                           oJEntries.Lines.Debit  := oValor;// * (-1);
                     end
                     else begin
                        if (oValor < 0) then// se cambio de > a <
                           oJEntries.Lines.Debit   := oValor* (-1)
                        else
                           oJEntries.Lines.Credit  := oValor;// * (-1);
                     end;
                 end
                 else begin
                     oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
                     if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                        if (oValor < 0) then// se cambio de > a <
                           oJEntries.Lines.FCCredit   := oValor* (-1)
                        else
                           oJEntries.Lines.FCDebit  := oValor;// * (-1);
                     end
                     else begin
                        if (oValor < 0) then// se cambio de > a <
                           oJEntries.Lines.FCDebit   := oValor* (-1)
                        else
                           oJEntries.Lines.FCCredit  := oValor;// * (-1);
                     end;
                 end;
                inc(lin);
                orst1.MoveNext(); 
            end;
         end;

         //*************Fin Revalorizacion

         // U_Deprecia
         if (lin > 0) then
            oJEntries.lines.Add;
         oJEntries.Lines.SetCurrentLine(lin);
         oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaDepAc', 0).Trim;
         oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, oDBDS.GetValue('U_CtaDepAc', 0).Trim); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJEntries.Lines.CostingCode  := oCtoCost1;
            oJEntries.Lines.CostingCode2 := oCtoCost2;
            oJEntries.Lines.CostingCode3 := oCtoCost3;
            oJEntries.Lines.CostingCode4 := oCtoCost4;
            oJEntries.Lines.CostingCode5 := oCtoCost5;
         end;

         if (RevBaja) then begin
            if (not oPostSysCu) then begin
               if (oValDepA > 0) then
                  oJEntries.Lines.Debit := oValDepA
               else
                  oJEntries.Lines.Credit  := oValDepA * (-1);
               if (oTasaFija) then begin
                  if (oValDepASys > 0) then
                     oJEntries.Lines.DebitSys  := oValDepASys
                  else
                     oJEntries.Lines.CreditSys := oValDepASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDepA > 0) then
                  oJEntries.Lines.FCDebit   := oValDepA
               else
                  oJEntries.Lines.FCCredit  := oValDepA * (-1);

               if (oTasaFija) then begin
                  if (oValDepASys > 0) then
                     oJEntries.Lines.Debit   := oValDepASys
                  else
                     oJEntries.Lines.Credit  := oValDepASys * (-1);

                  if (oValDepA > 0) then
                     oJEntries.Lines.DebitSys   := oValDepA
                  else
                     oJEntries.Lines.CreditSys  := oValDepA * (-1);
               end;
            end;
         end
         else begin
            if (not oPostSysCu) then begin
               if (oValDe > 0) then
                  oJEntries.Lines.Debit := oValDe
               else
                  oJEntries.Lines.Credit  := oValDe * (-1);
               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.DebitSys  := oValDeSys
                  else
                     oJEntries.Lines.CreditSys := oValDeSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDe > 0) then
                  oJEntries.Lines.FCDebit   := oValDe
               else
                  oJEntries.Lines.FCCredit  := oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.Debit   := oValDeSys
                  else
                     oJEntries.Lines.Credit  := oValDeSys * (-1);

                  if (oValDe > 0) then
                     oJEntries.Lines.DebitSys   := oValDe
                  else
                     oJEntries.Lines.CreditSys  := oValDe * (-1);
               end;
            end;
         end;
         inc(lin);

         if (oContabGastDepre) then begin
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasDe', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaGasDe', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDe > 0) then
                  oJEntries.Lines.Credit := oValDe
               else
                  oJEntries.Lines.Debit  := oValDe * (-1);
               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.CreditSys := oValDeSys
                  else
                     oJEntries.Lines.DebitSys  := oValDeSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDe > 0) then
                  oJEntries.Lines.FCCredit := oValDe
               else
                  oJEntries.Lines.FCDebit  := oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.Credit   := oValDeSys
                  else
                     oJEntries.Lines.Debit  := oValDeSys * (-1);

                  if (oValDe > 0) then
                     oJEntries.Lines.CreditSys   := oValDe
                  else
                     oJEntries.Lines.DebitSys  := oValDe * (-1);
               end;
            end;
            inc(lin);
         end;

         // U_Venta
         if (lin > 0) then
            oJEntries.lines.Add;
         oJEntries.Lines.SetCurrentLine(lin);
         oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaActFi', 0).Trim;
         oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, oDBDS.GetValue('U_CtaActFi', 0).Trim); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJEntries.Lines.CostingCode  := oCtoCost1;
            oJEntries.Lines.CostingCode2 := oCtoCost2;
            oJEntries.Lines.CostingCode3 := oCtoCost3;
            oJEntries.Lines.CostingCode4 := oCtoCost4;
            oJEntries.Lines.CostingCode5 := oCtoCost5;
         end;

         if (RevBaja) then begin
            if (oContabGastDepre) then 
               OAux_oValDe := 1.0;

            if (not oPostSysCu) then begin
               if (oValActF-oValDe*OAux_oValDe > 0) then
                  oJEntries.Lines.Credit := oValActF-oValDe*OAux_oValDe
               else
                  oJEntries.Lines.Debit  := (oValActF-oValDe*OAux_oValDe) * (-1);
    
               if (oTasaFija) then begin
                  if (oValActFSys-oValDeSys*OAux_oValDe > 0) then
                     oJEntries.Lines.CreditSys := oValActFSys-oValDeSys*OAux_oValDe
                  else
                     oJEntries.Lines.DebitSys  := (oValActFSys-oValDeSys*OAux_oValDe) * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValActF-oValDe*OAux_oValDe > 0) then
                  oJEntries.Lines.FCCredit := oValActF-oValDe*OAux_oValDe
               else
                  oJEntries.Lines.FCDebit  := oValActF-oValDe*OAux_oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValActFSys-oValDeSys*OAux_oValDe > 0) then
                     oJEntries.Lines.Credit   := oValActFSys-oValDeSys*OAux_oValDe
                  else
                     oJEntries.Lines.Debit  := oValActFSys-oValDeSys*OAux_oValDe * (-1);

                  if (oValActF-oValDe*OAux_oValDe > 0) then
                     oJEntries.Lines.CreditSys   := oValActF-oValDe*OAux_oValDe
                  else
                     oJEntries.Lines.DebitSys  := oValActF-oValDe*OAux_oValDe * (-1);
               end;
            end;
         end
         else begin
            if (not oPostSysCu) then begin
               if (oValAct > 0) then
                  oJEntries.Lines.Credit := oValAct
               else
                  oJEntries.Lines.Debit  := oValAct * (-1);
               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.CreditSys := oValActSys
                  else
                     oJEntries.Lines.DebitSys  := oValActSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValAct > 0) then
                  oJEntries.Lines.FCCredit := oValAct
               else
                  oJEntries.Lines.FCDebit  := oValAct * (-1);

               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.Credit   := oValActSys
                  else
                     oJEntries.Lines.Debit  := oValActSys * (-1);

                  if (oValAct > 0) then
                     oJEntries.Lines.CreditSys   := oValAct
                  else
                     oJEntries.Lines.DebitSys  := oValAct * (-1);
               end;
            end;
         end;
         inc(lin);

         if (RevBaja) and (not oContabGastDepre) then begin
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaDepAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDe > 0) then
                  oJEntries.Lines.Debit := oValDe
               else
                  oJEntries.Lines.Credit  := oValDe * (-1);
               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.DebitSys  := oValDeSys
                  else
                     oJEntries.Lines.CreditSys := oValDeSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDe > 0) then
                  oJEntries.Lines.FCDebit := oValDe
               else
                  oJEntries.Lines.FCCredit  := oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.Credit   := oValDeSys
                  else
                     oJEntries.Lines.Debit  := oValDeSys * (-1);

                  if (oValDe > 0) then
                     oJEntries.Lines.CreditSys   := oValDe
                  else
                     oJEntries.Lines.DebitSys  := oValDe * (-1);
               end;
            end;
               inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasDe', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaGasDe', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDe > 0) then
                  oJEntries.Lines.Credit := oValDe
               else
                  oJEntries.Lines.Debit  := oValDe * (-1);
               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.CreditSys  := oValDeSys
                  else
                     oJEntries.Lines.DebitSys := oValDeSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDe > 0) then
                  oJEntries.Lines.FCCredit := oValDe
               else
                  oJEntries.Lines.FCDebit  := oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.Credit   := oValDeSys
                  else
                     oJEntries.Lines.Debit  := oValDeSys * (-1);

                  if (oValDe > 0) then
                     oJEntries.Lines.CreditSys   := oValDe
                  else
                     oJEntries.Lines.DebitSys  := oValDe * (-1);
               end;
            end;
               inc(lin);
         end;

         if (lin > 0) then
            oJEntries.lines.Add;
         oJEntries.Lines.SetCurrentLine(lin);
         oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasBj', 0).Trim;
         oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
         s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
         s := String.Format(s, oDBDS.GetValue('u_CtaGasBj', 0).Trim); 
         orst.DoQuery(s);
         s := System.String(orst.Fields.Item('ActType').value).Trim();
   
         if (s = 'I') or (s = 'E') then
         begin
            oJEntries.Lines.CostingCode  := oCtoCost1;
            oJEntries.Lines.CostingCode2 := oCtoCost2;
            oJEntries.Lines.CostingCode3 := oCtoCost3;
            oJEntries.Lines.CostingCode4 := oCtoCost4;
            oJEntries.Lines.CostingCode5 := oCtoCost5;
         end;

            if (not oPostSysCu) then begin
               if (oValAct > 0) then
                  oJEntries.Lines.Debit := oValAct
               else
                  oJEntries.Lines.Credit  := oValAct * (-1);
               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.DebitSys  := oValActSys
                  else
                     oJEntries.Lines.CreditSys := oValActSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValAct > 0) then
                  oJEntries.Lines.FCDebit := oValAct
               else
                  oJEntries.Lines.FCCredit  := oValAct * (-1);

               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.Debit   := oValActSys
                  else
                     oJEntries.Lines.Credit  := oValActSys * (-1);

                  if (oValAct > 0) then
                     oJEntries.Lines.DebitSys   := oValAct
                  else
                     oJEntries.Lines.CreditSys  := oValAct * (-1);
               end;
            end;

         errCode := oJEntries.Add;
         if (errCode <> 0) then begin
            FCmpny.GetLastError(out errCode, out errMsg);
            var oFile   : String;
            oFile := System.IO.Path.GetDirectoryName(System.Windows.Forms.Application.ExecutablePath) + "\oJEntries.xml"; 
            oJEntries.SaveXML(var oFile);
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Error_anular_baja] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
         end;
   finally
      FSBOf._ReleaseCOMObject(oJEntries);
   end;
end;

method TDarDeBaja.DarDeBajaNoRepomoReversaAnual(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
  var oPerIngreso       : integer; 
  var oYrIngreso        : integer;
  var oDBDS             : SAPbouiCOM.DBDataSource;
  var oActivos          : SAPbobsCOM.GeneralService;
  var oActivosData      : SAPbobsCOM.GeneralData;
  var oActivosParameter : SAPbobsCOM.GeneralDataParams;
  var oValDe            : double;
  var oValAct           : double;
  var oValActF          : double;
  var oValDepA          : double;
  var oValDeSys         : double;
  var oValActsys        : double;
  var oValActFSys       : double;
  var oValDepASys       : double;
  var Fecha             : DateTime;
  var lin               : Integer;
  var oCtoCost1         : String;
  var oCtoCost2         : String;
  var oCtoCost3         : String;
  var oCtoCost4         : String;
  var oCtoCost5         : String;
  var soloTrib          : boolean;
  var oCorAnuAc         : double);
var
   oSql              : string;
   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;
   oJEntries         : SAPbobsCOM.JournalEntries;
   i, j, Id          : integer;
   AfacOrder         : List<integer> := new List<integer>;
   AfacList          : List<TAFAVRecord> := new List<TAFAVRecord>;
   AfacItem          : TAFAVRecord;
   oU_CurVal         : double;
   oU_CorAnuAc       : double;
   oU_DepAcum        : double;
   oU_DepreAnu       : double;
   oU_DepAcumN       : double;
   oU_CorAnuDe       : double;
   oU_Adicion        : double;
   oU_Bis33          : double;
   oAuxSys           : double;
begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.* " +
                     "  from [@vid_afac] d inner join [@vid_afas] h on d.code = h.code " +
                     " where h.u_actcode = '{0}'           " +
                     "   and d.U_Year = {1}                ", 
                     'Select d.* ' +
                     '  from "@VID_AFAC" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                     ' where h."U_ActCode" = ''{0}''         ' +
                     '   and d."U_Year" = {1}                ');

         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString);
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then
            raise new Exception('Información incompleta para el activo a dar de baja ');


         oActivosLines     := oActivosData.Child('VID_AFAC');

         for i:=0 to oActivosLines.Count - 1 do begin
             oActivosLinesData := oActivosLines.Item(i);
             if (int32(oActivosLinesData.GetProperty('U_Year')) <> oYr) then
                 continue
             else begin
                 AfacItem := new TAFAVRecord;
                 AfacItem.Id := i;
                 AfacItem.LineId     := int32(oActivosLinesData.GetProperty('LineId'     ));
                 AfacItem.U_Year     := int32(oActivosLinesData.GetProperty('U_Year'     ));
                 AfacItem.U_Periodo  := int32(oActivosLinesData.GetProperty('U_Periodo'  ));
                 AfacItem.U_CorrActi := double(oActivosLinesData.GetProperty('U_CorrActi'));
                 AfacItem.U_CorrDepr := double(oActivosLinesData.GetProperty('U_CorrDepr'));
                 AfacItem.U_Deprecia := double(oActivosLinesData.GetProperty('U_Deprecia'));
                 AfacItem.U_CorrDepM := double(oActivosLinesData.GetProperty('U_CorrDepM'));
                 AfacItem.U_DeprNom  := double(oActivosLinesData.GetProperty('U_DeprNom' ));
                 AfacItem.U_Adicion  := double(oActivosLinesData.GetProperty('U_Adicion' ));
                 AfacItem.U_PerVidUt := int32(oActivosLinesData.GetProperty('U_PerVidUt'));
                 AfacItem.U_PerDepre := int32(oActivosLinesData.GetProperty('U_PerDepre'));
                 AfacItem.U_PostFlag := string(oActivosLinesData.GetProperty('U_PostFlag'));
                 AfacList.Add(AfacItem);

                 AfacOrder.Add(AfacItem.U_Periodo);
             end;
         end;

         // Remove
         for j := AfacList.Count-1 downto 0 do 
             oActivosLines.Remove(AfacList[j].Id);

         // Order
         AfacOrder.Sort();

         for i:=0 to AfacOrder.Count-1 do begin
             Id := -1;
             for j:=0 to AfacList.Count-1 do begin
                 if (AfacList[j].U_Periodo = AfacOrder[i]) then begin
                     Id := j;
                     if (Id = -1) then
                        Id := AfacList[j].U_Periodo;
                     break;
                 end;
             end;

             if (Id = -1) then begin
                 raise("ERROR");
                 break; 
             end;

             oActivosLinesData := oActivosLines.Add();
             oActivosLinesData.SetProperty('U_Year'    , AfacList[Id].U_Year    );
             oActivosLinesData.SetProperty('U_Periodo' , AfacList[Id].U_Periodo );
             oActivosLinesData.SetProperty('U_CorrActi', AfacList[Id].U_CorrActi);
             oActivosLinesData.SetProperty('U_CorrDepr', AfacList[Id].U_CorrDepr);
             oActivosLinesData.SetProperty('U_Deprecia', AfacList[Id].U_Deprecia);
             oActivosLinesData.SetProperty('U_CorrDepM', AfacList[Id].U_CorrDepM);
             oActivosLinesData.SetProperty('U_DeprNom' , AfacList[Id].U_DeprNom );
             oActivosLinesData.SetProperty('U_Adicion' , AfacList[Id].U_Adicion );
             oActivosLinesData.SetProperty('U_PerVidUt', AfacList[Id].U_PerVidUt);
             oActivosLinesData.SetProperty('U_PerDepre', AfacList[Id].U_PerDepre);
             oActivosLinesData.SetProperty('U_PostFlag', AfacList[Id].U_PostFlag);

             oActivosLinesData := oActivosLines.Add();
             oActivosLinesData.SetProperty('U_Year'    , AfacList[Id].U_Year    );
             oActivosLinesData.SetProperty('U_Periodo' , AfacList[Id].U_Periodo );
             oActivosLinesData.SetProperty('U_CorrActi', -1.0 * AfacList[Id].U_CorrActi);
             oActivosLinesData.SetProperty('U_CorrDepr', -1.0 * AfacList[Id].U_CorrDepr);
             oActivosLinesData.SetProperty('U_Deprecia', -1.0 * AfacList[Id].U_Deprecia);
             oActivosLinesData.SetProperty('U_CorrDepM', -1.0 * AfacList[Id].U_CorrDepM);
             oActivosLinesData.SetProperty('U_DeprNom' , -1.0 * AfacList[Id].U_DeprNom );
             oActivosLinesData.SetProperty('U_Adicion' , -1.0 * AfacList[Id].U_Adicion );
             oActivosLinesData.SetProperty('U_PerVidUt', -1 * AfacList[Id].U_PerVidUt);
             oActivosLinesData.SetProperty('U_PerDepre', -1 * AfacList[Id].U_PerDepre);
             oActivosLinesData.SetProperty('U_PostFlag', AfacList[Id].U_PostFlag);
         end;

         // -- Valor ainicio del año tabla saldos anuales
         
         //oSql := iif(GlobalSettings.RunningUnderSQLServer, 
         //            "Select d.* " +
         //            "  from [@VID_AFSA] d inner join [@vid_afas] h on d.code = h.code " +
         //            " where h.u_actcode = '{0}'           " +
         //            "   and d.U_Year = {1}                ", 
         //            'Select d.* ' +
         //            '  from "@VID_AFSA" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
         //            ' where h."U_ActCode" = ''{0}''         ' +
         //            '   and d."U_Year" = {1}                ');
         
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select a.*                 " +
                     "  from [@VID_AFAS] a       " +
                     " where u_actcode = '{0}'   ", 
                     'Select A.*                      ' +
                     '  from "@VID_AFAS" A            ' +
                     ' where "U_ActCode" = ''{0}''    ');
         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim);
         oRecordSet.DoQuery(oSql);
         oU_CurVal   := System.Double(oRecordSet.Fields.Item('U_CurVal'  ).Value);
         oU_CorAnuAc := System.Double(oRecordSet.Fields.Item('U_CorAnuAc').Value);
         oU_DepAcum  := System.Double(oRecordSet.Fields.Item('U_DepAcum' ).Value);
         oU_DepreAnu := System.Double(oRecordSet.Fields.Item('U_DepreAnu').Value);
         oU_DepAcumN := System.Double(oRecordSet.Fields.Item('U_DepAcumN').Value);
         oU_CorAnuDe := System.Double(oRecordSet.Fields.Item('U_CorAnuDe').Value);
         oU_Adicion  := 0.0;
         oU_Bis33    := System.Double(oRecordSet.Fields.Item('U_Bis33'   ).Value);
         
         ////
         

         if (GlobalSettings.IFRSNativo) then begin
               // depreciacion anual
               oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
           
               Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, Fecha.Year, Fecha.Month, Fecha.Day, 'AF-', 'AF-Baja',
                                                   oDBDS.GetValue('U_Project', 0).Trim,
                                                   '',
                                                   'Reversa anual' );
           
               if (not oPostSysCu) then 
                  oAuxSys := oU_DepreAnu / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_DepreAnu * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_DepreAnu, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaDepAc', 0).Trim,
                                              oDBDS.GetValue('U_CtaGasDe', 0).Trim );
           
               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
         end;
   
         if (not GlobalSettings.IFRSNativo) then begin
               // depreciacion anual
               oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
           
               Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, Fecha.Year, Fecha.Month, Fecha.Day, 'AF-', 'AF-Baja',
                                                   oDBDS.GetValue('U_Project', 0).Trim,
                                                   '',
                                                   'Reversa Anual' );
           
               if (not oPostSysCu) then 
                  oAuxSys := oU_CorAnuAc / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_CorAnuAc * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_CorAnuAc, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaCorAc', 0).Trim,
                                              oDBDS.GetValue('U_CtaActFi', 0).Trim );
           
               if (not oPostSysCu) then 
                  oAuxSys := oU_CorAnuDe / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_CorAnuDe * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_CorAnuDe, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaDepAc', 0).Trim,
                                              oDBDS.GetValue('U_CtaCorDa', 0).Trim );

               if (not oPostSysCu) then 
                  oAuxSys := oU_DepreAnu / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_DepreAnu * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_DepreAnu, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaDepAc', 0).Trim,
                                              oDBDS.GetValue('U_CtaGasDe', 0).Trim );

               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);   
        end;

        // Ingreso de asiento de baja

        oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
        
        Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, Fecha.Year, Fecha.Month, Fecha.Day, 'AF-', 'AF-Baja',
                                            oDBDS.GetValue('U_Project', 0).Trim,
                                            '',
                                            'Reversa anual' );
        
        if (not oPostSysCu) then 
           oAuxSys := (oU_CurVal - oU_DepAcum) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
        else
           oAuxSys := (oU_CurVal - oU_DepAcum) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
        Utils.ContabilizarEnSBOInsertarValor(var oJEntries, (oU_CurVal - oU_DepAcum), oAuxSys, 
                                       oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                       oDBDS.GetValue('U_CtaActFi', 0).Trim,
                                       oDBDS.GetValue('U_CtaGasBj', 0).Trim );
        
        Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
end;

method TDarDeBaja.DarDeBajaReferencial(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
  var oPerIngreso       : integer; 
  var oYrIngreso        : integer;
  var oDBDS             : SAPbouiCOM.DBDataSource;
  var oActivos          : SAPbobsCOM.GeneralService;
  var oActivosData      : SAPbobsCOM.GeneralData;
  var oActivosParameter : SAPbobsCOM.GeneralDataParams;
  var oValDe            : double;
  var oValAct           : double;
  var oValActF          : double;
  var oValDepA          : double;
  var oValDeSys         : double;
  var oValActsys        : double;
  var oValActFSys       : double;
  var oValDepASys       : double;
  var Fecha             : DateTime;
  var lin               : Integer;
  var oCtoCost1         : String;
  var oCtoCost2         : String;
  var oCtoCost3         : String;
  var oCtoCost4         : String;
  var oCtoCost5         : String;
  var soloTrib          : boolean;
  var oCorAnuAc         : double);
var
   oSql              : string;
   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;
   i, j, Id          : integer;
   AfacOrder         : List<integer> := new List<integer>;
   AfacList          : List<TAFAVRecord> := new List<TAFAVRecord>;
   AfacItem          : TAFAVRecord;
   oU_CurVal         : double;
   oU_DepAcum        : double;
   oU_VidaUtiR       : int32;
   oU_PRrDepre       : int32;
   oPerDepre         : int32  := 0;
   vCorAnuAc         : double := 0.0;
   oCorAnuDe         : double := 0.0;
   oDepreAnu         : double := 0.0;
   oAdicion          : double := 0.0;
   U_Year     : int32;
   U_CurVal   : double;
   U_CorAnuAc : double;
   U_DepAcum  : double;
   U_DepAnual : double;
   U_DepAcumN : double;
   U_CorAnuDe : double;
   U_Adicion  : double;
   U_Bis33    : double;
begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.* " +
                     "  from [@vid_afacR] d inner join [@vid_afas] h on d.code = h.code " +
                     " where h.u_actcode = '{0}'           " +
                     "   and d.U_Year = {1}                ", 
                     'Select d.* ' +
                     '  from "@VID_AFACR" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                     ' where h."U_ActCode" = ''{0}''         ' +
                     '   and d."U_Year" = {1}                ');

         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString);
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then
            raise new Exception('Información incompleta para el activo a dar de baja ');


         oActivosLines     := oActivosData.Child('VID_AFACR');

         for i:=0 to oActivosLines.Count - 1 do begin
             oActivosLinesData := oActivosLines.Item(i);
             if (int32(oActivosLinesData.GetProperty('U_Year')) <> oYr) then
                 continue
             else begin
                 AfacItem := new TAFAVRecord;
                 AfacItem.Id := i;
                 AfacItem.LineId     := int32(oActivosLinesData.GetProperty('LineId'     ));
                 AfacItem.U_Year     := int32(oActivosLinesData.GetProperty('U_Year'     ));
                 AfacItem.U_Periodo  := int32(oActivosLinesData.GetProperty('U_Periodo'  ));
                 AfacItem.U_CorrActi := double(oActivosLinesData.GetProperty('U_CorrActi'));
                 AfacItem.U_CorrDepr := double(oActivosLinesData.GetProperty('U_CorrDepr'));
                 AfacItem.U_Deprecia := double(oActivosLinesData.GetProperty('U_Deprecia'));
                 AfacItem.U_CorrDepM := double(oActivosLinesData.GetProperty('U_CorrDepM'));
                 AfacItem.U_DeprNom  := double(oActivosLinesData.GetProperty('U_DeprNom' ));
                 AfacItem.U_Adicion  := double(oActivosLinesData.GetProperty('U_Adicion' ));
                 AfacItem.U_PerVidUt := int32(oActivosLinesData.GetProperty('U_PerVidUt'));
                 AfacItem.U_PerDepre := int32(oActivosLinesData.GetProperty('U_PerDepre'));
                 AfacItem.U_PostFlag := string(oActivosLinesData.GetProperty('U_PostFlag'));
                 AfacList.Add(AfacItem);

                 AfacOrder.Add(AfacItem.U_Periodo);
             end;
         end;

         // Remove
         for j := AfacList.Count-1 downto 0 do 
             oActivosLines.Remove(AfacList[j].Id);

         // Order
         AfacOrder.Sort();

         for i:=0 to AfacOrder.Count-1 do begin
             Id := -1;
             for j:=0 to AfacList.Count-1 do begin
                 if (AfacList[j].U_Periodo = AfacOrder[i]) then begin
                     Id := j;
                     if (Id = -1) then
                        Id := AfacList[j].U_Periodo;
                     break;
                 end;
             end;

             if (Id = -1) then begin
                 raise("ERROR");
                 break; 
             end;

             oActivosLinesData := oActivosLines.Add();
             oActivosLinesData.SetProperty('U_Year'    , AfacList[Id].U_Year    );
             oActivosLinesData.SetProperty('U_Periodo' , AfacList[Id].U_Periodo );
             oActivosLinesData.SetProperty('U_CorrActi', AfacList[Id].U_CorrActi);
             oActivosLinesData.SetProperty('U_CorrDepr', AfacList[Id].U_CorrDepr);
             oActivosLinesData.SetProperty('U_Deprecia', AfacList[Id].U_Deprecia);
             oActivosLinesData.SetProperty('U_CorrDepM', AfacList[Id].U_CorrDepM);
             oActivosLinesData.SetProperty('U_DeprNom' , AfacList[Id].U_DeprNom );
             oActivosLinesData.SetProperty('U_Adicion' , AfacList[Id].U_Adicion );
             oActivosLinesData.SetProperty('U_PerVidUt', AfacList[Id].U_PerVidUt);
             oActivosLinesData.SetProperty('U_PerDepre', AfacList[Id].U_PerDepre);
             oActivosLinesData.SetProperty('U_PostFlag', AfacList[Id].U_PostFlag);
             oActivosLinesData.SetProperty('U_RevBajaIni', "N");//PRUEBA******

             oActivosLinesData := oActivosLines.Add();
             oActivosLinesData.SetProperty('U_Year'    , AfacList[Id].U_Year    );
             oActivosLinesData.SetProperty('U_Periodo' , AfacList[Id].U_Periodo );
             oActivosLinesData.SetProperty('U_CorrActi', -1.0 * AfacList[Id].U_CorrActi);
             oActivosLinesData.SetProperty('U_CorrDepr', -1.0 * AfacList[Id].U_CorrDepr);
             oActivosLinesData.SetProperty('U_Deprecia', -1.0 * AfacList[Id].U_Deprecia);
             oActivosLinesData.SetProperty('U_CorrDepM', -1.0 * AfacList[Id].U_CorrDepM);
             oActivosLinesData.SetProperty('U_DeprNom' , -1.0 * AfacList[Id].U_DeprNom );
             oActivosLinesData.SetProperty('U_Adicion' , -1.0 * AfacList[Id].U_Adicion );
             oActivosLinesData.SetProperty('U_PerVidUt', -1 * AfacList[Id].U_PerVidUt);
             oActivosLinesData.SetProperty('U_PerDepre', -1 * AfacList[Id].U_PerDepre);
             oActivosLinesData.SetProperty('U_PostFlag', AfacList[Id].U_PostFlag);
             oActivosLinesData.SetProperty('U_RevBajaIni', "Y");//PRUEBA******

             oPerDepre := oPerDepre + AfacList[Id].U_PerDepre;
             vCorAnuAc := vCorAnuAc + AfacList[Id].U_CorrActi;
             oCorAnuDe := oCorAnuDe + AfacList[Id].U_CorrDepr;
             oDepreAnu := oDepreAnu + AfacList[Id].U_Deprecia + AfacList[Id].U_CorrDepM;
             oAdicion  := oAdicion  + AfacList[Id].U_Adicion;
         end;
         
         oActivosLines     := oActivosData.Child('VID_AFSAR');
         
         j := -1;
         for i:=0 to oActivosLines.Count - 1 do begin
             oActivosLinesData := oActivosLines.Item(i);
             if (int32(oActivosLinesData.GetProperty('U_Year')) = oYr) then begin
                j := i;
                break;
             end;
         end;

         if (j > -1) then begin
            U_Year     := int32(oActivosLinesData.GetProperty('U_Year'    ));
            U_CurVal   := double(oActivosLinesData.GetProperty('U_CurVal'  ));
            U_CorAnuAc := double(oActivosLinesData.GetProperty('U_CorAnuAc'));
            U_DepAcum  := double(oActivosLinesData.GetProperty('U_DepAcum' ));
            U_DepAnual := double(oActivosLinesData.GetProperty('U_DepAnual'));
            U_DepAcumN := double(oActivosLinesData.GetProperty('U_DepAcumN'));
            U_CorAnuDe := double(oActivosLinesData.GetProperty('U_CorAnuDe'));
            U_Adicion  := double(oActivosLinesData.GetProperty('U_Adicion' ));
            U_Bis33    := double(oActivosLinesData.GetProperty('U_Bis33'   ));

            oActivosLinesData := oActivosLines.Add();
            oActivosLinesData.SetProperty('U_Year'     ,  U_Year    );
            oActivosLinesData.SetProperty('U_CurVal'   , -1.0 * U_CurVal  );
            oActivosLinesData.SetProperty('U_CorAnuAc' , -1.0 * U_CorAnuAc);
            oActivosLinesData.SetProperty('U_DepAcum'  , -1.0 * U_DepAcum );
            oActivosLinesData.SetProperty('U_DepAnual' , -1.0 * U_DepAnual);
            oActivosLinesData.SetProperty('U_DepAcumN' , -1.0 * U_DepAcumN);
            oActivosLinesData.SetProperty('U_CorAnuDe' , -1.0 * U_CorAnuDe);
            oActivosLinesData.SetProperty('U_Adicion'  , -1.0 * U_Adicion );
            oActivosLinesData.SetProperty('U_Bis33'    , -1.0 * U_Bis33   );
            oActivosLinesData.SetProperty('U_RevBajaIni', "Y");//PRUEBA******
         end;


         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select a.* , isnull(cc.DimCode, 1) DimCode                   " +
                     "  from [@VID_AFAS] a                                         " +
                     "       left outer join OPRC cc on a.U_ProfitCt = cc.PrcCode  " +
                     " where u_actcode = '{0}'   ", 
                     'Select A.*, ifnull(CC."DimCode", 1) "DimCode"                   ' +
                     '  from "@VID_AFAS" A                                            ' +
                     '       left outer join OPRC CC on A."U_ProfitCt" = CC."PrcCode" ' +
                     ' where "U_ActCode" = ''{0}''                                    ');
         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim);
         oRecordSet.DoQuery(oSql);
         oU_CurVal   := System.Double(oRecordSet.Fields.Item('U_CurVal'  ).Value);
         oU_DepAcum  := System.Double(oRecordSet.Fields.Item('U_DepAcum' ).Value);
         oU_VidaUtiR := System.int32(oRecordSet.Fields.Item('U_VidaUtiR').Value);
         oU_PRrDepre := System.int32(oRecordSet.Fields.Item('U_PRrDepre').Value);

         oActivosData.SetProperty('U_VidaUtiR', oU_VidaUtiR + oPerDepre);
         oActivosData.SetProperty('U_PRrDepre', oU_PRrDepre - oPerDepre);
         oActivosData.SetProperty('U_CorAnuAR', 0.0);
         oActivosData.SetProperty('U_CorAnuDR', 0.0);
         oActivosData.SetProperty('U_DepreAnR', 0.0);
         oActivosData.SetProperty('U_Bis33'   , 0.0);
end;

method TDarDeBaja.AnularDarDeBaja(oForm: SAPbouiCOM.Form; oYr, oPer: integer): Boolean;
var
   oDBDS             : SAPbouiCOM.DBDataSource;
   oActivos          : SAPbobsCOM.GeneralService;
   oActivosData      : SAPbobsCOM.GeneralData;
   oActivosParameter : SAPbobsCOM.GeneralDataParams;
   s                 : string;
   Fecha             : DateTime;
   sql               : string;
   oValCA            : double;
   oValCD            : double;
   oValDe            : double;
   oValAct           : double;
   oFactor           : double;
   oValActF          : double;
   oValDepA          : double;
   oValCASys         : double;
   oValCDSys         : double;
   oValDeSys         : double;
   oValActsys        : double;
   oValActFSys       : double;
   oValDepASys       : double;
   oCorAnuAc         : double;

   lin               : Integer;
   oPerIngreso       : Integer;
   oYrIngreso        : Integer;
   oCtoCost1         : String;
   oCtoCost2         : String;
   oCtoCost3         : String;
   oCtoCost4         : String;
   oCtoCost5         : String;
   soloTrib          : boolean := false;
   oSql              : string;

   // No conatbilizar Gastos depreciacion, genera saldo de activos > 0
   oContabGastDepre  : boolean := false;
   oAux_oValDe: double := 0.0;
begin
      result := false;

      oDBDS     := oForm.DataSources.DBDataSources.Item('@VID_AFAS');

      try

         if (oDBDS.GetValue('U_ActTipo', 0).Trim = 'T') then begin
            soloTrib := true;

            oValDe  := 0.0;

            oActivos := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));

            oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select Code from [@VID_AFAS] where U_ActCode = '{0}'", 
                        'Select "Code" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
            oSql := string.Format(oSql, EditText(oForm.Items.Item('ActCode').Specific).Value);
            oRecordSet.DoQuery(oSql);
            s := System.string(oRecordSet.Fields.Item('Code').Value);
            oActivosParameter.SetProperty('Code', s);

            oActivosData := oActivos.GetByParams(oActivosParameter);

             if (RevBajaAnual) then
                 AnularDarDeBajaReferencial(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                                             , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                                             , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                                             , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                                             , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                                             , var oCorAnuAc, var oContabGastDepre, var oAux_oValDe);

            s := 'N';
            oActivosData.SetProperty('U_DeBaja' , s);
            oActivosData.SetProperty('U_ValBaja', oValDe);
            oActivosData.SetProperty('U_BajaFec', FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value));

            oActivos.Update(oActivosData);

            result := true;

            FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Baja_activo] + 
                                      EditText(oForm.Items.Item('ActCode').Specific).Value + 
                                      GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Dado_baja], 
                                      BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
         end;
      except
         on e: exception do begin
            FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            OutLog("Dar de baja: " + e.Message + '  ** Trace: ' + e.StackTrace);
         end;
      end;

      if (soloTrib) then
         exit;

      oCtoCost1 := oDBDS.GetValue('U_ProfitCt', 0).Trim;
      oCtoCost2 := oDBDS.GetValue('U_ProfitC2', 0).Trim;
      oCtoCost3 := oDBDS.GetValue('U_ProfitC3', 0).Trim;
      oCtoCost4 := oDBDS.GetValue('U_ProfitC4', 0).Trim;
      oCtoCost5 := oDBDS.GetValue('U_ProfitC5', 0).Trim;

      Fecha       := FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value);
      oPerIngreso := FSBOf.StrToInteger(oDBDS.GetValue('U_InitPer'  , 0));
      oYrIngreso  := FSBOf.StrToInteger(oDBDS.GetValue('U_InitYear' , 0));

      // AFAC
      try
         oActivos := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));

         oActivosParameter := SAPbobsCOM.GeneralDataParams(oActivos.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select Code from [@VID_AFAS] where U_ActCode = '{0}'", 
                     'Select "Code" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
         oSql := string.Format(oSql, EditText(oForm.Items.Item('ActCode').Specific).Value);
         oRecordSet.DoQuery(oSql);
         s := System.string(oRecordSet.Fields.Item('Code').Value);
         oActivosParameter.SetProperty('Code', s);

         oActivosData := oActivos.GetByParams(oActivosParameter);

         FSBOf.Cmpny.StartTransaction;

         if (oDBDS.GetValue('U_ActTipo', 0).Trim = 'T') or (oDBDS.GetValue('U_ActTipo', 0).Trim = 'N') then begin
             if (RevBajaAnual) then
                 AnularDarDeBajaReferencial(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                                             , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                                             , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                                             , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                                             , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                                             , var oCorAnuAc, var oContabGastDepre, var oAux_oValDe);

         end;

         if (Repomo) then begin
            AnularDarDeBajaRepomo(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                           , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                           , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                           , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                           , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib);   
         end
         else if (RevBajaAnual and RevBaja) and false then begin // por ahora no contabiliza
            AnularDarDeBajaNoRepomoReversaAnual(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                                                , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                                                , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                                                , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                                                , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                                                , var oCorAnuAc, var oContabGastDepre, var oAux_oValDe);
         end
         else begin
            AnularDarDeBajaNoRepomo(oForm,  oYr,  oPer, var oPerIngreso, var oYrIngreso
                              , var oDBDS, var oActivos, var oActivosData, var oActivosParameter, var oValCA
                              , var oValCD, var oValDe, var oValAct, var oFactor, var oValActF, var oValDepA, var oValCASys
                              , var oValCDSys, var oValDeSys, var oValActsys, var oValActFSys, var oValDepASys
                              , var Fecha, var lin, var oCtoCost1, var oCtoCost2, var oCtoCost3, var oCtoCost4, var oCtoCost5, var soloTrib
                              , var oCorAnuAc, var oContabGastDepre, var oAux_oValDe);
         end;


         s      := 'N';
         oValde := 0;
         oActivosData.SetProperty('U_DeBaja' , s);
         oActivosData.SetProperty('U_ValBaja', oValDe);
         oActivosData.SetProperty('U_BajaFec', FSBOf.StrToDate(EditText(oForm.Items.Item('BajaFec').Specific).Value));

         oActivos.Update(oActivosData);

         FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_Commit);
         result := true;

         FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Baja_activo] +
                                   EditText(oForm.Items.Item('ActCode').Specific).Value +   
                                   GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Anulada_baja], 
                                   BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
      except
         on e: exception do begin
            if (FSBOf.Cmpny.InTransaction) then
               FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
            FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            OutLog('Anular baja: ' + e.Message + '  ** Trace: ' + e.StackTrace);
         end;
      end;
end;

method TDarDeBaja.AnularDarDeBajaRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; var oPerIngreso: integer; var oYrIngreso: integer;  
                             var oDBDS             : SAPbouiCOM.DBDataSource;
                             var oActivos          : SAPbobsCOM.GeneralService;
                             var oActivosData      : SAPbobsCOM.GeneralData;
                             var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                             var oValCA            : double;
                             var oValCD            : double;
                             var oValDe            : double;
                             var oValAct           : double;
                             var oFactor           : double;
                             var oValActF          : double;
                             var oValDepA          : double;
                             var oValCASys         : double;
                             var oValCDSys         : double;
                             var oValDeSys         : double;
                             var oValActsys        : double;
                             var oValActFSys       : double;
                             var oValDepASys       : double;
                             var Fecha             : DateTime;
                             var lin               : Integer;
                             var oCtoCost1         : String;
                             var oCtoCost2         : String;
                             var oCtoCost3         : String;
                             var oCtoCost4         : String;
                             var oCtoCost5         : String;
                             var soloTrib          : boolean);
var
   oSql              : string;
   oJEntries         : SAPbobsCOM.JournalEntries;
   orst       : SAPbobsCOM.Recordset;
   s          : string;
begin
      orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
      try

         if (oPer = 1) then begin
            oYr  := oYr - 1;
            oPer := 12;
         end
         else
            oPer := oPer - 1;

         if ((oPer = oPerIngreso) and (oYr = oYrIngreso)) or (oYr < oYrIngreso) or ((oPer < oPerIngreso) and (oYr = oYrIngreso)) then begin
         end
         else begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                        "  from [@vid_afac] d inner join [@vid_afas] h on d.code = h.code " +
                        " where h.u_actcode = '{0}'           " +
                        "   and d.U_Year = {1}                " +
                        "   and d.U_Periodo = {2}             ", 
                        'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                        '  from "@VID_AFAC" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                        ' where h."U_ActCode" = ''{0}''         ' +
                        '   and d."U_Year" = {1}                ' +
                        '   and d."U_Periodo" = {2}             ');

            oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
            oRecordSet.DoQuery(oSql);
            if (oRecordSet.EoF) then
               raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Info_incompleta_en_baja]);
         end;

         oFactor := 0;

         oValAct  := FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0));
         oValDepA := FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0));
         if (not oPostSysCu) then begin
            oValAct  := AjustarDecimalesSUM(oValAct);
            oValDepA := AjustarDecimalesSUM(oValDepA);
         end
         else
         begin
            oValAct  := AjustarDecimalesSUMSys(oValAct);
            oValDepA := AjustarDecimalesSUMSys(oValDepA);
         end;
         oValDe   := oValAct - oValDepA;

         if (oTasaFija) then begin
            if (not oPostSysCu) then begin
               oValActSys  := (FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDepASys := (FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValActSys  := AjustarDecimalesSUM(oValActSys);
               oValDepASys := AjustarDecimalesSUM(oValDepASys);
               oValDeSys   := oValActSys - oValDepASys;
            end
            else begin
               oValActSys  := (FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDepASys := (FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) + FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValActSys  := AjustarDecimalesSUMSys(oValActSys);
               oValDepASys := AjustarDecimalesSUMSys(oValDepASys);
               oValDeSys   := oValActSys - oValDepASys;
            end;
            
         end;

         oJEntries.ReferenceDate := Fecha;
         oJEntries.TaxDate       := Fecha;
         oJEntries.DueDate       := Fecha;
         oJEntries.Reference     := 'RAF-Baja';
         oJEntries.Reference2    := oDBDS.GetValue('U_ActCode', 0).Trim;
         oJEntries.TransactionCode := '';
         oJEntries.ProjectCode     := oDBDS.GetValue('U_Project', 0).Trim;

         lin := 0;

            // U_Deprecia
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaDepAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDepA > 0) then
                  oJEntries.Lines.Credit := oValDepA
               else
                  oJEntries.Lines.Debit  := oValDepA * (-1);
               if (oTasaFija) then begin
                  if (oValDepASys > 0) then
                     oJEntries.Lines.CreditSys := oValDepASys
                  else
                     oJEntries.Lines.DebitSys  := oValDepASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDepA > 0) then
                  oJEntries.Lines.FCCredit   := oValDepA
               else
                  oJEntries.Lines.FCDebit  := oValDepA * (-1);

               if (oTasaFija) then begin
                  if (oValDepASys > 0) then
                     oJEntries.Lines.Credit   := oValDepASys
                  else
                     oJEntries.Lines.Debit  := oValDepASys * (-1);

                  if (oValDepA > 0) then
                     oJEntries.Lines.CreditSys   := oValDepA
                  else
                     oJEntries.Lines.DebitSys  := oValDepA * (-1);
               end;
            end;
            inc(lin);

            // U_Venta
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaAdqAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaAdqAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValAct > 0) then
                  oJEntries.Lines.Debit := oValAct
               else
                  oJEntries.Lines.Credit  := (oValAct) * (-1);
               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.DebitSys  := oValActSys
                  else
                     oJEntries.Lines.CreditSys := oValActSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValAct > 0) then
                  oJEntries.Lines.FCDebit   := oValAct
               else
                  oJEntries.Lines.FCCredit  := oValAct * (-1);

               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.Debit   := oValActSys
                  else
                     oJEntries.Lines.Credit  := oValActSys * (-1);

                  if (oValAct > 0) then
                     oJEntries.Lines.DebitSys   := oValAct
                  else
                     oJEntries.Lines.CreditSys  := oValAct * (-1);
               end;
            end;
            inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasBj', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaGasBj', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValDe > 0) then
                  oJEntries.Lines.Credit := oValDe
               else
                  oJEntries.Lines.Debit  := oValDe * (-1);
               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.CreditSys := oValDeSys
                  else
                     oJEntries.Lines.DebitSys  := oValDeSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValDe > 0) then
                  oJEntries.Lines.FCCredit   := oValDe
               else
                  oJEntries.Lines.FCDebit  := oValDe * (-1);

               if (oTasaFija) then begin
                  if (oValDeSys > 0) then
                     oJEntries.Lines.Credit   := oValDeSys
                  else
                     oJEntries.Lines.Debit  := oValDeSys * (-1);

                  if (oValDe > 0) then
                     oJEntries.Lines.CreditSys   := oValDe
                  else
                     oJEntries.Lines.DebitSys  := oValDe * (-1);
               end;
            end;

         errCode := oJEntries.Add;
         if (errCode <> 0) then begin
            FCmpny.GetLastError(out errCode, out errMsg);
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Error_anular_baja] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
         end;
   finally
      FSBOf._ReleaseCOMObject(oJEntries);
   end;
end;

method TDarDeBaja.AnularDarDeBajaNoRepomo(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
var
   oSql              : string;
   oJEntries         : SAPbobsCOM.JournalEntries;
   orst       : SAPbobsCOM.Recordset;
   orst1       : SAPbobsCOM.Recordset;
   s   :String;
begin
      oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
      orst := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      orst1 := Recordset(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      try

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                     "  from [@vid_afac] d inner join [@vid_afas] h on d.code = h.code " +
                     " where h.u_actcode = '{0}'           " +
                     "   and d.U_Year = {1}                " +
                     "   and d.U_Periodo = {2}             ", 
                     'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                     '  from "@VID_AFAC" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                     ' where h."U_ActCode" = ''{0}''         ' +
                     '   and d."U_Year" = {1}                ' +
                     '   and d."U_Periodo" = {2}             ');

         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Info_incompleta_en_baja]);

         oFactor := 1.0 - double(Fecha.Day)/Fecha.DaysInMonth(Fecha.Year, Fecha.Month);

         oValCA  := System.Double(oRecordSet.Fields.Item('U_CorrActi').Value) * oFactor;
         oValCD  := System.Double(oRecordSet.Fields.Item('U_CorrDepr').Value) * oFactor;
         if (not oPostSysCu) then 
         begin
            oValCA  := AjustarDecimalesSUM(oValCA);
            oValCD  := AjustarDecimalesSUM(oValCD);
         end
         else
         begin
            oValCA  := AjustarDecimalesSUMSys(oValCA);
            oValCD  := AjustarDecimalesSUMSys(oValCD);
         end;

         if (CorrPos) then begin
            if (oValCA < 0) then
               oValCA := 0; 
            if (oValCD < 0) then
               oValCD := 0; 
         end;

         oCorAnuac := 0;
         if (not GlobalSettings.IFRSNativo) then 
            oCorAnuAc := FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuAc', 0));

         oValDe  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor;
         if (not oPostSysCu) then begin
             oValDe  := AjustarDecimalesSUM(oValDe);
             oValAct := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'   , 0))) + AjustarDecimalesSUM(oCorAnuAc) +
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) -
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum'  , 0))) - AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) -
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) - oValCA + oValCD + oValDe;
             oValActF := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0))) + AjustarDecimalesSUM(oCorAnuAc) +
                         AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0))) - oValCA;
             oValDepA := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0))) + AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) +
                        AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) - oValCD - oValDe;
         end
         else begin
             oValDe  := AjustarDecimalesSUMSys(oValDe);
             oValAct := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'   , 0))) + AjustarDecimalesSUMSys(oCorAnuAc) +
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC' , 0))) -
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum'  , 0))) - AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) -
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) - oValCA + oValCD + oValDe;
             oValActF := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0))) + AjustarDecimalesSUMSys(oCorAnuAc) +
                         AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0))) - oValCA;
             oValDepA := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0))) + AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0))) +
                        AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu' , 0))) - oValCD - oValDe;
         end;

         if (oTasaFija) then begin
            if (not oPostSysCu) then begin
               oValCASys  := System.Double(oRecordSet.Fields.Item('U_CorrActi').Value) * oFactor / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCDSys  := System.Double(oRecordSet.Fields.Item('U_CorrDepr').Value) * oFactor / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCASys  := AjustarDecimalesSUM(oValCASys);
               oValCDSys  := AjustarDecimalesSUM(oValCDSys);
            end
            else begin
               oValCASys  := System.Double(oRecordSet.Fields.Item('U_CorrActi').Value) * oFactor * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCDSys  := System.Double(oRecordSet.Fields.Item('U_CorrDepr').Value) * oFactor * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValCASys  := AjustarDecimalesSUMSys(oValCASys);
               oValCDSys  := AjustarDecimalesSUMSys(oValCDSys);
            end;
            
            if (CorrPos) then begin
               if (oValCASys < 0) then
                  oValCASys := 0; 
               if (oValCDSys < 0) then
                  oValCDSys := 0; 
            end;

            if (not oPostSysCu) then begin
               oValDeSys  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDeSys  := AjustarDecimalesSUM(oValDeSys);
               oValActSys := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                             AjustarDecimalesSUM(oCorAnuAc / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - 
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys + oValCDSys + oValDeSys;
               oValActFSys := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUM(oCorAnuAc / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys;
               oValDepASys := AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUM(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCDSys - oValDeSys;
            end
            else begin
               oValDeSys  := System.Double(oRecordSet.Fields.Item('U_Deprecia').Value) * oFactor * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS'  , 0));
               oValDeSys  := AjustarDecimalesSUMSys(oValDeSys);
               oValActSys := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                             AjustarDecimalesSUMSys(oCorAnuAc * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - 
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) -
                             AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys + oValCDSys + oValDeSys;
               oValActFSys := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CurVal'  , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUMSys(oCorAnuAc * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_AdicAnuC', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCASys;
               oValDepASys := AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepAcum' , 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) + 
                              AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_CorAnuDe', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) +
                              AjustarDecimalesSUMSys(FSBOf.StrToDouble(oDBDS.GetValue('U_DepreAnu', 0)) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))) - oValCDSys - oValDeSys;
            end;
         end;

         oJEntries.ReferenceDate := Fecha;
         oJEntries.TaxDate       := Fecha;
         oJEntries.DueDate       := Fecha;
         oJEntries.Reference     := 'RAF-Baja';
         oJEntries.Reference2    := oDBDS.GetValue('U_ActCode', 0).Trim;
         oJEntries.TransactionCode := '';
         oJEntries.ProjectCode     := oDBDS.GetValue('U_Project', 0).Trim;

         lin := 0;
         // U_CorrActi
         if (oValCA <> 0) then begin
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaActFi', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaActFi', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCA > 0) then
                  oJEntries.Lines.Debit   := oValCA
               else
                  oJEntries.Lines.Credit  := oValCA * (-1);
               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.DebitSys  := oValCASys
                  else
                     oJEntries.Lines.CreditSys := oValCASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCA > 0) then
                  oJEntries.Lines.FCDebit   := oValCA
               else
                  oJEntries.Lines.FCCredit  := oValCA * (-1);

               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.Debit   := oValCASys
                  else
                     oJEntries.Lines.Credit  := oValCASys * (-1);

                  if (oValCA > 0) then
                     oJEntries.Lines.DebitSys   := oValCA
                  else
                     oJEntries.Lines.CreditSys  := oValCA * (-1);
               end;
            end;
            inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaCorAF', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaCorAF', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCA > 0) then
                  oJEntries.Lines.Credit := oValCA
               else
                  oJEntries.Lines.Debit  := oValCA * (-1);
               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.CreditSys := oValCASys
                  else
                     oJEntries.Lines.DebitSys  := oValCASys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCA > 0) then
                  oJEntries.Lines.FCCredit   := oValCA
               else
                  oJEntries.Lines.FCDebit  := oValCA * (-1);

               if (oTasaFija) then begin
                  if (oValCASys > 0) then
                     oJEntries.Lines.Credit   := oValCASys
                  else
                     oJEntries.Lines.Debit  := oValCASys * (-1);

                  if (oValCA > 0) then
                     oJEntries.Lines.CreditSys   := oValCA
                  else
                     oJEntries.Lines.DebitSys  := oValCA * (-1);
               end;
            end;
            inc(lin);
         end;

                  //*************Revalorizacion
         
          oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               " Select Case when rd.U_NewVal > rd.U_ValAnt then 'Rea' else 'Det' end Tipo,
                        Case when rd.U_NewVal > rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end CtaIFRS,  
                        a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5, 
                        SUM(Case when rd.U_NewVal > rd.U_ValAnt then rd.U_NewVal - rd.U_ValAnt else rd.U_ValAnt - rd.U_NewVal end) Monto
                   from [@VID_AFAS] a inner join [@VID_AFREVD] rd on a.U_ActCode = rd.U_ActCode
                                      inner join [@VID_AFREV]  rh on rh.DocEntry = rd.DocEntry
                                      inner join [@VID_AFAC]   ac on ac.Code = a.Code and ac.U_Year = rh.U_Year and ac.U_Periodo = rh.U_Periodo
                  where rh.U_Year <= {0} and rh.U_Periodo <= {1}  AND a.U_ActCode = '{2}'
                  group by  Case when rd.U_NewVal> rd.U_ValAnt then 'Rea' else 'Det' end,
                            Case when rd.U_NewVal> rd.U_ValAnt then a.U_CtaReaAF else a.U_CtaDetAF end,  
                            a.U_CtaActFi, a.U_Project, a.U_ProfitCt, a.U_ProfitC2, a.U_ProfitC3, a.U_ProfitC4, a.U_ProfitC5 ",
               ' Select Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end "Tipo",                  ' +
               '        Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end "CtaIFRS", ' +
               '        a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5",              ' +
               '        SUM(Case when rd."U_NewVal" > rd."U_ValAnt" then rd."U_NewVal" - rd."U_ValAnt" else rd."U_ValAnt" - rd."U_NewVal" end) "Monto" ' +
               '   from "@VID_AFAS" a inner join "@VID_AFREVD" rd on a."U_ActCode" = rd."U_ActCode"              ' + 
               '                      inner join "@VID_AFREV"  rh on rh."DocEntry" = rd."DocEntry"               ' +
               '                      inner join "@VID_AFAC"   ac on ac."Code" = a."Code" and ac."U_Year" = rh."U_Year" and ac."U_Periodo" = rh."U_Periodo" ' +
               '  where rh."U_Year" <= {0} and rh."U_Periodo" <= {1}  AND a."U_ActCode" = ''{2}''                                             ' +
               '  group by  Case when rd."U_NewVal" > rd."U_ValAnt" then ''Rea'' else ''Det'' end,               ' +   
               '            Case when rd."U_NewVal" > rd."U_ValAnt" then a."U_CtaReaAF" else a."U_CtaDetAF" end, ' +
               '            a."U_CtaActFi", a."U_Project", a."U_ProfitCt", a."U_ProfitC2", a."U_ProfitC3", a."U_ProfitC4", a."U_ProfitC5" ');
         oSql := String.Format(oSql, oYr.ToString(), oPer.ToString(), oDBDS.GetValue('U_ActCode', 0).Trim());
         orst1.DoQuery(oSql); 
         if (orst1.RecordCount > 0) and (not Repomo) then begin
            while (not orst1.EoF) do begin
                var oValor := system.Double( orst1.Fields.Item('Monto' ).Value );
                if (not oPostSysCu) then
                   oValor    := Utils.AjustarDecimalesSUM(oValor)
                else
                   oValor    := Utils.AjustarDecimalesSUMSys(oValor);

                if (lin > 0) then
                   oJEntries.lines.Add;
                oJEntries.Lines.SetCurrentLine(lin);
                oJEntries.Lines.AccountCode := system.String( orst1.Fields.Item('U_CtaActFi' ).Value );
                oJEntries.Lines.ProjectCode := system.String( orst1.Fields.Item('U_Project' ).Value );
                s := iif(GlobalSettings.RunningUnderSQLServer, 
                   "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
                   'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
                s := String.Format(s, system.String( orst1.Fields.Item('U_CtaActFi' ).Value )); 
                orst.DoQuery(s);
                s := System.String(orst.Fields.Item('ActType').value).Trim();
   
                if (s = 'I') or (s = 'E') then
                begin
                    oJEntries.Lines.CostingCode  := system.String( orst1.Fields.Item('U_ProfitCt' ).Value);
                    oJEntries.Lines.CostingCode2 := system.String( orst1.Fields.Item('U_ProfitC2' ).Value);
                    oJEntries.Lines.CostingCode3 := system.String( orst1.Fields.Item('U_ProfitC3' ).Value);
                    oJEntries.Lines.CostingCode4 := system.String( orst1.Fields.Item('U_ProfitC4' ).Value);
                    oJEntries.Lines.CostingCode5 := system.String( orst1.Fields.Item('U_ProfitC5' ).Value);
                end;

                if (not GlobalSettings.IFRSNativo) then begin
                   if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                      if (oValor > 0) then
                         oJEntries.Lines.Debit   := oValor
                      else
                         oJEntries.Lines.Credit  := oValor * (-1);
                   end
                   else begin
                      if (oValor > 0) then
                         oJEntries.Lines.Credit   := oValor
                      else
                         oJEntries.Lines.Debit  := oValor * (-1);
                   end;
                end
                else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
                  if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                      if (oValor > 0) then 
                         oJEntries.Lines.FCDebit   := oValor
                      else
                         oJEntries.Lines.FCCredit  := oValor * (-1);
                   end
                   else begin
                      if (oValor > 0) then
                         oJEntries.Lines.FCCredit   := oValor
                      else
                         oJEntries.Lines.FCDebit  := oValor * (-1);
                   end;
                end;
                inc(lin);

                if (lin > 0) then
                   oJEntries.lines.Add;
                oJEntries.Lines.SetCurrentLine(lin);
                oJEntries.Lines.AccountCode := system.String( orst1.Fields.Item('CtaIFRS' ).Value );
                oJEntries.Lines.ProjectCode := system.String( orst1.Fields.Item('U_Project' ).Value );
                s := iif(GlobalSettings.RunningUnderSQLServer, 
                   "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
                   'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
                s := String.Format(s, system.String( orst1.Fields.Item('CtaIFRS' ).Value )); 
                orst.DoQuery(s);
                s := System.String(orst.Fields.Item('ActType').value).Trim();
   
                if (s = 'I') or (s = 'E') then
                begin
                    oJEntries.Lines.CostingCode  := system.String( orst1.Fields.Item('U_ProfitCt' ).Value);
                    oJEntries.Lines.CostingCode2 := system.String( orst1.Fields.Item('U_ProfitC2' ).Value);
                    oJEntries.Lines.CostingCode3 := system.String( orst1.Fields.Item('U_ProfitC3' ).Value);
                    oJEntries.Lines.CostingCode4 := system.String( orst1.Fields.Item('U_ProfitC4' ).Value);
                    oJEntries.Lines.CostingCode5 := system.String( orst1.Fields.Item('U_ProfitC5' ).Value);
                end;

                if (not GlobalSettings.IFRSNativo) then begin
                     if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                        if (oValor > 0) then
                           oJEntries.Lines.Credit   := oValor
                        else
                           oJEntries.Lines.Debit  := oValor * (-1);
                     end
                     else begin
                        if (oValor > 0) then
                           oJEntries.Lines.Debit   := oValor
                        else
                           oJEntries.Lines.Credit  := oValor * (-1);
                     end;
                 end
                 else begin
                     oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency; 
                     if (system.String( orst1.Fields.Item('Tipo' ).Value ).Trim() = "Rea") then begin
                        if (oValor > 0) then
                           oJEntries.Lines.FCCredit   := oValor
                        else
                           oJEntries.Lines.FCDebit  := oValor * (-1);
                     end
                     else begin
                        if (oValor > 0) then
                           oJEntries.Lines.FCDebit   := oValor
                        else
                           oJEntries.Lines.FCCredit  := oValor * (-1);
                     end;
                 end;
                inc(lin);
                orst1.MoveNext(); 
            end;
         end;

         //*************Fin Revalorizacion

            // U_CorrDepr
         if (oValCD <> 0) then begin
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaDepAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCD > 0) then
                  oJEntries.Lines.Credit := oValCD
               else
                  oJEntries.Lines.Debit  := oValCD * (-1);
               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.CreditSys := oValCDSys
                  else
                     oJEntries.Lines.DebitSys  := oValCDSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCD > 0) then
                  oJEntries.Lines.FCCredit   := oValCD
               else
                  oJEntries.Lines.FCDebit  := oValCD * (-1);

               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.Credit   := oValCDSys
                  else
                     oJEntries.Lines.Debit  := oValCDSys * (-1);

                  if (oValCD > 0) then
                     oJEntries.Lines.CreditSys   := oValCD
                  else
                     oJEntries.Lines.DebitSys  := oValCD * (-1);
               end;
            end;
            inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaCorDA', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaCorDA', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValCD > 0) then
                  oJEntries.Lines.Debit := oValCD
               else
                  oJEntries.Lines.Credit  := oValCD * (-1);
               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.DebitSys  := oValCDSys
                  else
                     oJEntries.Lines.CreditSys := oValCDSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValCD > 0) then
                  oJEntries.Lines.FCDebit   := oValCD
               else
                  oJEntries.Lines.FCCredit  := oValCD * (-1);

               if (oTasaFija) then begin
                  if (oValCDSys > 0) then
                     oJEntries.Lines.Debit   := oValCDSys
                  else
                     oJEntries.Lines.Credit  := oValCDSys * (-1);

                  if (oValCD > 0) then
                     oJEntries.Lines.DebitSys   := oValCD
                  else
                     oJEntries.Lines.CreditSys  := oValCD * (-1);
               end;
            end;
            inc(lin);
         end;

            // U_Deprecia
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaDepAc', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (RevBaja) then begin
               if (not oPostSysCu) then begin
                  if (oValDepA > 0) then
                     oJEntries.Lines.Credit := oValDepA
                  else
                     oJEntries.Lines.Debit  := oValDepA * (-1);
                  if (oTasaFija) then begin
                     if (oValDepASys > 0) then
                        oJEntries.Lines.CreditSys := oValDepASys
                     else
                        oJEntries.Lines.DebitSys  := oValDepASys * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValDepA > 0) then
                     oJEntries.Lines.FCCredit   := oValDepA
                  else
                     oJEntries.Lines.FCDebit  := oValDepA * (-1);
               end;
            end
            else begin
               if (not oPostSysCu) then begin
                  if (oValDe > 0) then
                     oJEntries.Lines.Credit := oValDe
                  else
                     oJEntries.Lines.Debit  := oValDe * (-1);
                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.CreditSys := oValDeSys
                     else
                        oJEntries.Lines.DebitSys  := oValDeSys * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValDe > 0) then
                     oJEntries.Lines.FCCredit   := oValDe
                  else
                     oJEntries.Lines.FCDebit  := oValDe * (-1);

                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.Credit   := oValDeSys
                     else
                        oJEntries.Lines.Debit  := oValDeSys * (-1);

                     if (oValDe > 0) then
                        oJEntries.Lines.CreditSys   := oValDe
                     else
                        oJEntries.Lines.DebitSys  := oValDe * (-1);
                  end;
               end;
            end;
            inc(lin);

            if (oContabGastDepre) then begin
               if (lin > 0) then
                  oJEntries.lines.Add;
               oJEntries.Lines.SetCurrentLine(lin);
               oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasDe', 0).Trim;
               oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
               s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
              s := String.Format(s, oDBDS.GetValue('u_CtaGasDe', 0).Trim); 
              orst.DoQuery(s);
              s := System.String(orst.Fields.Item('ActType').value).Trim();
   
              if (s = 'I') or (s = 'E') then
              begin
                  oJEntries.Lines.CostingCode  := oCtoCost1;
                  oJEntries.Lines.CostingCode2 := oCtoCost2;
                  oJEntries.Lines.CostingCode3 := oCtoCost3;
                  oJEntries.Lines.CostingCode4 := oCtoCost4;
                  oJEntries.Lines.CostingCode5 := oCtoCost5;
               end;

               if (not oPostSysCu) then begin
                  if (oValDe > 0) then
                     oJEntries.Lines.Debit := oValDe
                  else
                     oJEntries.Lines.Credit  := oValDe * (-1);
                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.DebitSys  := oValDeSys
                     else
                        oJEntries.Lines.CreditSys := oValDeSys * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValDe > 0) then
                     oJEntries.Lines.FCDebit   := oValDe
                  else
                     oJEntries.Lines.FCCredit  := oValDe * (-1);

                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.Debit   := oValDeSys
                     else
                        oJEntries.Lines.Credit  := oValDeSys * (-1);

                     if (oValDe > 0) then
                        oJEntries.Lines.DebitSys   := oValDe
                     else
                        oJEntries.Lines.CreditSys  := oValDe * (-1);
                  end;
               end;
               inc(lin);
            end;

            // U_Venta
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('U_CtaActFi', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('U_CtaActFi', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (RevBaja) then begin
               if (oContabGastDepre) then 
                  OAux_oValDe := 1.0;

               if (not oPostSysCu) then begin
                  if (oValActF-oValDe*OAux_oValDe > 0) then
                     oJEntries.Lines.Debit := oValActF-oValDe*OAux_oValDe
                  else
                     oJEntries.Lines.Credit  := (oValActF-oValDe*OAux_oValDe) * (-1);
                  if (oTasaFija) then begin
                     if (oValActFSys-oValDeSys*OAux_oValDe > 0) then
                        oJEntries.Lines.DebitSys  := oValActFSys-oValDeSys*OAux_oValDe
                     else
                        oJEntries.Lines.CreditSys := (oValActFSys-oValDeSys*OAux_oValDe) * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValActF-oValDe*OAux_oValDe > 0) then
                     oJEntries.Lines.FCDebit   := oValActF-oValDe*OAux_oValDe
                  else
                     oJEntries.Lines.FCCredit  := (oValActF-oValDe*OAux_oValDe) * (-1);

                  if (oTasaFija) then begin
                     if ((oValActFSys-oValDeSys*OAux_oValDe) > 0) then
                        oJEntries.Lines.Debit   := (oValActFSys-oValDeSys*OAux_oValDe)
                     else
                        oJEntries.Lines.Credit  := (oValActFSys-oValDeSys*OAux_oValDe) * (-1);

                     if ((oValActF-oValDe*OAux_oValDe) > 0) then
                        oJEntries.Lines.DebitSys   := (oValActF-oValDe*OAux_oValDe)
                     else
                        oJEntries.Lines.CreditSys  := (oValActF-oValDe*OAux_oValDe) * (-1);
                  end;
               end;
            end
            else begin
               if (not oPostSysCu) then begin
                  if (oValAct > 0) then
                     oJEntries.Lines.Debit := oValAct
                  else
                     oJEntries.Lines.Credit  := oValAct * (-1);
                  if (oTasaFija) then begin
                     if (oValActSys > 0) then
                        oJEntries.Lines.DebitSys  := oValActSys
                     else
                        oJEntries.Lines.CreditSys := oValActSys * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValAct > 0) then
                     oJEntries.Lines.FCDebit   := oValAct
                  else
                     oJEntries.Lines.FCCredit  := oValAct * (-1);
               end;

               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.Debit   := oValActSys
                  else
                     oJEntries.Lines.Credit  := oValActSys * (-1);

                  if (oValAct > 0) then
                     oJEntries.Lines.DebitSys   := oValAct
                  else
                     oJEntries.Lines.CreditSys  := oValAct * (-1);
               end;
            end;
            inc(lin);

         if (RevBaja) and (not oContabGastDepre) then begin
            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaDepAc', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
              s := String.Format(s, oDBDS.GetValue('u_CtaDepAc', 0).Trim); 
              orst.DoQuery(s);
              s := System.String(orst.Fields.Item('ActType').value).Trim();
   
              if (s = 'I') or (s = 'E') then
              begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
              end;

               if (not oPostSysCu) then begin
                  if (oValDe > 0) then
                     oJEntries.Lines.Credit := oValDe
                  else
                     oJEntries.Lines.Debit  := oValDe * (-1);
                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.CreditSys  := oValDeSys
                     else
                        oJEntries.Lines.DebitSys := oValDeSys * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValDe > 0) then
                     oJEntries.Lines.FCCredit   := oValDe
                  else
                     oJEntries.Lines.FCDebit  := oValDe * (-1);

                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.Credit   := oValDeSys
                     else
                        oJEntries.Lines.Debit  := oValDeSys * (-1);

                     if (oValDe > 0) then
                        oJEntries.Lines.CreditSys   := oValDe
                     else
                        oJEntries.Lines.DebitSys  := oValDe * (-1);
                  end;
               end;
               inc(lin);

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasDe', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaGasDe', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

               if (not oPostSysCu) then begin
                  if (oValDe > 0) then
                     oJEntries.Lines.Debit := oValDe
                  else
                     oJEntries.Lines.Credit  := oValDe * (-1);
                  if (oTasaFija) then begin
                     if (oValDeSys > 0) then
                        oJEntries.Lines.DebitSys  := oValDeSys
                     else
                        oJEntries.Lines.CreditSys := oValDeSys * (-1);
                  end;
               end
               else begin
                  oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
                  if (oValDe > 0) then
                     oJEntries.Lines.FCDebit   := oValDe
                  else
                     oJEntries.Lines.FCCredit  := oValDe * (-1);
               end;
               inc(lin);
         end;

            if (lin > 0) then
               oJEntries.lines.Add;
            oJEntries.Lines.SetCurrentLine(lin);
            oJEntries.Lines.AccountCode := oDBDS.GetValue('u_CtaGasBj', 0).Trim;
            oJEntries.Lines.ProjectCode := oDBDS.GetValue('U_Project' , 0).Trim;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
               "SELECT ActType FROM OACT WHERE AcctCode = '{0}'", 
               'SELECT "ActType" FROM "OACT" WHERE "AcctCode" = ''{0}'' ');
            s := String.Format(s, oDBDS.GetValue('u_CtaGasBj', 0).Trim); 
            orst.DoQuery(s);
            s := System.String(orst.Fields.Item('ActType').value).Trim();
   
            if (s = 'I') or (s = 'E') then
            begin
                oJEntries.Lines.CostingCode  := oCtoCost1;
                oJEntries.Lines.CostingCode2 := oCtoCost2;
                oJEntries.Lines.CostingCode3 := oCtoCost3;
                oJEntries.Lines.CostingCode4 := oCtoCost4;
                oJEntries.Lines.CostingCode5 := oCtoCost5;
            end;

            if (not oPostSysCu) then begin
               if (oValAct > 0) then
                  oJEntries.Lines.Credit := oValAct
               else
                  oJEntries.Lines.Debit  := oValAct * (-1);
               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.CreditSys := oValActSys
                  else
                     oJEntries.Lines.DebitSys  := oValActSys * (-1);
               end;
            end
            else begin
               oJEntries.Lines.FCCurrency := FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency;
               if (oValAct > 0) then
                  oJEntries.Lines.FCCredit   := oValAct
               else
                  oJEntries.Lines.FCDebit  := oValAct * (-1);

               if (oTasaFija) then begin
                  if (oValActSys > 0) then
                     oJEntries.Lines.Credit   := oValActSys
                  else
                     oJEntries.Lines.Debit  := oValActSys * (-1);

                  if (oValActSys > 0) then
                     oJEntries.Lines.CreditSys   := oValAct
                  else
                     oJEntries.Lines.DebitSys  := oValActSys * (-1);
               end;
            end;

         errCode := oJEntries.Add;
         if (errCode <> 0) then begin
            FCmpny.GetLastError(out errCode, out errMsg);
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Error_anular_baja] + TMultiFunctions.inttostr(errCode) + ' - ' + errMsg);
         end;
   finally
      FSBOf._ReleaseCOMObject(oJEntries);
   end;
end;

method TDarDeBaja.AnularDarDeBajaNoRepomoReversaAnual(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
var
   oSql              : string;
   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;
   oJEntries         : SAPbobsCOM.JournalEntries;
   i, j, Id          : integer;
   AfacOrder         : List<integer> := new List<integer>;
   AfacList          : List<TAFAVRecord> := new List<TAFAVRecord>;
   AfacItem          : TAFAVRecord;
   oU_CurVal         : double;
   oU_CorAnuAc       : double;
   oU_DepAcum        : double;
   oU_DepreAnu       : double;
   oU_DepAcumN       : double;
   oU_CorAnuDe       : double;
   oU_Adicion        : double;
   oU_Bis33          : double;
   oAuxSys           : double;
begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                     "  from [@vid_afac] d inner join [@vid_afas] h on d.code = h.code " +
                     " where h.u_actcode = '{0}'           " +
                     "   and d.U_Year = {1}                " +
                     "   and d.U_Periodo = {2}             ", 
                     'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                     '  from "@VID_AFAC" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                     ' where h."U_ActCode" = ''{0}''         ' +
                     '   and d."U_Year" = {1}                ' +
                     '   and d."U_Periodo" = {2}             ');

         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Info_incompleta_en_baja]);


         oActivosLines     := oActivosData.Child('VID_AFAC');

         j := oActivosLines.Count - 1;
         for i := j downto 0 do begin
             oActivosLinesData := oActivosLines.Item(i);
             if (int32(oActivosLinesData.GetProperty('U_Year')) <> oYr) then
                 continue
             else if ( int32(oActivosLinesData.GetProperty('U_PerDepre')) < 0) and ( double(oActivosLinesData.GetProperty('U_Deprecia')) < 0.0) then begin
                oActivosLines.Remove(i);
             end;
         end;

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select a.*                 " +
                     "  from [@VID_AFAS] a       " +
                     " where u_actcode = '{0}'   ", 
                     'Select A.*                    ' +
                     '  from "@VID_AFAS" A          ' +
                     ' where "U_ActCode" = ''{0}''  ');
         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim);
         oRecordSet.DoQuery(oSql);
         oU_CurVal   := System.Double(oRecordSet.Fields.Item('U_CurVal'  ).Value);
         oU_CorAnuAc := System.Double(oRecordSet.Fields.Item('U_CorAnuAc').Value);
         oU_DepAcum  := System.Double(oRecordSet.Fields.Item('U_DepAcum' ).Value);
         oU_DepreAnu := System.Double(oRecordSet.Fields.Item('U_DepreAnu').Value);
         oU_DepAcumN := System.Double(oRecordSet.Fields.Item('U_DepAcumN').Value);
         oU_CorAnuDe := System.Double(oRecordSet.Fields.Item('U_CorAnuDe').Value);
         oU_Adicion  := 0.0;
         oU_Bis33    := System.Double(oRecordSet.Fields.Item('U_Bis33'   ).Value);

/////

         if (GlobalSettings.IFRSNativo) then begin
               // depreciacion anual
               oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
           
               Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, Fecha.Year, Fecha.Month, Fecha.Day, 'AF-', 'AF-Baja',
                                                   oDBDS.GetValue('U_Project', 0).Trim,
                                                   '',
                                                   'Reversa anual' );
           
               if (not oPostSysCu) then 
                  oAuxSys := oU_DepreAnu / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_DepreAnu * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_DepreAnu, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaGasDe', 0).Trim,
                                              oDBDS.GetValue('U_CtaDepAc', 0).Trim );
           
               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
         end;
   
         if (not GlobalSettings.IFRSNativo) then begin
               // depreciacion anual
               oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
           
               Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, Fecha.Year, Fecha.Month, Fecha.Day, 'AF-', 'AF-Baja',
                                                   oDBDS.GetValue('U_Project', 0).Trim,
                                                   '',
                                                   'Reversa Anual' );
           
               if (not oPostSysCu) then 
                  oAuxSys := oU_CorAnuAc / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_CorAnuAc * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_CorAnuAc, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaActFi', 0).Trim,
                                              oDBDS.GetValue('U_CtaCorAc', 0).Trim );
           
               if (not oPostSysCu) then 
                  oAuxSys := oU_CorAnuDe / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_CorAnuDe * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_CorAnuDe, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaCorDa', 0).Trim,
                                              oDBDS.GetValue('U_CtaDepAc', 0).Trim );

               if (not oPostSysCu) then 
                  oAuxSys := oU_DepreAnu / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
               else
                  oAuxSys := oU_DepreAnu * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
               Utils.ContabilizarEnSBOInsertarValor(var oJEntries, oU_DepreAnu, oAuxSys, 
                                              oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                              oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                              oDBDS.GetValue('U_CtaGasDe', 0).Trim,
                                              oDBDS.GetValue('U_CtaDepAc', 0).Trim );

               Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);   
        end;

        // Ingreso de asiento de baja

        oJEntries := JournalEntries(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries));
        
        Utils.ContabilizarEnSBOCrearAsiento(var oJEntries, Fecha.Year, Fecha.Month, Fecha.Day, 'AF-', 'AF-Baja',
                                            oDBDS.GetValue('U_Project', 0).Trim,
                                            '',
                                            'Reversa anual' );
        
        if (not oPostSysCu) then 
           oAuxSys := (oU_CurVal - oU_DepAcum) / FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0))
        else
           oAuxSys := (oU_CurVal - oU_DepAcum) * FSBOf.StrToDouble(oDBDS.GetValue('U_TasaCnMS', 0));
        Utils.ContabilizarEnSBOInsertarValor(var oJEntries, (oU_CurVal - oU_DepAcum), oAuxSys, 
                                       oDBDS.GetValue('U_ProfitCt', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC2', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC3', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC4', 0).Trim,
                                       oDBDS.GetValue('U_ProfitC5', 0).Trim,
                                       oDBDS.GetValue('U_CtaGasBj', 0).Trim,
                                       oDBDS.GetValue('U_CtaActFi', 0).Trim );
        
        Utils.ContabilizarEnSBOCerrarAsiento(var oJEntries);
end;

method TDarDeBaja.AnularDarDeBajaReferencial(oForm: SAPbouiCOM.Form; oYr, oPer: integer; 
                               var oPerIngreso       : integer; 
                               var oYrIngreso        : integer;
                               var oDBDS             : SAPbouiCOM.DBDataSource;
                               var oActivos          : SAPbobsCOM.GeneralService;
                               var oActivosData      : SAPbobsCOM.GeneralData;
                               var oActivosParameter : SAPbobsCOM.GeneralDataParams;
                               var oValCA            : double;
                               var oValCD            : double;
                               var oValDe            : double;
                               var oValAct           : double;
                               var oFactor           : double;
                               var oValActF          : double;
                               var oValDepA          : double;
                               var oValCASys         : double;
                               var oValCDSys         : double;
                               var oValDeSys         : double;
                               var oValActsys        : double;
                               var oValActFSys       : double;
                               var oValDepASys       : double;
                               var Fecha             : DateTime;
                               var lin               : Integer;
                               var oCtoCost1         : String;
                               var oCtoCost2         : String;
                               var oCtoCost3         : String;
                               var oCtoCost4         : String;
                               var oCtoCost5         : String;
                               var soloTrib          : boolean;
                               var oCorAnuAc         : double;
                               var oContabGastDepre  : boolean;
                               var oAux_oValDe       : double);
var
   oSql              : string;
   oActivosLines     : SAPbobsCOM.GeneralDataCollection; 
   oActivosLinesData : SAPbobsCOM.GeneralData;
   oJEntries         : SAPbobsCOM.JournalEntries;
   i, j, Id          : integer;
   AfacOrder         : List<integer> := new List<integer>;
   AfacList          : List<TAFAVRecord> := new List<TAFAVRecord>;
   AfacItem          : TAFAVRecord;
   oU_CurVal         : double;
   oU_DepAcum        : double;
   oU_Bis33          : double;
   oU_VidaUtiR       : int32;
   oU_PRrDepre       : int32;
   oPerDepre         : int32  := 0;
   vCorAnuAc         : double := 0.0;
   oCorAnuDe         : double := 0.0;
   oDepreAnu         : double := 0.0;
   oAdicion          : double := 0.0;
begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select d.U_CorrActi, d.U_CorrDepr, d.U_Deprecia " +
                     "  from [@vid_afacR] d inner join [@vid_afas] h on d.code = h.code " +
                     " where h.u_actcode = '{0}'           " +
                     "   and d.U_Year = {1}                " +
                     "   and d.U_Periodo = {2}             ", 
                     'Select d."U_CorrActi", d."U_CorrDepr", d."U_Deprecia" ' +
                     '  from "@VID_AFACR" d inner join "@VID_AFAS" h on d."Code" = h."Code" ' +
                     ' where h."U_ActCode" = ''{0}''         ' +
                     '   and d."U_Year" = {1}                ' +
                     '   and d."U_Periodo" = {2}             ');

         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim, oYr.ToString, oPer.ToString);
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then
            raise new Exception(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Info_incompleta_en_baja]);


         oActivosLines     := oActivosData.Child('VID_AFACR');

         j := oActivosLines.Count - 1;
         for i := j downto 0 do begin
             oActivosLinesData := oActivosLines.Item(i);
             if (int32(oActivosLinesData.GetProperty('U_Year')) <> oYr) then
                 continue
             //else if ( int32(oActivosLinesData.GetProperty('U_PerDepre')) < 0) or ( double(oActivosLinesData.GetProperty('U_Deprecia')) < 0.0) then begin
             else if ( string(oActivosLinesData.GetProperty('U_RevBajaIni')) = 'Y') then begin
                oPerDepre := oPerDepre + int32(oActivosLinesData.GetProperty('U_PerDepre'))*-1;
                vCorAnuAc := vCorAnuAc + double(oActivosLinesData.GetProperty('U_CorrActi'))*-1.0;
                oCorAnuDe := oCorAnuDe + double(oActivosLinesData.GetProperty('U_CorrDepr'))*-1.0;
                oDepreAnu := oDepreAnu + double(oActivosLinesData.GetProperty('U_Deprecia'))*-1.0 + double(oActivosLinesData.GetProperty('U_CorrDepM'))*-1.0;
                oAdicion  := oAdicion  + double(oActivosLinesData.GetProperty('U_Adicion'))*-1.0;
                oActivosLines.Remove(i);
             end;
         end;

         oActivosLines     := oActivosData.Child('VID_AFSAR');
         
         j := oActivosLines.Count - 1;
         for i := j downto 0 do begin
             oActivosLinesData := oActivosLines.Item(i);
             if (int32(oActivosLinesData.GetProperty('U_Year')) <> oYr) then
                 continue
             else if ( string(oActivosLinesData.GetProperty('U_RevBajaIni')) = 'Y') then begin
               //else if ( double(oActivosLinesData.GetProperty('U_CurVal')) < 0.0) or ( double(oActivosLinesData.GetProperty('U_DepAcum')) < 0.0) then begin
                oU_Bis33 := double(oActivosLinesData.GetProperty('U_Bis33'))*-1.0;
                oActivosLines.Remove(i);
             end;
         end;

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select a.* , isnull(cc.DimCode, 1) DimCode                   " +
                     "  from [@VID_AFAS] a                                         " +
                     "       left outer join OPRC cc on a.U_ProfitCt = cc.PrcCode  " +
                     " where u_actcode = '{0}'   ", 
                     'Select A.*, ifnull(CC."DimCode", 1) "DimCode"                   ' +
                     '  from "@VID_AFAS" A                                            ' +
                     '       left outer join OPRC CC on A."U_ProfitCt" = CC."PrcCode" ' +
                     ' where "U_ActCode" = ''{0}''                                    ');
         oSql := string.Format(oSql, oDBDS.GetValue('U_ActCode', 0).Trim);
         oRecordSet.DoQuery(oSql);
         oU_CurVal   := System.Double(oRecordSet.Fields.Item('U_CurVal'  ).Value);
         oU_DepAcum  := System.Double(oRecordSet.Fields.Item('U_DepAcum' ).Value);
         oU_VidaUtiR := System.int32(oRecordSet.Fields.Item('U_VidaUtiR').Value);
         oU_PRrDepre := System.int32(oRecordSet.Fields.Item('U_PRrDepre').Value);

         oActivosData.SetProperty('U_VidaUtiR', oU_VidaUtiR - oPerDepre);
         oActivosData.SetProperty('U_PRrDepre', oU_PRrDepre + oPerDepre);
         oActivosData.SetProperty('U_CorAnuAR', vCorAnuAc);
         oActivosData.SetProperty('U_CorAnuDR', oCorAnuDe);
         oActivosData.SetProperty('U_DepreAnR', oDepreAnu);
         oActivosData.SetProperty('U_Bis33'   , oU_Bis33);
end;

method TDarDeBaja.AjustarDecimalesSUM(Valor: double): double;
begin
   result := Math.Round(Valor, GlobalSettings.LocalCurr_Dec, MidpointRounding.AwayFromZero );
end;

method TDarDeBaja.AjustarDecimalesSUMSys(Valor: double): double;
begin
   result := Math.Round(Valor, FGlobalSettings.SysCurr_Dec, MidpointRounding.AwayFromZero );
end;

end.