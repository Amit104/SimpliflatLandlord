import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  static Future<FirebaseUser> getCurrentSignedInUser() async {
    return FirebaseAuth.instance.currentUser();
  }

  static Future<FirebaseUser> signinWithCredentials(String verificationId, String otp) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return FirebaseAuth.instance.signInWithCredential(credential).then((FirebaseUser user) {
      return user;
    }).catchError((e) {
      return null;
    });
  }

  static Future<bool> sendOTP(String phoneNumber, Function autoRetrieve, Function codeSent, Function verifiedSuccess, Function verifiedFailed) async {
    return FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: codeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: verifiedFailed).then((ret) {return true;}).catchError((e) {return false;});
  }
}