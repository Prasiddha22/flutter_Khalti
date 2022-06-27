import 'package:flutter/material.dart';
import 'package:khalti/khalti.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Khalti.init(
      publicKey: 'test_public_key_XXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      enabledDebugging: false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const KhaltiPayment(),
    );
  }
}

class KhaltiPayment extends StatefulWidget {
  const KhaltiPayment({Key? key}) : super(key: key);

  @override
  State<KhaltiPayment> createState() => _KhaltiPaymentState();
}

class _KhaltiPaymentState extends State<KhaltiPayment> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: pinCodeController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pin Code',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final initiationModel = await Khalti.service.initiatePayment(
                request: PaymentInitiationRequestModel(
                  amount: 1000,
                  mobile: phoneController.text,
                  productIdentity: 'pID',
                  productName: 'Product Name',
                  transactionPin: pinCodeController.text,
                  productUrl: '',
                  additionalData: {},
                ),
              );

              final otp = await showDialog(
                  context: (context),
                  barrierDismissible: false,
                  builder: (context) {
                    String? _opt;
                    return AlertDialog(
                      title: const Text('Enter OTP'),
                      content: TextField(
                        onChanged: (v) => _opt = v,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('OTP'),
                        ),
                      ),
                      actions: [
                        SimpleDialogOption(
                            child: const Text('Submit'),
                            onPressed: () {
                              Navigator.pop(context, _opt);
                            })
                      ],
                    );
                  });

              if (otp != null) {
                try {
                  final model = await Khalti.service.confirmPayment(
                    request: PaymentConfirmationRequestModel(
                      confirmationCode: otp,
                      token: initiationModel.token,
                      transactionPin: pinCodeController.text,
                    ),
                  );

                  showDialog(
                      context: (context),
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Payment Successful'),
                          content: Text('Verification Token: ${model.token}'),
                        );
                      });
                } catch (e) {
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Make Payment'),
          ),
        ],
      ),
    ));
  }
}
