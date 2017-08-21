#import "PLANIT_v1-Swift.h"
#import "HLEmailSender.h"
#import "StringUtils.h"
#import "HLAlertsFabric.h"

#import "BZipCompression.h"

NSString * const kReportFileName = @"Technical Report.gz";

@implementation HLEmailSender

+ (BOOL)canSendEmail
{
    return [MFMailComposeViewController canSendMail];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self createMailer];
    }
    return self;
}

- (void)createMailer
{
    if ([HLEmailSender canSendEmail]) {
        self.mailer = [[HLMailComposeVC alloc] init];
        self.mailer.mailComposeDelegate = self;
    }
}

- (void)sendFeedbackEmailTo:(NSString *)email
{
    NSError *error = nil;
    NSArray *toRecipients = @[email];
    NSData *techReport = [[self getTechInfo] dataUsingEncoding:NSUTF16StringEncoding allowLossyConversion:NO];
    techReport = [BZipCompression compressedDataWithData:techReport
                                               blockSize:BZipDefaultBlockSize
                                              workFactor:BZipDefaultWorkFactor
                                                   error:&error];

    [self.mailer setSubject:NSLS(@"HL_LOC_MAIL_FEEDBACK_SUBJECT")];
    [self.mailer setToRecipients:toRecipients];
    [self.mailer addAttachmentData:techReport mimeType:@"application/zip" fileName:kReportFileName];
}

+ (void)showUnavailableAlertInController:(UIViewController *)controller
{
    [HLAlertsFabric showMailSenderUnavailableAlertInController:controller];
}

- (NSString *)getTechInfo
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    NSMutableString *techInfo = [[NSMutableString alloc] init];
    [techInfo appendString:@"\n\n\n"];
    [techInfo appendString:NSLS(@"HL_LOC_MAIL_FEEDBACK_BODY")];
    [techInfo appendFormat:@"\nDevice: %@", device];
    [techInfo appendFormat:@"\niOS version: %@", [[UIDevice currentDevice] systemVersion]];
    [techInfo appendFormat:@"\nApplication version: %@", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"]];
    [techInfo appendFormat:@"\nApplication name: %@", [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleName"]];
	[techInfo appendFormat:@"\nMobile Token: %@", [HDKTokenManager mobileToken]];

    return techInfo;
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    HLEmailSender __weak *weakSelf = self;
    [self.mailer dismissViewControllerAnimated:YES completion:^{
        if ([weakSelf.delegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)]) {
            [weakSelf.delegate mailComposeController:controller didFinishWithResult:result error:error];
        }
        [weakSelf createMailer];
    }];
}

@end
