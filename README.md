# AdMaui.MetaAdapter

NuGet packages for .NET MAUI that provide the native dependencies required to use the **Meta Audience Network adapter** used in AdMob bidding on Android and iOS.

## Packages

| Package | Platform | NuGet Version | 
|---|---| --- |
| `AdMaui.MetaAdapter.Android` | Android | [![NuGet version (AdMaui.MetaAdapter.Android)](https://img.shields.io/nuget/v/AdMaui.MetaAdapter.Android.svg?style=flat-square)](https://www.nuget.org/packages/AdMaui.MetaAdapter.Android/) |
| `AdMaui.MetaAdapter.iOS` | iOS | [![NuGet version (AdMaui.MetaAdapter.iOS)](https://img.shields.io/nuget/vpre/AdMaui.MetaAdapter.iOS.svg?style=flat-square)](https://www.nuget.org/packages/AdMaui.MetaAdapter.iOS/) |

The NuGet package version reflects the version of the **Meta Audience Network adapter** (mediation) and **FBAudienceNetwork** SDK bundled in the package. For example, version `6.21.0` corresponds to adapter `6.21.0` and Audience Network SDK `6.21.0`.

## Getting started

Follow the official AdMob guides to configure the Meta Audience Network mediation integration:

- **Android:** https://developers.google.com/admob/android/mediation/meta
- **iOS:** https://developers.google.com/admob/ios/mediation/meta

## Android

No additional code is required. Just follow the setup guide above.

## iOS 
On iOS, the only binding provided by this package is for **Advertiser Tracking Enabled**, which is required by the Meta Audience Network [(see Meta docs)](https://developers.facebook.com/docs/audience-network/setting-up/platform-setup/ios/advertising-tracking-enabled).

You have two options after requesting ATT permission:

**Option 1 - Pass the bool status directly `SetAdvertiserTrackingEnabled`**:

```csharp
MetaAdSettings.SetAdvertiserTrackingEnabled(true);
```

**Option 2 - Use `ConfigureAdvertiserTracking`**:

It reads the current `ATTrackingManager.TrackingAuthorizationStatus` automatically.

```csharp
MetaAdSettings.ConfigureAdvertiserTracking();
```

## Behavior During Testing

During tests, the binding is requested normally. However, on **test devices**, when Meta wins the bidding, it may return **NoFill** - meaning no ad is served. This is expected behavior from the Meta Audience Network in test environments.

In **release builds** on real devices, ads have been confirmed to load successfully for both **Banner** and **Interstitial** formats.
