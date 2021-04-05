unit AF_IFRS.DefSeriesParaLotes;

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
  TDefSeriesParaLotes = class(TvkBaseForm, IvkFormInterface)
  private
    { Private Declarations }
    oRecordSet  : SAPbobsCOM.Recordset;
    pValPersist : SAPbouiCOM.ItemEvent;
    Lista       : List<String>;
    method  ValidacionFinal(oForm: SAPbouiCOM.Form; mtx: SAPbouiCOM.Matrix): boolean;
    method  ShowStr(oForm: SAPbouiCOM.Form);
  public
    method   InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method   FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
    method   MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean); reintroduce;
  end;

implementation

uses
  System.Globalization;

method   TDefSeriesParaLotes.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; 
var
   oForm:    SAPbouiCOM.Form;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   Lista     := new List<String>;
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_AFDefSerie_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_AFDefSerie.srf', Uid);
      oForm := FSBOApp.Forms.Item(uid);
      oForm.AutoManaged    := True;
      oForm.SupportedModes := -1;             // afm_All
      oForm.Mode           := SAPbouiCOM.BoFormMode.fm_FIND_MODE;
      VID_DelRow     := true;
      VID_DelLastRow := true;

                       // Ok Ad  Fnd Vw Rq Sec
      Lista.Add( 'Code  ,  f,  t,  t,  f, r, 1 ');
      Lista.Add( 'Name  ,  t,  t,  t,  f, r, 1 ');
      Lista.Add( 'mtx_0 ,  t,  t,  f,  f, r, 1 ');
      FSBOf.SetAutoManaged(oForm, Lista);

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      oForm.DataBrowser.BrowseBy := 'Code';

      oForm.Visible := true;
     except
      on e:exception do begin
         FSBOApp.MessageBox(e.Message + ' ** Trace: ' + e.StackTrace,1,'Ok','','');
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method   TDefSeriesParaLotes.MenuEvent(var pVal: MenuEvent; var BubbleEvent: boolean);
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
         FSBOApp.MessageBox(e.Message + ' ** Trace: ' + e.StackTrace,1,'Ok','','');
         OutLog('MenuEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method  TDefSeriesParaLotes.ShowStr(oForm: SAPbouiCOM.Form);
var
   oMatrix : SAPbouiCOM.Matrix;
   sValue  : string;
   tipo    : string;
   valor   : string;
   format  : string;
   i       : integer;
begin
   oMatrix     := Matrix(oForm.Items.Item('mtx_0').Specific);

   sValue := '';
   for i:=1 to oMatrix.RowCount do begin
       tipo := '';
       try
          tipo := ComboBox(oMatrix.Columns.Item('Tipo').Cells.Item(i).Specific).Selected.Value;
       except
       end;
       format := '';
       try
          format := ComboBox(oMatrix.Columns.Item('Formato').Cells.Item(i).Specific).Selected.Value;
       except
       end;
       valor  := EditText(oMatrix.Columns.Item('String' ).Cells.Item(i).Specific).Value;

       sValue := sValue + FSBOf.GetStrLote('', tipo, valor, format);
   end;

   EditText(oForm.Items.Item('StrFinal').Specific).Value := sValue;
end;

method   TDefSeriesParaLotes.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oMatrix         : SAPbouiCOM.Matrix;
   oDBDSD          : SAPbouiCOM.DBDataSource;
   sValue          : string;
   formato         : string;
   s               : string;
   i, j            : integer;
begin
   inherited FormEvent(FormUID, var pVal, var BubbleEvent);

   oForm       := FSBOApp.Forms.Item(pVal.FormUID);
   oMatrix     := Matrix(oForm.Items.Item('mtx_0').Specific);
   pValPersist := pVal;
   try
      if (oForm.Mode = BoFormMode.fm_ADD_MODE) and (oMatrix.RowCount = 0) then begin
         oDBDSD := oForm.DataSources.DBDataSources.Item('@VID_AFDEFSERIED');
         oDBDSD.Clear;
         oDBDSD.InsertRecord(oDBDSD.Size);
         i := oDBDSD.Size-1;
         oDBDSD.Offset := i;
         oDBDSD.SetValue('U_string' , i, '');
         oDBDSD.SetValue('U_Tipo'   , i, 'C');
         oDBDSD.SetValue('U_Formato', i, '0');
         oMatrix.AddRow(1, oMatrix.RowCount);
      end;

      if (pVal.EventType = BoEventTypes.et_MATRIX_LOAD) and (pVal.Before_Action = false) and (pVal.ItemUID = 'mtx_0') then begin
         oMatrix.FlushToDataSource;
         oDBDSD := oForm.DataSources.DBDataSources.Item('@VID_AFDEFSERIED');
         oDBDSD.InsertRecord(oDBDSD.Size);
         i := oDBDSD.Size-1;
         oDBDSD.Offset := i;
         oDBDSD.SetValue('U_string' , i, '');
         oDBDSD.SetValue('U_Tipo'   , i, 'C');
         oDBDSD.SetValue('U_Formato', i, '0');
         oMatrix.AddRow(1, oMatrix.RowCount);
         ShowStr(oForm);
         oForm.Mode := BoFormMode.fm_OK_MODE;
      end;

      // Validación de valores
      if (pVal.EventType = BoEventTypes.et_VALIDATE) and (pVal.BeforeAction = False) and (not pVal.InnerEvent) then begin
         BubbleEvent := true;
         if (pVal.ItemUID = 'mtx_0') then begin
            if (pVal.Row = oMatrix.RowCount) then begin
               oDBDSD := oForm.DataSources.DBDataSources.Item('@VID_AFDEFSERIED');
               oDBDSD.InsertRecord(oDBDSD.Size);
               i := oDBDSD.Size-1;
               oDBDSD.Offset := i;
               oDBDSD.SetValue('U_string' , i, '');
               oDBDSD.SetValue('U_Tipo'   , i, 'C');
               oDBDSD.SetValue('U_Formato', i, '0');
               oMatrix.AddRow(1, oMatrix.RowCount);
            end;
            ShowStr(oForm);
         end;
      end

      // Validación de valores
      else if (pVal.EventType = BoEventTypes.et_COMBO_SELECT) and (pVal.BeforeAction = false) then begin
         if (pVal.ColUID = 'Tipo') then begin
            sValue  := ComboBox(oMatrix.Columns.Item('Tipo'   ).Cells.Item(pVal.Row).Specific).Selected.Value;
            s       := EditText(oMatrix.Columns.Item('String' ).Cells.Item(pVal.Row).Specific).Value;
            formato := ComboBox(oMatrix.Columns.Item('Formato').Cells.Item(pVal.Row).Specific).Selected.Value;

            if (sValue = '+') or (sValue = '-') then begin
               try
                  i := FSBOf.StrToInteger(s);
                  ComboBox(oMatrix.Columns.Item('Formato').Cells.Item(pVal.Row).Specific).Active := True;
               except
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Dato_numerico], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
                  exit;
               end;

               j := 0;
               for i:=1 to oMatrix.RowCount do begin
                  if (sValue = '+') or (sValue = '-') then
                     inc(j);
               end;
               if (j > 1) then begin
                  FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Solo_un_numero_por_serie], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
                  exit;
               end;
            end;

            if (sValue = 'A') and (sValue = 'M') and (sValue = 'D') then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Fecha_al_crear_lote], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
               EditText(oMatrix.Columns.Item('String').Cells.Item(pVal.Row).Specific).Value := FSBOf.GetStrLote('', sValue, s, formato);
            end;
            if (sValue = 'I') then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Articulo_al_crear_lote], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
               EditText(oMatrix.Columns.Item('String').Cells.Item(pVal.Row).Specific).Value := FSBOf.GetStrLote('', sValue, s, formato);
            end;
            if (sValue = 'W') then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Documento_al_crear_lote], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
               EditText(oMatrix.Columns.Item('String').Cells.Item(pVal.Row).Specific).Value := FSBOf.GetStrLote('', sValue, s, formato);
            end;
            if (sValue = 'O') then begin
               FSBOApp.StatusBar.SetText(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Origen_al_crear_lote], BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
               EditText(oMatrix.Columns.Item('String').Cells.Item(pVal.Row).Specific).Value := FSBOf.GetStrLote('', sValue, s, formato);
            end;

        end;
         ShowStr(oForm);
      end

      else if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = true) then begin
         if (pVal.ItemUID = '1') and ((oForm.Mode = BoFormMode.fm_ADD_MODE) or (oForm.Mode = BoFormMode.fm_UPDATE_MODE)) then begin
            BubbleEvent := False;
            if (1 = FSBOApp.MessageBox(GlobalSettings.APP_MESSAGE[GlobalSettings.APP_Message_Arr, GlobalSettings.APP_Message_id.Actualizar_series_QM], 1, 'Ok', 'Cancelar','')) then begin
               if (ValidacionFinal(oForm, oMatrix)) then begin
                  BubbleEvent := true;
               end;
            end;
         end
      end

   except
      on e: exception do begin
         FSBOApp.StatusBar.SetText(e.Message + ' ** Trace: ' + e.StackTrace, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('FormEvent: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TDefSeriesParaLotes.ValidacionFinal(oForm: SAPbouiCOM.Form; mtx: SAPbouiCOM.Matrix): boolean;
var
   oMxDetalle:  SAPbouiCOM.Matrix;
   oRow:        integer;
   MaxLineId:   integer;
   TipoNumero:  integer;
   tipo:        string;
begin
   result := false;
   try
      oMxDetalle := Matrix(oForm.Items.Item('mtx_0').Specific);

      TipoNumero := 0;
      MaxLineId  := 0;
      oRow := 1;
      while oRow <= oMxDetalle.RowCount do begin
         tipo := '';
         try
            tipo := ComboBox(oMxDetalle.Columns.Item('Tipo').Cells.Item(oRow).Specific).Selected.Value;
         except
         end;
         if (tipo = '+') or (tipo = '-') then begin
            inc(TipoNumero);
            try
               FSBOf.StrToInteger(EditText(oMxDetalle.Columns.Item('String').Cells.Item(oRow).Specific).Value)
            except
               FSBOApp.StatusBar.SetText('string debe ser un valor numerico para tipo Número ' + int32(oRow+1).ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
               exit;
            end;
         end;

         if (EditText(oMxDetalle.Columns.Item('String').Cells.Item(oRow).Specific).Value = '') and (( tipo = '+') or ( tipo = '-')) then  begin
            FSBOApp.StatusBar.SetText('Debe ingresar numero en linea ' + int32(oRow).ToString, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
            exit;
         end
         else if (EditText(oMxDetalle.Columns.Item('String').Cells.Item(oRow).Specific).Value = '') and (tipo = 'C') then  begin
            oMxDetalle.DeleteRow(oRow);
            continue;
         end;
         if (EditText(oMxDetalle.Columns.Item('LineId').Cells.Item(oRow).Specific).Value = '') then begin
            inc(oRow);
            continue;
         end;
         if (MaxLineId < FSBOf.StrToInteger(EditText(oMxDetalle.Columns.Item('LineId').Cells.Item(oRow).Specific).Value)) then
            MaxLineId := FSBOf.StrToInteger(EditText(oMxDetalle.Columns.Item('LineId').Cells.Item(oRow).Specific).Value);
         inc(oRow);
      end;
      if (TipoNumero > 1) then begin
         FSBOApp.StatusBar.SetText('Solo se puede utilizar un tipo numerico por serie', BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
         exit;
      end;

      oRow := 1;
      while oRow <= oMxDetalle.RowCount do begin
         if (EditText(oMxDetalle.Columns.Item('LineId').Cells.Item(oRow).Specific).Value.Trim = '') then begin
            inc(MaxLineId);
            EditText(oMxDetalle.Columns.Item('LineId').Cells.Item(oRow).Specific).Value :=  MaxLineId.ToString;
         end;
         inc(oRow);
      end;

      result := true;
   except
      on e:exception do begin
         OutLog('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace);
         result := false;
         FSBOApp.StatusBar.SetText('ValidacionFinal : ' + e.Message + ' ** Trace: ' + e.StackTrace , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
      end;
   end;
end;

end.
