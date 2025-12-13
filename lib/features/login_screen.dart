import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_hub/widgets/alert/alert.dart';
import 'package:learn_hub/widgets/buttons/bar_button.dart';
import 'package:learn_hub/widgets/text_fields/custom_text_field.dart';

import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import '../repositories/login_repository.dart';
import '../services/api_service.dart';
import 'bottom_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String route = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return BlocProvider(
      create: (_) => LoginBloc(LoginRepository(api)),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => BottomNavigationScreen(),
                    ),
                  );
                }

                if (state.error != null) {
                  showAlert(context, message: state.error!);
                }
              },
              builder: (context, state) {
                final bloc = context.read<LoginBloc>();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Column(
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome Developer',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    CustomTextField(
                      title: 'User Name',
                      onChanged: (val) => bloc.add(PhoneNumberChanged(val)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 50),
                      child: CustomTextField(
                        title: 'Password',
                        obscureText: true,
                        onChanged: (val) => bloc.add(PasswordChanged(val)),
                      ),
                    ),

                    state.isLoading
                        ? const CircularProgressIndicator()
                        : BarButton(
                            title: 'Sign In',
                            onTap: () => bloc.add(LoginSubmitted()),
                          ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
