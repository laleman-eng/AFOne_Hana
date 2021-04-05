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
    <Name>Activo Fijo - dll</Name>
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
    <Reference Include="VisualD.ADOSBOScriptExecute">
      <HintPath>dll\VisualD.ADOSBOScriptExecute.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.ChooseFromListSubQuery">
      <HintPath>dll\VisualD.ChooseFromListSubQuery.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.Core">
      <HintPath>dll\VisualD.Core.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.Dimensions">
      <HintPath>dll\VisualD.Dimensions.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.Main">
      <HintPath>dll\VisualD.Main.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.MainObjBase">
      <HintPath>dll\VisualD.MainObjBase.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.MasterDataMatrixForm">
      <HintPath>dll\VisualD.MasterDataMatrixForm.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.Matrix_Helper">
      <HintPath>dll\VisualD.Matrix_Helper.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.MenuConfFr">
      <HintPath>dll\VisualD.MenuConfFr.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.MultiFunctions">
      <HintPath>dll\VisualD.MultiFunctions.dll</HintPath>
    </Reference>
    <Reference Include="Visuald.ReportWindowFr">
      <HintPath>dll\Visuald.ReportWindowFr.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.SBOCrystalPreview">
      <HintPath>dll\VisualD.SBOCrystalPreview.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.SBOFunctions">
      <HintPath>dll\VisualD.SBOFunctions.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.SBOGeneralService">
      <HintPath>dll\VisualD.SBOGeneralService.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.SBOObjectMg1">
      <HintPath>dll\VisualD.SBOObjectMg1.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.uEncrypt">
      <HintPath>dll\VisualD.uEncrypt.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.untLog">
      <HintPath>dll\VisualD.untLog.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.vkBaseForm">
      <HintPath>dll\VisualD.vkBaseForm.dll</HintPath>
    </Reference>
    <Reference Include="VisualD.vkFormInterface">
      <HintPath>dll\VisualD.vkFormInterface.dll</HintPath>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Activofijo\ActivoObj.pas" />
    <Compile Include="Activofijo\Activos.pas" />
    <Compile Include="Activofijo\ActivosIFRS.pas" />
    <Compile Include="Activofijo\ActivosVentaIFRS.pas" />
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
  <ItemGroup>
    <COMReference Include="Interop.SAPbouiCOM">
      <Guid>{6048236a-956d-498d-a6f1-9c81c13ab6e8}</Guid>
      <VersionMajor>9</VersionMajor>
      <VersionMinor>0</VersionMinor>
      <Lcid>0</Lcid>
      <Isolated>False</Isolated>
      <WrapperTool>tlbimp</WrapperTool>
      <Private>True</Private>
    </COMReference>
    <COMReference Include="Interop.SAPbobsCOM">
      <Guid>{fc8030be-f5d2-4b8e-8f92-44228fe30090}</Guid>
      <VersionMajor>9</VersionMajor>
      <VersionMinor>0</VersionMinor>
      <Lcid>0</Lcid>
      <Isolated>False</Isolated>
      <WrapperTool>tlbimp</WrapperTool>
      <Private>True</Private>
    </COMReference>
  </ItemGroup>
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
    <OutputPath>bin\Release\</OutputPath>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Echoes.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug SAP910 x64' ">
    <DefineConstants>DEBUG;TRACE;DLL;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <CpuType>x86</CpuType>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <OutputPath>bin\Debug SAP910 x64\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|x86'">
    <OutputPath>bin\Debug SAP910 x64\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug SAP910 x86' ">
    <DefineConstants>DEBUG;TRACE;DLL;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <CpuType>x86</CpuType>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <OutputPath>bin\Debug SAP910 x86\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|x86'">
    <OutputPath>bin\Debug SAP910 x86\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x64'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x64'">
    <OutputPath>bin\Release\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|x64'">
    <OutputPath>bin\Debug SAP910 x64\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|x64'">
    <OutputPath>bin\Debug SAP910 x86\</OutputPath>
  </PropertyGroup>
</Project>