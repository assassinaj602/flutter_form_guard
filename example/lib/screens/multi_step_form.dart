import 'package:flutter/material.dart';
import 'package:flutter_form_guard/flutter_form_guard.dart';

class MultiStepFormScreen extends StatefulWidget {
  const MultiStepFormScreen({super.key});

  @override
  State<MultiStepFormScreen> createState() => _MultiStepFormScreenState();
}

class _MultiStepFormScreenState extends State<MultiStepFormScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Step Wizard')),
      body: SmartFormGuard(
        formId: 'wizard_form',
        child: Builder(
          builder: (context) {
            final controller = SmartFormGuard.of(context);

            return Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                // Validate only current step fields?
                // SmartFormGuard validation validates EVERYTHING by default.
                // For a real wizard, you might want partial validation or just check specific fields manually if needed.
                // But let's assume valid form is needed to proceed for simplicity, or we just basic check.

                // Better approach: Check if current step fields have errors?
                // For this demo, we'll just move next. Real validation per step would require checking
                // specific field keys.

                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  if (controller.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Wizard Completed!")),
                    );
                    controller.reset();
                    setState(() => _currentStep = 0);
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              steps: [
                Step(
                  title: const Text('Personal Info'),
                  content: Column(
                    children: [
                      GuardField.text(
                        name: 'first_name',
                        label: 'First Name',
                        validators: [Validators.required()],
                      ),
                      const SizedBox(height: 8),
                      GuardField.text(
                        name: 'last_name',
                        label: 'Last Name',
                        validators: [Validators.required()],
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Contact Details'),
                  content: Column(
                    children: [
                      GuardField.email(name: 'wizard_email', label: 'Email'),
                      const SizedBox(height: 8),
                      GuardField.text(
                        name: 'wizard_phone',
                        label: 'Phone',
                        validators: [Validators.phone()],
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Review'),
                  content: Column(
                    children: [
                      const Text("Please review your details."),
                      // We can display summary here by accessing controller values
                      ListenableBuilder(
                        listenable: controller,
                        builder: (ctx, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name: ${controller.getField('first_name')?.value} ${controller.getField('last_name')?.value}",
                              ),
                              Text(
                                "Email: ${controller.getField('wizard_email')?.value}",
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
