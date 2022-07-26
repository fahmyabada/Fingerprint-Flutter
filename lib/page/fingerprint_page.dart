import 'package:fingerprint_flutter/api/local_auth_api.dart';
import 'package:fingerprint_flutter/main.dart';
import 'package:fingerprint_flutter/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class FingerprintPage extends StatelessWidget {
  const FingerprintPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(MyApp.title),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildAvailability(context),
                const SizedBox(height: 24),
                buildAuthenticate(context),
              ],
            ),
          ),
        ),
      );

  Widget buildAvailability(BuildContext context) => buildButton(
        text: 'Check Availability',
        icon: Icons.event_available,
        onClicked: () async {
          final isAvailable = await LocalAuthApi.hasBiometrics();
          final biometrics = await LocalAuthApi.getBiometrics();
          final hasAuth = await LocalAuthApi.deviceSupported();

          final hasFingerprint = biometrics.contains(BiometricType.fingerprint);
          final hasFace = biometrics.contains(BiometricType.face);
          print("isAvailable************* $isAvailable");
          print("biometrics************* $biometrics");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Availability'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildText('Biometrics', isAvailable),
                  buildText('Fingerprint', hasFingerprint),
                  buildText('Face', hasFace),
                  buildText('HasAuth', hasAuth),
                ],
              ),
            ),
          );
        },
      );

  Widget buildText(String text, bool checked) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            checked
                ? const Icon(Icons.check, color: Colors.green, size: 24)
                : const Icon(Icons.close, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 24)),
          ],
        ),
      );

  Widget buildAuthenticate(BuildContext context) => buildButton(
        text: 'Authenticate',
        icon: Icons.lock_open,
        onClicked: () async {
          final isAuthenticated = await LocalAuthApi.authenticate();

          print("isAuthenticated************* $isAuthenticated");
          isAuthenticated.fold((failure) {
            if (failure == auth_error.notEnrolled) {
              print("failure00************* $failure");
              // Add handling of no hardware here.
            } else if (failure == auth_error.lockedOut ||
                failure == auth_error.permanentlyLockedOut) {
              print("failure11************* $failure");
            } else if (failure == auth_error.notAvailable) {
              print("failure22************* $failure");
              showDialog(
                context: context,
                barrierDismissible: true,
                // outside to dismiss
                builder: (BuildContext context) => customDialog(
                    context, "you should create screen lock first"),
              );
            } else {
              print("failure33************* $failure");
            }
          }, (data) {
            if (data) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              showDialog(
                context: context,
                barrierDismissible: true,
                // outside to dismiss
                builder: (BuildContext context) => customDialog(
                    context, "this device not support fingerprint"),
              );
            }
          });
        },
      );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );

  Widget customDialog(BuildContext context, String desc) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding:
              EdgeInsets.only(top: 40.r, bottom: 20.r, left: 16.r, right: 16.r),
          margin: EdgeInsets.only(top: 50.r),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 10.r,
              ),
              Text(
                "Fingerprint Verification",
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16.r,
              ),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
              ),
              SizedBox(
                height: 24.h,
              ),
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.r, horizontal: 8.r),
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                  ))
            ],
          ),
        ),
      );
}
