namespace AF_IFRS.RevalorizacionIFRS;

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
  Visuald.ReportWindowFr;

type
  TRevalorizacionIFRS = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    Lista:      List<String>;
    ListaMx:    List<String>;
    FQueryCFL:  string;
    PeriodoProcesado: boolean := false;
    oActCode_Before:  string := '';
    method   ValidacionFinal(var oForm: SAPbouiCOM.Form; var mtx: SAPbouiCOM.Matrix): boolean;
    method   AddChooseFromList(var oForm: SAPbouiCOM.Form);
    method   ChooseFromListSubQuery(nper, nyear : string);
    method   LimpiarFila(var oForm: SAPbouiCOM.Form);
    method   DeleteReval(var oForm: SAPbouiCOM.Form): boolean;
    method   IngresarTrx(var oForm: SAPbouiCOM.Form): boolean;
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method  FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean); reintroduce;
    method  MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean); reintroduce;
    property  QueryCFL: string read FQueryCFL write FQueryCFL;
  end;

implementation

uses
  System.Globalization;

method   TRevalorizacionIFRS.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista     := New List<String>;
   ListaMx   := New List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_RevalorizacionActivosIFRS_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_RevalorizacionActivosIFRS.srf', Uid);

      oForm   := FSBOApp.Forms.Item(uid);
      VID_DelRow := true;

      oForm.Freeze(True);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := 15;             // afm_All

                           // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'Fecha    ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'Year     ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'Periodo  ,  f,  f,  t,  f, r, 1 ');
      Lista.Add( 'Comments ,  f,  t,  t,  f, n, 1 ');
      Lista.Add( 'mtx_0    ,  f,  t,  f,  f, n, 1 ');
      FSBOf.SetAutoManaged(oForm, Lista);

      ListaMx.Add('ActCode  , r ,   ');
      ListaMx.Add('NewVal   , r , >0');

      oForm.Items.Item("Procesad").AffectsFormMode := false;

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      if (not GlobalSettings.IFRSActivo) then
         exit;

        // CFL ItemCode
      AddChooseFromList(var oForm);
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListUID   := 'CFLAct';
      Matrix(oForm.Items.Item('mtx_0').Specific).Columns.Item('ActCode').ChooseFromListAlias := 'U_ActCode';

//      LinkedButton(oForm.Items.Item('lnkCalen').Specific).LinkedObject := BoLinkedObject.lf_None;

      oForm.Items.Item('btnDel').Visible := true;

      oForm.Freeze(False);
      oForm.DataBrowser.BrowseBy := 'DocEntry';

      oForm.Visible := true;

      System.Runtime.InteropServices.Marshal.ReleaseComObject(oForm);
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TRevalorizacionIFRS.ChooseFromListSubQuery(nper, nyear : string);
Var
   oSql     : String;
   Tabla    : String;
begin
    GlobalSettings.GLOB_DocEntry := '-1';
    if (GlobalSettings.IFRSNativo) then 
       Tabla := iif(GlobalSettings.RunningUnderSQLServer, "[@VID_AFAS]",  '"@VID_AFAS"' )
    else
       Tabla := iif(GlobalSettings.RunningUnderSQLServer, "[@VID_AFASIF]", '"@VID_AFASIF"');

    oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                "Select U_ActCode 'Código', U_ActName 'Descripción', U_CorAnuAc 'Valor actual', U_AdicAnuC 'Adición anual', U_DepAcum 'Dep. acumulada', " +
                "       U_DepreAnu 'Dep. anual', DocEntry  " +
                "  from  " + Tabla +
                " where U_DeBaja   = 'N' " +
                "   and U_NextPer  = {0} " +
                "   and U_NextYear = {1} " +
                "   and U_ActCode <> 'T' " +
                "   and U_ActCode not in (Select distinct d.U_ActCode " +
                "                           from [@VID_AFREV] h inner join [@VID_AFREVD] d on h.DocEntry = d.DocEntry " +
                "                          where h.U_Year     = {1} " +
                "                            and h.U_Periodo  = {0} ) ", 
                'Select "U_ActCode" "Código", "U_ActName" "Descripción", "U_CorAnuAc" "Valor actual", "U_AdicAnuC" "Adición anual", "U_DepAcum" "Dep. acumulada", ' +
                '       "U_DepreAnu" "Dep. anual", "DocEntry"  ' +
                '  from  ' + Tabla +
                ' where "U_DeBaja"   = ''N'' ' +
                '   and "U_NextPer"  = {0}   ' +
                '   and "U_NextYear" = {1}   ' +
                '   and "U_ActCode" <> ''T'' ' +
                '   and "U_ActCode" not in (Select distinct d."U_ActCode" ' +
                '                           from "@VID_AFREV" h inner join "@VID_AFREVD" d on h."DocEntry" = d."DocEntry" ' +
                '                          where h."U_Year"     = {1}   ' +
                '                            and h."U_Periodo"  = {0} ) ' ); 
    FQueryCFL := string.Format(oSql, nper, nyear);
end;

