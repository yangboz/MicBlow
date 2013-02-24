#import "MicBlowViewController.h"

@implementation MicBlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
		
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
		
	NSError *error;
		
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
		
	if (recorder) {
		[recorder prepareToRecord];
		recorder.meteringEnabled = YES;
		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	} else
		NSLog([error description]);	
}


- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];

	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;	
    NSString *resultStr = @"Average input:";
    resultStr = [resultStr stringByAppendingFormat:@"%f Peak input:%f Low pass results:%f",[recorder averagePowerForChannel:0],[recorder peakPowerForChannel:0],lowPassResults];
//	NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
    NSLog(@"Mic Blow befor filter:%@",resultStr);
    //@see: http://mobileorchard.com/tutorial-detecting-when-a-user-blows-into-the-mic/
	if (lowPassResults > 0.55)
    {
		NSLog(@"Mic blow detected");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mic blow detected!" message:resultStr delegate:self cancelButtonTitle:NULL otherButtonTitles:NULL, nil];
    [alertView show];
        
    }
}


- (void)dealloc {
	[levelTimer release];
	[recorder release];
    [super dealloc];
}

@end
