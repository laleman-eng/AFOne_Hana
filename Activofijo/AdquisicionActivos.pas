namespace AF_IFRS.AdquisicionActivos;

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
  TSerie = class
     CodeSerie        : String;
     Numero           : Integer;
     FormatoNumero    : String;
     Linea            : Integer;
     preStr           : String;
     postStr          : String;
     ValorSerie       : String;
     ActivosAgregados : Integer;
  end;

  TAdquisicionActivos = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet      : SAPbobsCOM.Recordset;
    oRecordAux      : SAPbobsCOM.Recordset;
    oCompanyService : SAPbobsCOM.CompanyService;
    Lista        : List<String>;
    ListaMx      : List<String>;
    FTipoDoc     : string;
    FDocEntry    : string;
    FIngresados  : Boolean;
    oTasaFija    : boolean := false;
    oPostSysCu   : boolean := false;
    oListSeries  : List<TSerie>;
    oValorSys    : List<double>;
    method    ExistenActivosEnDocumento(oForm: SAPbouiCOM.Form): boolean;
    method    ExistenActivosIngresados(oForm: SAPbouiCOM.Form): boolean;
    method    LoadFromDoc(oForm: SAPbouiCOM.Form): boolean;
    method    VerificarExistencia(oForm: SAPbouiCOM.Form): boolean;
    method    IngresarActivosFijos(oForm: SAPbouiCOM.Form): boolean;
    method    UpdateLoteSerie(Valor, Linea, Serie, SeriesObj, SeriesLines : String);
    method    _ReleaseCOMObject(_Object :Object) : Integer;
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method  RightClickEvent(var pVal: ContextMenuInfo; var BubbleEvent: boolean); reintroduce;
    property    Tipodoc:  string  read FTipoDoc  write FTipoDoc;
    property    DocEntry: string  read FDocEntry write FDocEntry;
  end;

implementation

uses
  System.Globalization;

method   TAdquisicionActivos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm    :  SAPbouiCOM.Form;
   oDBDSD   :  SAPbouiCOM.DBDataSource;
   oCons    :  SAPbouiCOM.Conditions;
   oCon     :  SAPbouiCOM.Condition;
   oColumn  :  SAPbouiCOM.Column;
   oDocEntry:  string;
   ActIngr  :  boolean;
   ActDocu  :  boolean;
   oSql     :  string;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista       := New List<String>;
   ListaMx     := New List<String>;
   oListSeries := new List<TSerie>;
   oValorSys   := new List<double>;

   try
      try
         oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         oRecordAux := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         // Es Activo Fijo - SBO 9.0
         oCompanyService := company.GetCompanyService;

         FIngresados := false;
         ActIngr := ExistenActivosIngresados(oForm);
         if (not ActIngr) then begin
            ActDocu := ExistenActivosEnDocumento(oForm);
            if (not ActDocu) then begin
               result := false;
               exit;
            end
         end;

         if (FCmpny.language = BoSuppLangs.ln_English) then
            FSBOf.LoadForm(xmlPath,'VID_AdquisicionActivos_EN.srf', Uid)
         else
            FSBOf.LoadForm(xmlPath,'VID_AdquisicionActivos.srf', Uid);

         oForm   := FSBOApp.Forms.Item(uid);
         VID_DelRow := false;

         oForm.Freeze(True);
         oForm.AutoManaged    := True;

         if (ActIngr) then begin
            oForm.SupportedModes := 1;             // afm_Ok
            oForm.Mode := BoFormMode.fm_UPDATE_MODE;
         end
         else if (ActDocu) then begin
            oForm.SupportedModes := 3;             // afm_Ok
            oForm.Mode := BoFormMode.fm_ADD_MODE;
         end;


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

                              // Ok Ad  Fnd Vw Rq Sec
         Lista.Add( 'TipoDoc ,  f,  f,  f,  f, r, 1 ');
         Lista.Add( 'DocNum  ,  f,  f,  f,  f, r, 1 ');
         Lista.Add( 'DocDate ,  f,  t,  f,  f, n, 1 ');
         if (FIngresados) then begin
            Lista.Add( 'mtx_0   ,  f,  f,  f,  f, n, 1 ');
            oForm.Mode := BoFormMode.fm_OK_MODE;
         end
         else
            Lista.Add( 'mtx_0   ,  t,  t,  f,  f, n, 1 ');
         FSBOf.SetAutoManaged(oForm, Lista);

         ListaMx.Add('ActCode  , r ,   ');
         ListaMx.Add('ItemCode , r ,   ');

         if (not ActIngr) and (ActDocu) then begin
            if (not LoadFromDoc(oForm)) then begin
               result := false;
               exit;
            end;
         end
         else begin
            oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFADQD');

            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select docentry from [@VID_AFADQ] " +
                        " where U_DocEntry = {0}           " +
                        "   and U_TipoDoc  = '{1}'", 
                        'Select "DocEntry" "docentry" from "@VID_AFADQ" ' +
                        ' where "U_DocEntry" = {0}                      ' +
                        '   and "U_TipoDoc"  = ''{1}''');
            oSql := string.Format(oSql, DocEntry, TipoDoc);
            oRecordSet.DoQuery(oSql);
            oDocEntry := TMultiFunctions.intToStr(System.Int32(oRecordSet.Fields.Item('docentry').Value));

            oCons          := New SAPbouiCOM.ConditionsClass;
            oCon           := oCons.Add;
            oCon.Alias     := 'DocEntry';
            oCon.Operation := BoConditionOperation.co_EQUAL;
            oCon.CondVal   := oDocEntry;

            oForm.DataSources.DBDataSources.Item('@VID_AFADQD').Query(oCons);
            Matrix(oForm.Items.Item('mtx_0').Specific).LoadFromDataSource;
            oDBDSD.Offset := 0;
            oForm.DataSources.DBDataSources.Item('@VID_AFADQ').Query(oCons);
         end;

         Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('Ingresar').ValOn  := 'Y';
         Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('Ingresar').ValOff := 'N';

         Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ItemCode').Editable := false;

         if (GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo) then begin
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('VidaUtiF').Visible := true;
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ItemCode').Visible := true;
         end
         else if (GlobalSettings.IFRSActivo) and (GlobalSettings.IFRSNativo) then begin
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('VidaUtiF').Visible := false;
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ItemCode').Visible := true;
         end
         else begin
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('VidaUtiF').Visible := false;
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ItemCode').Visible := true;
         end;

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select  U_Bis33Flg from [@VID_AFPA]", 
                     'Select "U_Bis33Flg" from "@VID_AFPA"');
         oRecordSet.DoQuery(oSql);
         if (System.String(oRecordSet.Fields.Item('U_Bis33Flg').Value) = 'Y') then
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('Bis33').Visible := true
         else
            Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('Bis33').Visible := false;

         // Grupos
         oColumn := Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ItmGrpCd');
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "select  code,  name from [@VID_AFGR] order by name", 
                     'Select "Code" "code", "Name" "name" from "@VID_AFGR" order by "Name"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillComboMtx(oColumn, var oRecordSet, false);
         oColumn := Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('LocCode');
         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "select  code,  name from [@VID_AFLOC] order by name", 
                     'Select "Code" "code", "Name" "name" from "@VID_AFLOC" order by "Name"');
         oRecordSet.DoQuery(oSql);
         FSBOf.FillComboMtx(oColumn, var oRecordSet, false);

         oForm.Visible := true;
      except
         on e:exception do begin
            FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
         end;
      end;
   finally
      if (oForm <> nil) then begin
         oForm.Freeze(False);
         oForm.Update;
         FSBOf._ReleaseCOMObject(oForm);
      end;
   end;
end;

