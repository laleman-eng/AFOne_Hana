namespace VisualD.GlobalVid;

interface

uses
System.Collections.Generic,
VisualD.SBOFunctions;

Type
[Serializable]
TEnumMensajes = public enum( SBO_Terminado 
                            ,SBO_BD_Cambiada
                            ,SBO_LANG_Cambiado
                            ,SBO_Shutdown
                            ,Iniciando
                            ,Error_UI
                            ,Error_DI
                            ,NO_Parametros
                            ,Parmetros_Reportes_No_Definido
                            ,Per_Post_Actividad
                            ,Sin_activos
                            ,Procesar_Activos_QM
                            ,Procesando
                            ,Proceso_Done
                            ,Post_period_QM
                            ,Post_Done
                            ,Reverse_Period_QM
                            ,Reverse_Done
                            ,Anular_Baja_QM
                            ,Depreciar_Activo
                            ,Contabilizar_Activo
                            ,Dar_Baja_QM
                            ,Baja_Info_Incompleta
                            ,Vida_Cero
                            ,Fecha_Ingr_Sin_Datos
                            ,Primera_Dep_Anterior_Ingreso
                            ,Primera_Dep_Anterior_Ingreso_Per
                            ,Primera_Cor_Anterior_Ingreso
                            ,Primera_Cor_Anterior_Ingreso_Per
                            ,Periodo_Mayor_1
                            ,Periodo_Menor_12
                            ,Tipo_Depr_Lineal
                            ,Tipo_Depr_Acel
                            ,No_Aplicar_Serie
                            ,Todos_los_activos
                            ,Adicion_Procesada
                            ,Adicion_Fecha_Anterior
                            ,Adicion_Fecha_Posterior
                            ,Adicion_Procesar_QM
                            ,Linea_Fecha_invalida
                            ,Linea_Valor_Negativo
                            ,Linea_Periodo_Negativo
                            ,Btn_Activo_Fijo
                            ,Grupo_Ya_ingresado
                            ,Actualizar_Grupo_QM
                            ,Codigo_ya_ingresado
                            ,Actualizar_Ciudades_QM
                            ,Actualizar_Comunas_QM
                            ,Actualiza_ubicacion_QM
                            ,Dato_numerico
                            ,Solo_un_numero_por_serie
                            ,Fecha_al_crear_lote
                            ,Articulo_al_crear_lote
                            ,Documento_al_crear_lote
                            ,Origen_al_crear_lote
                            ,Actualizar_series_QM
                            ,Actualizar_informacion_QM
                            ,Activos_en_baja_reversar
                            ,Activo_No_Clasificado
                            ,Indices_no_definidos
                            ,Periodo_invalido
                            ,Activo_sin_Actividad_posterior
                            ,Adicion_sin_Actividad_posterior
                            ,Sin_activo_a_procesar
                            ,Periodo_Cerrado
                            ,Periodo_anterior_con_actividad
                            ,Sin_activos_a_contabilizar
                            ,Cuenta_no_def_ActFij
                            ,Cuenta_no_def_CorrActFij
                            ,Cuenta_no_def_CorrDepr
                            ,Cuenta_no_def_DepAcum
                            ,Cuenta_no_def_GasDep
                            ,Cuenta_no_def_Bis33
                            ,Cuenta_no_def_GasBaja
                            ,Cuenta_no_def_AdqAct
                            ,Cuenta_no_def_Reavaluo
                            ,Cuenta_no_def_Deterioro
                            ,Error_contabilzacion
                            ,Info_incompleta_en_baja
                            ,Error_anular_baja
                            ,Error_baja
                            ,Baja_activo
                            ,Dado_baja
                            ,Anulada_baja
                            ,Origen_distinto_destino
                            ,Trasladar_activos_QM
                            ,Activo_Ya_Ingresado
                            ,Guia_Traslado_no_imprimible
                            );

  TGlobalAddOnOptions = public class
    private
    public
       AddonId  : String;
       Opciones : String;
       SQLUsers : String;
   end;

[Serializable]
TGlobalVid = public class(ICloneable)
private
   FSBO_f:      CSBOFunctions;
   method GetSBO_f : CSBOFunctions;
   method SetSBO_f(Value : CSBOFunctions);
