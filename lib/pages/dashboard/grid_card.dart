import 'package:flutter/material.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import '/services/api_service.dart'; // Ensure this path is correct

class GridCard extends StatefulWidget {
  const GridCard({super.key});

  @override
  _GridCardState createState() => _GridCardState();
}

class _GridCardState extends State<GridCard> {
  late ApiService apiService;
  late Future<int> totalUsers;
  late Future<int> totalProducts;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: 'http://localhost:2000/api');
    totalUsers = apiService.getTotalUsers();
    totalProducts = apiService.getTotalProducts();
  }

  @override
  Widget build(BuildContext loudspeakercontext) {
    return ScreenTypeLayout.builder(
      desktop: (context) => contentDesktopWidget(context),
      mobile: (context) => contentMobileWidget(context),
      tablet: (context) => contentMobileWidget(context),
    );
  }

  Widget contentDesktopWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: totalProducts,
            builder: (context, snapshot) {
              String productCount = snapshot.hasData ? '${snapshot.data}' : '0';
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading products'));
              }
              return _itemCardWidget(
                context,
                Icons.group,
                productCount,
                AppLocalizations.of(context)!.totalProduct,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FutureBuilder<int>(
            future: totalUsers,
            builder: (context, snapshot) {
              String userCount = snapshot.hasData ? '${snapshot.data}' : '0';
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading users'));
              }
              return _itemCardWidget(
                context,
                Icons.security_rounded,
                userCount,
                AppLocalizations.of(context)!.totalUsers,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget contentMobileWidget(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<int>(
          future: totalProducts,
          builder: (context, snapshot) {
            String productCount = snapshot.hasData ? '${snapshot.data}' : '0';
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading products'));
            }
            return _itemCardWidget(
              context,
              Icons.group,
              productCount,
              AppLocalizations.of(context)!.totalProduct,
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<int>(
          future: totalUsers,
          builder: (context, snapshot) {
            String userCount = snapshot.hasData ? '${snapshot.data}' : '0';
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading users'));
            }
            return _itemCardWidget(
              context,
              Icons.security_rounded,
              userCount,
              AppLocalizations.of(context)!.totalUsers,
            );
          },
        ),
      ],
    );
  }

  Widget _itemCardWidget(
      BuildContext context, IconData icons, String text, String subTitle) {
    return CommonCard(
      height: 166,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Icon(
                  icons,
                  color: GlobalColors.sideBar,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
