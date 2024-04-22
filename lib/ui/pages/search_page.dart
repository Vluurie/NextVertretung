import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/logout_button.dart';
import 'package:next_cloud_plans/ui/pages/hints/snackbar.dart';
import 'package:next_cloud_plans/ui/pages/selection/class_block_selection.dart';
import 'package:next_cloud_plans/ui/pages/selection/class_input_selection.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final UserRepository userRepository = UserRepository();
  bool _isContinuePressed = false;
  bool _isLoading = false;
  List<String> _availableClasses = [];
  String? selectedBlock;

  void toggleLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        toggleLoading(_isLoading);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData.dark();
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Plan'),
        actions: [ConfirmLogoutButton(userRepository: userRepository)],
      ),
      body: Stack(
        children: [
          PopScope(
            canPop: !_isContinuePressed,
            onPopInvoked: (bool didPop) {
              if (!_isContinuePressed && !didPop) {
                setState(() {
                  _isContinuePressed = false;
                });
              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: screenSize.height * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isContinuePressed)
                      ClassInputPage(
                          toggleLoading: toggleLoading,
                          onGoBack: goBack,
                          availableClasses: _availableClasses)
                    else
                      ClassBlockSelection(
                        onContinue: _handleContinue,
                        toggleLoading: toggleLoading,
                        availableClasses: const [],
                      ),
                    SizedBox(height: screenSize.height * 0.02),
                    SizedBox(
                      width: screenSize.width,
                      height: screenSize.height * 0.5,
                      child: Lottie.asset(
                          'assets/animations/block_animation.json'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: theme.primaryColor,
              child:
                  Center(child: Lottie.asset('assets/animations/loading.json')),
            ),
        ],
      ),
    );
  }

  void goBack() {
    setState(() {
      _isContinuePressed = false;
    });
  }

  void _handleContinue(String? selectedBlock, List<String> availableClasses) {
    if (selectedBlock != null) {
      setState(() {
        this.selectedBlock = selectedBlock;
        _availableClasses = availableClasses;
        _isContinuePressed = true;
      });
    } else {
      Snackbars.showHintsSnackbar(
          context, 'Please select a class block before continuing.');
    }
  }
}
