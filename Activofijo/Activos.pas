﻿namespace AF_IFRS.Activos;

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

{$DEFINE ShowDelay}
{$UNDEF ShowDelay}

type
  TActivos = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet      : SAPbobsCOM.Recordset;
    oCompanyService : SAPbobsCOM.CompanyService;
    Lista        : List<String>;
    lev1_RefPos  : Integer;
    lev2_RefPos  : Integer;
    PaneLevelFin : Integer;
    SaltoPeriodo : Integer;
    Bis33Flg     : boolean;
    Valor_resid  : Double;
    OldActTipo   : String;
    oSBObob      : SAPbobsCOM.SBObob;
    oTxFinIni    : string;
    oTxRefIni    : string;
    oTxFinDep    : string;
    oTxRefDep    : string;
    method   LlenarFinanzasDesdeGrupo(oForm: SAPbouiCOM.Form);
    method   LlenarFinanzas(oForm: SAPbouiCOM.Form);
    method   LimpiarFinanzas(oForm: SAPbouiCOM.Form);
    method   ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
    method   SetVisibilidad(oForm: SAPbouiCOM.Form);
    method   SetMatrixIFRSView(oForm: SAPbouiCOM.Form);
    method   VisualizarTipoActivo(oForm: SAPbouiCOM.Form);
    method   AddChooseFromList(oForm: SAPbouiCOM.Form);
    method   SetCamposAdicionales(oForm: SAPbouiCOM.Form);
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

method TActivos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm     : SAPbouiCOM.Form;
   oMatrixAC : SAPbouiCOM.Matrix;
   ForceExit : Boolean; 
   oSql      : string;

  {$IFDEF ShowDelay} ts: TimeSpan; {$ENDIF}
  {$IFDEF ShowDelay} di: DateTime; {$ENDIF}
