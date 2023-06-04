// part of auth_card_builder;

// class _PhoneNumberCard extends StatefulWidget {
//   const _PhoneNumberCard({
//     super.key,
//     required this.phoneValidator,
//     required this.onBack,
//     required this.userType,
//     this.loginTheme,
//     required this.navigateBack,
//     required this.onSubmitCompleted,
//     required this.loadingController,
//   });

//   final FormFieldValidator<String>? phoneValidator;
//   final VoidCallback onBack;
//   final LoginUserType userType;
//   final LoginTheme? loginTheme;
//   final bool navigateBack;
//   final AnimationController loadingController;

//   final VoidCallback onSubmitCompleted;

//   @override
//   _PhoneNumberCardState createState() => _PhoneNumberCardState();
// }

// class _PhoneNumberCardState extends State<_PhoneNumberCard>
//     with SingleTickerProviderStateMixin {
//   final GlobalKey<FormState> _formPhoneKey = GlobalKey();

//   bool _isSubmitting = false;

//   TextEditingController? _phoneController;

//   late AnimationController _submitController;

//   @override
//   void initState() {
//     super.initState();

//     final auth = Provider.of<Auth>(context, listen: false);
//     _phoneController = TextEditingController(text: auth.phone);

//     _submitController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//   }

//   @override
//   void dispose() {
//     _submitController.dispose();
//     super.dispose();
//   }

//   Future<bool> _submit() async {
//     FocusScope.of(context).unfocus();

//     final messages = Provider.of<LoginMessages>(context, listen: false);

//     if (!_formPhoneKey.currentState!.validate()) {
//       return false;
//     }

//     _formPhoneKey.currentState!.save();
//     await _submitController.forward();
//     setState(() => _isSubmitting = true);
//     final auth = Provider.of<Auth>(context, listen: false);
//     auth.phone = _phoneController!.text;
//     String? error;

//     // auth.authType = AuthType.provider;

//     error = await auth.onPhoneLogin?.call(
//       PhoneLoginData(
//         phone: auth.phone,
//       ),
//     );

//     // workaround to run after _cardSizeAnimation in parent finished
//     // need a cleaner way but currently it works so..
//     Future.delayed(const Duration(milliseconds: 270), () {
//       if (mounted) {
//         // setState(() => _showShadow = false);
//       }
//     });

//     await _submitController.reverse();

//     if (!DartHelper.isNullOrEmpty(error)) {
//       showErrorToast(context, messages.flushbarTitleError, error!);
//       Future.delayed(const Duration(milliseconds: 271), () {
//         if (mounted) {
//           // setState(() => _showShadow = true);
//         }
//       });
//       setState(() => _isSubmitting = false);
//       return false;
//     }

//     TextInput.finishAutofillContext();
//     widget.onSubmitCompleted.call();

//     return true;
//   }

//   Widget _buildRecoverNameField(
//     double width,
//     LoginMessages messages,
//     Auth auth,
//   ) {
//     return AnimatedTextFormField(
//       controller: _phoneController,
//       loadingController: widget.loadingController,
//       userType: widget.userType,
//       width: width,
//       labelText: messages.userHint,
//       prefixIcon: const Icon(FontAwesomeIcons.solidCircleUser),
//       keyboardType: TextFieldUtils.getKeyboardType(widget.userType),
//       autofillHints: [TextFieldUtils.getAutofillHints(widget.userType)],
//       textInputAction: TextInputAction.done,
//       onFieldSubmitted: (value) => _submit(),
//       validator: widget.phoneValidator,
//       // onSaved: (value) => auth.email = value!,
//     );
//   }

//   Widget _buildLoginButton(ThemeData theme, LoginMessages messages) {
//     return AnimatedButton(
//       controller: _submitController,
//       text: "Login",
//       onPressed: !_isSubmitting ? _submit : null,
//     );
//   }

//   Widget _buildBackButton(
//     ThemeData theme,
//     LoginMessages messages,
//     LoginTheme? loginTheme,
//   ) {
//     final calculatedTextColor =
//         (theme.cardTheme.color!.computeLuminance() < 0.5)
//             ? Colors.white
//             : theme.primaryColor;
//     return MaterialButton(
//       onPressed: !_isSubmitting
//           ? () {
//               _formPhoneKey.currentState!.save();
//               widget.onBack();
//             }
//           : null,
//       padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
//       child: Text(messages.goBackButton),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final auth = Provider.of<Auth>(context, listen: false);
//     final messages = Provider.of<LoginMessages>(context, listen: false);
//     final deviceSize = MediaQuery.of(context).size;
//     final cardWidth = min(deviceSize.width * 0.75, 360.0);
//     const cardPadding = 16.0;
//     final textFieldWidth = cardWidth - cardPadding * 2;

//     return FittedBox(
//       child: WillPopScope(
//         onWillPop: !_isSubmitting
//             ? () async {
//                 _formPhoneKey.currentState!.save();
//                 widget.onBack();
//                 return false;
//               }
//             : () async {
//                 return false;
//               },
//         child: Card(
//           child: Container(
//             padding: const EdgeInsets.only(
//               left: cardPadding,
//               top: cardPadding + 10.0,
//               right: cardPadding,
//               bottom: cardPadding,
//             ),
//             width: cardWidth,
//             alignment: Alignment.center,
//             child: Form(
//               key: _formPhoneKey,
//               child: Column(
//                 children: [
//                   Text(
//                     messages.signInWithPhoneButton,
//                     key: kRecoverPasswordIntroKey,
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                   const SizedBox(height: 20),
//                   _buildRecoverNameField(textFieldWidth, messages, auth),
//                   const SizedBox(height: 20),
//                   // Text(
//                   //   auth.onConfirmRecover != null
//                   //       ? messages.recoverCodePasswordDescription
//                   //       : messages.recoverPasswordDescription,
//                   //   key: kRecoverPasswordDescriptionKey,
//                   //   textAlign: TextAlign.center,
//                   //   style: theme.textTheme.bodyMedium,
//                   // ),
//                   const SizedBox(height: 26),
//                   _buildLoginButton(theme, messages),
//                   _buildBackButton(theme, messages, widget.loginTheme),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
