namespace AF_IFRS.ActualizarProyectos;

interface

uses
  SAPbouiCOM, 
  SAPbobsCOM, 
  System.Collections.Generic,
  System.IO,
  System.Globalization,
  VisualD.GlobalVid,
  VisualD.SBOFunctions, 
  VisualD.vkBaseForm, 
  VisualD.SBOGeneralService,
  VisualD.vkFormInterface,
  Visuald.MultiFunctions,
  Visuald.ReportWindowFr;

type
  TActualizarProyectos = class(TvkBaseForm, IvkFormInterface) 
  private
    oRecordSet: SAPbobsCOM.Recordset;
    s : String;
    method AddChooseFromList(var oForm: SAPbouiCOM.Form);
    method Actualizar(proyecto: String; grupo: String); 
  public
    method  InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean; reintroduce;
    method  FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean); reintroduce;
  end;

implementation

method   TActualizarProyectos.InitForm(uid: string; xmlPath: string; var application:SAPbouiCOM.Application; var company:SAPbobsCOM.Company; var SBOFunctions: VisualD.SBOFunctions.CSBOFunctions ; var _GlobalSettings:TGlobalVid): boolean;
var
   oForm:    SAPbouiCOM.Form;
begin
   Result := inherited InitForm(uid, xmlPath,var application,var company,var sboFunctions,var _GlobalSettings);
   // inicializa variable locales
   try
      if (FCmpny.language = BoSuppLangs.ln_English) then
         FSBOf.LoadForm(xmlPath,'VID_ActualizarProyectos_EN.srf', Uid)
      else
         FSBOf.LoadForm(xmlPath,'VID_ActualizarProyectos.srf', Uid);

      oForm   := FSBOApp.Forms.Item(uid);

      oForm.Freeze(True);
      oForm.AutoManaged    := false;
      oForm.SupportedModes := 1;   // afm_All
      

      oForm.DataSources.UserDataSources.Add("Proyecto", BoDataType.dt_SHORT_TEXT, 40);
      EditText(oForm.Items.Item("Proyecto").Specific).DataBind.SetBound(true, "", "Proyecto");

      oForm.DataSources.UserDataSources.Add("Grupo", BoDataType.dt_SHORT_TEXT, 50);
      ComboBox(oForm.Items.Item("Grupo").Specific).DataBind.SetBound(true, "", "Grupo");

        // CFL ItemCode
      AddChooseFromList(var oForm);
      EditText(oForm.Items.Item('Proyecto').Specific).ChooseFromListUID   := 'CFLPro';
      EditText(oForm.Items.Item('Proyecto').Specific).ChooseFromListAlias := 'PrjCode';

      oRecordSet := RecordSet(FCmpny.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset));

      s := iif(GlobalSettings.RunningUnderSQLServer, 
                     "SELECT 'Todos' 'Code', 'Todos' 'Name' UNION Select  code,  name from [@VID_AFGR] order by name", 
                     'SELECT ''Todos'' "Code", ''Todos'' "Name" FROM DUMMY UNION Select  "Code" "Code",  "Name" "Name" from "@VID_AFGR" order by "Name"');
         oRecordSet.DoQuery(s);
         FSBOf.FillCombo(ComboBox(oForm.Items.Item('Grupo').Specific), var oRecordSet, true);

      oForm.Freeze(False);
      oForm.Visible := true;

      System.Runtime.InteropServices.Marshal.ReleaseComObject(oForm);
   except
      on e:exception do begin
         FSBOApp.StatusBar.SetText(e.Message , BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
         OutLog('InitForm: ' + e.Message + ' ** Trace: ' + e.StackTrace);
      end;
   end;
end;

method TActualizarProyectos.AddChooseFromList(var oForm: SAPbouiCOM.Form);
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
         oCFLCreationParams.ObjectType := '63';    // 4 => Item
         oCFLCreationParams.UniqueID := 'CFLPro';
         oCFL := oCFLs.Add(oCFLCreationParams);
end;

method   TActualizarProyectos.FormEvent(FormUID: string; var pVal: SAPbouiCOM.ItemEvent; var BubbleEvent: Boolean);
var
   oForm           : SAPbouiCOM.Form;
   oFormIvk        : IvkFormInterface;
   sValue          : string; 
   oDataTable      : SAPbouiCOM.DataTable;
   proyecto        : String;
   grupo           : String;
begin
	inherited FormEvent(FormUID, var pVal, var BubbleEvent);
	oForm   := FSBOApp.Forms.Item(pVal.FormUID);

	try
		// CFL
		if (pVal.EventType = BoEventTypes.et_CHOOSE_FROM_LIST) and (pVal.BeforeAction = False) then 
		begin
			if (pVal.ItemUID = 'Proyecto') then 
			begin
				oDataTable := SAPbouiCOM.IChooseFromListEvent(pVal).SelectedObjects;
				try
					sValue  := System.String(oDataTable.GetValue('PrjCode', 0));
				except
					;
				end;
				if (sValue = '') then
					exit;
				oForm.Freeze(true);
				oForm.DataSources.UserDataSources.Item("Proyecto").Value := sValue;
			end;
		end;

		if (pVal.EventType = BoEventTypes.et_ITEM_PRESSED) and (pVal.BeforeAction = false) then 
		begin
			if (pVal.ItemUID = 'btn_1') then 
			begin
				BubbleEvent := False;
           
				proyecto := String(oForm.DataSources.UserDataSources.Item("Proyecto").Value).Trim();
				grupo := String(oForm.DataSources.UserDataSources.Item("Grupo").Value).Trim();
				if proyecto = "" then
				begin
					FSBOApp.StatusBar.SetText("Debe ingresar Proyecto", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
					exit;
				end
				else if grupo = "" then
				begin
					FSBOApp.StatusBar.SetText("Debe seleccionar Grupo", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
					exit;
				end;

				if (FCmpny.language = BoSuppLangs.ln_English) then
					s := "Are you sure you want to activate the projects in Master Fixed Assets"
				else
					s := "Esta seguro que desea actilizar los proyectos en maestro Activos Fijos";
				
				if (1 <> FSBOApp.MessageBox(s, 2, 'Si', 'No','')) then
					exit
				else 
					Actualizar(proyecto, grupo); 
			end;
		end;
	finally
		if oForm <> nil then
			oForm.Freeze(false);
	except
		on e: exception do 
		begin
			if (FSBOf.Cmpny.InTransaction) then
				FSBOf.Cmpny.EndTransaction(BoWfTransOpt.wf_RollBack);
			FSBOApp.StatusBar.SetText(e.Message, BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Error);
			OutLog(e.Message + ' ** Trace: ' + e.StackTrace);
		end;
	end;
end;






method   TActualizarProyectos.Actualizar(proyecto: string; grupo: String);
begin
    s := iif(GlobalSettings.RunningUnderSQLServer, 
    "UPDATE [@VID_AFAS] SET U_Project = '{0}' WHERE ISNULL(U_DeBaja,'N') = 'N' {1}",
                     'UPDATE "@VID_AFAS" SET "U_Project" = ''{0}'' WHERE IFNULL("U_DeBaja",''N'') = ''N'' {1}'
                     );
    s := String.Format(s, proyecto, iif(grupo = "Todos", "AND 1=1", iif(GlobalSettings.RunningUnderSQLServer, "AND U_ItmGrpCd = '" + grupo + "'", 'AND "U_ItmGrpCd" = ''' + grupo + '''')) ); 
    oRecordSet.DoQuery(s);

    FSBOApp.StatusBar.SetText("Se actualizado correctamente los proyectos", BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Success);
end;


end.