begin
   {$IFDEF ShowDelay} di := DateTime.Now; {$ENDIF}
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 01 -> ' + ts.ToString); {$ENDIF}
   Lista      := new List<String>;
   OldActTipo := '';
   VID_UsePaneAuto := False;

   try
      try
         if (FCmpny.language = BoSuppLangs.ln_English) then
            FSBOf.LoadForm(xmlPath,'VID_Activos_EN.srf', Uid)
         else
            FSBOf.LoadForm(xmlPath,'VID_Activos.srf', Uid);
         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 01 -> ' + ts.ToString); {$ENDIF}

         oForm := FSBOApp.Forms.Item(uid);
         oForm.Freeze(True);
         oForm.AutoManaged    := True;
         oForm.SupportedModes := -1;             // afm_All
         oForm.Mode           := SAPbouiCOM.BoFormMode.fm_FIND_MODE;

         lev1_RefPos := oForm.Items.Item('tx_RefIni').Left;
         lev2_RefPos := oForm.Items.Item('tx_RefDep').Left;

         oForm.DataSources.DBDataSources.Add('@VID_AFCAD');

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

         oForm.DataSources.UserDataSources.Add('DSEmpName',SAPbouiCOM.BoDataType.dt_LONG_TEXT,100);
         EditText(oForm.Items.Item('EmpName').Specific).DataBind.SetBound(true,'','DSEmpName');

         oForm.DataSources.UserDataSources.Add('DSValResi' ,SAPbouiCOM.BoDataType.dt_SUM,12);
         oForm.DataSources.UserDataSources.Add('DSValNeto' ,SAPbouiCOM.BoDataType.dt_SUM,12);
         EditText(oForm.Items.Item('ValorResi').Specific).DataBind.SetBound(true,'','DSValResi' );
         EditText(oForm.Items.Item('ValorNeto').Specific).DataBind.SetBound(true,'','DSValNeto' );
   //***
         oForm.DataSources.UserDataSources.Add('DSValResiR',SAPbouiCOM.BoDataType.dt_SUM,12);
         oForm.DataSources.UserDataSources.Add('DSValNetoR',SAPbouiCOM.BoDataType.dt_SUM,12);
         EditText(oForm.Items.Item('ValorResiR').Specific).DataBind.SetBound(true,'','DSValResiR');
         EditText(oForm.Items.Item('ValorNetoR').Specific).DataBind.SetBound(true,'','DSValNetoR');

         SAPbouiCOM.CheckBox(oForm.Items.Item('ConDepre').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('ConDepre').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('ConCorre').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('ConCorre').Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('DeBaja'  ).Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('DeBaja'  ).Specific).ValOff := 'N';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Flg').Specific).ValOn  := 'Y';
         SAPbouiCOM.CheckBox(oForm.Items.Item('Bis33Flg').Specific).ValOff := 'N';
         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 02 -> ' + ts.ToString); {$ENDIF}

                              // Ok Ad  Fnd Vw Rq Sec
{
//Estos campos deben estar siempre deshabilitados

         Lista.Add( 'ItemName ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'DeBaja   ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'InitYear ,  f,  f,  f,  f, r, 1 ');
         Lista.Add( 'InitPer  ,  f,  f,  f,  f, r, 1 ');
         Lista.Add( 'LocName  ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'VidaUtiR ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'CurValR  ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'DepAcuR  ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'CorAnuAR ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'CorAnuDR ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'DepreAnR ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'PRrDepre ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'VidaUtil ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'PerDepre ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'NextYear ,  f,  f,  f,  f, r, 1 ');
         Lista.Add( 'NextPer  ,  f,  f,  f,  f, r, 1 ');
         Lista.Add( 'CurVal   ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'DepAcum  ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'CorAnuAc ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'CorAnuDe ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'DepreAnu ,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'Mx_Adicion,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'MxVID_AFAC,  f,  f,  f,  f, n, 1 ');
         Lista.Add( 'MxVID_AFSA,  f,  f,  f,  f, n, 1 ');

}
         Lista.Add( 'ActCode  ,  f,  t,  t,  f, r, 1 ');
         Lista.Add( 'ActName  ,  f,  t,  t,  f, r, 1 ');
         Lista.Add( 'ActTipo  ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'ItemCode ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'ItmGrpCd ,  t,  t,  t,  f, n, 1 ');
         Lista.Add( 'ConDepre ,  t,  t,  f,  f, r, 1 ');
         Lista.Add( 'ConCorre ,  t,  t,  f,  f, r, 1 ');
         Lista.Add( 'InDate   ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'PerVidaU ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'NxYrDepr ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'NxPrDepr ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'NxYrCorr ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'NxPrCorr ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'EmpId    ,  t,  t,  t,  f, n, 1 ');
         Lista.Add( 'LocCode  ,  t,  t,  t,  f, n, 1 ');

         Lista.Add( 'OriVal   ,  f,  t,  f,  f, n, 1');
         Lista.Add( 'OriFec   ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'OriValCo ,  f,  t,  f,  f, n, >0');
         Lista.Add( 'PorResid ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'OriPerDp ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'OriDepre ,  f,  t,  f,  f, n, l');
         Lista.Add( 'InvDate  ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'InvNum   ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'InvLine  ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'TasaCnMS ,  f,  t,  f,  f, n, 1 ');

         Lista.Add( 'CtaActFi ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaCorAF ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaCorDA ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaDepAc ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaGasDe ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaGasBj ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaAdqAc ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'CtaReaAF ,  f,  t,  f,  f, n, 1');
         Lista.Add( 'CtaDetAF ,  f,  t,  f,  f, n, 1');

         Lista.Add( 'OriValCR ,  f,  t,  f,  f, n, >0');
         Lista.Add( 'PerVidaR ,  f,  t,  f,  f, r, 1 ');
         Lista.Add( 'OriPerDR ,  f,  t,  f,  f, n, 1 ');
         Lista.Add( 'OriDeprR ,  f,  t,  f,  f, n, l');
         Lista.Add( 'PorResiR ,  f,  t,  f,  f, n, 1 ');

         Lista.Add( 'Bis33Flg ,  f,  t,  f,  f, n, 1 ');

         Lista.Add( 'Mx_Compo  ,  t,  t,  f,  f, n, 1 ');
         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 03 -> ' + ts.ToString); {$ENDIF}

         FSBOf.SetAutoManaged(oForm, Lista);
         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 04 -> ' + ts.ToString); {$ENDIF}

         oForm.Items.Item('TabDatos').AffectsFormMode := false;
         oForm.Items.Item('TabDepre').AffectsFormMode := false;
         oForm.Items.Item('TabFinan').AffectsFormMode := false;
         oForm.Items.Item('TabAdiCom').AffectsFormMode := false;
         oForm.Items.Item('TabActiv').AffectsFormMode := false;
         oForm.Items.Item('TabSaldo').AffectsFormMode := false;
         oForm.Items.Item('tabFldAdic').AffectsFormMode := false;
         oForm.Items.Item('tab_ActRef').AffectsFormMode := false;
         oForm.Items.Item('tab_ActFin').AffectsFormMode := false;
         oForm.Items.Item('tab_AnuRef').AffectsFormMode := false;
         oForm.Items.Item('tab_AnuFin').AffectsFormMode := false;
         oForm.Items.Item('Mx_Adicion').AffectsFormMode := false;
         oForm.Items.Item('Mx_Compo'  ).AffectsFormMode := false;
         oForm.Items.Item('MxVID_AFAC').AffectsFormMode := false;
         oForm.Items.Item('MxVID_AFSA').AffectsFormMode := false;

         oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFAC').Specific);
         oMatrixAC.Columns.Item('PostFlag').ValOn  := 'Y';
         oMatrixAC.Columns.Item('PostFlag').ValOff := 'N';

         oMatrixAC.Columns.Item('DeprNom' ).Editable := false;
         oMatrixAC.Columns.Item('CorrDepM').Editable := false;

         oMatrixAC := Matrix(oForm.Items.Item('Mx_AFACR').Specific);
         oMatrixAC.Columns.Item('DeprNom' ).Editable := false;
         oMatrixAC.Columns.Item('CorrDepM').Editable := false;

         LinkedButton(oForm.Items.Item('LnLocCode').Specific).LinkedObject := SAPbouiCOM.BoLinkedObject.lf_None;

         oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         // Es Activo Fijo - SBO 9.0
         oCompanyService := company.GetCompanyService;

         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 05 -> ' + ts.ToString); {$ENDIF}
         // Params
         ForceExit := false;

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select U_UsarProj, U_Repomo, U_PlanIFRS, U_Jmp1Depr, U_Bis33Flg, U_Bis33Fin, U_ValResid, U_ActCamAd, U_UtiDepUs, U_ConMSCFi, U_PostSysCu from [@VID_AFPA]",
                     'Select "U_UsarProj", "U_Repomo", "U_PlanIFRS", "U_Jmp1Depr", "U_Bis33Flg", "U_Bis33Fin", "U_ValResid", "U_ActCamAd", "U_UtiDepUs", "U_ConMSCFi", "U_PostSysCu" from "@VID_AFPA"');
         oRecordSet.DoQuery(oSql);
         if (oRecordSet.EoF) then begin
            FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.NO_Parametros], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            oForm.Close;
            ForceExit := true;
            exit;
         end;

         if (System.String(oRecordSet.Fields.Item('U_ActCamAd').Value) = 'Y') then begin
            oForm.Items.Item('tabFldAdic' ).Visible := True;
            SetCamposAdicionales(oForm);
         end
         else 
            oForm.Items.Item('tabFldAdic' ).Visible := false;

         if (System.String(oRecordSet.Fields.Item('U_Bis33Flg').Value) = 'Y') then begin
            Bis33Flg := true;
            oForm.Items.Item('TxBis33' ).Visible := True;
            oForm.Items.Item('Bis33'   ).Visible := True;
            if (not GlobalSettings.IFRSActivo) or (GlobalSettings.IFRSActivo and (not GlobalSettings.IFRSNativo)) then
               oForm.Items.Item('Bis33Fin').Visible := True;
         end
         else begin
            Bis33Flg := false;
            oForm.Items.Item('TxBis33' ).Visible := False;
            oForm.Items.Item('Bis33'   ).Visible := False;
            oForm.Items.Item('Bis33Fin').Visible := False;
         end;

         if (System.String(oRecordSet.Fields.Item('U_UtiDepUs').Value) = 'Y') then begin
            Bis33Flg := true;
            oForm.Items.Item('txTipoDep').Visible := True;
            oForm.Items.Item('TipoDep'  ).Visible := True;
            oForm.Items.Item('TipoDepR' ).Visible := True;
         end
         else begin
            Bis33Flg := false;
            oForm.Items.Item('txTipoDep').Visible := False;
            oForm.Items.Item('TipoDep'  ).Visible := False;
            oForm.Items.Item('TipoDepR' ).Visible := False;
         end;

         if (System.String(oRecordSet.Fields.Item('U_Bis33Fin').Value) = 'Y') and (Bis33Flg) and ((not GlobalSettings.IFRSActivo)  or (GlobalSettings.IFRSActivo and (not GlobalSettings.IFRSNativo))) then begin
            oForm.Items.Item('LnCtaBis33').Visible := true;
            oForm.Items.Item('TxCtaBis33').Visible := true;
            oForm.Items.Item('FmtBis33'  ).Visible := true;
            oForm.Items.Item('DescBis33' ).Visible := true;
         end
         else begin
            oForm.Items.Item('LnCtaBis33').Visible := false;
            oForm.Items.Item('TxCtaBis33').Visible := false;
            oForm.Items.Item('FmtBis33'  ).Visible := false;
            oForm.Items.Item('DescBis33' ).Visible := false;
         end;

         // Contabilizar en moneda del sistema
         oTxFinIni := StaticText(oForm.Items.Item('tx_FinIni').Specific).Caption;
         oTxRefIni := StaticText(oForm.Items.Item('tx_RefIni').Specific).Caption;
         oTxFinDep := StaticText(oForm.Items.Item('tx_FinDep').Specific).Caption;
         oTxRefDep := StaticText(oForm.Items.Item('tx_RefDep').Specific).Caption;
         if (System.String(oRecordSet.Fields.Item('U_PostSysCu').Value) = 'Y') then begin
            StaticText(oForm.Items.Item('tx_FinIni').Specific).Caption := oTxFinIni + " (" + FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency + ")";
            StaticText(oForm.Items.Item('tx_RefIni').Specific).Caption := oTxRefIni + " (" + FCmpny.GetCompanyService.GetAdminInfo.LocalCurrency + ")";
            StaticText(oForm.Items.Item('tx_FinDep').Specific).Caption := oTxFinDep + " (" + FCmpny.GetCompanyService.GetAdminInfo.SystemCurrency + ")";
            StaticText(oForm.Items.Item('tx_RefDep').Specific).Caption := oTxRefDep + " (" + FCmpny.GetCompanyService.GetAdminInfo.LocalCurrency + ")";
         end;

         // Contabilar Moneda de sistema con cambio fijo
         if (System.String(oRecordSet.Fields.Item('U_ConMSCFi').Value) = 'Y') then begin
            oForm.Items.Item('txTasaCam').Visible := True;
            oForm.Items.Item('TasaCnMS'  ).Visible := True;
         end
         else begin
            oForm.Items.Item('txTasaCam').Visible := false;
            oForm.Items.Item('TasaCnMS'  ).Visible := false;
         end;

         SaltoPeriodo := System.Int32(oRecordSet.Fields.Item('U_Jmp1Depr').Value);
         if (SaltoPeriodo < 0) then
            SaltoPeriodo := 0;

         Valor_Resid := System.Double(oRecordSet.Fields.Item('U_ValResid').Value);
 
         if (GlobalSettings.IFRSActivo) and (GlobalSettings.IFRSNativo) then begin
            oForm.Items.Item('PxActTipo').Visible := True;
            oForm.Items.Item('ActTipo'  ).Visible := True;
         end
         else begin
            oForm.Items.Item('PxActTipo').Visible := False;
            oForm.Items.Item('ActTipo'  ).Visible := False;
         end;
         if (GlobalSettings.IFRSActivo) and (GlobalSettings.IFRSNativo) then 
            PaneLevelFin := 4
         else 
            PaneLevelFin := 3;

         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 06 -> ' + ts.ToString); {$ENDIF}
         // Repomo
         if (System.String(oRecordSet.Fields.Item('U_Repomo').Value).Trim = 'Y') then begin
            oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFAC').Specific);
            oMatrixAC.Columns.Item('DeprNom').Visible := true;
            oMatrixAC := Matrix(oForm.Items.Item('Mx_AFACR').Specific);
            oMatrixAC.Columns.Item('DeprNom').Visible := true;
         end
         else begin
            oMatrixAC := Matrix(oForm.Items.Item('MxVID_AFAC').Specific);
            oMatrixAC.Columns.Item('DeprNom').Visible := false;
            oMatrixAC := Matrix(oForm.Items.Item('Mx_AFACR').Specific);
            oMatrixAC.Columns.Item('DeprNom').Visible := false;
         end;

         // Project
         if (System.String(oRecordSet.Fields.Item('U_UsarProj').Value).Trim = 'N') then begin
            oForm.Items.Item('tx_project').Enabled := false;
            oForm.Items.Item('Project').Enabled    := false;
            oForm.Items.Item('tx_project').Width := -1;
            oForm.Items.Item('Project').Width    := -1;
         end
         else begin
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select prjcode code, prjname name from OPRJ where prjcode <> '' order by name", 
                        'Select "PrjCode" "code", "PrjName" "name" from "OPRJ" where "PrjCode" <> '''' order by "PrjName"');
            oRecordSet.DoQuery(oSql);
            FSBOf.FillCombo(ComboBox(oForm.Items.Item('Project').Specific), var oRecordSet, true);
         end;

         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 07 -> ' + ts.ToString); {$ENDIF}
         // ProfitCt
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select ocrcode code, ocrname name from OOCR where DimCode = 1 order by name", 
                     'Select "OcrCode" "code", "OcrName" "name" from OOCR where "DimCode" = 1 order by "OcrName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitCt').Specific), var oRecordSet, true);
         // ProfitC2
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select ocrcode code, ocrname name from OOCR where DimCode = 2 order by name", 
                     'Select "OcrCode" "code", "OcrName" "name" from OOCR where "DimCode" = 2 order by "OcrName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitC2').Specific), var oRecordSet, true);
         // ProfitC3
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select ocrcode code, ocrname name from OOCR where DimCode = 3 order by name", 
                     'Select "OcrCode" "code", "OcrName" "name" from OOCR where "DimCode" = 3 order by "OcrName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitC3').Specific), var oRecordSet, true);
         // ProfitC4
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select ocrcode code, ocrname name from OOCR where DimCode = 4 order by name", 
                     'Select "OcrCode" "code", "OcrName" "name" from OOCR where "DimCode" = 4 order by "OcrName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitC4').Specific), var oRecordSet, true);
         // ProfitC5
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select ocrcode code, ocrname name from OOCR where DimCode = 5 order by name", 
                     'Select "OcrCode" "code", "OcrName" "name" from OOCR where "DimCode" = 5 order by "OcrName"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('ProfitC5').Specific), var oRecordSet, true);

         // Grupos activos
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select  code,  name from [@VID_AFGR] order by name", 
                     'Select  "Code" "code",  "Name" "name" from "@VID_AFGR" order by "Name"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('ItmGrpCd').Specific), var oRecordSet, true);

         // visibilidad IFRS
         SetMatrixIFRSView(oForm);

         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 08 -> ' + ts.ToString); {$ENDIF}
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
         EditText(oForm.Items.Item('FmtGasBj').Specific).ChooseFromListUID   := 'CFL51';
         EditText(oForm.Items.Item('FmtGasBj').Specific).ChooseFromListAlias := 'FormatCode';
         EditText(oForm.Items.Item('FmtAdqAc').Specific).ChooseFromListUID   := 'CFL52';
         EditText(oForm.Items.Item('FmtAdqAc').Specific).ChooseFromListAlias := 'FormatCode';
         EditText(oForm.Items.Item('FmtReaAF').Specific).ChooseFromListUID   := 'CFL53';
         EditText(oForm.Items.Item('FmtReaAF').Specific).ChooseFromListAlias := 'FormatCode';
         EditText(oForm.Items.Item('FmtDetAF').Specific).ChooseFromListUID   := 'CFL54';
         EditText(oForm.Items.Item('FmtDetAF').Specific).ChooseFromListAlias := 'FormatCode';
         EditText(oForm.Items.Item('FmtBis33').Specific).ChooseFromListUID   := 'CFL10';
         EditText(oForm.Items.Item('FmtBis33').Specific).ChooseFromListAlias := 'FormatCode';

         EditText(oForm.Items.Item('ItemCode').Specific).ChooseFromListUID   := 'CFL6';
         EditText(oForm.Items.Item('ItemCode').Specific).ChooseFromListAlias := 'ItemCode';
         EditText(oForm.Items.Item('EmpId').Specific).ChooseFromListUID      := 'CFL7';
         EditText(oForm.Items.Item('EmpId').Specific).ChooseFromListAlias    := 'EmpId';
         EditText(oForm.Items.Item('LocCode').Specific).ChooseFromListUID    := 'CFL9';
         EditText(oForm.Items.Item('LocCode').Specific).ChooseFromListAlias  := 'Code';

         oSBObob := SBObob(FCmpny.GetBusinessObject(BoObjectTypes.BoBridge));

         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 09 -> ' + ts.ToString); {$ENDIF}
         oForm.PaneLevel := 1;
         oForm.DataBrowser.BrowseBy := 'ActCode';
         oForm.Update;
         {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 10 -> ' + ts.ToString); {$ENDIF}
     finally
         if (not ForceExit) then
            oForm.Freeze(False);
         oForm.Visible := true;
     end;
  except
   on e:exception do begin
      FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      OutLog('InitForm: ' + e.Message + ' - ' + e.StackTrace);
      oForm.Visible := true;
   end;
   end;
end;

method TActivos.AddChooseFromList(oForm: SAPbouiCOM.Form);
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
   oCFLCreationParams.UniqueID   := 'CFL51';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL52';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL53';
   oCFL := oCFLs.Add(oCFLCreationParams);

   oCons := oCFL.GetConditions();
   oCon := oCons.Add();
   oCon.Alias := 'Postable';
   oCon.Operation := BoConditionOperation.co_EQUAL;
   oCon.CondVal := 'Y';
   oCFL.SetConditions(oCons);

   oCFLCreationParams.MultiSelection := False;
   oCFLCreationParams.ObjectType := '1';    // 1 => Charts of accounts
   oCFLCreationParams.UniqueID   := 'CFL54';
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

method   TActivos.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
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
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').Clear;
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').InsertRecord(0);
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

method   TActivos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMatrixCo       : SAPbouiCOM.Matrix;
   oDBDS           : SAPbouiCOM.DBDataSource;
   i               : integer;
   sValue          : string;
   s               : string;
   oSql            : string;
   oFormIvk        : IvkFormInterface;
   y,m,d           : integer;
   Yr, Pr          : integer;
   oDataTable      : SAPbouiCOM.DataTable;
   oActTipo        : String; 

  {$IFDEF ShowDelay} ts: TimeSpan; {$ENDIF}
  {$IFDEF ShowDelay} di: DateTime; {$ENDIF}
begin
   {$IFDEF ShowDelay} di := DateTime.Now; {$ENDIF}
   {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' init Event ' + pVal.EventType.ToString + ' -> ' + ts.ToString); {$ENDIF}
   try

   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 000 Event ' + pVal.EventType.ToString + ' -> ' + ts.ToString); {$ENDIF}
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm           := FSBOApp.Forms.Item(pVal.FormUID);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 111 Event ' + pVal.EventType.ToString + ' -> ' + ts.ToString); {$ENDIF}
   oMatrixCo       := Matrix(oForm.Items.Item('Mx_Compo').Specific);
   oDBDS           := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFAS'));
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 222 Event ' + pVal.EventType.ToString + ' -> ' + ts.ToString); {$ENDIF}

   try
      oForm.Freeze(True);

      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' 00 Event ' + pVal.EventType.ToString + ' -> ' + ts.ToString); {$ENDIF}
      if (not EnableValidate) then
         exit;

      if (pVal.EventType = BoEventTypes.et_FORM_CLOSE) and (not cancelingForm) then begin
         BubbleEvent := false;
         FSBOApp.StatusBar.SetText('Utilizar boton cancelar', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;

      // CFL
      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = 'FmtActFi') or (pVal.ItemUID = 'FmtCorAF') or
            (pVal.ItemUID = 'FmtCorDA') or (pVal.ItemUID = 'FmtDepAc') or
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
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select ItemName from OITM where  ItemCode = '{0}'", 
                        'Select "ItemName" from OITM where  "ItemCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
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
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select empid, firstName, lastName, branch from ohem where EmpId = '{0}'", 
                           'Select "empID", "firstName", "lastName", "branch" from OHEM where "empID" = ''{0}''');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
               s := System.String(oRecordSet.Fields.Item('lastName').Value) + ', ' +
                    System.String(oRecordSet.Fields.Item('firstName').Value);
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
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaActFi', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtCorAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescCoAF').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtCorAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaCorAF', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtCorDA') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescCoDA').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtCorDA').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaCorDA', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtDepAc') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaDepAc', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtGasDe') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaGasDe', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtGasBj') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaGasBj', 0, sValue);
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
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaAdqAc', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtReaAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaReaAF', 0, sValue);
         end;
         if (pVal.ItemUID = 'FmtDetAF') then begin
            oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
            try
               sValue  := System.String(oDataTable.GetValue('AcctCode', 0));
            except
               ;
            end;
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaDetAF', 0, sValue);
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
                        'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oForm.DataSources.UserDataSources.Item('DDescBis33').ValueEx := System.String(oRecordSet.Fields.Item('AcctName').Value);
            oForm.DataSources.UserDataSources.Item('DSFmtBis33').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(sValue, true).Fields.Item(int32(0)).Value);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaBis33', 0, sValue);
         end;
      end;


      // Validación de valores
      if ( pVal.EventType = BoEventTypes.et_VALIDATE ) and ( pVal.BeforeAction = true ) and
              ( (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) or (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) ) then begin
         // ActCode
         if (pVal.ItemUID = 'ActCode') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (system.String(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ConDepre', 0)) = '') then
               oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ConDepre',0,'N');
            if (system.String(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ConCorre', 0)) = '') then
               oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ConCorre',0,'N');
            if (system.String(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DeBaja', 0)) = '') then
               oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_DeBaja',0,'N');
            if (sValue = '') then
               BubbleEvent     := true
            else begin
               oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select Count(*) cant from [@VID_AFAS] where U_ActCode = '{0}'", 
                           'Select Count(*) "cant" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
               oSql := string.Format(oSql, sValue);
               oRecordSet.DoQuery(oSql);
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

                  oDBDS.SetValue('U_NxYrDepr', 0 , TMultiFunctions.inttostr(y + (m + SaltoPeriodo - 1) div 12));
                  oDBDS.SetValue('U_NxYrCorr', 0 , TMultiFunctions.inttostr(y + (m + SaltoPeriodo - 1) div 12));
                  i := (m + SaltoPeriodo) mod 12;
                  if (i = 0) then
                     i := 12;
                  oDBDS.SetValue('U_NxPrDepr', 0 , TMultiFunctions.inttostr(i));
                  oDBDS.SetValue('U_NxPrCorr', 0 , TMultiFunctions.inttostr(i));

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
         // NxYrCorr
         if (pVal.ItemUID = 'NxYrCorr') then begin
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
               Yr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxYrCorr').Specific).Value);
               Pr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxPrCorr').Specific).Value);
               if ( Yr < y) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Cor_Anterior_Ingreso], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxYrCorr', 0, TMultiFunctions.inttostr(Yr));
               end
               else if (Yr = y) and (Pr < m) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Cor_Anterior_Ingreso_Per], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxPrCorr', 0, TMultiFunctions.inttostr(Pr));
               end
               else
                  BubbleEvent    := true;
            end;
         end;
         // NxPrCorr
         if (pVal.ItemUID = 'NxPrCorr') then begin
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
            else if (EditText(oForm.Items.Item('NxYrCorr').Specific).Value = '') then begin
               FSBOApp.StatusBar.SetText('Año primera correción sin datos', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               BubbleEvent     := true;
            end
            else begin
               y := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Year;
               m := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Month;
               d := FSBOf.StrToDate(EditText(oForm.Items.Item('InDate').Specific).Value).Day;
               Yr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxYrCorr').Specific).Value);
               Pr := FSBOf.StrToInteger(EditText(oForm.Items.Item('NxPrCorr').Specific).Value);
               if ( Yr < y) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Cor_Anterior_Ingreso], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxYrCorr', 0, TMultiFunctions.inttostr(Yr));
               end
               else if (Yr = y) and (Pr < m) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Primera_Cor_Anterior_Ingreso_Per], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  oDBDS.SetValue('U_NxPrCorr', 0, TMultiFunctions.inttostr(Pr));
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
//***         // PerVidaR
         if (pVal.ItemUID = 'PerVidaR') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (TMultiFunctions.StrToInt(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Vida_Cero], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (TMultiFunctions.StrToInt(svalue) < FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDR').Specific).Value)) then
               FSBOApp.StatusBar.SetText('Depreciación original no puede ser mayor que la vida util.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               oDBDS.SetValue('U_PRrDepre',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDR').Specific).Value)));
               oDBDS.SetValue('U_VidaUtiR',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('PerVidaR').Specific).Value) -
                                                       FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDR').Specific).Value)));
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
//***         // OriPerDR
         if (pVal.ItemUID = 'OriPerDR') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (TMultiFunctions.StrToInt(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Depreciación original no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else if (TMultiFunctions.StrToInt(svalue) > FSBOf.StrToInteger(EditText(oForm.Items.Item('PerVidaR').Specific).Value)) then
               FSBOApp.StatusBar.SetText('Depreciación original no puede ser mayor que la vida util.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               oDBDS.SetValue('U_PRrDepre',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDR').Specific).Value)));
               oDBDS.SetValue('U_VidaUtiR',0, TMultiFunctions.inttostr(FSBOf.StrToInteger(EditText(oForm.Items.Item('PerVidaR').Specific).Value) -
                                                                                                   FSBOf.StrToInteger(EditText(oForm.Items.Item('OriPerDR').Specific).Value)));
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
//            else if (FSBOf.StrToDouble(svalue) > FSBOf.StrToDouble(EditText(oForm.Items.Item('OriValCo').Specific).Value)) and  // se deja comentado 20200811, conversado con Andres Hermosilla por error en Froward
//                    (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriValCo').Specific).Value) <> 0) then
//               FSBOApp.StatusBar.SetText('Valor de compra no puede ser mayor a valor de compra corregido.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               if (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriValCo').Specific).Value) = 0) then begin
                  oDBDS.SetValue('U_OriValCo', 0, sValue);
