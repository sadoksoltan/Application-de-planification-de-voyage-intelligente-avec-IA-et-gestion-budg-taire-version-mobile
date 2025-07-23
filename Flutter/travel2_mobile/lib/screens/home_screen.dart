import 'package:flutter/material.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/banner_widget.dart';
// import '../widgets/about_us_widget.dart';
// import '../widgets/top_destinations_widget.dart';
// import '../widgets/about_us2_widget.dart';
// import '../widgets/best_tour_package_widget.dart';
// import '../widgets/last_minute_deals_widget.dart';
// import '../widgets/discount_action_widget.dart';
// import '../widgets/offer_packages_widget.dart';
// import '../widgets/our_team_widget.dart';
// import '../widgets/testimonial_widget.dart';
// import '../widgets/our_partners_widget.dart';
// import '../widgets/recent_articles_widget.dart';
// import '../widgets/footer_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppbarWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            BannerWidget(),
            // AboutUsWidget(),
            // TopDestinationsWidget(),
            // AboutUs2Widget(),
            // BestTourPackageWidget(),
            // LastMinuteDealsWidget(),
            // DiscountActionWidget(),
            // OfferPackagesWidget(),
            // OurTeamWidget(),
            // TestimonialWidget(),
            // OurPartnersWidget(),
            // RecentArticlesWidget(),
            // FooterWidget(),
          ],
        ),
      ),
    );
  }
}
