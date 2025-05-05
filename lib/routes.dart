import 'package:flareline/deferred_widget.dart';
import 'package:flareline/pages/modal/modal_page.dart' deferred as modal;
import 'package:flareline/pages/table/contacts_page.dart' deferred as contacts;
import 'package:flareline/pages/toast/toast_page.dart' deferred as toast;
import 'package:flareline/pages/tools/tools_page.dart' deferred as tools;
import 'package:flutter/material.dart';
import 'package:flareline/pages/alerts/alert_page.dart' deferred as alert;
import 'package:flareline/pages/button/button_page.dart' deferred as button;
import 'package:flareline/pages/form/form_elements_page.dart'
    deferred as formElements;
import 'package:flareline/pages/form/form_layout_page.dart'
    deferred as formLayout;
import 'package:flareline/pages/auth/sign_in/sign_in_page.dart'
    deferred as signIn;
import 'package:flareline/pages/auth/sign_up/sign_up_page.dart'
    deferred as signUp;

import 'package:flareline/pages/chart/chart_page.dart' deferred as chart;
import 'package:flareline/pages/dashboard/ecommerce_page.dart';
import 'package:flareline/pages/inbox/index.dart' deferred as inbox;
import 'package:flareline/pages/invoice/invoice_page.dart' deferred as invoice;
import 'package:flareline/pages/resetpwd/reset_pwd_page.dart'
    deferred as resetPwd;
import 'package:flareline/pages/setting/settings_page.dart'
    deferred as settings;
import 'package:flareline/pages/table/tables_page.dart' deferred as tables;
import 'package:get_storage/get_storage.dart';

typedef PathWidgetBuilder = Widget Function(BuildContext, String?);

final List<Map<String, Object>> MAIN_PAGES = [
  {'routerPath': '/', 'widget': const EcommercePage()},
  {
    'routerPath': '/formElements',
    'widget': DeferredWidget(
        formElements.loadLibrary, () => formElements.FormElementsPage()),
  },
  {
    'routerPath': '/formLayout',
    'widget': DeferredWidget(
        formLayout.loadLibrary, () => formLayout.FormLayoutPage())
  },
  {
    'routerPath': '/signIn',
    'widget': DeferredWidget(signIn.loadLibrary, () => signIn.SignInWidget())
  },
  {
    'routerPath': '/signUp',
    'widget': DeferredWidget(signUp.loadLibrary, () => signUp.SignUpWidget())
  },
  {
    'routerPath': '/invoice',
    'widget': DeferredWidget(invoice.loadLibrary, () => invoice.InvoicePage())
  },
  {
    'routerPath': '/inbox',
    'widget': DeferredWidget(inbox.loadLibrary, () => inbox.InboxWidget())
  },
  {
    'routerPath': '/tables',
    'widget': DeferredWidget(tables.loadLibrary, () => tables.TablesPage())
  },
  {
    'routerPath': '/basicChart',
    'widget': DeferredWidget(chart.loadLibrary, () => chart.ChartPage())
  },
  {
    'routerPath': '/buttons',
    'widget': DeferredWidget(button.loadLibrary, () => button.ButtonPage())
  },
  {
    'routerPath': '/alerts',
    'widget': DeferredWidget(alert.loadLibrary, () => alert.AlertPage())
  },
  {
    'routerPath': '/contacts',
    'widget':
        DeferredWidget(contacts.loadLibrary, () => contacts.ContactsPage())
  },
  {
    'routerPath': '/tools',
    'widget': DeferredWidget(tools.loadLibrary, () => tools.ToolsPage())
  },
  {
    'routerPath': '/toast',
    'widget': DeferredWidget(toast.loadLibrary, () => toast.ToastPage())
  },
  {
    'routerPath': '/modal',
    'widget': DeferredWidget(modal.loadLibrary, () => modal.ModalPage())
  },
];

class RouteConfiguration {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'Rex');

  static BuildContext? get navigatorContext =>
      navigatorKey.currentState?.context;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    String path = settings.name!;
    final storage = GetStorage();
    final token = storage.read('token');
    final userRole = storage.read('userRole');

    // Protect the dashboard route ('/')
    if (path == '/') {
      if (token == null || userRole != 'ADMIN') {
        return NoAnimationMaterialPageRoute<void>(
          builder: (context) =>
              DeferredWidget(signIn.loadLibrary, () => signIn.SignInWidget()),
          settings: const RouteSettings(name: '/signIn'),
        );
      }
    }

    // Find the matching route
    final map = MAIN_PAGES.firstWhere(
      (element) => element['routerPath'] == path,
      orElse: () => <String, Object>{}, // Return an empty map instead of null
    );

    // Check if the route was found (map is not empty)
    if (map.isEmpty) {
      return NoAnimationMaterialPageRoute<void>(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
        settings: settings,
      );
    }

    Widget targetPage = map['widget'] as Widget;

    PathWidgetBuilder builder = (context, match) => targetPage;

    return NoAnimationMaterialPageRoute<void>(
      builder: (context) => builder(context, null),
      settings: settings,
    );
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
