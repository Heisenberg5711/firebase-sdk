Pod::Spec.new do |s|
  s.name             = 'FirebaseDev'
  s.version          = '3.99.1'
  s.summary          = 'Firebase Open Source Libraries for iOS.'

  s.description      = <<-DESC
Simplify your iOS development, grow your user base, and monetize more effectively with Firebase.
                       DESC

  s.homepage         = 'https://firebase.google.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.authors          = 'Google, Inc.'
  s.source           = { :git => 'https://github.com/firebase/firebase-ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Firebase'
  s.ios.deployment_target = '8.0'
  s.default_subspec  = 'Root'

  s.subspec 'Root' do |sp|
    sp.source_files = 'Firebase/Firebase/Firebase.h'
    sp.public_header_files = 'Firebase/Firebase/Firebase.h'
    sp.preserve_paths = 'Firebase/Firebase/module.modulemap'
    sp.user_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/Firebase/Firebase/Firebase"' }
  end

  s.subspec 'Core' do |sp|
    sp.source_files = 'FirebaseCore/Core/**/*.[mh]'
    sp.public_header_files =
      'FirebaseCore/Core/Firebase.h',
      'FirebaseCore/Core/FirebaseCore.h',
      'FirebaseCore/Core/FIRAnalyticsConfiguration.h',
      'FirebaseCore/Core/FIRApp.h',
      'FirebaseCore/Core/FIRConfiguration.h',
      'FirebaseCore/Core/FIRLoggerLevel.h',
      'FirebaseCore/Core/FIROptions.h'
    sp.dependency 'GoogleToolboxForMac/NSData+zlib', '~> 2.1'
    sp.dependency 'FirebaseDev/Root'
  end

  s.subspec 'Auth' do |sp|
    sp.source_files = 'Firebase/Auth/Source/**/*.[mh]'
    sp.public_header_files =
      'Firebase/Auth/Source/FirebaseAuth.h',
      'Firebase/Auth/Source/FirebaseAuthVersion.h',
      'Firebase/Auth/Source/FIRAdditionalUserInfo.h',
      'Firebase/Auth/Source/FIRAuth.h',
      'Firebase/Auth/Source/FIRAuthAppDelegateProxy.h',
      'Firebase/Auth/Source/FIRAuthCredential.h',
      'Firebase/Auth/Source/FIRAuthAppCredential.h',
      'Firebase/Auth/Source/FIRAuthDataResult.h',
      'Firebase/Auth/Source/FIRAuthErrors.h',
      'Firebase/Auth/Source/AuthProviders/EmailPassword/FIREmailPasswordAuthProvider.h',
      'Firebase/Auth/Source/AuthProviders/Facebook/FIRFacebookAuthProvider.h',
      'Firebase/Auth/Source/AuthProviders/GitHub/FIRGitHubAuthProvider.h',
      'Firebase/Auth/Source/AuthProviders/Google/FIRGoogleAuthProvider.h',
      'Firebase/Auth/Source/AuthProviders/OAuth/FIROAuthProvider.h',
      'Firebase/Auth/Source/AuthProviders/Phone/FIRPhoneAuthCredential.h',
      'Firebase/Auth/Source/AuthProviders/Phone/FIRPhoneAuthProvider.h',
      'Firebase/Auth/Source/AuthProviders/Twitter/FIRTwitterAuthProvider.h',
      'Firebase/Auth/Source/FIRUser.h',
      'Firebase/Auth/Source/FIRUserInfo.h'
    sp.preserve_paths =
      'Firebase/Auth/README.md',
      'Firebase/Auth/CHANGELOG.md'
    sp.xcconfig = { 'OTHER_CFLAGS' => '-DFIRAuth_VERSION=' + s.version.to_s +
      ' -DFIRAuth_MINOR_VERSION=' + s.version.to_s.split(".")[0] + "." + s.version.to_s.split(".")[1]
    }
    sp.framework = 'Security'
    sp.dependency 'FirebaseDev/Core'
    sp.dependency 'GTMSessionFetcher/Core', '~> 1.1'
    sp.dependency 'GoogleToolboxForMac/NSDictionary+URLArguments', '~> 2.1'
  end

  s.subspec 'Database' do |sp|
    sp.source_files = 'Firebase/Database/**/*.[mh]',
      'Firebase/Database/Wrap-leveldb/APLevelDB.mm',
      'Firebase/Database/Libraries/SocketRocket/fbase64.c'
    sp.public_header_files =
      'Firebase/Database/Api/FirebaseDatabase.h',
      'Firebase/Database/Api/FIRDataEventType.h',
      'Firebase/Database/Api/FIRDataSnapshot.h',
      'Firebase/Database/Api/FIRDatabaseQuery.h',
      'Firebase/Database/Api/FIRMutableData.h',
      'Firebase/Database/Api/FIRServerValue.h',
      'Firebase/Database/Api/FIRTransactionResult.h',
      'Firebase/Database/Api/FIRDatabase.h',
      'Firebase/Database/FIRDatabaseReference.h'
    sp.library = 'c++'
    sp.library = 'icucore'
    sp.framework = 'CFNetwork'
    sp.framework = 'Security'
    sp.framework = 'SystemConfiguration'
    sp.dependency 'leveldb-library'
    sp.dependency 'FirebaseDev/Core'
  end

  s.subspec 'Messaging' do |sp|
    sp.source_files = 'Firebase/Messaging/**/*.[mh]'
    sp.requires_arc = 'Firebase/Messaging/*.m'

    sp.public_header_files =
      'Firebase/Messaging/Public/FirebaseMessaging.h',
      'Firebase/Messaging/Public/FIRMessaging.h'
    sp.library = 'sqlite3'
    sp.xcconfig ={ 'GCC_PREPROCESSOR_DEFINITIONS' =>
      '$(inherited) ' +
      'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1 ' +
      'FIRMessaging_LIB_VERSION=' + String(s.version)
    }
    sp.framework = 'AddressBook'
    sp.framework = 'SystemConfiguration'
    sp.dependency 'FirebaseDev/Core'
    sp.dependency 'GoogleToolboxForMac/Logger', '~> 2.1'
    sp.dependency 'Protobuf', '~> 3.1'
  end

  s.subspec 'Storage' do |sp|
    sp.source_files = 'Firebase/Storage/**/*.[mh]'
    sp.public_header_files =
      'Firebase/Storage/FirebaseStorage.h',
      'Firebase/Storage/FIRStorage.h',
      'Firebase/Storage/FIRStorageConstants.h',
      'Firebase/Storage/FIRStorageDownloadTask.h',
      'Firebase/Storage/FIRStorageMetadata.h',
      'Firebase/Storage/FIRStorageObservableTask.h',
      'Firebase/Storage/FIRStorageReference.h',
      'Firebase/Storage/FIRStorageTask.h',
      'Firebase/Storage/FIRStorageTaskSnapshot.h',
      'Firebase/Storage/FIRStorageUploadTask.h'
    sp.framework = 'MobileCoreServices'
    sp.dependency 'FirebaseDev/Core'
    sp.dependency 'GTMSessionFetcher/Core', '~> 1.1'
  end

end
