/* AmuaController */

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@interface AmuaController : NSObject
{
    //the status item that will be added to the system status bar
    NSStatusItem *statusItem;
	
	IBOutlet NSMenu *menu;
	
	//the preferences window controller
    PreferencesController *preferencesController;
	
	// Preferences tracking object
    NSUserDefaults * preferences;
}
- (IBAction)loveSong:(id)sender;
- (IBAction)skipSong:(id)sender;
- (IBAction)banSong:(id)sender;
- (IBAction)playStop:(id)sender;
- (IBAction)openLastfmHomepage:(id)sender;
- (IBAction)openPersonalPage:(id)sender;
- (IBAction)openPreferences:(id)sender;
@end