method   TAdquisicionActivos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMtx            : SAPbouiCOM.Matrix;
   oDBDSD          : SAPbouiCOM.DBDataSource;
   oDBDSH          : SAPbouiCOM.DBDataSource;
   oFormIvk        : IvkFormInterface;
   oAdquisicion           : SAPbobsCOM.GeneralService;
   oAdquisicionData       : SAPbobsCOM.GeneralData;
   oAdquisicionLines      : SAPbobsCOM.GeneralDataCollection;
   oGen                   : TSBOGeneralService;  
   sValue          : string;
   i               : integer;
   s               : String;
   oSql            : string;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm   := FSBOApp.Forms.Item(pVal.FormUID);
   oMtx    := Matrix(oForm.Items.Item('mtx_0').Specific);
   oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFADQ');
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFADQD');

   try
      if (pVal.EventType = BoEventTypes.et_DOUBLE_CLICK) and (pVal.BeforeAction) then begin
         BubbleEvent := False;
      end;

      if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (pVal.BeforeAction = False) then begin
         if (pVal.ColUID = 'ItmGrpCd')  then begin
            oMtx.GetLineData(pVal.Row);
            sValue  := oDBDSD.GetValue('U_ItmGrpCd', 0);
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select U_VidaUtil, U_VidaUtiR, U_VidaUtiF from [@VID_AFGR] where code = '{0}'", 
                        'Select "U_VidaUtil", "U_VidaUtiR", "U_VidaUtIF" "U_VidaUtiF" from "@VID_AFGR" where "Code" = ''{0}''');
            oSql := string.Format(oSql, sValue.Trim);
            oRecordSet.DoQuery(oSql);
            if (not oRecordSet.EoF) then begin
               sValue := System.Int32(oRecordSet.Fields.Item('U_VidaUtil').Value).ToString;
               oDBDSD.SetValue('U_VidaUtil', 0, sValue);
               sValue := System.Int32(oRecordSet.Fields.Item('U_VidaUtiR').Value).ToString;
               oDBDSD.SetValue('U_VidaUtiR', 0, sValue);
               sValue := System.Int32(oRecordSet.Fields.Item('U_VidaUtiF').Value).ToString;
               oDBDSD.SetValue('U_VidaUtiF', 0, sValue);
               oMtx.SetLineData(pVal.Row);
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction = true) then begin
         if (pVal.ColUID = 'ActCode') then begin
            BubbleEvent := false;
            sValue := EditText(oMtx.Columns.Item('ActCode').Cells.Item(pVal.Row).Specific).Value;
            if (sValue = '') then begin
               BubbleEvent := true;
               exit;
            end;
            for i:=1 to oMtx.RowCount do
               if (sValue = EditText(oMtx.Columns.Item('ActCode').Cells.Item(i).Specific).Value) and (i <> Pval.Row) then begin
                  FSBOApp.StatusBar.SetText('Código de activo duplicado en linea ' + TMultiFunctions.inttostr(i), BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;
            BubbleEvent := true;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
            BubbleEvent := false;
            if (VerificarExistencia(oForm)) then begin
               FCmpny.StartTransaction;

               IngresarActivosFijos(oForm);

               oGen         := New TSBOGeneralService;
               oGen.SBO_f   := FSBOf;
               oAdquisicion := GeneralService(FSBOf.Cmpny.GetCompanyService().GetGeneralService('VID_AFADQ'));

               oAdquisicionData:= SAPbobsCOM.GeneralData(oAdquisicion.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralData));

               oGen.SetNewDataSourceHeader_InUDO(oDBDSH, oAdquisicionData);
               if (oDBDSD.Size > 0) then begin
                  oAdquisicionLines := oAdquisicionData.Child('VID_AFADQD');
                  oGen.SetNewDataSourceLines_InUDO(oDBDSD, oAdquisicionData, oAdquisicionLines);
               end;

               oAdquisicion.Add(oAdquisicionData);

               FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_Commit);

               oForm.Mode := BoFormMode.fm_OK_MODE;
               oForm.Close;

            end;
         end
         else if (pVal.ItemUID = 'btnPrint') and ((oForm.Mode <> BoFormMode.fm_ADD_MODE) <> (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin

            s := '';
            for i:=0 to oDBDSD.Size-1 do begin
               if (oDBDSD.GetValue('U_Ingresar', i) <> 'Y') then
                  continue;
               if (s = '') then
                  s := "'" + oDBDSD.GetValue('U_ActCode', i).Trim + "'"
               else
                  s := s + ',' + "'" + oDBDSD.GetValue('U_ActCode', i).Trim + "'";
            end;

            if (s = '') then 
               exit;

            oFormIvk := IvkFormInterface(New TReportWindowFR_1);
            if (FCmpny.language = BoSuppLangs.ln_English) then
               TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptActivoFijoAdquisicion_EN.fr3'
            else
               TReportWindowFR_1(oFormIvk).ReportFR3  := Path.GetDirectoryName( System.Windows.Forms.Application.ExecutablePath ) + '\Reports\RptActivoFijoAdquisicion.fr3';
            TReportWindowFR_1(oFormIvk).ReportParams := ' -code "' + s + '"';
            if(oFormIvk<>nil) then begin
               oFormIvk.InitForm( FSBOf.generateFormId(GlobalSettings.SBOSpaceName, GlobalSettings), 'forms\', var FSBOApp, var FCmpny, var FSBOf, var FGlobalSettings);
               ooForms.Add(oFormIvk);
            end;
         end;
      end;

      FSBOf._ReleaseCOMObject(oForm);
      FSBOf._ReleaseCOMObject(oMtx);
      FSBOf._ReleaseCOMObject(oDBDSH);
      FSBOf._ReleaseCOMObject(oDBDSD);

   except
      on e: exception do begin
         if (FSBOf.Cmpny.InTransaction) then
            FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TAdquisicionActivos.RightClickEvent(var pVal: ContextMenuInfo; var BubbleEvent: boolean);
begin
   inherited RightClickEvent(var pVal, var BubbleEvent);
end;

method  TAdquisicionActivos.ExistenActivosEnDocumento(oForm: SAPbouiCOM.Form): boolean;
var
   s        : string;
   EsActivo : string;
   oSql     : string;
begin
   // Es Activo Fijo - SBO 9.0
   if (oCompanyService.GetCompanyInfo.Version >= 900000) then 
      EsActivo := iif(GlobalSettings.RunningUnderSQLServer, " and i.U_VID_AFAF = 'Y' ", ' and i."U_VID_AFAF" = ''Y'' ')
   else
      EsActivo := iif(GlobalSettings.RunningUnderSQLServer, " and i.AssetItem = 'Y' ", ' and i."AssetItem" = ''Y'' ');

   result := false;
   if (TipoDoc = 'F') then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select count(*) cant                                                     " +
                  "  from OPCH h inner join PCH1 d on h.docentry = d.docentry               " +
                  "              inner join OITM i on d.ItemCode = i.ItemCode               " +
                  "         left outer join [@VID_AFGR] af on i.ItmsGrpCod = af.U_ItmGrpCd  " +
                  " where h.Docentry = {0}                                                  " +
                  EsActivo +
                  "   and i.InvntItem = 'N' ", 
                  'Select Count(*) "cant"                                                      ' +                                     
                  '  from OPCH h inner join PCH1 d on h."DocEntry" = d."DocEntry"              ' +
                  '              inner join OITM i on d."ItemCode" = i."ItemCode"              ' + 
                  '         left outer join "@VID_AFGR" af on i."ItmsGrpCod" = af."U_ItmGrpCd" ' + 
                  ' where h."DocEntry" = {0}                                                   ' +
                  EsActivo +
                  '   and i."InvntItem" = ''N'' ');
      oSql := string.Format(oSql, DocEntry);
      oRecordSet.DoQuery(oSql);
      if (system.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
         result := true;
   end
   else if (TipoDoc = 'S') then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select count(*) cant                                                     " +
                  "  from OIGE h inner join IGE1 d on h.docentry = d.docentry               " +
                  "              inner join OITM i on d.ItemCode = i.ItemCode               " +
                  "         left outer join [@VID_AFGR] af on i.ItmsGrpCod = af.U_ItmGrpCd  " +
                  " where h.Docentry = {0}                                                  " +
                  EsActivo, 
                  'Select Count(*) "cant"                                                       ' +
                  '  from OIGE h inner join IGE1 d on h."DocEntry" = d."DocEntry"               ' +
                  '              inner join OITM i on d."ItemCode" = i."ItemCode"               ' +
                  '         left outer join "@VID_AFGR" af on i."ItmsGrpCod" = af."U_ItmGrpCd"  ' +
                  ' where h."DocEntry" = {0}                                                  ' +
                  EsActivo);
      oSql := string.Format(oSql, DocEntry);
      oRecordSet.DoQuery(oSql);
      if (system.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
         result := true;
   end
end;

method  TAdquisicionActivos.ExistenActivosIngresados(oForm: SAPbouiCOM.Form): boolean;
var
   s    : string;
   oSql : string;
begin
   result := false;
   if (TipoDoc = 'F') then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select Count(*) cant , sum(case u_ingresar  when 'Y' then 1 else 0 end) ingresos " +
                  "  from [@VID_AFADQ] h inner join [@VID_AFADQD] d on h.Docentry = d.DocEntry        " +
                  " where u_tipodoc = 'F'                                                             " +
                  "   and u_docentry = {0}", 
                  'Select Count(*) "cant" , Sum(Case "U_Ingresar" When ''Y'' Then 1 Else 0 End) "ingresos" ' +
                  '  from "@VID_AFADQ" h inner join "@VID_AFADQD" d on h."DocEntry" = d."DocEntry"         ' +
                  ' where "U_TipoDoc" = ''F''                                                              ' +
                  '   and "U_DocEntry" = {0}');
      oSql := string.Format(oSql, DocEntry);
      oRecordSet.DoQuery(oSql);
      if (system.Int32(oRecordSet.Fields.Item('ingresos').Value) > 0) then
         FIngresados := true;
      if (system.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
         result := true;
   end
   else if (TipoDoc = 'S') then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select Count(*) cant , sum(case u_ingresar  when 'Y' then 1 else 0 end) ingresos " +
                  "  from [@VID_AFADQ] h inner join [@VID_AFADQD] d on h.Docentry = d.DocEntry        " +
                  " where u_tipodoc = 'S'                                                             " +
                  "   and u_docentry = {0}", 
                  'Select Count(*) "cant" , Sum(Case "U_Ingresar" When ''Y'' Then 1 Else 0 End) "ingresos" ' +
                  '  from "@VID_AFADQ" h inner join "@VID_AFADQD" d on h."DocEntry" = d."DocEntry"         ' +
                  ' where "U_TipoDoc" = ''S''                                                              ' +
                  '   and "U_DocEntry" = {0}');
      oSql := string.Format(oSql, DocEntry);
      oRecordSet.DoQuery(oSql);
      if (system.Int32(oRecordSet.Fields.Item('ingresos').Value) > 0) then
         FIngresados := true;
      if (system.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
         result := true;
   end
end;

method  TAdquisicionActivos.LoadFromDoc(oForm: SAPbouiCOM.Form): boolean;
var
   oDBDSD          : SAPbouiCOM.DBDataSource;
   oDBDSH          : SAPbouiCOM.DBDataSource;
   oMtx            : SAPbouiCOM.Matrix;
   oSerie          : TSerie;
   i, cant, k      : integer;
   m, y, Salto     : Integer; 
   s               : string;
   d               : double;
   oProject        : string;
   oCCosto         : string;
   oCCosto2        : string;
   oCCosto3        : string;
   oCCosto4        : string;
   oCCosto5        : string;
   Fecha           : String;
   Documento       : String;
   Origen          : String;
   Articulo        : String;
   SerieTable      : String;
   SerieCode       : String;
   preStr          : String;
   postStr         : String;
   numberFormat    : String;
   numero          : Int32;
   activosAgregados: Int32;
   lineaNumero     : int32;
   oIndx           : Int32;
   EsActivo        : string;
   oSql            : string;
begin
   // Es Activo Fijo - SBO 9.0
   if (oCompanyService.GetCompanyInfo.Version >= 900000) then 
      EsActivo := iif(GlobalSettings.RunningUnderSQLServer, " and i.U_VID_AFAF = 'Y' ", ' and i."U_VID_AFAF" = ''Y'' ')
   else
      EsActivo := iif(GlobalSettings.RunningUnderSQLServer, " and i.AssetItem = 'Y' ", ' and i."AssetItem" = ''Y'' ');

   result := false;
   oDBDSH    := oForm.DataSources.DBDataSources.Item('@VID_AFADQ');
   oDBDSD    := oForm.DataSources.DBDataSources.Item('@VID_AFADQD');
   oMtx      := Matrix(oForm.Items.Item('mtx_0').Specific);

   oListSeries.Clear;
   oValorSys.Clear;

   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               "Select U_Jmp1Depr from [@VID_AFPA]", 
               'Select "U_Jmp1Depr" from "@VID_AFPA"');
   oRecordSet.DoQuery(oSql);
   Salto := System.Int32(oRecordSet.Fields.Item('U_Jmp1Depr').Value);
   if (Salto < 0) then
      Salto := 0;

   if (TipoDoc = 'F') then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select h.DocDate,  d.Quantity, d.LineNum,  d.Linetotal,   g.Code ,  g.U_CtaActFi, g.U_CtaAdqAc, " +
                  "       d.project, d.ocrcode, d.ocrcode2, d.ocrcode3, d.ocrcode4, d.ocrcode5,            " +
                  "       g.U_VidaUtil, g.U_VidaUtiF, g.U_IdSerie, g.U_ItmGrpCd, h.DocNum,  T2.intrserial, " +
                  "       isnull(g.U_VidaUtiR,12) U_VidaUtiR, i.ItemCode, d.LineTotal/d.Quantity valor,    " +
                  "       d.TotalSumSy/d.Quantity ValorSys,                                                " +
                  "       month(h.DocDate) mes, year(h.DocDate) year, i.ItemName, g.U_IdSerie              " +
                  "  from OPCH h inner join PCH1 d  on h.DocEntry = d.DocEntry                             " +
                  "              inner join OITM i  on d.ItemCode = i.ItemCode                             " +
                  "              left Outer Join (select OSRI.intrserial, OSRI.ItemCode, SRI1.BaseType, SRI1.BaseEntry, SRI1.BaseLinNum                   " +
                  "                                 from SRI1 inner join OSRI on OSRI.ItemCode  = SRI1.ItemCode and OSRI.SysSerial = SRI1.SysSerial ) T2  " +
                  "                               On  T2.ItemCode  = d.ItemCode and T2.BaseType   = d.ObjType and  " +
                  "                               T2.BaseEntry = d.DocEntry and T2.BaseLinNum = d.LineNum          " +
                  "              left outer join [@VID_AFGR]   g  on i.U_VID_AFGr = g.Code                         " +
                  " where h.Docentry = {0}                                                                         " +
                  EsActivo +
                  "   and  i.InvntItem = 'N' ", 
                  'Select h."DocDate",    d."Quantity",   d."LineNum",   d."LineTotal",  g."Code" ,    g."U_CtaActFi", g."U_CtaAdqAc", ' +
                  '       d."Project",    d."OcrCode",    d."OcrCode2",  d."OcrCode3",   d."OcrCode4", d."OcrCode5",   ' +
                  '       g."U_VidaUtil", g."U_VidaUtIF", g."U_IdSerie", g."U_ItmGrpCd", h."DocNum",  T2."IntrSerial", ' +
                  '       IfNull(g."U_VidaUtiR",12) "U_VidaUtiR", i."ItemCode", d."LineTotal"/d."Quantity" "valor",    ' +
                  '       d."TotalSumSy"/d."Quantity" "ValorSys",                                                      ' +
                  '       Month(h."DocDate") "mes", year(h."DocDate") "year", i."ItemName", g."U_IdSerie"              ' +
                  '  from OPCH h inner join PCH1 d  on h."DocEntry" = d."DocEntry"                             ' +
                  '              inner join OITM i  on d."ItemCode" = i."ItemCode"                             ' +
                  '              left outer join (Select OSRI."IntrSerial", OSRI."ItemCode", SRI1."BaseType", SRI1."BaseEntry", SRI1."BaseLinNum"                 ' +
                  '                                 from SRI1 inner join OSRI on OSRI."ItemCode"  = SRI1."ItemCode" and OSRI."SysSerial" = SRI1."SysSerial" ) T2  ' +
                  '                               On  T2."ItemCode"  = d."ItemCode" and T2."BaseType"   = d."ObjType" and  ' +
                  '                               T2."BaseEntry" = d."DocEntry" and T2."BaseLinNum" = d."LineNum"          ' +
                  '              left outer join "@VID_AFGR"   g  on i."U_VID_AFGr" = g."Code"                             ' +
                  ' where h."DocEntry" = {0}                                                                               ' +
                  EsActivo +
                  '   and  i."InvntItem" = ''N''');
      oSql := string.Format(oSql, DocEntry);
      oRecordSet.DoQuery(oSql);
      oDBDSH.SetValue('U_DocDate' , 0, FSBOf.DateToStr(System.DateTime(oRecordSet.Fields.Item('DocDate').Value)));
      oDBDSH.SetValue('U_DocEntry', 0, DocEntry);
      oDBDSH.SetValue('U_TipoDoc' , 0, 'F');

      m := System.int32(oRecordSet.Fields.Item('mes' ).Value);
      y := System.int32(oRecordSet.Fields.Item('year').Value);
      
      y := y + (m + Salto -1) div 12;
      m := (m + Salto) mod 12;
      if (m = 0) then
         m := 12;

      i := 0;
      oDBDSD.Clear;
      while (not oRecordSet.EoF) do begin
         d := System.Double(oRecordSet.Fields.Item('Quantity').Value);
         if (d - Math.Truncate(d) > 0) then
            cant := Convert.ToInt32(Math.Truncate(d)) + 1
         else
            cant := Convert.ToInt32(Math.Truncate(d));
         while (cant > 0) do begin
            oDBDSD.InsertRecord(oDBDSD.Size);
            oProject := System.String(oRecordSet.Fields.Item('Project').Value);
            if (oProject <> '')  then
               oProject := oProject.Trim;
            oCCosto := '';
            oCCosto2 := '';
            oCCosto3 := '';
            oCCosto4 := '';
            oCCosto5 := '';
            if (System.String(oRecordSet.Fields.Item('ocrcode').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode').Value) <> nil) then
               oCCosto := System.String(oRecordSet.Fields.Item('ocrcode').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode2').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode2').Value) <> nil) then
               oCCosto2 := System.String(oRecordSet.Fields.Item('ocrcode2').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode3').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode3').Value) <> nil) then
               oCCosto3 := System.String(oRecordSet.Fields.Item('ocrcode3').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode4').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode4').Value) <> nil) then
               oCCosto4 := System.String(oRecordSet.Fields.Item('ocrcode4').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode5').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode5').Value) <> nil) then
               oCCosto5 := System.String(oRecordSet.Fields.Item('ocrcode5').Value);
            if (oCCosto <> '')  then
               oCCosto := oCCosto.Trim;
            if (oCCosto2 <> '')  then
               oCCosto2 := oCCosto2.Trim;
            if (oCCosto3 <> '')  then
               oCCosto3 := oCCosto3.Trim;
            if (oCCosto4 <> '')  then
               oCCosto4 := oCCosto4.Trim;
            if (oCCosto5 <> '')  then
               oCCosto5 := oCCosto5.Trim;
            oDBDSD.SetValue('U_Ingresar', i, 'N');
            oDBDSD.SetValue('U_Bis33'   , i, 'N');
            oDBDSD.SetValue('U_ItemCode', i, System.String(oRecordSet.Fields.Item('ItemCode').Value).Trim);
            oDBDSD.SetValue('U_OriValCo', i, FSBOf.DoubleToStr(System.double(oRecordSet.Fields.Item('valor').Value)));
            oDBDSD.SetValue('U_VidaUtil', i, System.int32(oRecordSet.Fields.Item('U_VidaUtil').Value).ToString);
            oDBDSD.SetValue('U_VidaUtiR', i, System.int32(oRecordSet.Fields.Item('U_VidaUtiR').Value).ToString);
            oDBDSD.SetValue('U_VidaUtiF', i, System.int32(oRecordSet.Fields.Item('U_VidaUtiF').Value).ToString);
            oDBDSD.SetValue('U_InitYear', i, y.ToString);
            oDBDSD.SetValue('U_InitPer' , i, m.ToString);
            oDBDSD.SetValue('U_ItmGrpCd', i, System.String(oRecordSet.Fields.Item('Code').Value).Trim);
            oDBDSD.SetValue('U_Project' , i, oProject);
            oDBDSD.SetValue('U_ProfitCt', i, oCCosto);
            oDBDSD.SetValue('U_ProfitC2', i, oCCosto2);
            oDBDSD.SetValue('U_ProfitC3', i, oCCosto3);
            oDBDSD.SetValue('U_ProfitC4', i, oCCosto4);
            oDBDSD.SetValue('U_ProfitC5', i, oCCosto5);
            oValorSys.Add(System.double(oRecordSet.Fields.Item('ValorSys').Value));

            Fecha      := FSBOf.DateToStr(System.DateTime(oRecordSet.Fields.Item('DocDate').Value));
            Documento  := System.Int32(oRecordSet.Fields.Item('DocNum').Value).ToString;
            Origen     := 'F';
            Articulo   := System.String(oRecordSet.Fields.Item('ItemCode').Value).Trim;
            SerieCode  := System.String(oRecordSet.Fields.Item('U_IdSerie').Value).Trim;
            SerieTable := iif(GlobalSettings.RunningUnderSQLServer, '[@VID_AFDEFSERIED]', '@VID_AFDEFSERIED');

            oSerie := new TSerie;
            oSerie.CodeSerie := '';
            oSerie.Linea     := -1;
            oSerie.Numero    := -1;
            oSerie.FormatoNumero := '';
            oSerie.preStr     := '';
            oSerie.postStr    := '';
            oSerie.ActivosAgregados := 0;

            if (System.String(oRecordSet.Fields.Item('Code').Value).Trim = '') or (System.String(oRecordSet.Fields.Item('Code').Value) = nil) or (System.String(oRecordSet.Fields.Item('U_IdSerie').Value).Trim = '') or (System.String(oRecordSet.Fields.Item('U_IdSerie').Value) = nil) then begin
               oSerie.ValorSerie := 'F.' + DocEntry + '.' + TMultiFunctions.inttostr(i);
               oDBDSD.SetValue('U_ActCode' , i, oSerie.ValorSerie); 
               oDBDSD.SetValue('U_ActName' , i, 'F.' + DocEntry + '.' + TMultiFunctions.inttostr(i) + '- ' +System.String(oRecordSet.Fields.Item('ItemName').Value).Trim );                 end
            else begin
               oIndx := -1;
               for k:=oListSeries.Count-1 downto 0 do begin
                  s := TSerie(oListSeries[k]).CodeSerie;
                  if (s = System.String(oRecordSet.Fields.Item('U_IdSerie').Value).Trim) then begin
                     oIndx := k;
                     break;
                    end;
               end;

               if (oIndx = -1) then begin
                  FSBOf.GetLoteFromSerie(Fecha, Articulo, Documento, Origen, SerieCode, SerieTable, var oRecordAux, var preStr, var postStr, var numberFormat, var numero, var lineaNumero);
                  inc(numero);
                  oSerie.CodeSerie := SerieCode;
                  oSerie.Linea     := lineaNumero;
                  oSerie.Numero    := numero;
                  oSerie.FormatoNumero := numberFormat;
                  oSerie.preStr     := preStr;
                  oSerie.postStr    := postStr;
                  oSerie.ActivosAgregados := oSerie.ActivosAgregados + 1;

                  s := '';
                  if (lineaNumero > -1) then
                     s := FSBOf.GetStrLote('', '+', oSerie.Numero.ToString, oSerie.FormatoNumero);
                  s := oSerie.preStr + s + oSerie.postStr;
                  oDBDSD.SetValue('U_ActCode' , i, s); 
                  oDBDSD.SetValue('U_ActName' , i, System.String(oRecordSet.Fields.Item('ItemName').Value).Trim + ' ' + s);
                  oSerie.ValorSerie := s;
               end
               else begin
                  oSerie.CodeSerie := TSerie(oListSeries[oIndx]).CodeSerie;
                  oSerie.Linea     := TSerie(oListSeries[oIndx]).Linea;
                  oSerie.FormatoNumero := TSerie(oListSeries[oIndx]).FormatoNumero;
                  oSerie.preStr     := TSerie(oListSeries[oIndx]).preStr;
                  oSerie.postStr    := TSerie(oListSeries[oIndx]).postStr;
                  numero := TSerie(oListSeries[oIndx]).Numero;
                  activosAgregados := TSerie(oListSeries[oIndx]).ActivosAgregados + 1;
                  inc(numero);
                  oSerie.Numero    := numero;
                  oSerie.ActivosAgregados := ActivosAgregados;

                  s := '';
                  if (lineaNumero > -1) then
                     s := FSBOf.GetStrLote('', '+', oSerie.Numero.ToString, oSerie.FormatoNumero);
                  s := oSerie.preStr + s + oSerie.postStr;
                  oDBDSD.SetValue('U_ActCode' , i, s); 
                  oDBDSD.SetValue('U_ActName' , i, System.String(oRecordSet.Fields.Item('ItemName').Value).Trim + ' ' + s);
                  oSerie.ValorSerie := s;
               end;

               oListSeries.Add(oSerie);
            end;


            dec(cant);
            inc(i);
         end;
         oRecordSet.MoveNext;
      end;
      oMtx.LoadFromDataSource;
      oDBDSD.Offset := 0;
      result := true;
   end
   else if (TipoDoc = 'S') then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select h.DocDate,    d.Quantity,  d.LineNum,     d.Linetotal,  d.project, d.ocrcode, d.ocrcode2, d.ocrcode3, d.ocrcode4, d.ocrcode5, g.U_IdSerie, " +
                  "       T2.intrserial, g.Code,      g.U_VidaUtil, g.U_VidaUtiF, isnull(g.U_VidaUtiR,12) U_VidaUtiR, " +  
                  "       d.ItemCode, d.StockPrice valor, month(h.DocDate) mes, year(h.DocDate) year,                 " +
                  "       d.TotalSumSy/d.Quantity ValorSys,                                                           " +
                  "       i.ItemName, h.DocNum, g.U_ItmGrpCd, g.U_IdSerie        " +
                  "  from OIGE h inner join IGE1 d  on h.DocEntry = d.DocEntry   " +
                  "              inner join OITM i  on i.ItemCode = d.ItemCode   " +
                  "              left Outer Join (select OSRI.intrserial, OSRI.ItemCode, SRI1.BaseType, SRI1.BaseEntry, SRI1.BaseLinNum   " +
                  "                                 from SRI1 inner join OSRI on OSRI.ItemCode  = SRI1.ItemCode and OSRI.SysSerial = SRI1.SysSerial ) T2   " +
                  "                               On  T2.ItemCode   = d.ItemCode and T2.BaseType   = d.ObjType and   " +
                  "                                   T2.BaseEntry  = d.DocEntry and T2.BaseLinNum = d.LineNum       " +
                  "                 left outer join [@VID_AFGR]   g  on i.U_VID_AFGr = g.Code                        " +
                  " where h.Docentry = {0}                                                                           " +
                  EsActivo +
                  "   and  i.InvntItem = 'Y' ", 
                  'Select h."DocDate",    d."Quantity",  d."LineNum",     d."LineTotal",  d."Project", d."OcrCode", d."OcrCode2", d."OcrCode3", d."OcrCode4", d."OcrCode5", g."U_IdSerie", ' +
                  '       T2."IntrSerial", g."Code",      g."U_VidaUtil", g."U_VidaUtIF", IfNull(g."U_VidaUtiR",12) "U_VidaUtiR",   ' +
                  '       d."ItemCode", d."StockPrice" "valor", month(h."DocDate") "mes", year(h."DocDate") "year",                 ' +
                  '       d."TotalSumSy"/d."Quantity" "ValorSys",                                                                   ' +
                  '       i."ItemName", h."DocNum", g."U_ItmGrpCd", g."U_IdSerie"        ' +
                  '  from OIGE h inner join IGE1 d  on h."DocEntry" = d."DocEntry"       ' +
                  '              inner join OITM i  on i."ItemCode" = d."ItemCode"       ' +
                  '              left Outer Join (select OSRI."IntrSerial", OSRI."ItemCode", SRI1."BaseType", SRI1."BaseEntry", SRI1."BaseLinNum"   ' +
                  '                                 from SRI1 inner join OSRI on OSRI."ItemCode"  = SRI1."ItemCode" and OSRI."SysSerial" = SRI1."SysSerial" ) T2   ' +
                  '                               On  T2."ItemCode"   = d."ItemCode" and T2."BaseType"   = d."ObjType" and   ' +
                  '                                   T2."BaseEntry"  = d."DocEntry" and T2."BaseLinNum" = d."LineNum"       ' +
                  '                 left outer join "@VID_AFGR"   g  on i."U_VID_AFGr" = g."Code"                            ' +
                  ' where h."DocEntry" = {0}                                                                                ' +
                  EsActivo +
                  '   and  i."InvntItem" = ''Y''');
      oSql := string.Format(oSql, DocEntry);
      oRecordSet.DoQuery(oSql);

      oDBDSH.SetValue('U_DocDate' , 0, FSBOf.DateToStr(System.DateTime(oRecordSet.Fields.Item('DocDate').Value)));
      oDBDSH.SetValue('U_DocEntry', 0, DocEntry);
      oDBDSH.SetValue('U_TipoDoc' , 0, 'S');

      m := System.int32(oRecordSet.Fields.Item('mes' ).Value);
      y := System.int32(oRecordSet.Fields.Item('year').Value);
      
      y := y + (m + Salto -1) div 12;
      m := (m + Salto) mod 12;
      if (m = 0) then
         m := 12;

      i := 0;
      oDBDSD.Clear;
      while (not oRecordSet.EoF) do begin
         d := System.Double(oRecordSet.Fields.Item('Quantity').Value);
         if (d - Math.Truncate(d) > 0) then
            cant := Convert.ToInt32(Math.Truncate(d)) + 1
         else
            cant := Convert.ToInt32(Math.Truncate(d));
         if (System.String(oRecordSet.Fields.Item('intrserial').Value).Trim <> '') then
            cant := 1;
         while (cant > 0) do begin
            oDBDSD.InsertRecord(oDBDSD.Size);
            oProject := System.String(oRecordSet.Fields.Item('Project').Value);
            if (oProject <> '')  then
               oProject := oProject.Trim;
            oCCosto := '';
            oCCosto2 := '';
            oCCosto3 := '';
            oCCosto4 := '';
            oCCosto5 := '';
            if (System.String(oRecordSet.Fields.Item('ocrcode').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode').Value) <> nil) then
               oCCosto := System.String(oRecordSet.Fields.Item('ocrcode').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode2').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode2').Value) <> nil) then
               oCCosto2 := System.String(oRecordSet.Fields.Item('ocrcode2').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode3').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode3').Value) <> nil) then
               oCCosto3 := System.String(oRecordSet.Fields.Item('ocrcode3').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode4').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode4').Value) <> nil) then
               oCCosto4 := System.String(oRecordSet.Fields.Item('ocrcode4').Value);
            if (System.String(oRecordSet.Fields.Item('ocrcode5').Value) <> '') and (System.String(oRecordSet.Fields.Item('ocrcode5').Value) <> nil) then
               oCCosto5 := System.String(oRecordSet.Fields.Item('ocrcode5').Value);
            if (oCCosto <> '')  then
               oCCosto := oCCosto.Trim;
            if (oCCosto2 <> '')  then
               oCCosto2 := oCCosto2.Trim;
            if (oCCosto3 <> '')  then
               oCCosto3 := oCCosto3.Trim;
            if (oCCosto4 <> '')  then
               oCCosto4 := oCCosto4.Trim;
            if (oCCosto5 <> '')  then
               oCCosto5 := oCCosto5.Trim;
            oDBDSD.SetValue('U_Ingresar', i, 'N');
            oDBDSD.SetValue('U_Bis33'   , i, 'N');
            oDBDSD.SetValue('U_ItemCode', i, System.String(oRecordSet.Fields.Item('ItemCode').Value).Trim);
            oDBDSD.SetValue('U_OriValCo', i, FSBOf.DoubleToStr(System.double(oRecordSet.Fields.Item('valor').Value)));
            oDBDSD.SetValue('U_VidaUtil', i, System.int32(oRecordSet.Fields.Item('U_VidaUtil').Value).ToString);
            oDBDSD.SetValue('U_VidaUtiR', i, System.int32(oRecordSet.Fields.Item('U_VidaUtiR').Value).ToString);
            oDBDSD.SetValue('U_VidaUtiF', i, System.int32(oRecordSet.Fields.Item('U_VidaUtiF').Value).ToString);
            oDBDSD.SetValue('U_InitYear', i, y.ToString);
            oDBDSD.SetValue('U_InitPer' , i, m.ToString);
            oDBDSD.SetValue('U_ItmGrpCd', i, System.String(oRecordSet.Fields.Item('Code').Value).Trim);
            oDBDSD.SetValue('U_ActSerNu', i, System.String(oRecordSet.Fields.Item('intrserial').Value).Trim);
            oDBDSD.SetValue('U_Project' , i, oProject);
            oDBDSD.SetValue('U_ProfitCt', i, oCCosto);
            oDBDSD.SetValue('U_ProfitC2', i, oCCosto2);
            oDBDSD.SetValue('U_ProfitC3', i, oCCosto3);
            oDBDSD.SetValue('U_ProfitC4', i, oCCosto4);
            oDBDSD.SetValue('U_ProfitC5', i, oCCosto5);
            oValorSys.Add(System.double(oRecordSet.Fields.Item('ValorSys').Value));

            Fecha      := FSBOf.DateToStr(System.DateTime(oRecordSet.Fields.Item('DocDate').Value));
            Documento  := System.Int32(oRecordSet.Fields.Item('DocNum').Value).ToString;
            Origen     := 'S';
            Articulo   := System.String(oRecordSet.Fields.Item('ItemCode').Value).Trim;
            SerieCode  := System.String(oRecordSet.Fields.Item('U_IdSerie').Value).Trim;
            SerieTable := iif(GlobalSettings.RunningUnderSQLServer, '[@VID_AFDEFSERIED]', '@VID_AFDEFSERIED');

            oSerie := new TSerie;
            oSerie.CodeSerie := '';
            oSerie.Linea     := -1;
            oSerie.Numero    := -1;
            oSerie.FormatoNumero := '';
            oSerie.preStr     := '';
            oSerie.postStr    := '';
            oSerie.ActivosAgregados := 0;


            if (System.String(oRecordSet.Fields.Item('Code').Value).Trim = '') or (System.String(oRecordSet.Fields.Item('Code').Value) = nil) or (System.String(oRecordSet.Fields.Item('U_IdSerie').Value).Trim = '') or (System.String(oRecordSet.Fields.Item('U_IdSerie').Value) = nil) then begin
               oSerie.ValorSerie := 'S.' + DocEntry + '.' + TMultiFunctions.inttostr(i);
               oDBDSD.SetValue('U_ActCode' , i, oSerie.ValorSerie); 
               oDBDSD.SetValue('U_ActName' , i, 'S.' + DocEntry + '.' + TMultiFunctions.inttostr(i) + '- ' + System.String(oRecordSet.Fields.Item('ItemName').Value).Trim );
            end
            else begin
               oIndx := -1;
               for k:=oListSeries.Count-1 downto 0 do begin
                  s := TSerie(oListSeries[k]).CodeSerie;
                  if (s = System.String(oRecordSet.Fields.Item('U_IdSerie').Value).Trim) then begin
                     oIndx := k;
                     break;
                  end;
               end;

               if (oIndx = -1) then begin
                  FSBOf.GetLoteFromSerie(Fecha, Articulo, Documento, Origen, SerieCode, SerieTable, var oRecordAux, var preStr, var postStr, var numberFormat, var numero, var lineaNumero);
                  inc(numero);
                  oSerie.CodeSerie := SerieCode;
                  oSerie.Linea     := lineaNumero;
                  oSerie.Numero    := numero;
                  oSerie.FormatoNumero := numberFormat;
                  oSerie.preStr     := preStr;
                  oSerie.postStr    := postStr;
                  oSerie.ActivosAgregados := oSerie.ActivosAgregados + 1;

                  s := '';
                  if (lineaNumero > -1) then
                     s := FSBOf.GetStrLote('', '+', oSerie.Numero.ToString, oSerie.FormatoNumero);
                  s := oSerie.preStr + s + oSerie.postStr;
                  oDBDSD.SetValue('U_ActCode' , i, s); 
                  oDBDSD.SetValue('U_ActName' , i, System.String(oRecordSet.Fields.Item('ItemName').Value).Trim + ' ' + s);
                  oSerie.ValorSerie := s;
               end
               else begin
                  oSerie.CodeSerie := TSerie(oListSeries[oIndx]).CodeSerie;
                  oSerie.Linea     := TSerie(oListSeries[oIndx]).Linea;
                  oSerie.FormatoNumero := TSerie(oListSeries[oIndx]).FormatoNumero;
                  oSerie.preStr     := TSerie(oListSeries[oIndx]).preStr;
                  oSerie.postStr    := TSerie(oListSeries[oIndx]).postStr;
                  numero := TSerie(oListSeries[oIndx]).Numero;
                  activosAgregados := TSerie(oListSeries[oIndx]).ActivosAgregados + 1;
                  inc(numero);
                  oSerie.Numero    := numero;
                  oSerie.ActivosAgregados := activosAgregados;

                  s := '';
                  if (lineaNumero > -1) then
                     s := FSBOf.GetStrLote('', '+', oSerie.Numero.ToString, oSerie.FormatoNumero);
                  s := oSerie.preStr + s + oSerie.postStr;
                  oDBDSD.SetValue('U_ActCode' , i, s); 
                  oDBDSD.SetValue('U_ActName' , i, System.String(oRecordSet.Fields.Item('ItemName').Value).Trim + ' ' + s);
                  oSerie.ValorSerie := s;
               end;

               oListSeries.Add(oSerie);
            end;

            dec(cant);
            inc(i);
         end;
         oRecordSet.MoveNext;
      end;
      oMtx.LoadFromDataSource;
      oDBDSD.Offset := 0;
      result := true;
   end;