//***
                  oDBDS.SetValue('U_OriValCR', 0, sValue);
                  oDBDS.SetValue('U_CurVal'  , 0, sValue);
                  oDBDS.SetValue('U_CurValR' , 0, sValue);
               end;
               BubbleEvent     := true;
            end;
         end;

         // OriValCo
         if (pVal.ItemUID = 'OriValCo') then begin
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
                  oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_OriVal', 0, sValue);
               oDBDS.SetValue('U_CurVal', 0, sValue);
               BubbleEvent     := true;
            end;
         end;
//***         // OriValCR
         if (pVal.ItemUID = 'OriValCR') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (FSBOf.StrToDouble(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Valor de compra corregido no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               if (FSBOf.StrToDouble(svalue) < FSBOf.StrToDouble(EditText(oForm.Items.Item('OriVal').Specific).Value)) then
                  FSBOApp.StatusBar.SetText('Valor de compra es menor a valor de compra corregido.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               if (FSBOf.StrToDouble(EditText(oForm.Items.Item('OriVal').Specific).Value) = 0) then
                  oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_OriVal', 0, sValue);
               oDBDS.SetValue('U_CurValR', 0, sValue);
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
//***         // OriDeprR
         if (pVal.ItemUID = 'OriDeprR') then begin
            BubbleEvent     := False;
            sValue          := EditText(oForm.Items.Item(pVal.ItemUID).Specific).Value;
            if (sValue = '') then
               BubbleEvent     := true
            else if (FSBOf.StrToDouble(svalue) < 0 ) then
               FSBOApp.StatusBar.SetText('Depreciación corregida no puede ser menor a 0.', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
            else begin
               oDBDS.SetValue('U_DepAcuR', 0, sValue);
               BubbleEvent     := true;
            end;
         end;
      end;


      if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = 'ItmGrpCd')  then begin
            if (not oForm.Items.Item('InDate').Enabled) then begin
               if (1 <> FSBOApp.MessageBox('Modificar el grupo, cambiará la contabilización del activo. ¿Desea continuar?', 2, 'Ok', 'Cancelar','')) then
                  BubbleEvent := false;
            end;
            FSBOApp.StatusBar.SetText('Modificar el grupo, cambiara la contabilización del activo', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
         end
         else if (pVal.ItemUID = 'ActTipo')  then begin
            if (1 <> FSBOApp.MessageBox('Modificar el tipo de activo, cambiará sus características. ¿Desea continuar?', 2, 'Ok', 'Cancelar','')) then
               BubbleEvent := false;
         end
      end

      else if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (pVal.BeforeAction = False) then begin
         if (pVal.ItemUID = 'ItmGrpCd')  then begin
            sValue  := oDBDS.GetValue('U_ItmGrpCd', 0);
            if (sValue <> '') then begin
               LlenarFinanzasDesdeGrupo(oForm);
               LlenarFinanzas(oForm);
            end;
         end
         else if (pVal.ItemUID = 'ActTipo') and (GlobalSettings.IFRSNativo) then begin
            sValue  := oDBDS.GetValue('U_ActTipo', 0);
            if (sValue <> '') then begin
               VisualizarTipoActivo(oForm);
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) then begin
         oActTipo := '';
         if (GlobalSettings.IFRSNativo) then begin
            oActTipo := oDBDS.GetValue('U_ActTipo', 0);
            if (oActTipo = '') then
               oActTipo := 'N';
         end;

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
         end
         else if  (pVal.ItemUID = 'TabDatos') then begin
            oForm.PaneLevel := 1;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabDepre') then begin
            oForm.PaneLevel := 2;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabFinan') then begin
            oForm.PaneLevel := PaneLevelFin;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabAdiCom') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '1';
            oForm.PaneLevel := 7;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabActiv') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '1';
            oForm.PaneLevel := 9;
            if (GlobalSettings.IFRSNativo) and (oActTipo = 'T') then
               oForm.PaneLevel := 10;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'TabSaldo') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '1';
            oForm.PaneLevel := 11;
            if (GlobalSettings.IFRSNativo) and (oActTipo = 'T') then
               oForm.PaneLevel := 12;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'tabFldAdic') then begin
            oForm.PaneLevel := 21
         end
         else if  (pVal.ItemUID = 'tab_adic') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '1';
            oForm.PaneLevel := 7;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'tab_comp') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '2';
            oForm.PaneLevel := 8;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'tab_ActFin') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '1';
            oForm.PaneLevel := 9;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'tab_ActRef') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '2';
            oForm.PaneLevel := 10;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'tab_AnuFin') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '1';
            oForm.PaneLevel := 11;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if  (pVal.ItemUID = 'tab_AnuRef') then begin
            oForm.DataSources.UserDataSources.Item('FolderDS2').ValueEx := '2';
            oForm.PaneLevel := 12;
