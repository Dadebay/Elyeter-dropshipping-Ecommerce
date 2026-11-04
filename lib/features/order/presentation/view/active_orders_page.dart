import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../widgets/paged_orders_list.dart';

/// Orders still on their way: new, confirmed or placed with the supplier.
class ActiveOrdersPage extends StatelessWidget {
  const ActiveOrdersPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppPageAppBar(title: context.l10n.profileActiveOrders),
    body: const PagedOrdersList(activeOnly: true),
  );
}