end;

method  TAdquisicionActivos.VerificarExistencia(oForm: SAPbouiCOM.Form): boolean;
var
   oDBDSD : SAPbouiCOM.DBDataSource;
   i,j    : integer;
   y,m,d  : integer;
   Yr, Pr : integer;
   oSql   : string;
begin
   result  := false;
   Matrix(oForm.Items.Item('mtx_0').Specific).FlushToDataSource;
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFADQD');

   if (oForm.DataSources.DBDataSources.Item('@VID_AFADQ').GetValue('U_DocDate', 0) = '') or (oForm.DataSources.DBDataSources.Item('@VID_AFADQ').GetValue('U_DocDate', 0) = nil) then
       raise New exception('Debe ingresar fecha de ingreso de activos.');

    y := FSBOf.StrToDate(oForm.DataSources.DBDataSources.Item('@VID_AFADQ').GetValue('U_DocDate', 0)).Year;
    m := FSBOf.StrToDate(oForm.DataSources.DBDataSources.Item('@VID_AFADQ').GetValue('U_DocDate', 0)).Month;
    d := FSBOf.StrToDate(oForm.DataSources.DBDataSources.Item('@VID_AFADQ').GetValue('U_DocDate', 0)).Day;
   Yr := y;
   Pr := m;

   j := 0;
   for i:=0 to oDBDSD.Size-1 do
      if (oDBDSD.GetValue('U_Ingresar', i) = 'Y') then begin
         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_VidaUtil', i) ) < 0) then
            raise New exception('Vida util debe ser mayor o igual a 0, en linea ' + TMultiFunctions.inttostr(i+1));

         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_VidaUtiR', i) ) < 0) then
            raise New exception('Vida util referencial debe ser mayor o igual a 0, en linea ' + TMultiFunctions.inttostr(i+1));

         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_VidaUtiF', i) ) < 0) and ((GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo)) then
            raise New exception('Vida util IFRS debe ser mayor o igual a 0, en linea ' + TMultiFunctions.inttostr(i+1));

         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_OriValCo', i) ) <= 0) then
            raise New exception('Valor del activo debe ser mayor a 0, en linea ' + TMultiFunctions.inttostr(i+1));

         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_InitYear', i) ) < Yr) then
            raise New exception('Primera depreciación no puede ser anterior al mes de ingreso, en linea ' + TMultiFunctions.inttostr(i+1));

         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_InitPer', i) ) < 1) or (FSBOf.StrToDouble( oDBDSD.GetValue('U_InitPer', i) ) > 12) then
            raise New exception('Periodo de Primera depreciación debe estar entre 1 y 12, en linea ' + TMultiFunctions.inttostr(i+1));

         if (FSBOf.StrToDouble( oDBDSD.GetValue('U_InitPer', i) ) < Pr) and (FSBOf.StrToDouble( oDBDSD.GetValue('U_InitYear', i) ) = Yr) then
            raise New exception('Primera depreciación no puede ser anterior al mes de ingreso, en linea ' + TMultiFunctions.inttostr(i+1));