//            FSBOf.ActPosFormBorde_VID(oForm);
         end
         else if (pVal.ItemUID = '1') and ((oForm.Mode = SAPbouiCOM.BoFormMode.fm_ADD_MODE) or (oForm.Mode = SAPbouiCOM.BoFormMode.fm_UPDATE_MODE)) then begin
            BubbleEvent := false;
            if (1 <> FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualizar_informacion_QM], 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(oForm)) then
               exit;
            if (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) then begin
               // oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               //             "Select AutoKey from ONNM where ObjectCode = 'VID_mAFAS'", 
               //             'Select "AutoKey" from ONNM where "ObjectCode" = ''VID_mAFAS''');
               // oRecordSet.DoQuery(oSql);
               // EditText(oForm.Items.Item('Code').Specific).String := TMultiFunctions.inttostr(System.Int32(oRecordSet.Fields.Item('AutoKey').Value));
               EditText(oForm.Items.Item('Code').Specific).Value := EditText(oForm.Items.Item('ActCode').Specific).Value; 
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
                 DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFCO')).Clear;
                oMatrixCo.AddRow(1, oMatrixCo.RowCount);
             end;
         end
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = SAPbouiCOM.BoFormMode.fm_ADD_MODE) or (oForm.Mode = SAPbouiCOM.BoFormMode.fm_UPDATE_MODE)) and
            (pVal.Action_Success) then begin
            LimpiarFinanzas(oForm);
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').Clear;
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').InsertRecord(0);
         end;
         if (pVal.ItemUID = 'Imprimir') then begin
            oFormIvk := IvkFormInterface(New TReportWindowFR_1);
            if (FCmpny.language = BoSuppLangs.ln_English) then
               TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptActivoFijo_EN.fr3'
            else
               TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptActivoFijo.fr3';

            TReportWindowFR_1(oFormIvk).ReportParams := ' -code "' + EditText(oForm.Items.Item('Code').Specific).value + '"';
            if(oFormIvk<>nil) then begin
               oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings);
               ooForms.Add(oFormIvk);
            end;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_DATASOURCE_LOAD) and (pVal.BeforeAction = false) then begin
{
          if (pVal.ItemUID = 'MxVID_AFAC') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFAC');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'MxVID_AFSA') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFSA');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'Mx_AFACR') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFACR');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'Mx_AFSAR') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFSAR');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'Mx_Adicion') then begin
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFAD');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (oDBDSAux.GetValue('Code', i).Trim = '') then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
          if (pVal.ItemUID = 'Mx_Compo') then begin
             // borrar componentes nulos
             oDBDSAux := oForm.DataSources.DBDataSources.Item('@VID_AFCO');
             i := 0;
             while (i <= oDBDSAux.Size-1) do begin
                if (FSBOf.StrToInteger(oDBDSAux.GetValue('U_Cantidad', i)) <= 0) then
                   oDBDSAux.RemoveRecord(i)
                else
                   inc(i);
             end;
          end;
};
      end;

    finally 
      oForm.Freeze(False);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' Event ' + pVal.EventType.ToString + ' -> ' + ts.ToString); {$ENDIF}
    end;
   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TActivos.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm   : SAPbouiCOM.Form;
   oDBDS   : SAPbouiCOM.DBDataSource;
   i       : integer;
  {$IFDEF ShowDelay} ts: TimeSpan; {$ENDIF}
  {$IFDEF ShowDelay} di: DateTime; {$ENDIF}
