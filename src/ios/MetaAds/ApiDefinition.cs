using Foundation;
using ObjCRuntime;

namespace AdMaui.MetaAdapter;

// @interface MetaAdSettings
[BaseType (typeof(NSObject))]
public interface MetaAdSettings
{
	// +(void)setAdvertiserTrackingEnabledWithIsAdvertiserTrackingEnabled:(id)isAdvertiserTrackingEnabled;
	[Static]
	[Export ("setAdvertiserTrackingEnabledWithIsAdvertiserTrackingEnabled:")]
	void SetAdvertiserTrackingEnabled (bool isAdvertiserTrackingEnabled);

	// +(void)configureAdvertiserTracking;
	[Static]
	[Export ("configureAdvertiserTracking")]
	void ConfigureAdvertiserTracking ();
}