//         if (oDBDSD.GetValue('U_LocCode', i).Trim = '') then
//            raise New exception('Ubicación de activo debe ingresarse, en linea ' + inttostr(i+1));

         if (oDBDSD.GetValue('U_ItmGrpCd', i).Trim = '') then
            raise New exception('Grupo de activos debe ingresarse, en linea ' + TMultiFunctions.inttostr(i+1));

         if (oDBDSD.GetValue('U_ActCode', i).Trim = '') then
            raise New exception('Codigo de activo debe ingresarse, en linea ' + TMultiFunctions.inttostr(i+1));

         oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select count(*) cant from [@VID_AFAS] where U_ActCode = '{0}'", 
                     'Select count(*) "cant" from "@VID_AFAS" where "U_ActCode" = ''{0}''');
         oSql := string.Format(oSql, oDBDSD.GetValue('U_ActCode', i));
         oRecordSet.DoQuery(oSql);
         if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then
            raise New exception('Codigo de activo existente ' + oDBDSD.GetValue('U_ActCode', i).trim + ' en linea ' + TMultiFunctions.inttostr(i+1));

         inc(j);
      end;

      if (j = 0) then
         raise New exception('No se han seleccionado activos para ingresar ');

   result := true;
end;

method  TAdquisicionActivos.IngresarActivosFijos(oForm: SAPbouiCOM.Form): boolean;
var
   oDBDSD           : SAPbouiCOM.DBDataSource;
   oDBDSH           : SAPbouiCOM.DBDataSource;
   oActivos         : SAPbobsCOM.GeneralService;
   oActivosData     : SAPbobsCOM.GeneralData;
   oActivosIFRS     : SAPbobsCOM.GeneralService;
   oActivosIFRSData : SAPbobsCOM.GeneralData;
   oListaActivo     : List<SAPbobsCOM.GeneralData>;
   oListaActivoIFRS : List<SAPbobsCOM.GeneralData>;
   i, j, cero       : integer;
   k1, k2           : Integer; 
   s                : string;
   y,m,d            : integer;
   oItemCode        : string;
   oItemName        : string;
   oUbiCode         : string;
   oUbiName         : string;
   SaltoPeriodo     : integer;
   oSql             : string;