begin
   {$IFDEF ShowDelay} di := DateTime.Now; {$ENDIF}
   {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' DataEvent inicio -> ' + ts.ToString); {$ENDIF}
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);

   oForm   := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);

   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_ADD) and (BusinessObjectInfo.BeforeAction) then begin
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFAC");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end;
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFSA");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end; 
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFACR");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end;
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFSAR");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end; 
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFAD");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end;
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFCO");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end; 
      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFCAD");
      i := 0;
      while (i <= oDBDS.Size-1) do begin
         if (oDBDS.GetValue('Code', i).Trim = '') then
             oDBDS.RemoveRecord(i)
         else
             inc(i);
      end; 
   end
   else if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (not BusinessObjectInfo.BeforeAction) and (BusinessObjectInfo.ActionSuccess) then begin
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' DataEvent Data_Load inicio  -> ' + ts.ToString); {$ENDIF}
      LimpiarFinanzas(oForm);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' DataEvent Data_Load LimpiarFinanzas -> ' + ts.ToString); {$ENDIF}
      LlenarFinanzas(oForm);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' DataEvent Data_Load LlenarFiananzas -> ' + ts.ToString); {$ENDIF}
      SetVisibilidad(oForm);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' DataEvent Data_Load SetVisibilidad -> ' + ts.ToString); {$ENDIF}
      VisualizarTipoActivo(oForm);
      {$IFDEF ShowDelay} ts := DateTime.Now.Subtract(di); OutLog(' DataEvent Data_Load VisualizarTipoActivo -> ' + ts.ToString); {$ENDIF}
   end;
end;

method TActivos.LlenarFinanzasDesdeGrupo(oForm: SAPbouiCOM.Form);
var
   s:       string;
   oSql:    string;
   oRecordSet1: SAPbobsCOM.Recordset;
begin
   try
      EnableValidate := false;
      s := oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ItmGrpCd', 0);
      oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select U_CtaActFi,U_CtaCorAF,U_CtaGasDe,U_CtaCorDA,U_CtaDepAc, U_CtaGasBj, U_CtaAdqAc, U_CtaReaAF, U_CtaDetAF, U_CtaBis33, U_VidaUtil, U_VidaUtiR " +
                  "  from [@VID_AFGR] where Code  = '{0}'", 
                  'Select "U_CtaActFi", "U_CtaCorAF", "U_CtaGasDe", "U_CtaCorDA", "U_CtaDepAc", "U_CtaGasBj", "U_CtaAdqAc", "U_CtaReaAF", "U_CtaDetAF", "U_CtaBis33", "U_VidaUtil", "U_VidaUtiR" ' +
                  '  from "@VID_AFGR" where "Code"  = ''{0}''');
      oSql := string.Format(oSql, s.Trim);
      oRecordSet1.DoQuery(oSql);
      oRecordSet1.MoveFirst;
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaCorAF',0,System.String(oRecordSet1.Fields.Item('U_CtaCorAF').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaGasDe',0,System.String(oRecordSet1.Fields.Item('U_CtaGasDe').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaCorDA',0,System.String(oRecordSet1.Fields.Item('U_CtaCorDA').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaActFi',0,System.String(oRecordSet1.Fields.Item('U_CtaActFi').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaDepAc',0,System.String(oRecordSet1.Fields.Item('U_CtaDepAc').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaGasBj',0,System.String(oRecordSet1.Fields.Item('U_CtaGasBj').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaAdqAc',0,System.String(oRecordSet1.Fields.Item('U_CtaAdqAc').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaReaAF',0,System.String(oRecordSet1.Fields.Item('U_CtaReaAF').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaDetAF',0,System.String(oRecordSet1.Fields.Item('U_CtaDetAF').Value));
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_CtaBis33',0,System.String(oRecordSet1.Fields.Item('U_CtaBis33').Value));
      if (oForm.Items.Item('InDate').Enabled) then begin
         EditText(oForm.Items.Item('VidaUtil').Specific).value := TMultiFunctions.IntToStr(System.Int32(oRecordSet1.Fields.Item('U_VidaUtil').Value));
         EditText(oForm.Items.Item('PerVidaU').Specific).value := TMultiFunctions.IntToStr(System.Int32(oRecordSet1.Fields.Item('U_VidaUtil').Value));
         EditText(oForm.Items.Item('VidaUtiR').Specific).value := TMultiFunctions.IntToStr(System.Int32(oRecordSet1.Fields.Item('U_VidaUtiR').Value));
         EditText(oForm.Items.Item('PerVidaR').Specific).value := TMultiFunctions.IntToStr(System.Int32(oRecordSet1.Fields.Item('U_VidaUtiR').Value));
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

method TActivos.LlenarFinanzas(oForm: SAPbouiCOM.Form);
var
   oRecordSet1 : SAPbobsCOM.Recordset;
   s           : string;
   oSql        : string;
   minYrRv     : integer;
   minPrRv     : integer;
   oCodeAct    : string;
   oCode       : string;
   NextYr      : integer;
   NextPr      : integer;
begin
   try
   try
     oform.Freeze(True);
      // llenar finanzas
      oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaActFi', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaCorAF', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescCoAF').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtCorAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaCorDA', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescCoDA').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtCorDA').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaDepAc', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaGasDe', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaGasBj', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaAdqAc', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaReaAF', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaDetAF', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

      s := TMultiFunctions.trim(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaBis33', 0));
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select AcctName, FormatCode from OACT where  AcctCode = '{0}'", 
                     'Select "AcctName", "FormatCode" from OACT where  "AcctCode" = ''{0}''');
         oSql := string.Format(oSql, s);
         oRecordSet1.DoQuery(oSql);
         oForm.DataSources.UserDataSources.Item('DDescBis33').ValueEx := System.String(oRecordSet1.Fields.Item('AcctName').Value);
         oForm.DataSources.UserDataSources.Item('DSFmtBis33').ValueEx := System.String(oSBObob.GetAccountSegmentsByCode(s, true).Fields.Item(int32(0)).Value);
      end;

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

      if (FSBOf.StringToDouble(oForm.DataSources.UserDataSources.Item('DSValResi').ValueEx) = 0.0) then
          oForm.DataSources.UserDataSources.Item('DSValResi').ValueEx := FSBOf.DoubleToStr(Valor_Resid);



      s := FSBOf.DoubleToStr( FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CurValR', 0))  +
                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CorAnuAR', 0)) +
                              FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_AdicAnuR', 0)) );
      oForm.DataSources.UserDataSources.Item('DSValNetoR').ValueEx := s;

      s := FSBOf.DoubleToStr( FSBOf.StrToDouble(s) -
                              (FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DepAcuR' , 0)) +
                               FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CorAnuDR', 0)) +
                               FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_Bis33'   , 0)) +
                               FSBOf.StrToDouble(oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_DepreAnR', 0)))   );
      oForm.DataSources.UserDataSources.Item('DSValResiR').ValueEx := s;
      if (FSBOf.StringToDouble(s) = 0.0) then
          oForm.DataSources.UserDataSources.Item('DSValResiR').ValueEx := FSBOf.DoubleToStr(Valor_Resid);

      s := EditText(oForm.Items.Item('EmpId').Specific).value;
      if (s <> '') then begin
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select empid, firstname, lastname, branch from ohem where EmpId =  {0}", 
                     'Select "empID", "firstName", "lastName", "branch" from OHEM Where "empID" = {0}');
         oSql := string.Format(oSql, s);
         oRecordSet.DoQuery(oSql);
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

   finally 
     oForm.Freeze(False);
   end;

   except
      on e:exception do begin
         OutLog('LlenarFinanzas : ' + e.Message + ' - ' + e.StackTrace );
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TActivos.LimpiarFinanzas(oForm: SAPbouiCOM.Form);
var
    oSql: string;
begin
   try
   try
     oForm.Freeze(True);

      EnableValidate := false;
      oForm.DataSources.UserDataSources.Item('DSDescAcFi').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescCoAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescCoDA').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescDeAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescGaDe').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescGaBj').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescAdAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescReAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSDescDeAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DDescBis33').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtActFi').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtCorAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtCorDA').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtDepAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtGasDe').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtGasBj').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtAdqAc').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtReaAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtDetAF').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSFmtBis33').ValueEx := '';
      oForm.DataSources.UserDataSources.Item('DSEmpName' ).ValueEx := '';
      EnableValidate := true;

      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ConDepre', 0) = '') then
         oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ConDepre', 0, 'Y');
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ConCorre', 0) = '') then
         oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ConCorre', 0, 'Y');

      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select U_Bis33Flg from [@VID_AFPA]", 
                  'Select "U_Bis33Flg" from "@VID_AFPA"');
      oRecordSet.DoQuery(oSql);
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_Bis33Flg', 0) = '') then begin
         if (System.String(oRecordSet.Fields.Item('U_Bis33Flg').Value) = 'Y') then
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_Bis33Flg', 0, 'Y')
         else
            oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_Bis33Flg', 0, 'N');
      end;

   finally 
     oForm.Freeze(False);
   end;
   except
      on e:exception do begin
         OutLog('Limpiar Finanzas : ' + e.Message + ' - ' + e.StackTrace );
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TActivos.ValidacionFinal(oForm: SAPbouiCOM.Form): boolean;
var
   s:      String;
   i:      Integer; 
   maxlin: Integer;
   oDSD:   SAPbouiCOM.DBDataSource;
