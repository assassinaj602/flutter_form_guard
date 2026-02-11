import 'package:flutter/material.dart';
import 'package:flutter_form_guard/flutter_form_guard.dart';

class BasicFormScreen extends StatelessWidget {
  const BasicFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Form & Validators')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SmartFormGuard(
            formId: 'basic_signup_v2',
            child: Column(
              children: [
                GuardField.text(
                  name: 'username',
                  label: 'Username',
                  validators: [Validators.required(), Validators.minLength(3)],
                ),
                const SizedBox(height: 16),
                GuardField.email(name: 'email', label: 'Email Address'),
                const SizedBox(height: 16),
                GuardField.text(
                  // Using text for phone demonstration
                  name: 'phone',
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validators: [Validators.phone()],
                ),
                const SizedBox(height: 16),
                GuardField.text(
                  name: 'age',
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  validators: [Validators.numeric(), Validators.range(18, 100)],
                ),
                const SizedBox(height: 16),
                // Password
                Builder(
                  builder: (context) {
                    return GuardField.password(
                      name: 'password',
                      label: 'Password',
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password
                Builder(
                  builder: (context) {
                    return GuardField(
                      name: 'confirm_password',
                      label: 'Confirm Password',
                      obscureText: true,
                      validator: Validators.match(() {
                        // Access the parent form controller to get the password value
                        final controller = SmartFormGuard.of(context);
                        return controller
                                .getField('password')
                                ?.value
                                ?.toString() ??
                            '';
                      }, message: "Passwords do not match"),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final controller = SmartFormGuard.of(context);
                    if (controller.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form Valid!')),
                      );
                      controller.reset();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
