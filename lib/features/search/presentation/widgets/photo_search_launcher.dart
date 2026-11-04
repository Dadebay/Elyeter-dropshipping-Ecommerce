import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../view/visual_search_page.dart';
import 'visual_search_source_sheet.dart';

/// Search by photo: choose camera or gallery, then hand the picture to the
/// results page. Needs a signed-in customer, as the API does.
Future<void> startPhotoSearch(BuildContext context) async {
  if (!context.read<AuthCubit>().state.isAuthenticated) {
    await promptSignIn(context);
    return;
  }
  if (!context.mounted) return;
  final source = await VisualSearchSourceSheet.show(context);
  if (source == null || !context.mounted) return;
  final XFile? photo = switch (source) {
    VisualSearchSource.camera => await VisualSearchPage.open(context),
    VisualSearchSource.gallery => await ImagePicker().pickImage(
      source: ImageSource.gallery,
    ),
  };
  if (photo == null || !context.mounted) return;
  unawaited(context.pushNamed(AppRoutes.imageSearch.name, extra: photo.path));
}