begin
   result  := false;
   cero    := 0;
   Matrix(oForm.Items.Item('mtx_0').Specific).FlushToDataSource;
   oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFADQ');
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFADQD');

   oActivos     := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFAS'));
   oActivosIFRS := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFASIF'));

   oListaActivo     := new List<SAPbobsCOM.GeneralData>;
   oListaActivoIFRS := new List<SAPbobsCOM.GeneralData>;

   oSql := iif(GlobalSettings.RunningUnderSQLServer, 
               "Select U_Jmp1Depr from [@VID_AFPA]", 
               'Select "U_Jmp1Depr" from "@VID_AFPA"');
   oRecordSet.DoQuery(oSql);
   SaltoPeriodo := 0;
   if (not oRecordSet.EoF) then begin
      SaltoPeriodo := System.Int32(oRecordSet.Fields.Item('U_Jmp1Depr').Value);
      if (SaltoPeriodo < 0) then
         SaltoPeriodo := 0;
   end;

    y := FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)).Year;
    m := FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)).Month;
    d := FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)).Day;

   k1 := 0;
   k2 := 0;
   for i:=0 to oDBDSD.Size-1 do begin
      if (oDBDSD.GetValue('U_Ingresar', i) <> 'Y') then
         continue;

      oItemCode := '';
      oItemName := '';
      oUbiCode  := '';
      oUbiName  := '';

      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select i.ItemCode, i.ItemName " +
                  "  from OITM i          " +
                  " where i.Itemcode = '{0}'", 
                  'Select i."ItemCode", i."ItemName" ' +
                  '  from OITM i          ' +
                  ' where i."ItemCode" = ''{0}''');
      oSql := string.Format(oSql, oDBDSD.GetValue('U_ItemCode', i).Trim);
      oRecordSet.DoQuery(oSql);
      if (not oRecordSet.EoF) then begin
         oItemCode := System.String(oRecordSet.Fields.Item('ItemCode').Value).Trim;
         oItemName := System.String(oRecordSet.Fields.Item('ItemName').Value).Trim;
      end;

      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select lo.Code, lo.Name " +
                  "  from [@VID_AFLOC] lo  " +
                  " where lo.Code    = '{0}'", 
                  'Select lo."Code", lo."Name" ' +
                  '  from "@VID_AFLOC" lo  ' +
                  ' where lo."Code"    = ''{0}''');
      oSql := string.Format(oSql, oDBDSD.GetValue('U_LocCode' , i).Trim);
      oRecordSet.DoQuery(oSql);
      if (not oRecordSet.EoF) then begin
         oUbiCode := System.String(oRecordSet.Fields.Item('Code').Value).Trim;
         oUbiName := System.String(oRecordSet.Fields.Item('Name').Value).Trim;
      end;

      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select af.U_CtaActFi, af.U_CtaDepAc, af.U_CtaCorAF, af.U_CtaCorDA, af.U_CtaGasDe, af.U_CtaGasBj, af.U_CtaAdqAc, af.U_CtaBis33, af.U_CtaReaAF, af.U_CtaDetAF " +
                  "  from [@VID_AFGR]  af " +
                  " where af.Code    = '{0}'", 
                  'Select af."U_CtaActFi", af."U_CtaDepAc", af."U_CtaCorAF", af."U_CtaCorDA", af."U_CtaGasDe", af."U_CtaGasBj", af."U_CtaAdqAc", af."U_CtaBis33", af."U_CtaReaAF", af."U_CtaDetAF" ' +
                  '  from "@VID_AFGR"  af ' +
                  ' where af."Code"    = ''{0}''');
      oSql := string.Format(oSql, oDBDSD.GetValue('U_ItmGrpCd', i).Trim);
      oRecordSet.DoQuery(oSql);

      oActivosData := GeneralData(oActivos.GetDataInterface(GeneralServiceDataInterfaces.gsGeneralData));

      oActivosData.SetProperty('U_ItmGrpCd' , oDBDSD.GetValue('U_ItmGrpCd', i).Trim );
      oActivosData.SetProperty('U_ItemCode' , oItemCode );
      oActivosData.SetProperty('U_ItemName' , oItemName );
      oActivosData.SetProperty('U_InvNum'   , FSBOf.StrToInteger(oDBDSH.GetValue('U_DocEntry', 0)));
      oActivosData.SetProperty('U_InvLine'  , cero);
      oActivosData.SetProperty('U_InvDate'  , FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)));

      oActivosData.SetProperty('U_ActCode'  , oDBDSD.GetValue('U_ActCode' , i).Trim);
      oActivosData.SetProperty('U_ActName'  , oDBDSD.GetValue('U_ActName' , i).Trim);
      oActivosData.SetProperty('U_ActSerNu' , oDBDSD.GetValue('U_ActSerNu', i).Trim);
      oActivosData.SetProperty('U_CtaActFi' , system.String(oRecordSet.Fields.Item('U_CtaActFi'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaAdqAc' , system.String(oRecordSet.Fields.Item('U_CtaAdqAc'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaCorAF' , system.String(oRecordSet.Fields.Item('U_CtaCorAF'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaCorDA' , system.String(oRecordSet.Fields.Item('U_CtaCorDA'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaDepAc' , system.String(oRecordSet.Fields.Item('U_CtaDepAc'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaGasDe' , system.String(oRecordSet.Fields.Item('U_CtaGasDe'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaGasBj' , system.String(oRecordSet.Fields.Item('U_CtaGasBj'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaBis33' , system.String(oRecordSet.Fields.Item('U_CtaBis33'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaReaAF' , system.String(oRecordSet.Fields.Item('U_CtaReaAF'  ).Value).Trim);
      oActivosData.SetProperty('U_CtaDetAF' , system.String(oRecordSet.Fields.Item('U_CtaDetAF'  ).Value).Trim);
      oActivosData.SetProperty('U_Project'  , oDBDSD.GetValue('U_Project'  , i).Trim);
      oActivosData.SetProperty('U_ProfitCt' , oDBDSD.GetValue('U_ProfitCt' , i).Trim);
      oActivosData.SetProperty('U_ProfitC2' , oDBDSD.GetValue('U_ProfitC2' , i).Trim);
      oActivosData.SetProperty('U_ProfitC3' , oDBDSD.GetValue('U_ProfitC3' , i).Trim);
      oActivosData.SetProperty('U_ProfitC4' , oDBDSD.GetValue('U_ProfitC4' , i).Trim);
      oActivosData.SetProperty('U_ProfitC5' , oDBDSD.GetValue('U_ProfitC5' , i).Trim);
      s := 'Y';
      oActivosData.SetProperty('U_ConDepre' , s);
      oActivosData.SetProperty('U_ConCorre' , s);
      oActivosData.SetProperty('U_InDate'   , FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)));
      oActivosData.SetProperty('U_InitYear' , y);
      oActivosData.SetProperty('U_InitPer'  , m);
      oActivosData.SetProperty('U_PerVidaU' , FSBOf.StrToInteger(oDBDSD.GetValue('U_VidaUtil', i)));

      oActivosData.SetProperty('U_NxYrDepr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitYear', i)));
      oActivosData.SetProperty('U_NxPrDepr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitPer' , i)));
      oActivosData.SetProperty('U_NxYrCorr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitYear', i)));
      oActivosData.SetProperty('U_NxPrCorr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitPer' , i)));
      oActivosData.SetProperty('U_NextYear' , y);
      oActivosData.SetProperty('U_NextPer'  , m);

      if (oPostSysCu) then
         oActivosData.SetProperty('U_OriVal'   , oValorSys[i])
      else
         oActivosData.SetProperty('U_OriVal'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
//      oActivosData.SetProperty('U_OriVal'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosData.SetProperty('U_OriFec'   , FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)));

      if (oPostSysCu) then
         oActivosData.SetProperty('U_OriValCo'   , oValorSys[i])
      else
         oActivosData.SetProperty('U_OriValCo'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
//      oActivosData.SetProperty('U_OriValCo' , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosData.SetProperty('U_PorResid' , cero);
      oActivosData.SetProperty('U_OriPerDp' , cero);
      oActivosData.SetProperty('U_OriDepre' , cero);
      oActivosData.SetProperty('U_VidaUtil' , FSBOf.StrToInteger(oDBDSD.GetValue('U_VidaUtil', i)));
      oActivosData.SetProperty('U_PerDepre' , cero);
      if (oPostSysCu) then
         oActivosData.SetProperty('U_CurVal'   , oValorSys[i])
      else
         oActivosData.SetProperty('U_CurVal'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
//      oActivosData.SetProperty('U_CurVal'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosData.SetProperty('U_DepAcum'  , cero);
      oActivosData.SetProperty('U_CorAnuAc' , cero);
      oActivosData.SetProperty('U_CorAnuDe' , cero);
      oActivosData.SetProperty('U_DepreAnu' , cero);
      s := 'N';
      oActivosData.SetProperty('U_Bis33Flg' , oDBDSD.GetValue('U_Bis33'   , i).Trim );
      oActivosData.SetProperty('U_VidaUtiR' , FSBOf.StrToInteger(oDBDSD.GetValue('U_VidaUtiR', i)));
      oActivosData.SetProperty('U_CurValR'  , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosData.SetProperty('U_PorResiR' , cero);
      oActivosData.SetProperty('U_DepAcuR'  , cero);
      oActivosData.SetProperty('U_AdicAnuR' , cero);
      oActivosData.SetProperty('U_CorAnuAR' , cero);
      oActivosData.SetProperty('U_CorAnuDR' , cero);
      oActivosData.SetProperty('U_DepreAnR' , cero);
      oActivosData.SetProperty('U_PerVidaR' , FSBOf.StrToInteger(oDBDSD.GetValue('U_VidaUtiR', i)));
      oActivosData.SetProperty('U_PRrDepre' , cero);
      oActivosData.SetProperty('U_PRrDepYr' , cero);
      oActivosData.SetProperty('U_OriValCR' , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosData.SetProperty('U_OriPerDR' , cero);
      oActivosData.SetProperty('U_OriDeprR' , cero);
      oActivosData.SetProperty('U_LocCode'  , oUbiCode);
      oActivosData.SetProperty('U_LocName'  , oUbiName);
      oActivosData.SetProperty('U_DeBaja'   , s);

      inc(k1);
      s := iif(GlobalSettings.RunningUnderSQLServer, 'Select max(isnull(DocEntry, 0)) Nro from [@VID_AFAS] ', 'Select max(ifnull("DocEntry", 0)) "Nro" from "@VID_AFAS" ');
      oRecordSet.DoQuery(s);
      j := System.Int32(oRecordSet.Fields.Item('Nro').Value) + k1;

      s := j.ToString;
      oActivosData.SetProperty('Code'       , s);
      oActivosData.SetProperty('Name'       , s);

      oListaActivo.Add(oActivosData);

      if (not ((GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo))) then
         Continue;

// IFRS
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select af.U_CtaActFi, af.U_CtaDepAc, af.U_CtIReaAF, af.U_CtIDetAF, af.U_CtIGasDe, af.U_CtIGasBj, af.U_CtIAdqAc " +
                  "  from [@VID_AFGR]  af " +
                  " where af.Code    = '{0}'", 
                  'Select af."U_CtaActFi", af."U_CtaDepAc", af."U_CtIReaAF", af."U_CtIDetAF", af."U_CtIGasDe", af."U_CtIGasBj", af."U_CtIAdqAc" ' +
                  '  from "@VID_AFGR"  af ' +
                  ' where af."Code"    = ''{0}''');
      oSql := string.Format(oSql, oDBDSD.GetValue('U_ItmGrpCd', i).Trim);
      oRecordSet.DoQuery(oSql);

      oActivosIFRSData := GeneralData(oActivosIFRS.GetDataInterface(GeneralServiceDataInterfaces.gsGeneralData));

      oActivosIFRSData.SetProperty('U_ItmGrpCd' , oDBDSD.GetValue('U_ItmGrpCd', i).Trim );
      oActivosIFRSData.SetProperty('U_ItemCode' , oItemCode );
      oActivosIFRSData.SetProperty('U_ItemName' , oItemName );
      oActivosIFRSData.SetProperty('U_InvNum'   , FSBOf.StrToInteger(oDBDSH.GetValue('U_DocEntry', 0)));
      oActivosIFRSData.SetProperty('U_InvLine'  , cero);
      oActivosIFRSData.SetProperty('U_InvDate'  , FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)));

      oActivosIFRSData.SetProperty('U_ActCode'  , oDBDSD.GetValue('U_ActCode' , i).Trim);
      oActivosIFRSData.SetProperty('U_ActName'  , oDBDSD.GetValue('U_ActName' , i).Trim);
      oActivosIFRSData.SetProperty('U_ActSerNu' , oDBDSD.GetValue('U_ActSerNu', i).Trim);
      oActivosIFRSData.SetProperty('U_CtaActFi' , system.String(oRecordSet.Fields.Item('U_CtIActFi'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_CtaAdqAc' , system.String(oRecordSet.Fields.Item('U_CtIAdqAc'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_CtaReaAF' , system.String(oRecordSet.Fields.Item('U_CtIReaAF'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_CtaDetAF' , system.String(oRecordSet.Fields.Item('U_CtIDetAF'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_CtaDepAc' , system.String(oRecordSet.Fields.Item('U_CtIDepAc'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_CtaGasDe' , system.String(oRecordSet.Fields.Item('U_CtIGasDe'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_CtaGasBj' , system.String(oRecordSet.Fields.Item('U_CtIGasBj'  ).Value).Trim);
      oActivosIFRSData.SetProperty('U_Project'  , oDBDSD.GetValue('U_Project'  , i).Trim);
      oActivosIFRSData.SetProperty('U_ProfitCt' , oDBDSD.GetValue('U_ProfitCt' , i).Trim);
      oActivosIFRSData.SetProperty('U_ProfitC2' , oDBDSD.GetValue('U_ProfitC2' , i).Trim);
      oActivosIFRSData.SetProperty('U_ProfitC3' , oDBDSD.GetValue('U_ProfitC3' , i).Trim);
      oActivosIFRSData.SetProperty('U_ProfitC4' , oDBDSD.GetValue('U_ProfitC4' , i).Trim);
      oActivosIFRSData.SetProperty('U_ProfitC5' , oDBDSD.GetValue('U_ProfitC5' , i).Trim);
      s := 'Y';
      oActivosIFRSData.SetProperty('U_ConDepre' , s);
      oActivosIFRSData.SetProperty('U_ConCorre' , s);
      oActivosIFRSData.SetProperty('U_InDate'   , FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)));
      oActivosIFRSData.SetProperty('U_InitYear' , y);
      oActivosIFRSData.SetProperty('U_InitPer'  , m);
      oActivosIFRSData.SetProperty('U_PerVidaU' , FSBOf.StrToInteger(oDBDSD.GetValue('U_VidaUtiF', i)));

      oActivosIFRSData.SetProperty('U_NxYrDepr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitYear', i)));
      oActivosIFRSData.SetProperty('U_NxPrDepr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitPer' , i)));
      oActivosIFRSData.SetProperty('U_NxYrCorr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitYear', i)));
      oActivosIFRSData.SetProperty('U_NxPrCorr' , FSBOf.StrToInteger(oDBDSD.GetValue('U_InitPer' , i)));
      oActivosIFRSData.SetProperty('U_NextYear' , y);
      oActivosIFRSData.SetProperty('U_NextPer'  , m);

      oActivosIFRSData.SetProperty('U_OriVal'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosIFRSData.SetProperty('U_OriFec'   , FSBOf.StrToDate(oDBDSH.GetValue('U_DocDate', 0)));

      oActivosIFRSData.SetProperty('U_OriValIn' , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosIFRSData.SetProperty('U_PorResid' , cero);
      oActivosIFRSData.SetProperty('U_OriPerDp' , cero);
      oActivosIFRSData.SetProperty('U_OriDepre' , cero);
      oActivosIFRSData.SetProperty('U_VidaUtil' , FSBOf.StrToInteger(oDBDSD.GetValue('U_VidaUtiF', i)));
      oActivosIFRSData.SetProperty('U_PerDepre' , cero);
      oActivosIFRSData.SetProperty('U_CurVal'   , FSBOf.StrToDouble(oDBDSD.GetValue('U_OriValCo' , i)));
      oActivosIFRSData.SetProperty('U_DepAcum'  , cero);
      oActivosIFRSData.SetProperty('U_DepreAnu' , cero);
      s := 'N';
      oActivosIFRSData.SetProperty('U_LocCode'  , oUbiCode);
      oActivosIFRSData.SetProperty('U_LocName'  , oUbiName);
      oActivosIFRSData.SetProperty('U_DeBaja'   , s);

      inc(k2);
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select max(isnull(DocEntry, 0)) Nro from [@VID_AFASIF]", 
                  'Select max(IfNull("DocEntry", 0)) "Nro" from "@VID_AFASIF"');
      oRecordSet.DoQuery(oSql);
      j := System.Int32(oRecordSet.Fields.Item('Nro').Value) + k2;

      s := j.ToString;
      oActivosIFRSData.SetProperty('Code'       , s);
      oActivosIFRSData.SetProperty('Name'       , s);

      oListaActivoIFRS.Add(oActivosIFRSData);

   end;

   i  := oListSeries.Count - 1;
   k1 := oListSeries.Count - 1;
   k2 := 0;
   while (k1 >= 0) do begin
      s :=  TSerie(oListSeries[k1]).CodeSerie;
      for j:=k1-1 downto 0 do 
         if (s = TSerie(oListSeries[j]).CodeSerie) then
            oListSeries.RemoveAt(j);

      inc(k2);
      k1 := oListSeries.Count - 1 - k2;
   end;

   for i:=0 to oListSeries.Count-1 do
      UpdateLoteSerie(TSerie(oListSeries[i]).ActivosAgregados.ToString, TSerie(oListSeries[i]).Linea.ToString, TSerie(oListSeries[i]).CodeSerie, 'VID_AFDefSerie', 'VID_AFDEFSERIED'); 

   for i:=0 to oListaActivo.Count-1 do 
      oActivos.Add(SAPbobsCOM.GeneralData(oListaActivo[i]));

   if ((GlobalSettings.IFRSActivo) and (not GlobalSettings.IFRSNativo)) then
      for i:=0 to oListaActivo.Count-1 do
         oActivosIFRS.Add(SAPbobsCOM.GeneralData(oListaActivoIFRS[i]));

end;

method  TAdquisicionActivos.UpdateLoteSerie(Valor, Linea, Serie, SeriesObj, SeriesLines : String);
var
   oSeries           : SAPbobsCOM.GeneralService;
   oSeriesData       : SAPbobsCOM.GeneralData;
   oSeriesParameter  : SAPbobsCOM.GeneralDataParams;
   oSeriesLines      : SAPbobsCOM.GeneralDataCollection;
   oSeriesLinesData  : SAPbobsCOM.GeneralData;
   i, lin            : Integer;
begin
   try
      oSeries          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService(SeriesObj));
      oSeriesParameter := SAPbobsCOM.GeneralDataParams(oSeries.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
      oSeriesParameter.SetProperty('Code', Serie);
      oSeriesData      := oSeries.GetByParams(oSeriesParameter);
      oSeriesLines     := oSeriesData.Child(SeriesLines);

      lin := -1;
      for i:=0 to oSeriesLines.Count-1 do begin
         oSeriesLinesData := oSeriesLines.Item(i);
         if (System.int32(oSeriesLinesData.GetProperty('LineId')).ToString = Linea) then begin
            lin := i;
            break;
         end;
      end;

      if (lin > -1) then begin
         var u_s: string:= System.String(oSeriesLinesData.GetProperty('U_string'));
         var u_i: Integer:= int32.parse(u_s) + int32.parse(Valor);
         u_s:=u_i.ToString;
         oSeriesLinesData.SetProperty('U_string', u_s);
         oSeries.Update(oSeriesData);
      end;
   finally
      _ReleaseCOMObject(oSeries);
      _ReleaseCOMObject(oSeriesData);
      _ReleaseCOMObject(oSeriesParameter);
      _ReleaseCOMObject(oSeriesLines);
      _ReleaseCOMObject(oSeriesLinesData);
   end;
end;

method TAdquisicionActivos._ReleaseCOMObject(_Object :Object) : Integer;
Begin
   if (_Object <> nil) Then Begin
      if (System.Runtime.InteropServices.Marshal.IsComObject(_Object)) Then 
         Result := System.Runtime.InteropServices.Marshal.ReleaseComObject(_Object)
      else
         Result := 0;
      _Object := nil;
   end
   else
      Result:=0;
end;

end.
