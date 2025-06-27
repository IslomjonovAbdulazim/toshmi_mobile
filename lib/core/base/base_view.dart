import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import '../../app/utils/widgets/common/empty_state_widget.dart';
import '../../app/utils/widgets/common/error_widget.dart';
import '../../app/utils/widgets/common/loading_widget.dart';
import 'base_controller.dart';

abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({Key? key}) : super(key: key);

  // Abstract methods for child views to implement
  Widget buildBody(BuildContext context);

  // Optional overrides
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;
  Widget? buildFloatingActionButton(BuildContext context) => null;
  Widget? buildBottomNavigationBar(BuildContext context) => null;
  Widget? buildDrawer(BuildContext context) => null;
  Widget? buildBottomSheet(BuildContext context) => null;

  // Background color
  Color? get backgroundColor => null;

  // Safe area configuration
  bool get useSafeArea => true;

  // Resizes to avoid bottom inset (keyboard)
  bool get resizeToAvoidBottomInset => true;

  // Enable pull to refresh
  bool get enableRefresh => false;

  @override
  Widget build(BuildContext context) {
    Widget body = buildBody(context);

    // Wrap with pull to refresh if enabled
    if (enableRefresh) {
      body = RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: body,
      );
    }

    // Wrap with safe area if enabled
    if (useSafeArea) {
      body = SafeArea(child: body);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildAppBar(context),
      body: Obx(() => _buildBodyWithStates(context, body)),
      floatingActionButton: buildFloatingActionButton(context),
      bottomNavigationBar: buildBottomNavigationBar(context),
      drawer: buildDrawer(context),
      bottomSheet: buildBottomSheet(context),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildBodyWithStates(BuildContext context, Widget body) {
    // Show loading overlay
    if (controller.isLoading.value) {
      return const LoadingWidget();
    }

    // Show error state
    if (controller.hasError.value) {
      return CustomErrorWidget(
        message: controller.errorMessage.value,
        onRetry: () {
          controller.clearError();
          controller.refreshData();
        },
      );
    }

    // Show offline state
    if (!controller.isOnline.value) {
      return const CustomErrorWidget(
        message: 'Internet aloqasi yo\'q',
        icon: Icons.wifi_off,
      );
    }

    return body;
  }
}

// Base view with loading states for lists
abstract class BaseListView<T extends BaseController> extends BaseView<T> {
  const BaseListView({Key? key}) : super(key: key);

  // Abstract methods for list views
  Widget buildListItem(BuildContext context, int index);
  int getItemCount();

  // Optional configurations
  EdgeInsets get padding => const EdgeInsets.all(16);
  double get itemSpacing => 8;
  bool get shrinkWrap => false;
  ScrollPhysics? get physics => null;

  // Empty state configuration
  String get emptyTitle => 'Ma\'lumot topilmadi';
  String get emptyMessage => 'Ko\'rsatish uchun hech qanday element yo\'q';
  IconData get emptyIcon => Icons.inbox_outlined;

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() {
      final itemCount = getItemCount();

      if (itemCount == 0 && !controller.isLoading.value) {
        return EmptyStateWidget(
          title: emptyTitle,
          message: emptyMessage,
          icon: emptyIcon,
          onRetry: controller.refreshData,
        );
      }

      return ListView.separated(
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount,
        separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
        itemBuilder: buildListItem,
      );
    });
  }

  @override
  bool get enableRefresh => true;
}

// Base view with tab functionality
abstract class BaseTabView<T extends BaseController> extends BaseView<T> {
  const BaseTabView({Key? key}) : super(key: key);

  // Abstract methods for tab views
  List<Tab> buildTabs();
  List<Widget> buildTabViews();

  // Tab controller
  TabController? get tabController => null;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(getAppBarTitle()),
      bottom: TabBar(
        controller: tabController,
        tabs: buildTabs(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: buildTabViews(),
    );
  }

  String getAppBarTitle();
}

// Base form view
abstract class BaseFormView<T extends BaseController> extends BaseView<T> {
  const BaseFormView({Key? key}) : super(key: key);

  // Form key
  GlobalKey<FormState> get formKey;

  // Abstract methods for form views
  List<Widget> buildFormFields(BuildContext context);
  void onSubmit();

  // Form configuration
  EdgeInsets get formPadding => const EdgeInsets.all(16);
  double get fieldSpacing => 16;
  CrossAxisAlignment get crossAxisAlignment => CrossAxisAlignment.stretch;

  @override
  Widget buildBody(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: formPadding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            ...buildFormFields(context)
                .expand((widget) => [widget, SizedBox(height: fieldSpacing)])
                .toList()
              ..removeLast(), // Remove last spacing
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : _handleSubmit,
              child: controller.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(getSubmitButtonText()),
            )),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (formKey.currentState?.validate() == true) {
      onSubmit();
    }
  }

  String getSubmitButtonText() => 'Yuborish';
}