begin
   result := false;          // esta condicion debe mejorarse
   s := FSBOf.VerificarItemsRequeridos(oForm, Lista);
   if (s <> '') then begin
      FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      exit;
   end;

   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ActTipo', 0) <> 'T') then begin
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaActFi', 0) = '') then begin
         FSBOApp.StatusBar.SetText('Cuenta de Activo Fijo requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaCorAF', 0) = '') and (not GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Cuenta de Corrección de Activo Fijo requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaCorDA', 0) = '') and (not GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Cuenta de Corrección Depreciación requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaDepAc', 0) = '') then begin
         FSBOApp.StatusBar.SetText('Cuenta de Depreciación Acumulada requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaGasDe', 0) = '') then begin
         FSBOApp.StatusBar.SetText('Cuenta de Gastos de Depreciación requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaGasBj', 0) = '') then begin
         FSBOApp.StatusBar.SetText('Cuenta de Gastos de Baja requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaAdqAc', 0) = '') then begin
         FSBOApp.StatusBar.SetText('Cuenta de Adquisición de Activos requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaReaAF', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Cuenta de Reavaluo de Activos requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_CtaDetAF', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Cuenta de Deterioro de Activos requerida.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
   end;

   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ActTipo', 0) <> 'T') then begin
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_OriValCo', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Valor de compra corregido es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_PorResid', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Valor residual es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_OriPerDp', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Periodos depreciados a fecha ingreso es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_OriDepre', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Depreciación corregida a fecha ingreso es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
   end
   else if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ActTipo', 0) <> 'I') then begin
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_OriValCR', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Valor de compra corregido es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_PorResiR', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Valor residual es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_OriPerDR', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Periodos depreciados a fecha ingreso es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
      if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_OriDeprR', 0) = '') and (GlobalSettings.IFRSNativo) then begin
         FSBOApp.StatusBar.SetText('Depreciación corregida a fecha ingreso es requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         result := false;
         exit;
      end;
   end;

   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitCt', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitCt', 0) = nil) then
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ProfitCt', 0, '');
   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC2', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC2', 0) = nil) then
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ProfitC2', 0, '');
   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC3', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC3', 0) = nil) then
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ProfitC3', 0, '');
   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC4', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC4', 0) = nil) then
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ProfitC4', 0, '');
   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC5', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ProfitC5', 0) = nil) then
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_ProfitC5', 0, '');
   if (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_Project', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_Project', 0) = nil) then
      oForm.DataSources.DBDataSources.Item('@VID_AFAS').SetValue('U_Project', 0, '');

   Matrix(oForm.Items.Item('Mx_Compo').Specific).FlushToDataSource;
   oDSD := oForm.DataSources.DBDataSources.Item('@VID_AFCO');
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

method TActivos.SetVisibilidad(oForm: SAPbouiCOM.Form);
var
   s   : string;
   oSql: string;
   i   : integer;
