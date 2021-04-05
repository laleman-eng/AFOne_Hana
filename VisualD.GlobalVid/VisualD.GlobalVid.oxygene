<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <ProductVersion>3.5</ProductVersion>
    <ProjectGuid>{c1a27262-baa6-496e-809c-3ddc9827e271}</ProjectGuid>
    <RootNamespace>VisualD.GlobalVid</RootNamespace>
    <OutputType>library</OutputType>
    <AssemblyName>VisualD.GlobalVid</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFrameworkVersion>v3.5</TargetFrameworkVersion>
    <Name>VisualD.GlobalVid</Name>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <Optimize>False</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <GenerateMDB>True</GenerateMDB>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <CpuType>x86</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <SuppressWarnings />
    <FutureHelperClassName />
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <Optimize>true</Optimize>
    <OutputPath>.\bin\Release</OutputPath>
    <GeneratePDB>False</GeneratePDB>
    <GenerateMDB>False</GenerateMDB>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <RegisterForComInterop>False</RegisterForComInterop>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)' == 'Debug SAP910 x64'">
		<DefineConstants>DEBUG;TRACE;</DefineConstants>
		<GeneratePDB>True</GeneratePDB>
		<SuppressWarnings/>
		<CpuType>x64</CpuType>
		<XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
		<FutureHelperClassName/>
		<OutputPath>bin\Debug\</OutputPath>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)' == 'Debug SAP910 x86'">
		<DefineConstants>DEBUG;TRACE;</DefineConstants>
		<GeneratePDB>True</GeneratePDB>
		<SuppressWarnings/>
		<CpuType>x86</CpuType>
		<XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
		<FutureHelperClassName/>
		<OutputPath>bin\Debug\</OutputPath>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'">
		<DebugSymbols>true</DebugSymbols>
		<DebugType>full</DebugType>
		<Optimize>false</Optimize>
		<OutputPath>bin\Debug\</OutputPath>
		<DefineConstants>DEBUG;TRACE</DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<PlatformTarget>x86</PlatformTarget>
		<Prefer32Bit>false</Prefer32Bit>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|AnyCPU'">
		<DebugType>pdbonly</DebugType>
		<Optimize>true</Optimize>
		<OutputPath>bin\Release\</OutputPath>
		<DefineConstants>TRACE</DefineConstants>
		<ErrorReport>prompt</ErrorReport>
		<WarningLevel>4</WarningLevel>
		<Prefer32Bit>false</Prefer32Bit>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
		<PlatformTarget>x86</PlatformTarget>
		<OutputPath>bin\Debug\</OutputPath>
		<DefineConstants>TRACE;DEBUG</DefineConstants>
		<Prefer32Bit>false</Prefer32Bit>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x86'">
		<PlatformTarget>x86</PlatformTarget>
		<OutputPath>bin\Release\</OutputPath>
		<Prefer32Bit>false</Prefer32Bit>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|AnyCPU'">
		<DebugSymbols>true</DebugSymbols>
		<OutputPath>bin\Debug\</OutputPath>
		<DefineConstants>DEBUG;TRACE</DefineConstants>
		<DebugType>full</DebugType>
		<PlatformTarget>x86</PlatformTarget>
		<ErrorReport>prompt</ErrorReport>
		<CodeAnalysisRuleSet>MinimumRecommendedRules.ruleset</CodeAnalysisRuleSet>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|x86'">
		<DebugSymbols>true</DebugSymbols>
		<OutputPath>bin\Debug\</OutputPath>
		<DefineConstants>TRACE;DEBUG</DefineConstants>
		<PlatformTarget>x86</PlatformTarget>
		<CodeAnalysisRuleSet>MinimumRecommendedRules.ruleset</CodeAnalysisRuleSet>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|AnyCPU'">
		<DebugSymbols>true</DebugSymbols>
		<OutputPath>bin\Debug\</OutputPath>
		<DefineConstants>DEBUG;TRACE</DefineConstants>
		<DebugType>full</DebugType>
		<PlatformTarget>x86</PlatformTarget>
		<ErrorReport>prompt</ErrorReport>
		<CodeAnalysisRuleSet>MinimumRecommendedRules.ruleset</CodeAnalysisRuleSet>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|x86'">
		<DebugSymbols>true</DebugSymbols>
		<OutputPath>bin\Debug\</OutputPath>
		<DefineConstants>TRACE;DEBUG</DefineConstants>
		<PlatformTarget>x86</PlatformTarget>
		<CodeAnalysisRuleSet>MinimumRecommendedRules.ruleset</CodeAnalysisRuleSet>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x64'">
		<PlatformTarget>x64</PlatformTarget>
		<OutputPath>bin\Debug\</OutputPath>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x64'">
		<PlatformTarget>x64</PlatformTarget>
		<OutputPath>bin\Release\</OutputPath>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x64|x64'">
		<PlatformTarget>x64</PlatformTarget>
		<OutputPath>bin\Debug\</OutputPath>
	</PropertyGroup>
	<PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug SAP910 x86|x64'">
		<PlatformTarget>x64</PlatformTarget>
		<OutputPath>bin\Debug\</OutputPath>
	</PropertyGroup>
  <ItemGroup>
    <Reference Include="mscorlib" />
    <Reference Include="System" />
    <Reference Include="System.Data" />
    <Reference Include="System.Xml" />
    <Reference Include="System.Core">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
    <Reference Include="System.Xml.Linq">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
    <Reference Include="System.Data.DataSetExtensions">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Global_Vid.pas" />
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
    <Folder Include="Properties\" />
  </ItemGroup>
  <Choose>
		<When Condition=" '$(Configuration)'=='Debug SAP910 x86' ">
			<PropertyGroup>
				<DefineConstants>DEBUG;TRACE;SAP_900;DYNAMIC;SAP_910_UP;</DefineConstants>
			</PropertyGroup>
			<ItemGroup>
				<Reference Include="Interop.SAPbobsCOM">
					<HintPath>..\SAP91\Interop.SAPbobsCOM.dll</HintPath>
					<EmbedInteropTypes>False</EmbedInteropTypes>
				</Reference>
				<Reference Include="Interop.SAPbouiCOM">
					<HintPath>..\SAP91\Interop.SAPbouiCOM.dll</HintPath>
					<EmbedInteropTypes>False</EmbedInteropTypes>
				</Reference>
				<Reference Include="VisualD.SBOFunctions">
					<HintPath>..\Dll\VisualD.SBOFunctions.dll</HintPath>
				</Reference>
			</ItemGroup>
		</When>
		<When Condition=" '$(Configuration)'=='Debug SAP910 x64' ">
			<PropertyGroup>
				<DefineConstants>DEBUG;TRACE;SAP_900;DYNAMIC;SAP_910_UP;</DefineConstants>
			</PropertyGroup>
			<ItemGroup>
				<Reference Include="Interop.SAPbobsCOM">
					<HintPath>..\SAP91 x64\Interop.SAPbobsCOM.dll</HintPath>
					<EmbedInteropTypes>False</EmbedInteropTypes>
				</Reference>
				<Reference Include="Interop.SAPbouiCOM">
					<HintPath>..\SAP91 x64\Interop.SAPbouiCOM.dll</HintPath>
					<EmbedInteropTypes>False</EmbedInteropTypes>
				</Reference>
				<Reference Include="VisualD.SBOFunctions">
					<HintPath>..\Dll x64\VisualD.SBOFunctions.dll</HintPath>
				</Reference>
			</ItemGroup>
		</When>
	</Choose>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|x86'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Release|x86'">
    <OutputPath>bin\Debug\</OutputPath>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Echoes.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>