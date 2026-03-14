param (
    [String]$MetaAdsAdapterVersion = '6.21.0',
	[String]$BuildNumber = '0',
	[String]$BuildPath = $null,
	[Switch]$IsRelease,
	[Switch]$BuildNuGet,
    [Switch]$DownloadSDKs,
    [Switch]$GenerateBindings
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Set default BuildPath relative to script location if not specified
if (-not $BuildPath) {
    $BuildPath = Join-Path $ScriptDir ".build"
}

Function DownloadMetaAdapterSdks(
	[String]$DownloadPath = '.build/'
){
	# Get the download URL's for the Google Mobile Ads SDK tar.gz
	$FBAudienceNetworkDownloadUrl = ((Invoke-WebRequest -Uri $FBAudienceNetworkPodspecUrl).Content | ConvertFrom-Json).source.http
	$GoogleMetaAdapterDownloadUrl = ((Invoke-WebRequest -Uri $GoogleMetaAdapterPodspecUrl).Content | ConvertFrom-Json).source.http

	# Make sure download path exists
	New-Item -ItemType Directory -Force -Path $DownloadPath -ErrorAction SilentlyContinue

	$FBAudienceTgzPath = (Join-Path $DownloadPath "FBAudienceNetwork.zip")
	$GoogleMetaAdapterTgzPath = (Join-Path $DownloadPath "GoogleMetaAdapter.zip")

	# Download the iOS SDK files
	Invoke-WebRequest $FBAudienceNetworkDownloadUrl -OutFile $FBAudienceTgzPath
	Invoke-WebRequest $GoogleMetaAdapterDownloadUrl -OutFile $GoogleMetaAdapterTgzPath

	$FBAudienceSdkPath = (Join-Path $DownloadPath "FBAudienceNetwork")
	$GoogleMetaAdapterSdkPath = (Join-Path $DownloadPath "GoogleMetaAdapter")
	
	# Make directories to extract
	New-Item -ItemType Directory -Force -Path $FBAudienceSdkPath -ErrorAction SilentlyContinue
	New-Item -ItemType Directory -Force -Path $GoogleMetaAdapterSdkPath -ErrorAction SilentlyContinue

	# Extract the tar.gz files
	& tar -xf $FBAudienceTgzPath -C $FBAudienceSdkPath
	& tar -xf $GoogleMetaAdapterTgzPath -C $GoogleMetaAdapterSdkPath

    $FBAudienceAndroidTgzPath = (Join-Path $DownloadPath "FBAudienceNetwork.aar")
	$GoogleMetaAdapterAndroidTgzPath = (Join-Path $DownloadPath "GoogleMetaAdapter.aar")

    # Download the Android SDK files
	Invoke-WebRequest $FBAudienceNetworkAndroidUrl -OutFile $FBAudienceAndroidTgzPath
	Invoke-WebRequest $GoogleMetaAdapterAndroidUrl -OutFile $GoogleMetaAdapterAndroidTgzPath
}

$FBAudienceNetworkAndroidUrl = "https://repo1.maven.org/maven2/com/facebook/android/audience-network-sdk/$MetaAdsAdapterVersion/audience-network-sdk-$MetaAdsAdapterVersion.aar"
$GoogleMetaAdapterAndroidUrl = "https://dl.google.com/android/maven2/com/google/ads/mediation/facebook/$MetaAdsAdapterVersion.0/facebook-$MetaAdsAdapterVersion.0.aar"
$FBAudienceNetworkPodspecUrl = "https://raw.githubusercontent.com/CocoaPods/Specs/master/Specs/2/1/5/FBAudienceNetwork/$MetaAdsAdapterVersion/FBAudienceNetwork.podspec.json"
$GoogleMetaAdapterPodspecUrl = "https://raw.githubusercontent.com/CocoaPods/Specs/master/Specs/4/1/b/GoogleMobileAdsMediationFacebook/$MetaAdsAdapterVersion.0/GoogleMobileAdsMediationFacebook.podspec.json"

if ($DownloadSDKs -eq $true) {
    # Clear out old 
    Remove-Item -Recurse -Force -Path $BuildPath -ErrorAction SilentlyContinue

    DownloadMetaAdapterSdks -DownloadPath $BuildPath
}

if ($BuildNuGet -eq $true) {

	if ($IsRelease -eq $true) {
		$NuGetMetaAdsVersion = "$MetaAdsAdapterVersion.$BuildNumber"
	} else {
		$NuGetMetaAdsVersion = "$MetaAdsAdapterVersion-ci.$BuildNumber"
    }	

	$NuGetOutputPath = (Join-Path $BuildPath "NuGet")
	New-Item -ItemType Directory -Force -Path $NuGetOutputPath -ErrorAction SilentlyContinue

	dotnet build -t:Pack -c:Release -p:PackageVersion=$NuGetMetaAdsVersion -p:PackageOutputPath=$NuGetOutputPath src/android/MetaAds/MetaAds.csproj
    dotnet build -t:Pack -c:Release -p:PackageVersion=$NuGetMetaAdsVersion -p:PackageOutputPath=$NuGetOutputPath src/ios/MetaAds/MetaAds.csproj
}

if ($GenerateBindings -eq $true) {
	$BindingOutputPath = (Join-Path $BuildPath "Bindings")
	New-Item -ItemType Directory -Force -Path $BindingOutputPath -ErrorAction SilentlyContinue

	dotnet build src/ios/MetaAds/MetaAds.csproj -c Debug -f net9.0-ios
	& sharpie bind --sdk=iphoneos --output (Join-Path $BindingOutputPath "FBAds/") --namespace=FBAds --scope=Headers "src/ios/MetaAds/bin/Debug/net9.0-ios/MetaAds.resources/FBAdsiOS.xcframework/ios-arm64/FBAds.framework/Headers/FBAds-Swift.h"
}