begin
   try
      oForm.Freeze(true);
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select Count(*) cant from [@vid_afac] where u_year is not null and code = '{0}'", 
                  'Select Count(*) "cant" from "@VID_AFAC" where "U_Year" is not null and "Code" = ''{0}''');
      oSql := string.Format(oSql, EditText(oForm.Items.Item('Code').Specific).value);
      oRecordSet.DoQuery(oSql);
      i := System.Int32(oRecordSet.Fields.Item('cant').Value);
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select Count(*) cant from [@vid_afacR] where u_year is not null and code = '{0}'", 
                  'Select Count(*) "cant" from "@VID_AFACR" where "U_Year" is not null and "Code" =  ''{0}''');
      oSql := string.Format(oSql, EditText(oForm.Items.Item('Code').Specific).value);
      oRecordSet.DoQuery(oSql);
      i := i + System.Int32(oRecordSet.Fields.Item('cant').Value);

      if (i = 0) and (not CheckBox(oForm.Items.Item('DeBaja').Specific).Checked) then begin
      Lista.Clear;
                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'ActCode  ,  t,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActName  ,  t,  t,  t,  f, r, 1 ');
      Lista.Add( 'ActTipo  ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'ActSerNu ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ItemCode ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'ConCorre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'InDate   ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrCorr ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrCorr ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'TipoDep  ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'TipoDepR ,  t,  t,  f,  f, r, 1 ');

      Lista.Add( 'OriVal   ,  t,  t,  f,  f, n, 1');
      Lista.Add( 'OriFec   ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriValCo ,  t,  t,  f,  f, n, >0');
      Lista.Add( 'PorResid ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriPerDp ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriDepre ,  t,  t,  f,  f, n, l');
      Lista.Add( 'InvDate  ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'TasaCnMS ,  t,  t,  f,  f, n, 1 ');

      Lista.Add( 'FmtActFi ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtCorAF ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtCorDA ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtReaAF ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtDetAF ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtDepAc ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasDe ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasBj ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtAdqAc ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtBis33 ,  t,  t,  f,  f, n, 1 ');

      Lista.Add( 'OriValCR ,  t,  t,  f,  f, n, >0');
      Lista.Add( 'PerVidaR ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDR ,  t,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriDeprR ,  t,  t,  f,  f, n, l');
      Lista.Add( 'PorResiR ,  t,  t,  f,  f, n, 1 ');

      Lista.Add( 'Bis33Flg ,  t,  t,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Compo  ,  t,  t,  f,  f, n, 1 ');

{
         oForm.Items.Item('ActCode').Enabled  := true;
         oForm.Items.Item('ActName').Enabled  := true;
         oForm.Items.Item('ItemCode').Enabled := true;
//         oForm.Items.Item('ItemName').Enabled := true;
         oForm.Items.Item('ItmGrpCd').Enabled := true;
         oForm.Items.Item('ConDepre').Enabled := true;
         oForm.Items.Item('ConCorre').Enabled := true;
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
         oForm.Items.Item('OriValCo').Enabled := true;
         oForm.Items.Item('OriFec').Enabled   := true;
         oForm.Items.Item('PorResid').Enabled := true;
         oForm.Items.Item('InvNum').Enabled   := true;
         oForm.Items.Item('InvLine').Enabled  := true;
         oForm.Items.Item('InvDate').Enabled  := true;
         oForm.Items.Item('OriPerDp').Enabled := true;
         oForm.Items.Item('OriDepre').Enabled := true;

         oForm.Items.Item('FmtActFi').Enabled := true;
         oForm.Items.Item('FmtCorAF').Enabled := true;
         oForm.Items.Item('FmtCorDA').Enabled := true;
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
      Lista.Add( 'ActTipo  ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'ActSerNu ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ItemCode ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'ConCorre ,  t,  t,  f,  f, r, 1 ');
      Lista.Add( 'InDate   ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxYrCorr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'NxPrCorr ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  t,  t,  t,  f, n, 1 ');
      Lista.Add( 'TipoDep  ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'TipoDepR ,  f,  t,  f,  f, n, 1 ');

      Lista.Add( 'OriVal   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriFec   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriValCo ,  f,  t,  f,  f, n, >0');
      Lista.Add( 'PorResid ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriPerDp ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriDepre ,  f,  t,  f,  f, n, l');
      Lista.Add( 'InvDate  ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'TasaCnMS ,  f,  t,  f,  f, n, 1 ');

      Lista.Add( 'FmtActFi ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtCorAF ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtCorDA ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtReaAF ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtDetAF ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'FmtDepAc ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasDe ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasBj ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtAdqAc ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'FmtBis33 ,  f,  t,  f,  f, n, 1 ');
                  
      Lista.Add( 'OriValCR ,  f,  t,  f,  f, n, >0');
      Lista.Add( 'PerVidaR ,  f,  t,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDR ,  f,  t,  f,  f, n, 1 ');
      Lista.Add( 'OriDeprR ,  f,  t,  f,  f, n, l');
      Lista.Add( 'PorResiR ,  f,  t,  f,  f, n, 1 ');

      Lista.Add( 'Bis33Flg ,  f,  t,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Compo  ,  t,  t,  f,  f, n, 1 ');
      end

      else  begin
      Lista.Clear;
                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'ActCode  ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'ActName  ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'ActTipo  ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'ActSerNu ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'ItemCode ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'ItmGrpCd ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'ConDepre ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'ConCorre ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'InDate   ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'PerVidaU ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NxYrDepr ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NxPrDepr ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NxYrCorr ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'NxPrCorr ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'EmpId    ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'LocCode  ,  f,  f,  t,  f, n, 1 ');
      Lista.Add( 'TipoDep  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'TipoDepR ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'OriVal   ,  f,  f,  f,  f, n, 1');
      Lista.Add( 'OriFec   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'OriValCo ,  f,  f,  f,  f, n, >0');
      Lista.Add( 'PorResid ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'OriPerDp ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'OriDepre ,  f,  f,  f,  f, n, l');
      Lista.Add( 'InvDate  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InvNum   ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'InvLine  ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'TasaCnMS ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'FmtActFi ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtCorAF ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'FmtCorDA ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'FmtReaAF ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'FmtDetAF ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'FmtDepAc ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasDe ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtGasBj ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtAdqAc ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'FmtBis33 ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'OriValCR ,  f,  f,  f,  f, n, >0');
      Lista.Add( 'PerVidaR ,  f,  f,  f,  f, r, 1 ');
      Lista.Add( 'OriPerDR ,  f,  f,  f,  f, n, 1 ');
      Lista.Add( 'OriDeprR ,  f,  f,  f,  f, n, l');
      Lista.Add( 'PorResiR ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'Bis33Flg ,  f,  f,  f,  f, n, 1 ');

      Lista.Add( 'Mx_Compo  , f,  f,  f,  f, n, 1 ');
      end;

      FSBOf.SetAutoManaged(oForm, Lista);
   finally
      oForm.Freeze(false);
//      oForm.Update;
   end;
end;

method TActivos.VisualizarTipoActivo(oForm: SAPbouiCOM.Form);
var
   ActTipo : String;
   LeftFin : Integer;
   LeftRef : Integer;
   PaneLev : Integer;
begin
   ActTipo := oForm.DataSources.DBDataSources.Item('@VID_AFAS').GetValue('U_ActTipo', 0);
   PaneLev := oForm.PaneLevel;
   if (OldActTipo = ActTipo) then
      exit
   else
      OldActTipo := ActTipo;
   try
      oForm.Freeze(True);
      if (ActTipo = 'I') and (GlobalSettings.IFRSNativo) then begin
         oForm.Items.Item('TabFinan').Visible := True;

         if (oForm.PaneLevel = 10) then
            PaneLev := 9;
         if (oForm.PaneLevel = 12) then
            PaneLev := 11;

         oForm.PaneLevel := 9;
         oForm.Items.Item('tab_ActFin').Visible := False;
         oForm.Items.Item('tab_ActRef').Visible := False;
         oForm.PaneLevel := 11;
         oForm.Items.Item('tab_AnuFin').Visible := False;
         oForm.Items.Item('tab_AnuRef').Visible := False;
   
         // Level 1
         LeftFin := oForm.Items.Item('tx_FinIni').Left;
         LeftRef := lev1_RefPos;
   
         oForm.PaneLevel := 1;
         oForm.Items.Item('tx_RefIni').Left := LeftRef;   
         oForm.Items.Item('OriValCR' ).Left := LeftRef;
         oForm.Items.Item('OriPerDR' ).Left := LeftRef;
         oForm.Items.Item('OriDeprR' ).Left := LeftRef;

         oForm.Items.Item('tx_RefIni').Visible := False;   
         oForm.Items.Item('OriValCR' ).Visible := False;
         oForm.Items.Item('OriPerDR' ).Visible := False;
         oForm.Items.Item('OriDeprR' ).Visible := False;
   
         oForm.Items.Item('tx_FinIni').Visible := True;   
         oForm.Items.Item('OriValCo' ).Visible := True;
         oForm.Items.Item('OriPerDp' ).Visible := True;
         oForm.Items.Item('OriDepre' ).Visible := True;
   
         // Level 2
         LeftFin := oForm.Items.Item('tx_FinDep').Left;
         LeftRef := lev2_RefPos;
   
         oForm.PaneLevel := 2;
         oForm.Items.Item('tx_RefDep' ).Left := LeftRef;   
         oForm.Items.Item('VidaUtiR'  ).Left := LeftRef;   
         oForm.Items.Item('PRrDepre'  ).Left := LeftRef;   
         oForm.Items.Item('CurValR'   ).Left := LeftRef;   
         oForm.Items.Item('DepAcuR'   ).Left := LeftRef;   
         oForm.Items.Item('CorAnuAR'  ).Left := LeftRef;   
         oForm.Items.Item('CorAnuDR'  ).Left := LeftRef;   
         oForm.Items.Item('DepreAnR'  ).Left := LeftRef;   
         oForm.Items.Item('ValorNetoR').Left := LeftRef;   
         oForm.Items.Item('AdicAnuCR' ).Left := LeftRef;   
         oForm.Items.Item('ValorResiR').Left := LeftRef;   
         if (Bis33Flg) then 
            oForm.Items.Item('Bis33'     ).Left := LeftRef;   

         oForm.Items.Item('tx_RefDep' ).Visible := False;
         oForm.Items.Item('VidaUtiR'  ).Visible := False;
         oForm.Items.Item('PRrDepre'  ).Visible := False;
         oForm.Items.Item('CurValR'   ).Visible := False;
         oForm.Items.Item('DepAcuR'   ).Visible := False;
         oForm.Items.Item('CorAnuAR'  ).Visible := False;
         oForm.Items.Item('CorAnuDR'  ).Visible := False;
         oForm.Items.Item('DepreAnR'  ).Visible := False;
         oForm.Items.Item('ValorNetoR').Visible := False;
         oForm.Items.Item('AdicAnuCR' ).Visible := False;
         oForm.Items.Item('ValorResiR').Visible := False;
         if (Bis33Flg) then 
            oForm.Items.Item('Bis33'     ).Visible := False;

         oForm.Items.Item('CorAnuAc'  ).Visible := False;
         oForm.Items.Item('TxCorAnuAc').Visible := False;
         oForm.Items.Item('CorAnuDe'  ).Visible := False;
         oForm.Items.Item('TxCorAnuDe').Visible := False;

         oForm.Items.Item('tx_FinDep').Visible := True;
         oForm.Items.Item('VidaUtil' ).Visible := True;
         oForm.Items.Item('PerDepre' ).Visible := True;
         oForm.Items.Item('CurVal'   ).Visible := True;
         oForm.Items.Item('DepAcum'  ).Visible := True;
//         oForm.Items.Item('CorAnuAc' ).Visible := True;
//         oForm.Items.Item('CorAnuDe' ).Visible := True;
         oForm.Items.Item('DepreAnu' ).Visible := True;
         oForm.Items.Item('ValorNeto').Visible := True;
         oForm.Items.Item('AdicAnuC' ).Visible := True;
         oForm.Items.Item('ValorResi').Visible := True;
         if (Bis33Flg) and ((not GlobalSettings.IFRSActivo)  or (GlobalSettings.IFRSActivo and (not GlobalSettings.IFRSNativo))) then 
            oForm.Items.Item('Bis33Fin').Visible := True;
      end
      else if (ActTipo = 'T') and (GlobalSettings.IFRSNativo) then begin
         oForm.Items.Item('TabFinan').Visible := False;
         if (oForm.PaneLevel = 3) or (oForm.PaneLevel = 4) then
            PaneLev := 1;

         if (oForm.PaneLevel = 9) then
            PaneLev := 10;
         if (oForm.PaneLevel = 11) then
            PaneLev := 12;

         oForm.PaneLevel := 9;
         oForm.Items.Item('tab_ActFin').Visible := False;
         oForm.Items.Item('tab_ActRef').Visible := False;
         oForm.PaneLevel := 11;
         oForm.Items.Item('tab_AnuFin').Visible := False;
         oForm.Items.Item('tab_AnuRef').Visible := False;

         // Level 1
         LeftFin := oForm.Items.Item('tx_FinIni').Left;
         LeftRef := lev2_RefPos;
   
         oForm.PaneLevel := 1;
         oForm.Items.Item('tx_RefIni').Left := LeftFin;   
         oForm.Items.Item('OriValCR' ).Left := LeftFin;
         oForm.Items.Item('OriPerDR' ).Left := LeftFin;
         oForm.Items.Item('OriDeprR' ).Left := LeftFin;

         oForm.Items.Item('tx_RefIni').Visible := True;   
         oForm.Items.Item('OriValCR' ).Visible := True;
         oForm.Items.Item('OriPerDR' ).Visible := True;
         oForm.Items.Item('OriDeprR' ).Visible := True;
   
         oForm.Items.Item('tx_FinIni').Visible := False;   
         oForm.Items.Item('OriValCo' ).Visible := False;
         oForm.Items.Item('OriPerDp' ).Visible := False;
         oForm.Items.Item('OriDepre' ).Visible := False;   

         // Level 2
         LeftFin := oForm.Items.Item('tx_FinDep').Left;
         LeftRef := lev1_RefPos;
   
         oForm.PaneLevel := 2;
         oForm.Items.Item('tx_RefDep' ).Left := LeftFin;   
         oForm.Items.Item('VidaUtiR'  ).Left := LeftFin;   
         oForm.Items.Item('PRrDepre'  ).Left := LeftFin;   
         oForm.Items.Item('CurValR'   ).Left := LeftFin;   
         oForm.Items.Item('DepAcuR'   ).Left := LeftFin;   
         oForm.Items.Item('CorAnuAR'  ).Left := LeftFin;   
         oForm.Items.Item('CorAnuDR'  ).Left := LeftFin;   
         oForm.Items.Item('DepreAnR'  ).Left := LeftFin;   
         oForm.Items.Item('ValorNetoR').Left := LeftFin;   
         oForm.Items.Item('AdicAnuCR' ).Left := LeftFin;   
         oForm.Items.Item('ValorResiR').Left := LeftFin;   
         if (Bis33Flg) then 
            oForm.Items.Item('Bis33'  ).Left := LeftFin;   

         oForm.Items.Item('CorAnuAc'  ).Visible := True;
         oForm.Items.Item('TxCorAnuAc').Visible := True;
         oForm.Items.Item('CorAnuDe'  ).Visible := True;
         oForm.Items.Item('TxCorAnuDe').Visible := True;

         oForm.Items.Item('tx_RefDep' ).Visible := True;
         oForm.Items.Item('VidaUtiR'  ).Visible := True;
         oForm.Items.Item('PRrDepre'  ).Visible := True;
         oForm.Items.Item('CurValR'   ).Visible := True;
         oForm.Items.Item('DepAcuR'   ).Visible := True;
         oForm.Items.Item('CorAnuAR'  ).Visible := True;
         oForm.Items.Item('CorAnuDR'  ).Visible := True;
         oForm.Items.Item('DepreAnR'  ).Visible := True;
         oForm.Items.Item('ValorNetoR').Visible := True;
         oForm.Items.Item('AdicAnuCR' ).Visible := True;
         oForm.Items.Item('ValorResiR').Visible := True;
         if (Bis33Flg) then 
            oForm.Items.Item('Bis33'  ).Visible := True;
  
         oForm.Items.Item('tx_FinDep').Visible := False;
         oForm.Items.Item('VidaUtil' ).Visible := False;
         oForm.Items.Item('PerDepre' ).Visible := False;
         oForm.Items.Item('CurVal'   ).Visible := False;
         oForm.Items.Item('DepAcum'  ).Visible := False;
//         oForm.Items.Item('CorAnuAc' ).Visible := False;
//         oForm.Items.Item('CorAnuDe' ).Visible := False;
         oForm.Items.Item('DepreAnu' ).Visible := False;
         oForm.Items.Item('ValorNeto').Visible := False;
         oForm.Items.Item('AdicAnuC' ).Visible := False;
         oForm.Items.Item('ValorResi').Visible := False;
         oForm.Items.Item('Bis33Fin').Visible := False;
      end
      else begin // ActTipo = 'N'
         oForm.Items.Item('TabFinan').Visible := True;

         oForm.PaneLevel := 9;
         oForm.Items.Item('tab_ActFin').Visible := True;
         oForm.Items.Item('tab_AnuFin').Visible := True;
         oForm.PaneLevel := 11;
         oForm.Items.Item('tab_ActRef').Visible := True;
         oForm.Items.Item('tab_AnuRef').Visible := True;

         // Level 1
         LeftFin := oForm.Items.Item('tx_FinIni').Left;
         LeftRef := lev1_RefPos;
   
         oForm.PaneLevel := 1;
         oForm.Items.Item('tx_RefIni').Left := LeftRef;   
         oForm.Items.Item('OriValCR' ).Left := LeftRef;
         oForm.Items.Item('OriPerDR' ).Left := LeftRef;
         oForm.Items.Item('OriDeprR' ).Left := LeftRef;

         oForm.Items.Item('tx_RefIni').Visible := True;   
         oForm.Items.Item('OriValCR' ).Visible := True;
         oForm.Items.Item('OriPerDR' ).Visible := True;
         oForm.Items.Item('OriDeprR' ).Visible := True;
   
         oForm.Items.Item('tx_FinIni').Visible := True;   
         oForm.Items.Item('OriValCo' ).Visible := True;
         oForm.Items.Item('OriPerDp' ).Visible := True;
         oForm.Items.Item('OriDepre' ).Visible := True;   

         // Level 2
         LeftFin := oForm.Items.Item('tx_FinDep').Left;
         LeftRef := lev2_RefPos;
   
         oForm.PaneLevel := 2;
         oForm.Items.Item('tx_RefDep' ).Left := LeftRef;   
         oForm.Items.Item('VidaUtiR'  ).Left := LeftRef;   
         oForm.Items.Item('PRrDepre'  ).Left := LeftRef;   
         oForm.Items.Item('CurValR'   ).Left := LeftRef;   
         oForm.Items.Item('DepAcuR'   ).Left := LeftRef;   
         oForm.Items.Item('CorAnuAR'  ).Left := LeftRef;   
         oForm.Items.Item('CorAnuDR'  ).Left := LeftRef;   
         oForm.Items.Item('DepreAnR'  ).Left := LeftRef;   
         oForm.Items.Item('ValorNetoR').Left := LeftRef;   
         oForm.Items.Item('AdicAnuCR' ).Left := LeftRef;   
         oForm.Items.Item('ValorResiR').Left := LeftRef;   
         if (Bis33Flg) then 
            oForm.Items.Item('Bis33'  ).Left := LeftRef;   

         if (GlobalSettings.IFRSNativo) then begin
            oForm.Items.Item('CorAnuAc'  ).Visible := false;
            oForm.Items.Item('CorAnuDe'  ).Visible := false;
         end
         else begin
            oForm.Items.Item('CorAnuAc'  ).Visible := True;
            oForm.Items.Item('CorAnuDe'  ).Visible := True;
         end;
         oForm.Items.Item('TxCorAnuAc').Visible := True;
         oForm.Items.Item('TxCorAnuDe').Visible := True;

         oForm.Items.Item('tx_RefDep' ).Visible := True;
         oForm.Items.Item('VidaUtiR'  ).Visible := True;
         oForm.Items.Item('PRrDepre'  ).Visible := True;
         oForm.Items.Item('CurValR'   ).Visible := True;
         oForm.Items.Item('DepAcuR'   ).Visible := True;
         oForm.Items.Item('CorAnuAR'  ).Visible := True;
         oForm.Items.Item('CorAnuDR'  ).Visible := True;
         oForm.Items.Item('DepreAnR'  ).Visible := True;
         oForm.Items.Item('ValorNetoR').Visible := True;
         oForm.Items.Item('AdicAnuCR' ).Visible := True;
         oForm.Items.Item('ValorResiR').Visible := True;
         if (Bis33Flg) then 
            oForm.Items.Item('Bis33'  ).Visible := True;

         oForm.Items.Item('tx_FinDep').Visible := True;
         oForm.Items.Item('VidaUtil' ).Visible := True;
         oForm.Items.Item('PerDepre' ).Visible := True;
         oForm.Items.Item('CurVal'   ).Visible := True;
         oForm.Items.Item('DepAcum'  ).Visible := True;
//         oForm.Items.Item('CorAnuAc' ).Visible := True;
//         oForm.Items.Item('CorAnuDe' ).Visible := True;
         oForm.Items.Item('DepreAnu' ).Visible := True;
         oForm.Items.Item('ValorNeto').Visible := True;
         oForm.Items.Item('AdicAnuC' ).Visible := True;
         oForm.Items.Item('ValorResi').Visible := True;
         if (Bis33Flg) and ((not GlobalSettings.IFRSActivo)  or (GlobalSettings.IFRSActivo and (not GlobalSettings.IFRSNativo))) then 
            oForm.Items.Item('Bis33Fin').Visible := True;
      end;
   finally
      oForm.PaneLevel := PaneLev;
      oForm.Freeze(False);
      oForm.Update;
   end;
end;

method TActivos.SetMatrixIFRSView(oForm: SAPbouiCOM.Form);
var
   oMtx : SAPBouiCOM.Matrix;
begin

   oMtx := oForm.Items.Item("MxVID_AFAC").Specific as Matrix;

   if (not GlobalSettings.IFRSActivo) then begin
      oMtx.Columns.Item("RvNewVal").Visible := false;
      exit;
   end;

   oMtx.Columns.Item("CorrActi").Visible := false;
   oMtx.Columns.Item("CorrDepr").Visible := false;
   oMtx.Columns.Item("CorrDepM").Visible := false;
   oMtx.Columns.Item("RvNewVal").Visible := true;
   

   oMtx := oForm.Items.Item("MxVID_AFSA").Specific as Matrix;
   oMtx.Columns.Item("CorAnuAc").Visible := false;
   oMtx.Columns.Item("CorAnuDe").Visible := false;
   oMtx.Columns.Item("Bis33").Visible := false;

end;

method TActivos.SetCamposAdicionales(oForm: SAPbouiCOM.Form);
var
  oT, oH, oL, oW : integer;
  oFieldHeight   : integer;
  oSQL           : String;
  oField         : integer;
  NFields        : integer;
  MaxRows        : integer;
  NColumns       : integer;
  ColumnWidth    : Integer;
  oLeft          : Integer;
  oTop           : integer;
  oFactor        : Double;
  i, k           : Integer;
  oItm1          : SAPbouiCOM.Item;
  oCombo         : boolean;
  oRecordSet1    : SAPbobsCOM.Recordset;
begin
  oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

  oT := oForm.Items.Item('TabDatos').Top + oForm.Items.Item('TabDatos').Height + 10;
  oH := oForm.Items.Item('Comments').Top - 10 - oT;
  oL := 25;
  oW := oForm.ClientWidth - 50;
  oFieldHeight := oForm.Items.Item('ActCode').Height;

  oSql := iif(GlobalSettings.RunningUnderSQLServer, 
              "Select h.Descr, h.AliasID, h.TypeID, h.EditSize, d.FldValue, h.FieldID                  " +
              "  from CUFD h left outer join UFD1 d on h.FieldID = d.FieldID and h.TableID = d.TableID " +
              " where h.TableID = '@VID_AFCAD' ", 
              'Select h."Descr", h."AliasID", h."TypeID", h."EditSize", d."FldValue", h."FieldID"               ' +   
              '  from CUFD h left outer join UFD1 d on h."FieldID" = d."FieldID" and h."TableID" = d."TableID"  ' +
              ' where h."TableID" = ''@VID_AFCAD''');
  oRecordSet1.DoQuery(oSql);

  NFields := 0;
  oField  := -1;
  while (not oRecordSet1.EoF) do begin
     if (oField <> System.Int32(oRecordSet1.Fields.Item('FieldID').Value)) then begin
        oField := System.Int32(oRecordSet1.Fields.Item('FieldID').Value);
        inc(NFields);
     end;
     oRecordSet1.MoveNext;
  end;

  MaxRows     := (oH + 2) / (oFieldHeight + 1);
  NColumns    := (NFields / MaxRows) + 1;  
  ColumnWidth := (oW + 2) / NColumns;
  if (ColumnWidth >= 220) then
     oFactor := 1.0
  else 
     oFactor := Convert.ToDouble(ColumnWidth) / 220.0;

  // Titulo (100) + separacion (10) + campo (90) + separacion (20) = total usado (220)
  i       := 1;
  k       := 1;
  oLeft   := oL;
  oTop    := oT;
  oField  := -1;
  oRecordSet1.MoveFirst;
  while (not oRecordSet1.EoF) do begin
     if (oField = System.Int32(oRecordSet1.Fields.Item('FieldID').Value)) then begin
        oRecordSet1.MoveNext;
        continue;
     end;
     oField := System.Int32(oRecordSet1.Fields.Item('FieldID').Value);

     oCombo := false;
     if (System.String(oRecordSet1.Fields.Item('FldValue').Value) <> '') and (System.String(oRecordSet1.Fields.Item('FldValue').Value) <> '') then
        oCombo := true;

     if (i > MaxRows) then begin
        oTop  := oT;
        oLeft := oLeft + convert.ToInt32(oFactor * 220);
        i := 1;
     end;
 
     oForm.Items.Add('tx_'  + k.ToString, BoFormItemTypes.it_STATIC);
     if (not oCombo) then
        oForm.Items.Add('fld_' + k.ToString, BoFormItemTypes.it_EDIT)
     else
        oForm.Items.Add('fld_' + k.ToString, BoFormItemTypes.it_COMBO_BOX);

     oItm1 := oForm.Items.Item('tx_'  + k.ToString);
     oItm1.LinkTo := 'fld_' + k.ToString;
     oItm1.Left   := oLeft;
     oItm1.Top    := oTop;
     oItm1.Height := oFieldHeight;
     oItm1.Width  := convert.ToInt32(oFactor * 100);
     oItm1.FromPane := 21;
     oItm1.ToPane := 21;
     StaticText(oItm1.Specific).Caption := System.String(oRecordSet1.Fields.Item('Descr').Value);

     oItm1 := oForm.Items.Item('fld_' + k.ToString);
     oItm1.Left   := oLeft +  convert.ToInt32(oFactor * 110);
     oItm1.Top    := oTop;
     oItm1.Height := oFieldHeight;
     oItm1.Width  := convert.ToInt32(oFactor * 90);
     oItm1.FromPane := 21;
     oItm1.ToPane := 21;
     if (not oCombo) then
        EditText(oItm1.Specific).DataBind.SetBound(true, '@VID_AFCAD', 'U_' + system.String(oRecordSet1.Fields.Item('AliasID').Value))
     else begin
        ComboBox(oItm1.Specific).DataBind.SetBound(true, '@VID_AFCAD', 'U_' + system.String(oRecordSet1.Fields.Item('AliasID').Value));
        oItm1.DisplayDesc := true;
     end;
       
     oTop := oTop + oFieldHeight + 1;
     inc(i);
     inc(k);
     oRecordSet1.MoveNext;
  end;
end;

end.
