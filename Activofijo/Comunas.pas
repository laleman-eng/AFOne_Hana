namespace AF_IFRS.Comunas;

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
  TComunas = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet: SAPbobsCOM.Recordset;
    ListaMx:    List<String>;
    pValPersist:SAPbouiCOM.ItemEvent;
    method    ValidacionFinal(oForm: SAPbouiCOM.Form; mtx: SAPbouiCOM.Matrix): boolean;
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method   MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TComunas.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
   oMtx:     SAPbouiCOM.Matrix;
   oDBDSDetalle: SAPbouiCOM.DBDataSource;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   ListaMx := new List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_AFComunas_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_AFComunas.srf', Uid);
      oForm := FSBOApp.Forms.Item(uid);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := 11;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_OK_MODE;
      VID_DelRow := true;

      ListaMx.Add('Code , r  , tx');
      ListaMx.Add('Name , r , tx');

      oMtx := Matrix(oForm.Items.Item('mtx_0').Specific);
      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      oDBDSDetalle    := DBDataSource(oForm.DataSources.DBDataSources.Item('@VID_AFCOMUNA'));
      oDBDSDetalle.Query(nil);
      oMtx.Clear;
      oMtx.LoadFromDataSource;
      oDBDSDetalle.Clear;
      oMtx.AddRow(1, oMtx.RowCount);

      oForm.Visible := true;
//      oForm.DataBrowser.BrowseBy := 'CodAtr';
     except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method   TComunas.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
var
   oForm : SAPbouiCOM.Form;
begin
   inherited MenuEvent(var pVal, var BubbleEvent);
   try
      oForm   := FSBOApp.Forms.Item(Self.getFormId);

      // Proceso de MenuEvent
      if (pVal.MenuUid <> '') and  (pVal.BeforeAction = true) then begin
            if (pVal.MenuUID = '774')then begin
               if (pValPersist.ItemUID = 'mtx_0') then
                  Matrix(oForm.Items.Item('mtx_0').Specific).DeleteRow(pValPersist.Row);
            end;
      end;
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('MenuEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method   TComunas.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMatrix         : SAPbouiCOM.Matrix;
   oDBDS           : SAPbouiCOM.DBDataSource;
   sValue          : string;
   ExisteYearPeriod: boolean;
   i: integer;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);
   //  Mask:
   //    1 - BoAutoFormMode.afm_OK
   //    2 - BoAutoFormMode.afm_Add
   //    4 - BoAutoFormMode.afm_Find
   //    8 - BoAutoFormMode.afm_View

   oForm       := FSBOApp.Forms.Item(pVal.FormUID);
   oMatrix     := Matrix(oForm.Items.Item('mtx_0').Specific);
   oDBDS       := oForm.DataSources.DBDataSources.Item('@VID_AFCOMUNA');
   pValPersist := pVal;
   try
      // Validación de valores
      if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction = False) then begin
         BubbleEvent := true;
         if (pVal.ItemUID = 'mtx_0') then begin

            if (EditText(oMatrix.Columns.Item('Code').Cells.Item(pVal.Row).Specific).Value <> '') and (pVal.Row = oMatrix.RowCount) then begin
               oDBDS.Clear;
               oMatrix.AddRow(1, oMatrix.RowCount);
            end;

            if (pVal.ColUID = 'Code') then begin
               BubbleEvent := false;
               sValue := EditText(oMatrix.Columns.Item('Code').Cells.Item(pVal.Row).Specific).Value;
               if (sValue = '') then
                  BubbleEvent := true
               else begin
                  ExisteYearPeriod := false;
                  for i:=1 to oMatrix.RowCount do
                     if (i <> pVal.Row) and (sValue = EditText(oMatrix.Columns.Item('Code').Cells.Item(i).Specific).Value) then
                        ExisteYearPeriod := true;
                  if (not ExisteYearPeriod) then
                     BubbleEvent := true
                  else
                     FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Codigo_ya_ingresado], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error)
               end;
            end;

          end;
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
            BubbleEvent := False;
            if (1 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualizar_Comunas_QM], 1, 'Ok', 'Cancelar','')) then begin
               if (ValidacionFinal(oForm, oMatrix)) then begin
                  oForm.Mode := BoFormMode.fm_OK_MODE;
               end;
            end;
         end
      end

   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TComunas.ValidacionFinal(oForm: SAPbouiCOM.Form; mtx: SAPbouiCOM.Matrix): boolean;
var
   s:           string;
   ok:          boolean;
   oRecordSet1: SAPbobsCOM.Recordset;
   oMxDetalle:  SAPbouiCOM.Matrix;
   oRow:        integer;
begin
   result := false;
   try
      try
         ok := FSBOf.MatrizConDatosOK(mtx, ListaMx, false, var s);
         if (not ok) and (s <> '') then begin
            FSBOApp.StatusBar.SetText('Campo ' + s + ' Requerido.' , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            result := false;
            exit;
         end;

         oMxDetalle  := Matrix(oForm.Items.Item('mtx_0').Specific);
         oRecordSet1 := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));
         if (ok) then begin
            FCmpny.StartTransaction;
            s := iif(GlobalSettings.RunningUnderSQLServer, "Delete from [@VID_AFCOMUNA] ", 'Delete from "@VID_AFCOMUNA" ');
            oRecordSet1.DoQuery(s);

            for oRow:=1 to oMxDetalle.RowCount do begin
               if (EditText(oMxDetalle.Columns.Item('Code').Cells.Item(oRow).Specific).Value = '') then
                  continue;

               s := iif(GlobalSettings.RunningUnderSQLServer, "Insert into [@VID_AFCOMUNA] ( code, docentry, name, DataSource, Object) " +
                                                              " values ( '{0}', {1}, '{2}', 'M', 'VID_AFCOMUNA' ) ",
                                                              'Insert into "@VID_AFCOMUNA" ( "Code", "DocEntry", "Name", "DataSource", "Object") ' +
                                                              ' values ( ''{0}'', {1}, ''{2}'', ''M'', ''VID_AFCOMUNA'' )' );
               s := string.Format(s, EditText(oMxDetalle.Columns.Item('Code').Cells.Item(oRow).Specific).Value, 
                                     oRow.ToString(), 
                                     EditText(oMxDetalle.Columns.Item('Name').Cells.Item(oRow).Specific).Value);
               oRecordSet1.DoQuery(s);
            end;
            FCmpny.EndTransaction(BoWfTransOpt.wf_Commit);
         end;

         result := true;
      except
         on e:exception do begin
            if (FCmpny.InTransaction) then
               FCmpny.EndTransaction(SAPbobsCOM.BoWfTransOpt.wf_RollBack);
            OutLog('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace);
            result := false;
            FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         end;
      end;
   finally
      FSBOf._ReleaseCOMObject(oRecordSet1);
      oRecordSet1 := nil;
   end;
end;

end.