method TRevalorizacionIFRS.AddChooseFromList(var oForm: SAPbouiCOM.Form);
var
   oCFLs: SAPbouiCOM.ChooseFromListCollection;
   oCFL:  SAPbouiCOM.ChooseFromList;
   oCFLCreationParams: SAPbouiCOM.ChooseFromListCreationParams;
begin
   oCFLs := oForm.ChooseFromLists;
   oCFLCreationParams := ChooseFromListCreationParams(FSBOApp.CreateObject(SAPbouiCOM.BoCreatableObjectType.cot_ChooseFromListCreationParams));

   oCFLCreationParams.MultiSelection := False;
   if (GlobalSettings.IFRSNativo) then
      oCFLCreationParams.ObjectType := 'VID_mAFAS'
   else
      oCFLCreationParams.ObjectType := 'VID_mAFASIF';

   oCFLCreationParams.UniqueID := 'CFLAct';
   oCFL := oCFLs.Add(oCFLCreationParams);
end;

method  TRevalorizacionIFRS.LimpiarFila(var oForm: SAPbouiCOM.Form);
var
   oDBDSD          : SAPbouiCOM.DBDataSource;
begin
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFREVD');
   oDBDSD.SetValue('U_ActCode' , 0, '');
   oDBDSD.SetValue('U_NewVal'  , 0, '0');
   oDBDSD.SetValue('U_ReaDet'  , 0, '');
   oDBDSD.SetValue('U_CtaCont' , 0, '');
   oDBDSD.SetValue('U_ValAnt'  , 0, '0');
end;

