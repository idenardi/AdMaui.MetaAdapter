import FBAudienceNetwork
import AppTrackingTransparency

@objc(MetaAdSettings)
public class MetaAdSettings : NSObject
{
    @objc
    public static func setAdvertiserTrackingEnabled(isAdvertiserTrackingEnabled: Bool) -> Void {
        FBAdSettings.setAdvertiserTrackingEnabled(isAdvertiserTrackingEnabled)
    }
    
    @objc
    public static func configureAdvertiserTracking() -> Void {
        guard #available(iOS 14.5, *) else {
            // iOS versions prior to 14.5 do not require this configuration
            return
        }
        
        if #available(iOS 17.0, *) {
            // iOS 17+ with SDK 6.15.0+: Meta reads ATT status automatically via ATTrackingManager
            return
        }
        
        // iOS 14.5 to 16.x: read current ATT status without prompting the user
        let status = ATTrackingManager.trackingAuthorizationStatus
        FBAdSettings.setAdvertiserTrackingEnabled(status == .authorized)
    }
}