public
   ThousandSeparator : String := '';
   DecimalSeparator  : String := '.';
   SBOSpaceName      : String := 'VID_AF';
   LastFormUID       : String :='';
   PrevFormUID       : String :='';
   MinFormWidth      : Integer:=800;
   MinFormHeight     : Integer:=600;
   HeightBtn         : Integer:=50;
   MenuFile          : String;
   NumberDecimalDigits: Integer := 6;
   NumberDecimalDigitsQty : Integer := 6;
   FilaMatrix        : Integer := -1;
   GLOB_CenterForm   : Boolean := false;
   GLOB_DocEntry     : String  := '-1';
   GLOB_ValDig       : String  := '';
   FoForms           : List<Object>;
   GLOB_ListDocEntry : List<String>  :=new List<String>;
   IFRSActivo        : Boolean:=False;     
   IFRSNativo        : Boolean:=False;
   IFRS_Plan_Code    : String; 
   IFRS_Plan_Name    : String; 
   LocalCurr_Dec     : Integer;
   APP_Message_Arr   : Integer:=0;
   APP_Message_id    : TEnumMensajes;

   CrystalReportFileName : String :='';
   Menu_List_CrystalReports: Dictionary<String, String>:=New Dictionary<String, String>;
   Menu_List_vkBaseForm    : Dictionary<String, System.Type>:=New Dictionary<String, System.Type>;       
   FormFolderPanes    : Dictionary<String,Dictionary<String,Integer>> := New Dictionary<String,Dictionary<String,Integer>>;

