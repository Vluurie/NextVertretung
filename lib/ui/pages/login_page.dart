import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/bloc/api/network_service.dart';
import 'package:next_cloud_plans/bloc/login/login_bloc.dart';
import 'package:next_cloud_plans/database/database.dart';
import 'package:next_cloud_plans/model/substitution_plan.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/custom_button.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/password_field.dart';
import 'package:next_cloud_plans/ui/pages/hints/snackbar.dart';
import 'package:next_cloud_plans/ui/pages/search_page.dart';
import 'package:next_cloud_plans/ui/pages/substitution_plan_page.dart';
import 'package:next_cloud_plans/utils/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserRepository userRepository = UserRepository();
  bool _isLoading = false;
  String noConnection =
      "No internet connection. Please check your network settings.";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkCredentialsAndNavigate());
  }

  void _checkCredentialsAndNavigate() async {
    final StorageItems storageItems = StorageItems();
    final UserRepository userRepository = UserRepository();
    final ApiService apiService =
        ApiService(storage: const FlutterSecureStorage());

    setState(() {
      _isLoading = true;
    });

    try {
      bool isConnected = await NetworkService.checkInternetConnection();
      if (!isConnected) {
        if (mounted) {
          Snackbars.showErrorSnackbar(context, noConnection);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final hasCredentials = await userRepository.hasCredentials();
      final classBlock = await storageItems.getClassBlockFromStorage();
      final className = await storageItems.getClassNameFromStorage();

      if (!hasCredentials || classBlock == null || className == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch data from the API
      Map<String, List<SubstitutionPlanItem>> singlePlanData =
          await apiService.fetchPlansForAllDates(className, classBlock);
      Map<String, List<SubstitutionPlanItem>> allPlanData =
          await apiService.fetchForAllPlans();

      if (singlePlanData.isNotEmpty || allPlanData.isNotEmpty) {
        for (var entry in singlePlanData.entries) {
          await DatabaseHelper.instance
              .insertOrUpdatePlan(entry.key, entry.value);
        }
        for (var entry in allPlanData.entries) {
          await DatabaseHelper.instance
              .insertOrUpdatePlan(entry.key, entry.value);
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SubstitutionPlan(
                apiService: apiService,
                currentClass: className,
                singlePlanData: singlePlanData,
                allPlanData: allPlanData,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          Snackbars.showErrorSnackbar(context, 'No data available.');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Snackbars.showErrorSnackbar(
            context, 'Failed to load data: ${e.toString()}');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _isLoading ? const Text('') : const Text('Login')),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          } else if (state is LoginFailure) {
            setState(() {
              _isLoading = false;
            });
            Snackbars.showErrorSnackbar(context,
                "'Invalid Login or App password, please check your credentials'");
          }
        },
        child: _isLoading
            ? Center(
                child: Lottie.asset('assets/animations/loading.json'),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        PasswordField(controller: _passwordController),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: CustomElevatedButton(
                            label: 'Login',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool isConnected = await NetworkService
                                    .checkInternetConnection();
                                if (!isConnected) {
                                  if (context.mounted) {
                                    Snackbars.showErrorSnackbar(
                                        context, noConnection);
                                  }
                                  return;
                                }
                                setState(() {
                                  _isLoading = true;
                                });
                                if (context.mounted) {
                                  context.read<LoginBloc>().add(
                                        LoginCredentialsAdded(
                                          username: _usernameController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1.0,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Lottie.asset(
                              'assets/animations/login_page_init.json'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
