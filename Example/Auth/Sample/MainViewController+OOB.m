/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "MainViewController+OOB.h"

#import "AppManager.h"
#import "MainViewController_Internal.h"

@implementation MainViewController (OOB)

- (void)toggleActionCodeRequestType {
  switch (self.actionCodeRequestType) {
    case ActionCodeRequestTypeInApp:
      self.actionCodeRequestType = ActionCodeRequestTypeContinue;
      break;
    case ActionCodeRequestTypeContinue:
      self.actionCodeRequestType = ActionCodeRequestTypeEmail;
      break;
    case ActionCodeRequestTypeEmail:
      self.actionCodeRequestType = ActionCodeRequestTypeInApp;
      break;
  }
  [self updateTable];
}

- (NSString *)nameForActionCodeOperation:(FIRActionCodeOperation)operation {
  switch (operation) {
    case FIRActionCodeOperationVerifyEmail:
      return @"Verify Email";
    case FIRActionCodeOperationRecoverEmail:
      return @"Recover Email";
    case FIRActionCodeOperationPasswordReset:
      return @"Password Reset";
    case FIRActionCodeOperationEmailLink:
      return @"Email Sign-In Link";
    case FIRActionCodeOperationUnknown:
      return @"Unknown action";
  }
}

- (NSString *)actionCodeRequestTypeString {
  switch (self.actionCodeRequestType) {
    case ActionCodeRequestTypeInApp:
      return @"In-App + Continue URL";
    case ActionCodeRequestTypeContinue:
      return @"Continue URL";
    case ActionCodeRequestTypeEmail:
      return @"Email Only";
  }
}

- (void)changeActionCodeContinueURL {
  [self showTextInputPromptWithMessage:kContinueURLDescription
                       completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
   if (userPressedOK) {
     self.actionCodeContinueURL = userInput.length ? [NSURL URLWithString:userInput] : nil;
     [self updateTable];
   }
 }];
}

- (void)requestVerifyEmail {
  [self showSpinner:^{
    void (^sendEmailVerification)(void (^)(NSError *)) = ^(void (^completion)(NSError *)) {
      if (self.actionCodeRequestType == ActionCodeRequestTypeEmail) {
        [[self user] sendEmailVerificationWithCompletion:completion];
      } else {
        [[self user] sendEmailVerificationWithActionCodeSettings:[self actionCodeSettings]
                                                      completion:completion];
      }
    };
    sendEmailVerification(^(NSError *_Nullable error) {
      [self hideSpinner:^{
        if (error) {
          [self logFailure:@"request verify email failed" error:error];
          [self showMessagePrompt:error.localizedDescription];
          return;
        }
        [self logSuccess:@"request verify email succeeded."];
        [self showMessagePrompt:@"Sent"];
      }];
    });
  }];
}

- (void)requestPasswordReset {
  [self showTextInputPromptWithMessage:@"Email:"
                       completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
     if (!userPressedOK || !userInput.length) {
       return;
     }
     [self showSpinner:^{
       void (^requestPasswordReset)(void (^)(NSError *)) = ^(void (^completion)(NSError *)) {
         if (self.actionCodeRequestType == ActionCodeRequestTypeEmail) {
           [[AppManager auth] sendPasswordResetWithEmail:userInput completion:completion];
         } else {
           [[AppManager auth] sendPasswordResetWithEmail:userInput
                                      actionCodeSettings:[self actionCodeSettings]
                                              completion:completion];
         }
       };
       requestPasswordReset(^(NSError *_Nullable error) {
         [self hideSpinner:^{
           if (error) {
             [self logFailure:@"request password reset failed" error:error];
             [self showMessagePrompt:error.localizedDescription];
             return;
           }
           [self logSuccess:@"request password reset succeeded."];
           [self showMessagePrompt:@"Sent"];
         }];
       });
     }];
   }];
}

- (void)resetPassword {
  [self showTextInputPromptWithMessage:@"OOB Code:"
                       completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
   if (!userPressedOK || !userInput.length) {
     return;
   }
   NSString *code =  userInput;
   [self showTextInputPromptWithMessage:@"New Password:"
                        completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
    if (!userPressedOK || !userInput.length) {
      return;
    }

    [self showSpinner:^{
      [[AppManager auth] confirmPasswordResetWithCode:code
                                          newPassword:userInput
                                           completion:^(NSError *_Nullable error) {
       [self hideSpinner:^{
         if (error) {
           [self logFailure:@"Password reset failed" error:error];
           [self showMessagePrompt:error.localizedDescription];
           return;
         }
         [self logSuccess:@"Password reset succeeded."];
         [self showMessagePrompt:@"Password reset succeeded."];
       }];
     }];
    }];
  }];
 }];
}

- (void)checkActionCode {
  [self showTextInputPromptWithMessage:@"OOB Code:"
                       completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
   if (!userPressedOK || !userInput.length) {
     return;
   }
   [self showSpinner:^{
     [[AppManager auth] checkActionCode:userInput completion:^(FIRActionCodeInfo *_Nullable info,
                                                               NSError *_Nullable error) {
       [self hideSpinner:^{
         if (error) {
           [self logFailure:@"Check action code failed" error:error];
           [self showMessagePrompt:error.localizedDescription];
           return;
         }
         [self logSuccess:@"Check action code succeeded."];
         NSString *email = [info dataForKey:FIRActionCodeEmailKey];
         NSString *fromEmail = [info dataForKey:FIRActionCodeFromEmailKey];
         NSString *message =
         fromEmail ? [NSString stringWithFormat:@"%@ -> %@", fromEmail, email] : email;
         NSString *operation = [self nameForActionCodeOperation:info.operation];
         [self showMessagePromptWithTitle:operation
                                  message:message
                         showCancelButton:NO
                               completion:nil];
       }];
     }];
   }];
 }];
}

- (void)applyActionCode {
  [self showTextInputPromptWithMessage:@"OOB Code:"
                       completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
   if (!userPressedOK || !userInput.length) {
     return;
   }
   [self showSpinner:^{

     [[AppManager auth] applyActionCode:userInput completion:^(NSError *_Nullable error) {
       [self hideSpinner:^{
         if (error) {
           [self logFailure:@"Apply action code failed" error:error];
           [self showMessagePrompt:error.localizedDescription];
           return;
         }
         [self logSuccess:@"Apply action code succeeded."];
         [self showMessagePrompt:@"Action code was properly applied."];
       }];
     }];
   }];
 }];
}

- (void)verifyPasswordResetCode {
  [self showTextInputPromptWithMessage:@"OOB Code:"
                       completionBlock:^(BOOL userPressedOK, NSString *_Nullable userInput) {
   if (!userPressedOK || !userInput.length) {
     return;
   }
   [self showSpinner:^{
     [[AppManager auth] verifyPasswordResetCode:userInput completion:^(NSString *_Nullable email,
                                                                       NSError *_Nullable error) {
       [self hideSpinner:^{
         if (error) {
           [self logFailure:@"Verify password reset code failed" error:error];
           [self showMessagePrompt:error.localizedDescription];
           return;
         }
         [self logSuccess:@"Verify password resest code succeeded."];
         NSString *alertMessage =
         [[NSString alloc] initWithFormat:@"Code verified for email: %@", email];
         [self showMessagePrompt:alertMessage];
       }];
     }];
   }];
 }];
}

@end
