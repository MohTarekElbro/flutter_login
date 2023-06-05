part of auth_card_builder;

class _RecoverCard extends StatefulWidget {
  _RecoverCard({
    required this.userValidator,
    required this.onBack,
    required this.userType,
    this.loginTheme,
    required this.navigateBack,
    required this.onSubmitCompleted,
    required this.loadingController,
  });

  final FormFieldValidator<String>? userValidator;
  final VoidCallback onBack;
  LoginUserType userType;
  final LoginTheme? loginTheme;
  final bool navigateBack;
  final AnimationController loadingController;

  final VoidCallback onSubmitCompleted;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();
  late LoginUserType userType;

  bool _isSubmitting = false;

  late TextEditingController _nameController;

  late AnimationController _submitController;

  @override
  void initState() {
    super.initState();
    userType = widget.userType == LoginUserType.email
        ? LoginUserType.email
        : LoginUserType.intlPhone;
    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = TextEditingController(text: auth.email);

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _submitController.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onRecoverPassword!(auth.email);

    if (error != null) {
      showErrorToast(context, messages.flushbarTitleError, error);
      setState(() => _isSubmitting = false);
      await _submitController.reverse();
      return false;
    } else {
      showSuccessToast(
        context,
        messages.flushbarTitleSuccess,
        messages.recoverPasswordSuccess,
      );
      setState(() => _isSubmitting = false);
      widget.onSubmitCompleted();
      return true;
    }
  }

  Widget _buildRecoverNameField(
    double width,
    LoginMessages messages,
    Auth auth,
  ) {
    return AnimatedTextFormField(
      controller: _nameController,
      loadingController: widget.loadingController,
      userType: userType,
      width: width,
      labelText: messages.userHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleUser),
      keyboardType: TextFieldUtils.getKeyboardType(userType),
      autofillHints: [TextFieldUtils.getAutofillHints(userType)],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.userValidator,
      onSaved: (value) => auth.email = value!,
    );
  }

  Widget _buildRecoverButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.recoverPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(
    ThemeData theme,
    LoginMessages messages,
    LoginTheme? loginTheme,
  ) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed: !_isSubmitting
          ? () {
              _formRecoverKey.currentState!.save();
              widget.onBack();
            }
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
      child: Text(messages.goBackButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final loginTheme = Provider.of<LoginTheme>(context, listen: false);

    return FittedBox(
      child: WillPopScope(
        onWillPop: !_isSubmitting
            ? () async {
                _formRecoverKey.currentState!.save();
                widget.onBack();
                return false;
              }
            : () async {
                return false;
              },
        child: Card(
          child: Container(
            padding: const EdgeInsets.only(
              left: cardPadding,
              top: cardPadding + 10.0,
              right: cardPadding,
              bottom: cardPadding,
            ),
            width: cardWidth,
            alignment: Alignment.center,
            child: Form(
              key: _formRecoverKey,
              child: Column(
                children: [
                  Text(
                    messages.recoverPasswordIntro,
                    key: kRecoverPasswordIntroKey,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildRecoverNameField(textFieldWidth, messages, auth),
                  const SizedBox(height: 10),
                  _buildPhoneNumber(loginTheme, messages, auth),
                  Text(
                    auth.onConfirmRecover != null
                        ? messages.recoverCodePasswordDescription
                        : messages.recoverPasswordDescription,
                    key: kRecoverPasswordDescriptionKey,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 26),
                  _buildRecoverButton(theme, messages),
                  _buildBackButton(theme, messages, widget.loginTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumber(
      LoginTheme theme, LoginMessages messages, Auth auth) {
    return FadeIn(
      controller: widget.loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      child: TextButton(
        onPressed: () {
          // save state to populate email field on recovery card
          // widget.onSwitchPhoneNumber();
          if (userType == LoginUserType.email) {
            if (!auth.isLogin) {
              // _switchAuthController.reverse().then((value) {
              setState(() {
                userType = LoginUserType.intlPhone;
              });
              // });
            } else {
              setState(() {
                userType = LoginUserType.intlPhone;
              });
            }
          } else {
            setState(() {
              userType = LoginUserType.email;
            });
          }
        },
        child: Text(
          userType == LoginUserType.email
              ? messages.signInWithPhoneButton
              : messages.defaultsignInWithEmail,
          style: TextStyle(
              color: theme.switchAuthTextColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