APP_MESSAGE      : array [0..1,0..87] of String := [["Se ha cerrado Business One...   Terminando AddOn."
                                                 ,"Se ha cambiado de base de datos...   Terminando AddOn."   
                                                 ,"Se ha cambiado el lenguaje de SAP B1... Reinicie AddOn"  
                                                 ,"El servidor ha finalizado...   Terminando AddOn."
                                                 ,"Iniciando..."
                                                 ,"Error en conexión a SAP SBO. (UI)"
                                                 ,"Error en conexión a SAP SBO 2007 (DI)."
                                                 ,"Parametros no definidos."
                                                 ,"Parametros de reportes no definidos."
                                                 ,"Periodo posterior al indicado con actividad, el cual debe ser reversado previamente."
                                                 ,"Sin activos con actividad a reversar."
                                                 ,"¿ Desea procesar activos para este periodo ?"
                                                 ,"Procesando..."
                                                 ,"Proceso realizado."
                                                 ,"¿ Desea contabilizar este periodo ?"
                                                 ,"Contabilización  realizada."
                                                 ,"¿ Desea reversar este periodo ?"
                                                 ,"Reversa de movimientos y contabilización realizada."
                                                 ,"Anular baja para este activo. ¿ Desea continuar ?"
                                                 ,"El Activo de debe ser depreciado hasta el periodo anterior en que se da de baja."
                                                 ,"El Activo de debe ser contabilizado hasta el periodo anterior en que se da de baja."
                                                 ,"Una vez dado de baja no sera actualizado este activo en los procesos posteriores. ¿ Desea dar de baja este activo fijo ?"
                                                 ,"Información incompleta para el activo a dar de baja."
                                                 ,"Vida util debe ser mayor o igual a 0."
                                                 ,"Fecha de ingreso sin datos."
                                                 ,"Año de primera depreciación no puede ser anterior al año de ingreso."
                                                 ,"Periodo de primera depreciación no puede ser anterior al mes de la fecha de ingreso."
                                                 ,"Año de primera corrección no puede ser anterior al año de ingreso."
                                                 ,"Periodo de primera corrección no puede ser anterior al mes de la fecha de ingreso."
                                                 ,"Periodo debe ser mayor o igual a 1."
                                                 ,"Periodo debe ser menor o igual a 12."
                                                 ,"Lineal"
                                                 ,"Acelerada"
                                                 ,"No Aplicar serie"
                                                 ,"Todos los activos"
                                                 ,"Adición ya procesada, no puede modificarse"
                                                 ,"Adicion no puede tener fecha anterior a fecha de ingreso del activo."
                                                 ,"Adicion debe ser posterior a último proceso realizado."
                                                 ,"¿ Desea modificar este activo con estas adiciones ?"
                                                 ,"Fecha invalida, en línea "
                                                 ,"Valor no puede ser negativo, en linea "
                                                 ,"Periodo no puede ser negativo, en linea "
                                                 ,"Activo Fijo"
                                                 ,"Código de grupo de artículos ya ingresado"
                                                 ,"¿ Desea actualizar este grupo de activos ?"
                                                 ,"Codigo ya ingresado"
                                                 ,"¿ Desea actualizar Ciudades ?"
                                                 ,"¿ Desea actualizar Comunas ?"
                                                 ,"¿ Desea actualizar esta ubicación ?"
                                                 ,"Dato debe ser un númerico"
                                                 ,"Solo se puede utilizar un tipo numerico por cada serie"
                                                 ,"Fecha se asignará al momento de crear el Lote"
                                                 ,"Artículo se asignará al momento de crear el Lote"
                                                 ,"Documento se asignará al momento de crear el Lote"
                                                 ,"Origen se asignará al momento de crear el Lote"
                                                 ,"¿ Desea actualizar series ?"
                                                 ,"¿ Desea actualizar la información ?"
                                                 ,"Activo dado de baja en este periodo, debe anular operación de baja para reversar el periodo."
                                                 ,"Activo fijo no clasificado"
                                                 ,"Indices no definidos para periodo a procesar "
                                                 ,"Periodo a procesar invalido."
                                                 ,"Activo sin actividad, ingresado con fecha anterior al proceso. Revisar fechas de ingreso y reprocese. Id activo: "
                                                 ,"Adición sin actividad, ingresada con fecha anterior al proceso. Revisar fechas de ingreso y reprocese. Id adición "
                                                 ,"Sin activos para procesar"
                                                 ,"Periodo cerrado, no se puede procesar"
                                                 ,"Periodo anterior al indicado con actividad no contabilizada, el cual debe ser contabilizado previamente"
                                                 ,"Sin activos con actividad a contabilizar"
                                                 ,"Cuenta Activo Fijo no definida  "
                                                 ,"Cuenta Corrección Activo Fijo no definida  "
                                                 ,"Cuenta Corrección Depreciación no definida  "
                                                 ,"Cuenta Depreciación Acumulada no definida  "
                                                 ,"Cuenta Gastos Depreciación  no definida  "
                                                 ,"Cuenta crédito Bis33 no definida  "
                                                 ,"Cuenta gastos de baja no definida  "
                                                 ,"Cuenta adquisición de activos no definida  "
                                                 ,"Cuenta Reavaluo no definida  "
                                                 ,"Cuenta Deterioro no definida  "
                                                 ,"Error en contabilización "
                                                 ,"Información incompleta para el activo a dar de baja "
                                                 ,"Error al anular baja activo "
                                                 ,"Error al dar de baja activo "
                                                 ,"Activo "
                                                 ," dado de baja."
                                                 ," baja reversada."
                                                 ,"Origen debe ser distinto del destino"
                                                 ,"¿ Desea trasladar estos activos ?"
                                                 ,"Codigo de activo ya ingresado"
                                                 ,"No se puede imprimir una guía no creada"
                                                 ],
                                                 ["Business One is closed...   Addon finishing."
                                                 ,"Database was changed...   Addon finishing." 
                                                 ,"Language was changed... Restart AddOn"
                                                 ,"Server has ended...   Addon finishing."
                                                 ,"Starting..."
                                                 ,"Connection error to SAP SBO. (UI)"
                                                 ,"Connection error to SAP SBO 2007 (DI)."
                                                 ,"Undefined parameters."
                                                 ,"Undefined report parameters."
                                                 ,"After period with activity, which must be reversed before."
                                                 ,"Without assets with activity to reverse."
                                                 ,"Do you want to process fixed assets for this period?" 
                                                 ,"Processing..."
                                                 ,"Process completed."
                                                 ,"Do you want to post this period ?"
                                                 ,"Accounting done."
                                                 ,"Do you want to reverse this period ?"
                                                 ,"Reverse movements and accounting done."
                                                 ,"Reverse unsuscribe for this asset. Continue?"
                                                 ,"The asset must be depreciated until the period in wich is unsuscribed."
                                                 ,"The asset must be post until the period in wich is unsuscribed."
                                                 ,"If the asset is retired, it will no longer be considered in future processes. Continue?"
                                                 ,"Incomplete information to unsuscribe."
                                                 ,"Lifetime must be greater than or equal to zero."
                                                 ,"Admission date without data."
                                                 ,"First year depreciation can not be earlier than the year of admission."
                                                 ,"First period depreciation can not be earlier than the month of admission date."
                                                 ,"First year correction can not be earlier than the year of admission."
                                                 ,"First period correction can not be earlier than the month of admission date."
                                                 ,"Period must be greater than or equal to 1."
                                                 ,"Period must be lees than or equal to 12."
                                                 ,"Linear"
                                                 ,"Accelerated"
                                                 ,"Do not apply series"
                                                 ,"All assets"
                                                 ,"Adding processed and can not be changed"
                                                 ,"Addition can not be dated prior to date of entry of active"
                                                 ,"Addition should be made ​​after last process done." 
                                                 ,"Do you want to modify this asset with these additions?"
                                                 ,"Invalid date "
                                                 ,"Value can not be negative, in line "
                                                 ,"Period can not be negative, in line "
                                                 ,"Fixed Asset"
                                                 ,"Class asset group already entered "
                                                 ,"Would you like to update this asset class ?"
                                                 ,"Code already entered"
                                                 ,"Would you like to update cities ?"
                                                 ,"Would you like to update counties ?"
                                                 ,"Would you like to update this location ?"
                                                 ,"Data must be numeric"
                                                 ,"Only one numeric type can be used by each serie"
                                                 ,"Date will be assigned when use the serie"
                                                 ,"Item will be assigned when use the serie"
                                                 ,"Document will be assigned when use the serie"
                                                 ,"Origin will be assigned when use the serie"
                                                 ,"Would you like to update series ?"
                                                 ,"Would you like to update the information ?"
                                                 ,"Asset retired during this period, you must override this operation to reverse the period"
                                                 ,"Asset type not defined"
                                                 ,"Indexes not defined for period to process"
                                                 ,"Invalid period to process"
                                                 ,"Asset without activity, registered prior to this period. Check admission date and reprocess. Asset Id: "
                                                 ,"Addition without activity, registered prior to this period. Check admission date and reprocess. Asset Id: "
                                                 ,"There are no assets to process"
                                                 ,"Closed period, can not be processed"
                                                 ,"Previous period with activity no posted, it must be posted before"
                                                 ,"There are no assets with activity to post"
                                                 ,"Fixed assets account not defined "
                                                 ,"Assets correction account not defined "
                                                 ,"Accumulated Depreciation Correction account not defined "
                                                 ,"Accumulated Depreciation account not defined "
                                                 ,"Depreciation expenses account not defined "
                                                 ,"Bis33 account not defined "
                                                 ,"Retirement account not defined "
                                                 ,"Asset acquisition account not defined "
                                                 ,"Reappraisal account not defined "
                                                 ,"Impairment account not defined "
                                                 ,"Error in posting "
                                                 ,"Insufficient information for the asset"
                                                 ,"Error on reversing retirement "
                                                 ,"Error on retirement "
                                                 ,"Asset "
                                                 ," , Retirement done"
                                                 ," , Retirement reversed"
                                                 ,"Initial location must be different from final location"
                                                 ,"Would you like to transfer this assets ?"
                                                 ,"Asset code already entered"
                                                 ,"A transfer not created can not  be printed"
                                                 ]
                                                ];
   Property iCorrelativo      :  Integer  := 0;
   Property UsarSkinLinkVID   : Boolean :=True;
   Property UsarSkinVID       : Boolean :=False;
   Property UsarSkinVID_Form0 : Boolean :=False;
   Property SBO_f             : CSBOFunctions read GetSBO_f Write SetSBO_f;
   method   Clone: System.Object; implements ICloneable.Clone; 
end;

implementation

method TGlobalVid.Clone: System.Object;
begin
    exit self.MemberwiseClone();
end;

method TGlobalVid.GetSBO_f: CSBOFunctions;
begin
  result := FSBO_f;
end;

method TGlobalVid.SetSBO_f(Value: CSBOFunctions);
begin
  FSBO_f := value;
end;

end.