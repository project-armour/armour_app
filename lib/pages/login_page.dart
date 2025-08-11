import 'dart:ui';

import 'package:armour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
  bool loginMode = true;
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  final pwdConfController = TextEditingController();

  bool showPassword = false;

  bool loading = false;

  var errorTexts = ["", "", ""];

  @override
  void dispose() {
    emailController.dispose();
    pwdController.dispose();
    pwdConfController.dispose();
    super.dispose();
  }

  void signIn() async {
    final email = emailController.text;
    final pwd = pwdController.text;

    setState(() {
      loading = true;
      errorTexts = ["", "", ""];
    });

    if (email.isEmpty) {
      setState(() {
        errorTexts[0] = "Email cannot be empty";
        loading = false;
      });
    }
    if (pwd.isEmpty) {
      setState(() {
        errorTexts[1] = "Password cannot be empty";
        loading = false;
      });
      return;
    }

    if (errorTexts.every((str) => str.isEmpty)) {
      try {
        await supabase.auth.signInWithPassword(email: email, password: pwd);
      } on AuthException catch (e) {
        if (e.code != null) {
          if (e.code!.contains("email")) {
            setState(() {
              errorTexts[0] = e.message;
              loading = false;
            });
          } else if (e.code!.contains("password")) {
            setState(() {
              errorTexts[1] = e.message;
              loading = false;
            });
          } else {
            setState(() {
              errorTexts[0] = errorTexts[1] = e.message;
              loading = false;
            });
          }
        } else {
          setState(() {
            errorTexts[0] = errorTexts[1] = e.message;
            loading = false;
          });
        }
      }
    }
  }

  void signUp() async {
    final email = emailController.text;
    final pwd = pwdController.text;
    final pwdConf = pwdConfController.text;

    setState(() {
      loading = true;
      errorTexts = ["", "", ""];
    });

    if (email.isEmpty) {
      setState(() {
        errorTexts[0] = "Email cannot be empty";
        loading = false;
      });
    }
    if (pwd.isEmpty) {
      setState(() {
        errorTexts[1] = "Password cannot be empty";
        loading = false;
      });
    }
    if (pwdConf.isEmpty || pwd != pwdConf) {
      setState(() {
        errorTexts[2] = "Confirmation and Password do not match";
        loading = false;
      });
      return;
    }

    if (errorTexts.every((str) => str.isEmpty)) {
      try {
        AuthResponse resp = await supabase.auth.signUp(
          email: email,
          password: pwd,
        );
        if (resp.user != null) {
          supabase.auth.signInWithPassword(email: email, password: pwd);
        }
      } on AuthWeakPasswordException catch (e) {
        setState(() {
          errorTexts[1] = errorTexts[2] = e.message;
          loading = false;
        });
      } on AuthException catch (e) {
        if (e.code != null) {
          if (e.code!.contains("email")) {
            setState(() {
              errorTexts[0] = e.message;
              loading = false;
            });
          } else if (e.code!.contains("password")) {
            setState(() {
              errorTexts[1] = e.message;
              loading = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tiled background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/login-bg.png",
              scale: 1.75,
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              opacity: AlwaysStoppedAnimation(0.3),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 240),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                SvgPicture.asset(
                  "assets/images/gradient-wordmark.svg",
                  height: 48,
                ),
                Text(
                  "The personal safety app for the modern age.",
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).bodySmall,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: ColorScheme.of(
                    context,
                  ).surfaceContainerLow.withValues(alpha: 0.4),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 12,
                    children: [
                      Text(
                        loginMode ? "Login" : "Sign Up",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox.shrink(),
                      TextField(
                        controller: emailController,
                        onChanged: (value) {
                          if (emailRegex.hasMatch(value) || value.isEmpty) {
                            setState(() {
                              errorTexts[0] = "";
                            });
                          } else {
                            setState(() {
                              errorTexts[0] = "Invalid email";
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Email",
                          errorText: errorTexts[0] != '' ? errorTexts[0] : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      TextField(
                        controller: pwdController,
                        obscureText: !showPassword,
                        obscuringCharacter: '⬤',
                        onChanged: (value) {
                          if (errorTexts[1] != '') {
                            setState(() {
                              errorTexts[1] = "";
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          errorText: errorTexts[1] != '' ? errorTexts[1] : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: Icon(
                              showPassword
                                  ? LucideIcons.eye
                                  : LucideIcons.eyeOff,
                            ),
                          ),
                        ),
                      ),
                      if (!loginMode)
                        TextField(
                          controller: pwdConfController,
                          obscureText: !showPassword,
                          obscuringCharacter: '⬤',
                          onChanged: (value) {
                            if (errorTexts[2] != '') {
                              setState(() {
                                errorTexts[2] = "";
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            errorText:
                                errorTexts[2] != '' ? errorTexts[2] : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: Icon(
                                showPassword
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                              ),
                            ),
                          ),
                        ),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          if (loginMode) {
                            signIn();
                          } else {
                            signUp();
                          }
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        label: Text("Continue"),
                        icon:
                            loading
                                ? CircularProgressIndicator(
                                  color: ColorScheme.of(context).surface,
                                  strokeWidth: 1.75,
                                  constraints: BoxConstraints.tight(
                                    Size.fromRadius(8),
                                  ),
                                )
                                : Icon(LucideIcons.arrowRight300, size: 24),
                        iconAlignment: IconAlignment.end,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            loginMode = !loginMode;
                          });
                        },
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        child:
                            loginMode
                                ? Text("Dont have an account?")
                                : Text("Already have an account?"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