method   TRevalorizacionIFRS.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMtx            : SAPbouiCOM.Matrix;
   oDataTable      : SAPbouiCOM.DataTable;
   oDBDSH          : SAPbouiCOM.DBDataSource;
   oDBDSD          : SAPbouiCOM.DBDataSource;
   oActCode        : String;
   sValue          : String;
   sValaux         : String;
   U_CurVal        : Double;
   U_AdicAnuC      : Double;
   U_DepAcum       : Double;
   U_DepreAnu      : Double;
   U_ValResid      : Double;
   U_VidaUtil      : integer;
   ValNeto         : Double;
   ValResi         : Double;
   UNID_DEPREC     : integer;
   i               : Integer;
   s               : String;
   oCode           : String;
   NextYr          : integer;
   NextPr          : integer;
   minYrRv         : integer;
   minPrRv         : integer;
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
   oDBDSH  := oForm.DataSources.DBDataSources.Item('@VID_AFREV');
   oDBDSD  := oForm.DataSources.DBDataSources.Item('@VID_AFREVD');

   try
      //if (oForm.Mode = boFormMode.fm_ADD_MODE) and (PeriodoProcesado) then
      //   PeriodoProcesado := false;

      if (oMtx.RowCount = 0) and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
         oMtx.AddRow(1,0);
      end;

      if (pVal.EventType = BoEventTypes.et_GOT_FOCUS) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'mtx_0') then begin
            if (pVal.Row > 0) and (pVal.ColUID = 'ActCode') then
               oActCode_Before := EditText(oMtx.Columns.Item('ActCode').Cells.Item(pVal.Row).Specific).Value
            else
              oActCode_Before := '';
          end;
      end;

      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction) then begin
         sValue  := oDBDSH.GetValue('U_Periodo' , 0);
         sValaux := oDBDSH.GetValue('U_Year'    , 0);
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') then begin
            ChooseFromListSubQuery(sValue, sValaux);
            Self.CFLExtendido    := true;
         end 
         else
            Self.CFLExtendido := False;
      end;
      if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') then begin
            oDataTable := SAPbouiCOM.ChooseFromListEvent(pVal).SelectedObjects;
            if (oDataTable = nil) then 
               exit;

            if (GlobalSettings.GLOB_DocEntry = '-1') then
               exit;

            sValue:=TMultiFunctions.Trim(GlobalSettings.GLOB_DocEntry);
               
            oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select U_ActCode   " +
                        "  from [@VID_AFAS] " +
                        " where DocEntry = {0} and U_ActTipo <> 'T' ", 
                        'Select "U_ActCode" ' +
                        '  from "@VID_AFAS" ' +
                        ' where "DocEntry" = {0} and "U_ActTipo" <> ''T'' ');
            oSql := string.Format(oSql, sValue);
            oRecordSet.DoQuery(oSql);
            oRecordSet.MoveFirst;

            sValue     := System.String(oRecordSet.Fields.Item('U_ActCode').Value);
            oDBDSD.SetValue('U_ActCode' , 0, sValue);
            oMtx.SetLineData(pVal.Row);
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'Fecha') then begin
           // Permite solo revalorizaciones para periodo siguiente al periodo procesado
            sValue  := EditText(oForm.Items.Item('Fecha').Specific).Value;
            if (sValue = "") or (sValue = nil) then
              exit;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select COUNT(*) cant from [@VID_AFAC]     " +
                     " where U_Year = {0}  and U_Periodo = {1}  ", 
                     'Select COUNT(*) "cant" from "@VID_AFAC"   ' +
                     ' where "U_Year" = {0}  and "U_Periodo" = {1}  ');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2));
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Periodo con activos ya procesados, se debe reversar para modificar revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select COUNT(*) cant from [@VID_AFAS]     " +
                     " where U_NextYear = {0}  and U_NextPer = {1}  ", 
                     'Select COUNT(*) "cant" from "@VID_AFAS"   ' +
                     ' where "U_NextYear" = {0}  and "U_NextPer" = {1} ');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2));
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) = 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("No existen activos a procesar en este periodo.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select COUNT(*) cant from [@VID_AFAS]     " +
                     " where ( u_nextyear < {0} or ( u_nextyear = {0} and u_nextper  < {1} ) ) " +
                     "   and isnull(u_debaja,'N')  <> 'Y' ",
                     'Select COUNT(*) "cant" from "@VID_AFAS"   ' +
                     ' where ( "U_NextYear" < {0} or ( "U_NextYear" = {0} and "U_NextPer"  < {1} ) ) ' +
                     '   and ifnull("U_DeBaja", ''N'')  <> ''Y''  ');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2));
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Activos sin procesar en periodos anteriores a fecha de revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            oRecordSet.DoQuery(s);
            s := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select COUNT(*) cant from [@VID_AFREV]     " +
                     " where U_Year = {0}  and U_Periodo = {1}   ", 
                     'Select COUNT(*) "cant" from "@VID_AFREV"   ' +
                     ' where "U_Year" = {0}  and "U_Periodo" = {1}  ');
            s := string.Format(s, sValue.Substring(0,4), sValue.SubString(4,2));
            oRecordSet.DoQuery(s);
            if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
               BubbleEvent := false;
               FSBOApp.StatusBar.SetText("Revalorización para este periodo ya ingresada.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
         end;

         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'ActCode') and (pVal.Row >=1) then begin
            sValue := EditText(oMtx.Columns.Item('ActCode').Cells.Item(pVal.Row).Specific).Value;
            if (sValue = '') then begin
               LimpiarFila(var oForm);
               oMtx.SetLineData(pVal.Row);
               exit;
            end
            else if (sValue = oActCode_Before) then begin
               if (pVal.Row = oMtx.RowCount) and (sValue <> '') then begin
                  LimpiarFila(var oForm);
                  oMtx.AddRow(1, oMtx.RowCount);
               end;
               exit;
            end;

            s := iif(GlobalSettings.RunningUnderSQLServer, 
                     "Select U_ActTipo from [@VID_AFAS]     " +
                     " where U_ActCode = '{0}'  ", 
                     'Select "U_ActTipo" from "@VID_AFAS"   ' +
                     ' where "U_ActCode" = ''{0}''  ');
            s := string.Format(s, sValue.Trim());
            oRecordSet.DoQuery(s);
            oRecordSet.MoveFirst;
            if (not oRecordSet.EoF) then begin
               sValaux := System.String(oRecordSet.Fields.Item('U_ActTipo').Value);
               if (sValaux <> "") and (sValaux <> nil) then 
                  if (sValaux = 'T') then begin
                     BubbleEvent := false;
                     FSBOApp.StatusBar.SetText("Código no corresponde a activo IFRS.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                     exit;
                  end;
            end;

            for i:=1 to oMtx.RowCount do begin
               if (sValue = EditText(oMtx.Columns.Item('ActCode').Cells.Item(i).Specific).Value) and (pVal.Row <> i) then begin
                  bubbleEvent := false;
                  FSBOApp.StatusBar.SetText("Activo ya ingresado en lista de revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;
            end;

            try
               s := iif(GlobalSettings.RunningUnderSQLServer, 
                        "Select U_ActCode, U_ActName, U_CorAnuAc, U_CurVal, U_AdicAnuC, U_DepAcum, U_DepreAnu, U_ValResid, U_VidaUtil, isnull(U_TipoDep,'') U_TipoDep  " +
                        "  from [@VID_AFAS] " +
                        " where U_ActCode = '{0}'  ", 
                        'Select "U_ActCode",  "U_ActName",  "U_CorAnuAc", "U_CurVal",            "U_AdicAnuC", "U_DepAcum", ' +
                        '       "U_DepreAnu", "U_ValResid", "U_VidaUtil", ifnull("U_TipoDep",'''') "U_TipoDep"  ' +
                        '  from "@VID_AFAS" ' +
                        ' where "U_ActCode" = ''{0}''  ');
               s := string.Format(s, sValue.Trim());

               oRecordSet.DoQuery(s);
               oRecordSet.MoveFirst;

               sValue     := System.String(oRecordSet.Fields.Item('U_ActCode').Value);
               sValaux    := System.String(oRecordSet.Fields.Item('U_ActName').Value);
               U_CurVal   := System.Double(oRecordSet.Fields.Item('U_CorAnuAc').Value);  // En IFRS CorAnuAc tiene el valor actual revalorizado
               U_AdicAnuC := System.Double(oRecordSet.Fields.Item('U_AdicAnuC').Value);    
               U_DepAcum  := System.Double(oRecordSet.Fields.Item('U_DepAcum').Value);  
               U_DepreAnu := System.Double(oRecordSet.Fields.Item('U_DepreAnu').Value);   
               U_ValResid := System.Double(oRecordSet.Fields.Item('U_ValResid').Value);  
               U_VidaUtil := System.int32(oRecordSet.Fields.Item('U_VidaUtil').Value);  

               sValaux  := EditText(oForm.Items.Item('Fecha').Specific).Value;
               UNID_DEPREC := 0;
               if (System.String(oRecordSet.Fields.Item('U_TipoDep').Value).Trim() = 'U') then begin
                  s := iif(GlobalSettings.RunningUnderSQLServer, 
                           "Select isnull(d.U_Uso,0) Uso  " +
                           "  from [@VID_AFUS] h inner join [@VID_AFUSD] d on h.DocEntry = d.DocEntry " +
                           "  where h.U_Year    =  {0}  " + 
                           "   and h.U_Periodo  =  {1}  " + 
                           "   and d.U_ActCode  = '{2}' ", 
                           'Select isnull(d."U_Uso",0) "Uso"  ' +
                           '  from "@VID_AFUS" h inner join "@VID_AFUSD" d on h."DocEntry" = d."DocEntry" ' +
                           '  where h."U_Year"     =   {0}   ' + 
                           '    and h."U_Periodo"  =   {1}   ' + 
                           '    and d."U_ActCode"  = ''{2}'' ');
                  s := string.Format(s, sValaux.Substring(0,4), sValaux.SubString(4,2), sValue);
                   oRecordSet.DoQuery(s);
                   if (not oRecordSet.EoF) then
                      UNID_DEPREC := System.Int32(oRecordSet.Fields.Item('Uso').Value);
                   end
                else 
                   UNID_DEPREC := 1;

               ValNeto := U_CurVal + U_AdicAnuC;

               ValResi := ValNeto - U_DepAcum - U_DepreAnu + U_ValResid; // Cargar cuando se procese en "valresi"

              // Valor libro para activos revalorizados
              s := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select U_NextYear, U_NextPer, Code from [@VID_AFAS]    " +
                       " where U_ActCode = '{0}'  ", 
                       'Select "U_NextYear", "U_NextPer", "Code" from "@VID_AFAS"   ' +
                       ' where "U_ActCode" = ''{0}''  ');
              s := string.Format(s, sValue);
              oRecordSet.DoQuery(s);
              oCode  := System.String(oRecordSet.Fields.Item('Code').Value).Trim;
              NextYr := System.Int32(oRecordSet.Fields.Item('U_NextYear').Value);
              NextPr := System.Int32(oRecordSet.Fields.Item('U_NextPer').Value);
              if (NextPr = 1) then begin
                  NextPr := 12;
                  NextYr := NextYr - 1;
              end
              else
                  NextPr := NextPr - 1;

              s := iif(GlobalSettings.RunningUnderSQLServer, 
                       "Select Month(max(h.U_Fecha)) Mes, Year(max(h.U_Fecha)) Year, count(*) cant   " +
                       "   from [@VID_AFREVD] d inner join [@VID_AFREV] h on h.DocEntry = d.DocEntry " +
                       "  where ((h.U_Year = {0} and h.U_Periodo <= {1}) or (h.U_Year < {0}))  " +
                       "    and d.U_ActCode = '{2}'                                            ", 
                       'Select Month(max(h."U_Fecha")) "Mes", Year(max(h."U_Fecha")) "Year", count(*) "cant"   ' +
                       '   from "@VID_AFREVD" d inner join "@VID_AFREV" h on h."DocEntry" = d."DocEntry" ' +
                       '  where ((h."U_Year" = {0} and h."U_Periodo" <= {1}) or (h."U_Year" < {0}))  ' +
                       '    and d."U_ActCode" = ''{2}''                                          ' ); 
              s := string.Format(s, NextYr.ToString, NextPr.ToString, sValue);
              oRecordSet.DoQuery(s);
              minYrRv := 0;
              minPrRv := 0;
              if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
                 minYrRv := System.Int32(oRecordSet.Fields.Item('Year').Value);
                 minPrRv := System.Int32(oRecordSet.Fields.Item('Mes').Value);
                 s := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select sum(U_Deprecia) Depreciacion  " +
                          "  from [@VID_AFAC]                 " +
                          " where Code = '{0}' " +
                          "   and ((U_Year > {1}) or (U_Year = {1} and U_Periodo >= {2}))", 
                          'Select sum("U_Deprecia") "Depreciacion"  ' +
                          '  from "@VID_AFAC"                 ' +
                          ' where "Code" = ''{0}''            ' +
                          '   and (("U_Year" > {1}) or ("U_Year" = {1} and "U_Periodo" >= {2}))');
                 s := string.Format(s, sValue, minYrRv.ToString(), minPrRv.ToString() );
                 oRecordSet.DoQuery(s);
                 ValResi := ValNeto - System.Double(oRecordSet.Fields.Item('Depreciacion').Value);
              end;
              // Termina Revalorizacion

               //if (U_VidaUtil > 0) then
               //   ValResi := ValResi - (ValResi * UNID_DEPREC / U_VidaUtil);
            except
               on e: exception do begin
                  if (FSBOf.Cmpny.InTransaction) then
                     FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
                  FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
                  exit;
               end;
            end;
               
            oDBDSD.SetValue('U_ActCode' , 0, sValue);
            oDBDSD.SetValue('U_ValAnt'  , 0, FSBOf.DoubleToStr(ValResi));
            oDBDSD.SetValue('U_PerDepAn', 0, '0');
            oMtx.SetLineData(pVal.Row);
            if (pVal.Row = oMtx.RowCount) and (sValue <> '') then begin
               LimpiarFila(var oForm);
               oMtx.AddRow(1, oMtx.RowCount);
            end;
         end;

//revalorizacion para el periodo depreciado
//revalorizacion se procesa en proceso de activo fijo
         if (pVal.ItemUID = 'mtx_0') and (pVal.ColUID = 'NewVal') then begin
            sValue := EditText(oMtx.Columns.Item('NewVal').Cells.Item(pVal.Row).Specific).Value;
            if (FSBOf.StringToDouble(sValue) = 0) then
               exit;

            BubbleEvent := false;
            if (FSBOf.StrToDouble(sValue) < 0)then begin
               FSBOApp.StatusBar.SetText('Valorización no puede ser negativa', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
            // Determina si es reavaluo o deterioro al momento de contabilizar
            // Validar cuantas de reavaulo y deterioro al contabilizar

            oMtx.GetLineData(pVal.Row);
            sValaux := EditText(oMtx.Columns.Item('ValAnt').Cells.Item(pVal.Row).Specific).Value;
            oActCode := ODBDSD.GetValue("U_ActCode", 0).Trim();

            if (FSBOf.StringToDouble(sValue) > FSBOf.StringToDouble(sValaux)) then begin
               oDBDSD.SetValue("U_ReaDet", 0, "R");

               if (GlobalSettings.IFRSNativo) then begin
                  s := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_CtaReaAF from [@VID_AFAS] where U_ActCode = '{0}'  ",
                          'Select "U_CtaReaAF" from "@VID_AFAS" where "U_ActCode" = ''{0}''  ');
                  s := string.Format(s, oActCode );
               end
               else begin
                  s := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_CtaReaAF from [@VID_AFASIF] where U_ActCode = '{0}'  ",
                          'Select "U_CtaReaAF" from "@VID_AFASIF" where "U_ActCode" = ''{0}''  ');
                  s := string.Format(s, oActCode );
               end;
               oRecordSet.DoQuery(s);

               sValaux := System.String(oRecordSet.Fields.Item("U_CtaReaAF").Value);
               if (sValaux = "") or (sValaux = nil) then begin
                  FSBOApp.StatusBar.SetText("Cuenta de Reavaluo no definida, para activo: " + oActCode, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;
               oDBDSD.SetValue('U_CtaCont' , 0, sValaux);
            end
            else begin
               oDBDSD.SetValue("U_ReaDet", 0, "D");

               if (GlobalSettings.IFRSNativo) then begin
                  s := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_CtaDetAF from [@VID_AFAS] where U_ActCode = '{0}'  ",
                          'Select "U_CtaDetAF" from "@VID_AFAS" where "U_ActCode" = ''{0}''  ');
                  s := string.Format(s, oActCode );
               end
               else begin
                  s := iif(GlobalSettings.RunningUnderSQLServer, 
                          "Select U_CtaDetAF from [@VID_AFASIF] where U_ActCode = '{0}'  ",
                          'Select "U_CtaDetAF" from "@VID_AFASIF" where "U_ActCode" = ''{0}''  ');
                  s := string.Format(s, oActCode );
               end;
               oRecordSet.DoQuery(s);

               sValaux := System.String(oRecordSet.Fields.Item("U_CtaDetAF").Value);
               if (sValaux = "") or (sValaux = nil) then begin
                  FSBOApp.StatusBar.SetText("Cuenta de Deterioro no definida, para activo: " + oActCode, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;
               oDBDSD.SetValue('U_CtaCont' , 0, sValaux);
            end;
            oMtx.SetLineData(pVal.Row);

            LimpiarFila(var oForm);
            BubbleEvent := true;
         end;
      end

      else if (pVal.EventType = BoEventTypes.et_VALIDATE) and (not pVal.BeforeAction) then begin
         if (pVal.ItemUID = 'Fecha') then begin
            sValue  := oForm.DataSources.DBDataSources.Item('@VID_AFREV').GetValue('U_Fecha', 0);
            if (sValue = '') then begin
               oForm.DataSources.DBDataSources.Item('@VID_AFREV').SetValue('U_Periodo', 0, '');
               oForm.DataSources.DBDataSources.Item('@VID_AFREV').SetValue('U_Year'   , 0, '');
            end
            else begin
               sValaux := sValue.Substring(4,2);
               sValue  := sValue.Substring(0,4); 
               oForm.DataSources.DBDataSources.Item('@VID_AFREV').SetValue('U_Periodo', 0, sValAux);
               oForm.DataSources.DBDataSources.Item('@VID_AFREV').SetValue('U_Year'   , 0, sValue);
            end;
         end;
      end;

      if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction) then begin
         if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_ADD_MODE) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox('¿Ingresar revalorización de activo?', 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(var oForm, var oMtx)) then
               exit;
            if (IngresarTrx(var oForm)) then begin
                oForm.DataSources.DBDataSources.Item('@VID_AFREV').Clear;
                oForm.DataSources.DBDataSources.Item('@VID_AFREVD').Clear;
                oForm.DataSources.DBDataSources.Item('@VID_AFREV').InsertRecord(0);
                oForm.DataSources.DBDataSources.Item('@VID_AFREVD').InsertRecord(0);
                Matrix(oForm.Items.Item('mtx_0').Specific).Clear;
                oForm.Mode := BoFormMode.fm_ADD_MODE;
                FSBOApp.StatusBar.SetText("Operación realizada correctamente.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
            end;
         end

         else if (pVal.ItemUID = '1') and (BoFormMode(pVal.FormMode) = BoFormMode.fm_UPDATE_MODE) then begin
            BubbleEvent := False;
            if (1 <> FSBOApp.MessageBox('¿Actualizar revalorización de activo?', 1, 'Ok', 'Cancelar','')) then
               exit;
            if (not ValidacionFinal(var oForm, var oMtx)) then
               exit;
            if (IngresarTrx(var oForm)) then begin
                oForm.Mode := BoFormMode.fm_OK_MODE;
                FSBOApp.StatusBar.SetText("Operación realizada correctamente.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
            end;
         end;

         if (pVal.ItemUID = 'btnDel') and (oForm.Mode = BoFormMode.fm_OK_MODE) and (oForm.Mode <> BoFormMode.fm_ADD_MODE) then begin
            if (1 <> FSBOApp.MessageBox('¿Eliminar revalorización de activos?', 1, 'Ok', 'Cancelar','')) then
                exit;
            if (DeleteReval(var oForm)) then begin
                oForm.Mode := BoFormMode.fm_ADD_MODE;
                FSBOApp.StatusBar.SetText("Operación realizada correctamente.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
            end;
         end;
      end;
   except
      on e: exception do begin
         if (FSBOf.Cmpny.InTransaction) then
            FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TRevalorizacionIFRS.FormDataEvent(var BusinessObjectInfo: BusinessObjectInfo; var BubbleEvent: boolean);
var
   oForm   : SAPbouiCOM.Form;
   oDBDS   : SAPbouiCOM.DBDataSource;
   oSql    : string;
begin
   inherited FormDataEvent(var BusinessObjectInfo, var BubbleEvent);

   oForm := FSBOApp.Forms.Item(BusinessObjectInfo.FormUID);
   oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFREV");

   if (BusinessObjectInfo.EventType = BoEventTypes.et_FORM_DATA_LOAD) and (not BusinessObjectInfo.BeforeAction) and (BusinessObjectInfo.ActionSuccess) then begin
      oSql := iif(GlobalSettings.RunningUnderSQLServer, 
                  "Select COUNT(*) cant from [@VID_AFAC] " +
                  " where (U_Year > {0}) or (U_Year = {0} and U_Periodo >= {1})",
                  'Select COUNT(*) "cant" from "@VID_AFAC" ' +
                  ' where ("U_Year" > {0}) or ("U_Year" = {0} and "U_Periodo" >= {1})');
      oSql := string.Format(oSql, oDBDS.GetValue('U_Year', 0), oDBDS.GetValue('U_Periodo', 0));
      oRecordSet.DoQuery(oSql);

      if (System.Int32(oRecordSet.Fields.Item('cant').Value) > 0) then begin
         oForm.Mode := BoFormMode.fm_OK_MODE;
         oForm.Items.Item("mtx_0").SetAutoManagedAttribute(BoAutoManagedAttr.ama_Editable, int32(BoAutoFormMode.afm_Ok), BoModeVisualBehavior.mvb_False);
         oForm.Items.Item("Comments").SetAutoManagedAttribute(BoAutoManagedAttr.ama_Editable, int32(BoAutoFormMode.afm_Ok), BoModeVisualBehavior.mvb_False);
         oDBDS.SetValue("U_Procesad", 0, "Y");
         PeriodoProcesado := true;
      end
      else begin
         oForm.Mode := BoFormMode.fm_OK_MODE;
         oForm.Items.Item("mtx_0").SetAutoManagedAttribute(BoAutoManagedAttr.ama_Editable, int32(BoAutoFormMode.afm_Ok), BoModeVisualBehavior.mvb_True);
         oForm.Items.Item("Comments").SetAutoManagedAttribute(BoAutoManagedAttr.ama_Editable, int32(BoAutoFormMode.afm_Ok), BoModeVisualBehavior.mvb_True);
         oDBDS.SetValue("U_Procesad", 0, "N");
         PeriodoProcesado := false;
      end;
      oForm.DataSources.DBDataSources.Item("@VID_AFREVD").Offset := 0;
   end;
end;

method   TRevalorizacionIFRS.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
var
   oForm : SAPbouiCOM.Form;
begin
   inherited MenuEvent(var pVal, var BubbleEvent);
   try
      oForm           := FSBOApp.Forms.Item(Self.getFormId);

      if (pVal.MenuUid <> '') and  (pVal.BeforeAction) then begin
         if (pVal.MenuUID = '1283') and (PeriodoProcesado) then 
             BubbleEvent := false;
      end;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog(e.Message + ' - ' + e.StackTrace);
      end;
   end;
end;

method TRevalorizacionIFRS.ValidacionFinal(var oForm: SAPbouiCOM.Form;var mtx: SAPbouiCOM.Matrix): boolean;
var
   s:    string;
   s1:   string;
   s2:   string;
   i:    Integer;
   yr:   integer;
   pr:   integer;
   oDBDS   : SAPbouiCOM.DBDataSource;
begin
   try
      result := false;

      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFREV");
      if (oDBDS.GetValue("U_Procesad", 0) = "Y") or (PeriodoProcesado) then begin
          FSBOApp.StatusBar.SetText("Periodo procesado, no se puede modificar la revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFREVD");
      s := iif(GlobalSettings.RunningUnderSQLServer, 
              "Select isnull(Max(U_Year * 100 + U_Periodo),0) YearPer from [@VID_AFREV]",
              'Select ifnull(Max("U_Year" * 100 + "U_Periodo"),0) "YearPer" from "@VID_AFREV"');
      oRecordSet.DoQuery(s); // Aplicar maximo año
      i  := System.Int32(oRecordSet.Fields.Item('YearPer').Value);
      yr := i div 100;
      pr := i - yr*100;

      s := oForm.DataSources.DBDataSources.Item("@VID_AFREV").GetValue("U_Fecha", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar la fecha de la revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      s := oForm.DataSources.DBDataSources.Item("@VID_AFREV").GetValue("U_Year", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar el año de la revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;
      s := oForm.DataSources.DBDataSources.Item("@VID_AFREV").GetValue("U_Periodo", 0);
      if (s = '') then begin
         FSBOApp.StatusBar.SetText("Se debe ingresar el periodo de la revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         exit;
      end;

      i := mtx.RowCount;
      while (i > 0) do 
      begin
          mtx.GetLineData(i);
          if ((oDBDS.GetValue("U_ActCode", 0).Trim() = "") or (oDBDS.GetValue("U_ActCode", 0) = nil)) then
               mtx.DeleteRow(i);
          dec(i);
      end;

      for i:=mtx.RowCount downto 1 do begin
         if (s = '') then begin
            FSBOApp.StatusBar.SetText("Activo inexistente en linea: " + i.ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end;
         s := EditText(mtx.Columns.Item("NewVal").Cells.Item(i).specific).value;
         if (FSBOf.StringToDouble(s) = 0) then begin
            FSBOApp.StatusBar.SetText("Nuevo valor no puede ser igual a 0 en linea: " + i.ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end;
      end;

      { controlado en el ingreso de revalorizaciones
      if (FSBOf.StrToInteger(s) < yr) or ((FSBOf.StrToInteger(s) = yr) and (FSBOf.StrToInteger(s1) <= pr)) then begin
         if (FSBOApp.MessageBox("Se eliminaran revalorizaciones para periodos posteriores.  ¿Desea continuar?",1, "Cancelar", "Ok", "") = 2) then begin
            s1 := oForm.DataSources.DBDataSources.Item("@VID_AFREV").GetValue("U_Year", 0);
            s2 := oForm.DataSources.DBDataSources.Item("@VID_AFREV").GetValue("U_Periodo", 0);
            s := "Delete from [@VID_AFREVD] " +
                 " where DocEntry in (select DocEntry from [@VID_AFREV] where (U_Year > " + s1 + " or (U_Year = " + s1 + " and U_Periodo > " + s2 + ")))";
            oRecordSet.DoQuery(s);
            s := "Delete from [@VID_AFREV] " +
                 " where (U_Year > " + s1 + " or (U_Year = " + s1 + " and U_Periodo > " + s2 + "))";
            oRecordSet.DoQuery(s);
         end
         else
            exit;
      end;
      }

      result := true;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace);
         result := false;
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

method TRevalorizacionIFRS.IngresarTrx(var oForm: SAPbouiCOM.Form): boolean;
var
      oReval:          SAPbobsCOM.GeneralService;
      oRevalData:      SAPbobsCOM.GeneralData;
      oRevalParam:     SAPbobsCOM.GeneralDataParams;
      oRevalLines:     SAPbobsCOM.GeneralDataCollection;
      oRevalLinesData: SAPbobsCOM.GeneralData ;

      oDBDSH:     SAPbouiCOM.DBDataSource;
      oDBDSD:     SAPbouiCOM.DBDataSource;
      oMtx0:      SAPbouiCOM.Matrix;
      i:       integer;
begin

      oDBDSH := (DBDataSource)(oForm.DataSources.DBDataSources.Item("@VID_AFREV"));
      oDBDSD := (DBDataSource)(oForm.DataSources.DBDataSources.Item("@VID_AFREVD"));
      oMtx0  := (Matrix)(oForm.Items.Item("mtx_0").Specific);

      try
      begin
          result := false;

          // Preparar transacciones
          oReval      := (SAPbobsCOM.GeneralService)(FCmpny.GetCompanyService().GetGeneralService("VID_mAFREV"));
          oRevalData  := (SAPbobsCOM.GeneralData)(oReval.GetDataInterface(GeneralServiceDataInterfaces.gsGeneralData));
          oRevalParam := (SAPbobsCOM.GeneralDataParams)(oReval.GetDataInterface(GeneralServiceDataInterfaces.gsGeneralDataParams));

          if (oForm.Mode = BoFormMode.fm_ADD_MODE) then
              oRevalData := (GeneralData)(oReval.GetDataInterface(GeneralServiceDataInterfaces.gsGeneralData))
          else
          begin
              oRevalParam := (SAPbobsCOM.GeneralDataParams)(oReval.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));
              oRevalParam.SetProperty("DocEntry", FSBOf.StrToInteger(oDBDSH.GetValue("DocEntry", 0)));
              oRevalData := oReval.GetByParams(oRevalParam);
          end;

          oRevalLines := oRevalData.Child("VID_AFREVD");

          oRevalData.SetProperty("U_Fecha"   , FSBOf.StrToDate(oDBDSH.GetValue("U_Fecha", 0)));
          oRevalData.SetProperty("U_Year"    , FSBOf.StrToInteger(oDBDSH.GetValue("U_Year", 0)));
          oRevalData.SetProperty("U_Periodo" , FSBOf.StrToInteger(oDBDSH.GetValue("U_Periodo", 0)));
          oRevalData.SetProperty("U_Comments", oDBDSH.GetValue("U_Comments", 0));

          for i := oRevalLines.Count - 1 downto 0 do 
              oRevalLines.Remove(i);

          for i := 1 to oMtx0.RowCount do
          begin
              oMtx0.GetLineData(i);
              oRevalLinesData := oRevalLines.Add();
              oRevalLinesData.SetProperty("U_ActCode", oDBDSD.GetValue("U_ActCode", 0));
              oRevalLinesData.SetProperty("U_NewVal" , FSBOf.StrToDouble(oDBDSD.GetValue("U_NewVal", 0)));
              oRevalLinesData.SetProperty("U_ReaDet" , oDBDSD.GetValue("U_ReaDet", 0));
              oRevalLinesData.SetProperty("U_CtaCont", oDBDSD.GetValue("U_CtaCont", 0));
              oRevalLinesData.SetProperty("U_ValAnt" , FSBOf.StrToDouble(oDBDSD.GetValue("U_ValAnt", 0)));
          end;

          if (oForm.Mode = BoFormMode.fm_ADD_MODE) then
              oReval.Add(oRevalData)
          else
              oReval.Update(oRevalData);

          result := true;
      end
      except 
          on e:exception do begin
            OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
            result := false;
            FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         end;
      end;
end;

method TRevalorizacionIFRS.DeleteReval(var oForm: SAPbouiCOM.Form): Boolean;
var
   oReval          : SAPbobsCOM.GeneralService;
   oRevalParameter : SAPbobsCOM.GeneralDataParams;
   s               : String;
   oDBDS   : SAPbouiCOM.DBDataSource;
begin
   result := false;

   oDBDS := oForm.DataSources.DBDataSources.Item("@VID_AFREV");
   if (oDBDS.GetValue("U_Procesad", 0) = "Y") or (PeriodoProcesado) then begin
       FSBOApp.StatusBar.SetText("Periodo procesado, no se puede eliminar la revalorización.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
       exit;
   end;

   oReval          := SAPbobsCOM.GeneralService(FCmpny.GetCompanyService.GetGeneralService('VID_mAFREV'));
   oRevalParameter := SAPbobsCOM.GeneralDataParams(oReval.GetDataInterface(SAPbobsCOM.GeneralServiceDataInterfaces.gsGeneralDataParams));

   s := oForm.DataSources.DBDataSources.Item('@VID_AFREV').GetValue('DocEntry', 0);
   oRevalParameter.SetProperty('DocEntry', FSBOf.StrToInteger(s));

   oReval.Delete(oRevalParameter);
 
   FSBOApp.StatusBar.SetText("Revalorazación eliminada.", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
   oForm.DataSources.DBDataSources.Item('@VID_AFREV').Clear;
   oForm.DataSources.DBDataSources.Item('@VID_AFREVD').Clear;
   oForm.DataSources.DBDataSources.Item('@VID_AFREV').InsertRecord(0);
   oForm.DataSources.DBDataSources.Item('@VID_AFREVD').InsertRecord(0);
   Matrix(oForm.Items.Item('mtx_0').Specific).Clear;
   result := true;
end;

end.
