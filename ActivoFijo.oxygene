<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <RootNamespace>AF_IFRS</RootNamespace>
    <OutputType>WinExe</OutputType>
    <AssemblyName>Activo Fijo - IFRS</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <ApplicationIcon>Properties\App.ico</ApplicationIcon>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFrameworkVersion>v3.5</TargetFrameworkVersion>
    <ProjectGuid>{20BDA41C-3BFE-47B4-9E07-C22E5C42FE87}</ProjectGuid>
    <RunPostBuildEvent>OnBuildSuccess</RunPostBuildEvent>
    <Company />
    <DefaultUses />
    <StartupClass />
    <InternalAssemblyName />
    <Name>ActivoFijo</Name>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <DefineConstants>DEBUG;TRACE;DLL;</DefineConstants>
    <OutputPath>bin\Debug\</OutputPath>
    <GeneratePDB>True</GeneratePDB>
    <CpuType>x86</CpuType>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <OutputPath>.\bin\Release</OutputPath>
    <EnableAsserts>False</EnableAsserts>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Interop.SBOReporterOne">
      <HintPath>bin\Debug\Interop.SBOReporterOne.dll</HintPath>
    </Reference>
    <Reference Include="mscorlib">
      <HintPath>mscorlib.dll</HintPath>
    </Reference>
    <Reference Include="System">
      <HintPath>System.dll</HintPath>
    </Reference>
    <Reference Include="System.Core">
      <HintPath>$(ProgramFiles)\Reference Assemblies\Microsoft\Framework\v3.5\System.Core.dll</HintPath>
    </Reference>
    <Reference Include="System.Data">
      <HintPath>System.Data.dll</HintPath>
    </Reference>
    <Reference Include="System.Data.DataSetExtensions">
      <HintPath>$(ProgramFiles)\Reference Assemblies\Microsoft\Framework\v3.5\System.Data.DataSetExtensions.dll</HintPath>
    </Reference>
    <Reference Include="System.Drawing">
      <HintPath>System.Drawing.dll</HintPath>
    </Reference>
    <Reference Include="System.Windows.Forms">
      <HintPath>System.Windows.Forms.dll</HintPath>
    </Reference>
    <Reference Include="System.Xml">
      <HintPath>System.Xml.dll</HintPath>
    </Reference>
    <Reference Include="System.Xml.Linq">
      <HintPath>$(ProgramFiles)\Reference Assemblies\Microsoft\Framework\v3.5\System.Xml.Linq.dll</HintPath>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Activofijo\ActivoObj.pas" />
    <Compile Include="Activofijo\Activos.pas" />
    <Compile Include="Activofijo\ActivosIFRS.pas" />
    <Compile Include="Activofijo\ActivosVentaIFRS.pas" />
    <Compile Include="Activofijo\ActualizarProyectos.pas" />
    <Compile Include="Activofijo\Adiciones.pas" />
    <Compile Include="Activofijo\AdquisicionActivos.pas" />
    <Compile Include="Activofijo\AgrupacionIFRS.pas" />
    <Compile Include="Activofijo\Ciudades.pas" />
    <Compile Include="Activofijo\Comunas.pas" />
    <Compile Include="Activofijo\DarDeBaja.pas" />
    <Compile Include="Activofijo\DefSeriesParaLotes.pas" />
    <Compile Include="Activofijo\FacturaCompra.pas" />
    <Compile Include="Activofijo\FiltroReportes.pas" />
    <Compile Include="Activofijo\GoodsIssue.pas" />
    <Compile Include="Activofijo\GrupoArticulos.pas" />
    <Compile Include="Activofijo\Items.pas" />
    <Compile Include="Activofijo\Parametros.pas" />
    <Compile Include="Activofijo\ProcesoAF.pas" />
    <Compile Include="Activofijo\RealizaProcesoAFS.pas">
    </Compile>
    <Compile Include="Activofijo\RevalorizacionIFRS.pas" />
    <Compile Include="Activofijo\TrasladoActivos.pas" />
    <Compile Include="Activofijo\UbicacionesActivos.pas" />
    <Compile Include="Activofijo\UsoActivos.pas">
    </Compile>
    <Compile Include="Activofijo\Utils.pas" />
    <Compile Include="Main.pas">
      <SubType>Form</SubType>
      <DesignableClassName>Activo_Fijo__IFRS.MainForm</DesignableClassName>
    </Compile>
    <Compile Include="Main.Designer.pas">
      <SubType>Form</SubType>
      <DesignableClassName>Activo_Fijo__IFRS.MainForm</DesignableClassName>
    </Compile>
    <EmbeddedResource Include="Main.resx" />
    <Compile Include="Program.pas" />
    <Content Include="Properties\App.ico" />
    <Compile Include="Properties\AssemblyInfo.pas" />
    <EmbeddedResource Include="Properties\Resources.resx">
      <Generator>ResXFileCodeGenerator</Generator>
    </EmbeddedResource>
    <Compile Include="Properties\Resources.Designer.pas" />
    <None Include="Properties\Settings.settings">
      <Generator>SettingsSingleFileGenerator</Generator>
    </None>
    <Compile Include="Properties\Settings.Designer.pas" />
  </ItemGroup>
  <ItemGroup>
    <Folder Include="Activofijo\" />
    <Folder Include="Properties\" />
  </ItemGroup>
  <Choose>
    <When Condition=" '$(Configuration)'=='Debug SAP910 x86' ">
      <PropertyGroup>
        <DefineConstants>DEBUG;TRACE;SAP_900;</DefineConstants>
      </PropertyGroup>
      <ItemGroup>
        <Reference Include="Interop.SAPbobsCOM">
          <HintPath>SAP91\Interop.SAPbobsCOM.dll</HintPath>
          <EmbedInteropTypes>False</EmbedInteropTypes>
        </Reference>
        <Reference Include="Interop.SAPbouiCOM">
          <HintPath>SAP91\Interop.SAPbouiCOM.dll</HintPath>
          <EmbedInteropTypes>False</EmbedInteropTypes>
        </Reference>
        <Reference Include="VisualD.ADOSBOScriptExecute">
          <HintPath>Dll\VisualD.ADOSBOScriptExecute.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.ChooseFromListSubQuery">
          <HintPath>Dll\VisualD.ChooseFromListSubQuery.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Core">
          <HintPath>Dll\VisualD.Core.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Dimensions">
          <HintPath>Dll\VisualD.Dimensions.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Main">
          <HintPath>Dll\VisualD.Main.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MainObjBase">
          <HintPath>Dll\VisualD.MainObjBase.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MasterDataMatrixForm">
          <HintPath>Dll\VisualD.MasterDataMatrixForm.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Matrix_Helper">
          <HintPath>Dll\VisualD.Matrix_Helper.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MenuConfFr">
          <HintPath>Dll\VisualD.MenuConfFr.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MultiFunctions">
          <HintPath>Dll\VisualD.MultiFunctions.dll</HintPath>
        </Reference>
        <Reference Include="Visuald.ReportWindowFr">
          <HintPath>Dll\Visuald.ReportWindowFr.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOCrystalPreview">
          <HintPath>Dll\VisualD.SBOCrystalPreview.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOFunctions">
          <HintPath>Dll\VisualD.SBOFunctions.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOGeneralService">
          <HintPath>Dll\VisualD.SBOGeneralService.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOObjectMg1">
          <HintPath>Dll\VisualD.SBOObjectMg1.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.uEncrypt">
          <HintPath>Dll\VisualD.uEncrypt.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.untLog">
          <HintPath>Dll\VisualD.untLog.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.vkBaseForm">
          <HintPath>Dll\VisualD.vkBaseForm.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.vkFormInterface">
          <HintPath>Dll\VisualD.vkFormInterface.dll</HintPath>
        </Reference>
      </ItemGroup>
    </When>
    <When Condition=" '$(Configuration)'=='Debug SAP910 x64' ">
      <PropertyGroup>
        <DefineConstants>DEBUG;TRACE;SAP_900;</DefineConstants>
      </PropertyGroup>
      <ItemGroup>
        <Reference Include="Interop.SAPbobsCOM">
          <HintPath>SAP91 x64\Interop.SAPbobsCOM.dll</HintPath>
          <EmbedInteropTypes>False</EmbedInteropTypes>
        </Reference>
        <Reference Include="Interop.SAPbouiCOM">
          <HintPath>SAP91 x64\Interop.SAPbouiCOM.dll</HintPath>
          <EmbedInteropTypes>False</EmbedInteropTypes>
        </Reference>
        <Reference Include="VisualD.ADOSBOScriptExecute">
          <HintPath>Dll x64\VisualD.ADOSBOScriptExecute.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.ChooseFromListSubQuery">
          <HintPath>Dll x64\VisualD.ChooseFromListSubQuery.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Core">
          <HintPath>Dll x64\VisualD.Core.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Dimensions">
          <HintPath>Dll x64\VisualD.Dimensions.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Main">
          <HintPath>Dll x64\VisualD.Main.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MainObjBase">
          <HintPath>Dll x64\VisualD.MainObjBase.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MasterDataMatrixForm">
          <HintPath>Dll x64\VisualD.MasterDataMatrixForm.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.Matrix_Helper">
          <HintPath>Dll x64\VisualD.Matrix_Helper.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MenuConfFr">
          <HintPath>Dll x64\VisualD.MenuConfFr.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.MultiFunctions">
          <HintPath>Dll x64\VisualD.MultiFunctions.dll</HintPath>
        </Reference>
        <Reference Include="Visuald.ReportWindowFr">
          <HintPath>Dll x64\Visuald.ReportWindowFr.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOCrystalPreview">
          <HintPath>Dll x64\VisualD.SBOCrystalPreview.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOFunctions">
          <HintPath>Dll x64\VisualD.SBOFunctions.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOGeneralService">
          <HintPath>Dll x64\VisualD.SBOGeneralService.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.SBOObjectMg1">
          <HintPath>Dll x64\VisualD.SBOObjectMg1.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.uEncrypt">
          <HintPath>Dll x64\VisualD.uEncrypt.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.untLog">
          <HintPath>Dll x64\VisualD.untLog.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.vkBaseForm">
          <HintPath>Dll x64\VisualD.vkBaseForm.dll</HintPath>
        </Reference>
        <Reference Include="VisualD.vkFormInterface">
          <HintPath>Dll x64\VisualD.vkFormInterface.dll</HintPath>
        </Reference>
      </ItemGroup>
    </When>
  </Choose>
  <ItemGroup>
    <ProjectReference Include="VisualD.GlobalVid\VisualD.GlobalVid.oxygene">
      <Name>VisualD.GlobalVid</Name>
      <Project>{c1a27262-baa6-496e-809c-3ddc9827e271}</Project>
      <Private>True</Private>
      <HintPath>VisualD.GlobalVid\bin\Debug\VisualD.GlobalVid.dll</HintPath>
    </ProjectReference>
  </ItemGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x86'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)' == 'Debug SAP910 x64'">
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <SuppressWarnings />
    <CpuType>x64</CpuType>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <FutureHelperClassName />
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)' == 'Debug SAP910 x86'">
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <SuppressWarnings />
    <CpuType>x86</CpuType>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <FutureHelperClassName />
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|x86'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|x86'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x64'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x64'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|x64'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|x64'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Echoes.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>