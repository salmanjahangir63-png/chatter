import 'package:bot_toast/bot_toast.dart';
import 'package:chatter/ui/widgets/custom_top_snackbar.dart';
import 'package:chatter/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';


class DisplayUtils {
  static void showSnackBar(BuildContext context,
      {String? title, required String message, Color? backgroundColor, bool isError = true,}) {
    CustomTopSnackBar.show(context, title: title, message: message,isError: isError);
  }

  static void showLoader() {
    BotToast.showCustomLoading(toastBuilder: (_) => const LoadingIndicator());
  }

  static void showToast({required String text}) {
    BotToast.showText(text: text);
  }

  static void removeLoader() {
    BotToast.closeAllLoading();
  }
}
